"""Build the hold-to-hold road network (data/world/roads.json) from Natural Earth 1:10m data
(public domain, naturalearthdata.com) and data/world/holds.json.

Pipeline
  1. Load NE roads inside the map's bounding box and classify them
     (interstate = US Interstate / Mexican expressway / Canadian major highway; else highway).
  2. Build a vertex graph, welding line ends that sit within SNAP_KM of each other.
  3. Living rivers (Mississippi, Ohio, Missouri, Tennessee, Niagara, Detroit) are barriers:
     a road edge that crosses one survives only within CROSSING_RADIUS_KM of a crossing hold that
     covers that river. Every other bridge is out.
  4. Snap each surface hold to the road graph (a back-road spur if it's off the network).
  5. Contract to a hold graph: for each hold, Dijkstra outward, not passing through other holds.
     Then prune edges that a two-hop path covers within PRUNE_SLACK.
  6. Add authored edges: dry riverbeds, winter ice roads, Up lifts and cables, Down tunnels.
  7. Seeded breaks (overpasses down, pileups) per edge.

Usage: python3 tools/build_roads.py [--ne-dir DIR]   (downloads NE data into data/raw/ if missing)
Requires: pyshp (pip install pyshp)
"""
import argparse, heapq, json, math, random, sys, urllib.request, zipfile
from collections import defaultdict
from pathlib import Path

import shapefile  # pyshp

ROOT = Path(__file__).resolve().parent.parent
HOLDS = ROOT / "data/world/holds.json"
OUT = ROOT / "data/world/roads.json"
RAW = ROOT / "data/raw"
NE_URL = "https://naciscdn.org/naturalearth/10m/{}.zip"
NE_LAYERS = {"roads": "cultural/ne_10m_roads", "rivers": "physical/ne_10m_rivers_lake_centerlines"}

BBOX = (-104.5, 17.8, -75.5, 46.0)  # lon0, lat0, lon1, lat1
SNAP_KM = 1.5
CROSSING_RADIUS_KM = 35.0
HOLD_SNAP_MAX_KM = 60.0
PRUNE_SLACK = 1.08
MAIN_MIN_VERTICES = 500  # snap holds only onto road components at least this big
SEED = 1522  # the year Joao sails; seeds the breaks
LIVING_RIVERS = {"Mississippi", "Ohio", "Missouri", "Tennessee", "Niagara", "St. Clair"}
# NE lacks the Detroit River and has only part of the Niagara; draw them by hand.
EXTRA_RIVERS = {
    "Detroit": [(-82.93, 42.34), (-83.03, 42.31), (-83.10, 42.27), (-83.13, 42.05)],
    "Niagara": [(-78.90, 42.88), (-78.94, 42.96), (-79.02, 43.03), (-79.07, 43.08), (-79.06, 43.16), (-79.05, 43.26)],
}
RIVER_ALIAS = {"St. Clair": "St. Clair"}

# Authored edges. Lengths are computed (great-circle x factor) unless given.
RIVERBEDS = [  # dry riverbeds: highways in their own right (02-world.md)
    ("Rio Grande", ["gullet", "gemela", "falcon", "pesca", "mouth"]),
    ("Rio Grande", ["border", "gemela"]),
    ("Red", ["red", "partridge"]),
    ("Arkansas", ["rock", "gallows"]),
    ("Pecos", ["last_stop", "drift"]),
]
ICE_ROADS = [("highwater", "falls"), ("falls", "burnriver"), ("burnriver", "visage")]  # winter only
# Crossings whose road isn't continuous in NE: the Old River dam, and Helena's US-49 bridge.
DAMS = [("brace_win", "crawdad", "the dam road"), ("helena", "crossroads", "US-49 bridge")]
UP_LINKS = [("dog_head", "harrowgate", "lift"), ("harrowgate", "wisher", "cable"), ("harrowgate", "gondola", "cable")]
DOWN_LINKS = [  # the Deep Lines: walked, no fuel, under the rivers
    ("reserve", "krin_s_nest", "tunnel"), ("krin_s_nest", "junction", "tunnel"),
    ("junction", "pumphouse", "tunnel"),
    ("reserve", "@surface", "entrance"), ("krin_s_nest", "@surface", "entrance"),
    ("pumphouse", "@surface", "entrance"),
    ("junction", "@west", "entrance"), ("junction", "@east", "entrance"),  # both banks: the crossing under the river
]


def km(a, b):
    lon1, lat1, lon2, lat2 = map(math.radians, (a[0], a[1], b[0], b[1]))
    h = math.sin((lat2 - lat1) / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin((lon2 - lon1) / 2) ** 2
    return 6371.0 * 2 * math.asin(math.sqrt(h))


def in_bbox(bb):
    return not (bb[2] < BBOX[0] or bb[0] > BBOX[2] or bb[3] < BBOX[1] or bb[1] > BBOX[3])


def fetch(layer, ne_dir):
    name = layer.split("/")[-1]
    shp = ne_dir / name / f"{name}.shp"
    if shp.exists():
        return shp
    ne_dir.mkdir(parents=True, exist_ok=True)
    z = ne_dir / f"{name}.zip"
    print(f"downloading {name} ...", file=sys.stderr)
    urllib.request.urlretrieve(NE_URL.format(layer), z)
    zipfile.ZipFile(z).extractall(ne_dir / name)
    return shp


def road_class(rec):
    t, lvl, sov = rec["type"], rec["level"], rec["sov_a3"]
    if t == "Ferry Route":
        return None
    if (sov == "USA" and lvl == "Interstate") or (sov == "MEX" and rec["expressway"] == 1) \
            or (sov == "CAN" and t == "Major Highway"):
        return "interstate"
    return "highway"


def route_label(rec):
    n, lvl, sov = (rec["name"] or "").strip(), rec["level"], rec["sov_a3"]
    if not n:
        return ""
    if sov == "USA" and lvl == "Interstate":
        return f"I-{n}"
    if sov == "MEX":
        return f"MEX-{n}"
    if sov == "CAN":
        return f"ON-{n}"
    return f"US-{n}" if lvl == "Federal" else n


def seg_intersect(p1, p2, p3, p4):
    def orient(a, b, c):
        return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
    d1, d2, d3, d4 = orient(p3, p4, p1), orient(p3, p4, p2), orient(p1, p2, p3), orient(p1, p2, p4)
    return (d1 > 0) != (d2 > 0) and (d3 > 0) != (d4 > 0)


class Grid:
    """Spatial hash of points for snapping (cell ~ 0.05 deg)."""
    def __init__(self, cell=0.05):
        self.cell, self.cells = cell, defaultdict(list)

    def key(self, p):
        return (int(p[0] // self.cell), int(p[1] // self.cell))

    def add(self, p, v):
        self.cells[self.key(p)].append((p, v))

    def near(self, p, r_cells=1):
        kx, ky = self.key(p)
        for dx in range(-r_cells, r_cells + 1):
            for dy in range(-r_cells, r_cells + 1):
                yield from self.cells.get((kx + dx, ky + dy), ())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ne-dir", type=Path, default=RAW / "naturalearth")
    args = ap.parse_args()
    holds = json.loads(HOLDS.read_text())["holds"]
    H = {h["id"]: h for h in holds}

    # --- rivers (barriers) -------------------------------------------------------------
    rivers = defaultdict(list)  # name -> list of segments ((lon,lat),(lon,lat))
    rv = shapefile.Reader(str(fetch(NE_LAYERS["rivers"], args.ne_dir)))
    for sr in rv.iterShapeRecords():
        if sr.shape.shapeType == shapefile.NULL:
            continue
        name = sr.record.as_dict().get("name")
        if name not in LIVING_RIVERS or not in_bbox(sr.shape.bbox):
            continue
        pts, parts = sr.shape.points, list(sr.shape.parts) + [len(sr.shape.points)]
        for i in range(len(parts) - 1):
            seg = pts[parts[i]:parts[i + 1]]
            rivers[RIVER_ALIAS.get(name, name)] += list(zip(seg, seg[1:]))
    for name, line in EXTRA_RIVERS.items():
        rivers[name] += list(zip(line, line[1:]))
    river_grid = Grid(0.25)
    for name, segs in rivers.items():
        for a, b in segs:
            river_grid.add(((a[0] + b[0]) / 2, (a[1] + b[1]) / 2), (name, a, b))
    crossing_holds = [(h["lon"], h["lat"], set(h["crossing"]) | ({"St. Clair"} if "Detroit" in h["crossing"] else set()), h["id"])
                      for h in holds if h["crossing"]]

    def river_crossed(a, b):
        mid = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2)
        for _, (name, r1, r2) in river_grid.near(mid, 2):
            if seg_intersect(a, b, r1, r2):
                return name
        return None

    def crossing_allowed(name, a):
        best = None
        for lon, lat, rs, hid in crossing_holds:
            if name in rs:
                d = km(a, (lon, lat))
                if d <= CROSSING_RADIUS_KM and (best is None or d < best[0]):
                    best = (d, hid)
        return best[1] if best else None

    # --- roads -> vertex graph ---------------------------------------------------------
    rd = shapefile.Reader(str(fetch(NE_LAYERS["roads"], args.ne_dir)))
    vid, coords, grid = {}, [], Grid(0.05)
    adj = defaultdict(dict)  # v -> {u: edge}
    adj_all = defaultdict(set)  # includes cut bridges; used only to find the main network for snapping

    def vertex(p):
        for q, v in grid.near(p):
            if km(p, q) <= SNAP_KM:
                return v
        v = len(coords)
        coords.append(p)
        grid.add(p, v)
        return v

    cut, kept_cross = 0, defaultdict(int)
    for sr in rd.iterShapeRecords():
        if sr.shape.shapeType == shapefile.NULL or not in_bbox(sr.shape.bbox):
            continue
        rec = sr.record.as_dict()
        cls = road_class(rec)
        if cls is None:
            continue
        label = route_label(rec)
        pts, parts = sr.shape.points, list(sr.shape.parts) + [len(sr.shape.points)]
        for i in range(len(parts) - 1):
            line = [tuple(p) for p in pts[parts[i]:parts[i + 1]]]
            prev = None
            for p in line:
                v = vertex(p)
                if prev is not None and prev != v:
                    adj_all[prev].add(v); adj_all[v].add(prev)
                    a, b = coords[prev], coords[v]
                    crossing = None
                    rname = river_crossed(a, b)
                    if rname:
                        crossing = crossing_allowed(rname, a)
                        if not crossing:
                            cut += 1
                            prev = v
                            continue
                        kept_cross[crossing] += 1
                    e = {"km": km(a, b), "cls": cls, "label": label, "crossing": crossing}
                    old = adj[prev].get(v)
                    if old is None or e["km"] < old["km"]:
                        adj[prev][v] = e
                        adj[v][prev] = e
                prev = v
    print(f"road graph: {len(coords)} vertices; {cut} bridge segments cut by living rivers; "
          f"crossings in use: {dict(kept_cross)}", file=sys.stderr)

    # --- snap holds (only onto the main network, never onto stray fragments) -------------
    comp, sizes = {}, defaultdict(int)
    for s0 in range(len(coords)):
        if s0 in comp:
            continue
        comp[s0], stack = s0, [s0]
        while stack:
            x = stack.pop()
            sizes[s0] += 1
            for y in adj_all[x]:
                if y not in comp:
                    comp[y] = s0
                    stack.append(y)
    main = {v for v in range(len(coords)) if sizes[comp[v]] >= MAIN_MIN_VERTICES}
    hold_v, spur = {}, {}
    for h in holds:
        if h["layer"] != "surface":
            continue
        p = (h["lon"], h["lat"])
        best = min(((km(p, q), v) for q, v in grid.near(p, 6) if v in main), default=None)
        if best is None:
            best = min((km(p, coords[v]), v) for v in main)
        d, v = best
        if d > HOLD_SNAP_MAX_KM:
            sys.exit(f"{h['id']} is {d:.0f} km from any road")
        hold_v[h["id"]] = v
        spur[h["id"]] = d
    v_holds = defaultdict(list)
    for hid, v in hold_v.items():
        v_holds[v].append(hid)

    # --- contract to a hold graph ------------------------------------------------------
    edges = {}

    def add_edge(a, b, e):
        k = tuple(sorted((a, b)))
        if k not in edges or e["km"] < edges[k]["km"]:
            edges[k] = dict(e, a=k[0], b=k[1])

    for hid, v0 in hold_v.items():
        # holds sharing a vertex: a city street apart
        for other in v_holds[v0]:
            if other != hid:
                d = km((H[hid]["lon"], H[hid]["lat"]), (H[other]["lon"], H[other]["lat"])) * 1.3 + 1
                add_edge(hid, other, {"km": d, "mix": {"highway": d}, "labels": [], "crossing": None, "kind": "road"})
        dist, mix, labels, cross = {v0: 0.0}, {v0: defaultdict(float)}, {v0: defaultdict(float)}, {v0: None}
        pq, done = [(0.0, v0)], set()
        while pq:
            d, v = heapq.heappop(pq)
            if v in done:
                continue
            done.add(v)
            if v != v0 and v in v_holds:
                for other in v_holds[v]:
                    tot = d + spur[hid] * 1.5 + spur[other] * 1.5
                    m = dict(mix[v]); m["back"] = m.get("back", 0) + (spur[hid] + spur[other]) * 1.5
                    lab = [k for k, _ in sorted(labels[v].items(), key=lambda kv: -kv[1]) if k][:3]
                    add_edge(hid, other, {"km": tot, "mix": m, "labels": lab, "crossing": cross[v], "kind": "road"})
                continue  # don't pass through another hold
            for u, e in adj[v].items():
                nd = d + e["km"]
                if nd < dist.get(u, 1e18):
                    dist[u] = nd
                    m = defaultdict(float, mix[v]); m[e["cls"]] += e["km"]
                    lb = defaultdict(float, labels[v]); lb[e["label"]] += e["km"]
                    mix[u], labels[u], cross[u] = m, lb, e["crossing"] or cross[v]
                    heapq.heappush(pq, (nd, u))

    # prune edges that a two-hop path covers almost as well
    nbr = defaultdict(dict)
    for (a, b), e in edges.items():
        nbr[a][b] = e["km"]; nbr[b][a] = e["km"]
    pruned = {}
    for (a, b), e in edges.items():
        redundant = any(c != b and b in nbr[c] and nbr[a][c] + nbr[c][b] <= e["km"] * PRUNE_SLACK
                        for c in nbr[a])
        if not redundant:
            pruned[(a, b)] = e
    edges = pruned

    # --- authored edges -----------------------------------------------------------------
    def gc(a, b):
        return km((H[a]["lon"], H[a]["lat"]), (H[b]["lon"], H[b]["lat"]))

    for river, chain in RIVERBEDS:
        for a, b in zip(chain, chain[1:]):
            d = gc(a, b) * 1.25
            add_edge(a, b, {"km": d, "mix": {"riverbed": d}, "labels": [f"{river} bed"], "crossing": None, "kind": "riverbed"})
    for a, b, label in DAMS:
        d = gc(a, b) * 1.3
        add_edge(a, b, {"km": d, "mix": {"highway": d}, "labels": [label], "crossing": a, "kind": "road"})
    for a, b in ICE_ROADS:
        d = gc(a, b) * 1.1
        add_edge(a, b, {"km": d, "mix": {"ice": d}, "labels": ["ice road"], "crossing": None, "kind": "ice", "season": "winter"})
    for a, b, kind in UP_LINKS:
        add_edge(a, b, {"km": max(gc(a, b), 1.0), "mix": {kind: max(gc(a, b), 1.0)}, "labels": [], "crossing": None, "kind": kind})

    def nearest_surface(hid, side=None):
        p = (H[hid]["lon"], H[hid]["lat"])
        cands = [(km(p, (H[o]["lon"], H[o]["lat"])), o) for o in hold_v
                 if side is None or (side == "@west") == (H[o]["lon"] < -90.85)]
        return min(cands)[1]

    for a, b, kind in DOWN_LINKS:
        if b.startswith("@"):
            b = nearest_surface(a, None if b == "@surface" else b)
        d = gc(a, b) * 1.4
        add_edge(a, b, {"km": d, "mix": {"tunnel": d}, "labels": ["the Deep Lines"],
                        "crossing": "junction" if "junction" in (a, b) and kind == "entrance" else None, "kind": kind})

    # --- breaks (seeded) ----------------------------------------------------------------
    rng = random.Random(SEED)
    out = []
    for (a, b), e in sorted(edges.items()):
        road_km = sum(v for k, v in e["mix"].items() if k in ("interstate", "highway"))
        breaks = sum(1 for _ in range(int(road_km // 50)) if rng.random() < 0.3)
        out.append({"a": a, "b": b, "kind": e["kind"], "km": round(e["km"], 1),
                    "mix": {k: round(v, 1) for k, v in e["mix"].items() if v > 0.05},
                    "roads": e["labels"], "crossing": e.get("crossing"), "breaks": breaks,
                    **({"season": e["season"]} if "season" in e else {})})

    # --- connectivity check -------------------------------------------------------------
    g = defaultdict(set)
    for e in out:
        g[e["a"]].add(e["b"]); g[e["b"]].add(e["a"])
    seen, stack = {"lighthouse"}, ["lighthouse"]
    while stack:
        for n in g[stack.pop()]:
            if n not in seen:
                seen.add(n); stack.append(n)
    unreached = sorted(set(H) - seen)
    OUT.write_text(json.dumps({
        "_doc": "Hold-to-hold road network built by tools/build_roads.py from Natural Earth 1:10m (public domain). "
                "km = driving distance; mix = km by road class; breaks = seeded blockages (each costs a detour or a "
                "clearing project); crossing = the crossing hold this edge uses to get over a living river.",
        "source": "Natural Earth 1:10m roads + rivers_lake_centerlines (public domain)",
        "seed": SEED, "edges": out}, indent=1, ensure_ascii=False) + "\n")
    print(f"wrote {len(out)} edges; unreachable from the Lighthouse: {unreached}", file=sys.stderr)


if __name__ == "__main__":
    main()
