"""Validate data/ against itself and against the design docs. Exits non-zero on any error.

Checks: hold schema and counts; Lean sums; goods and services; sub-faction presence; consistency with
docs/design/16-gazetteer.md (names, tiers, bosses, starting Lean); road network references and
connectivity; faction, Choir and sub-faction references (seats, lieutenants, targets, homes).

Usage: python3 tools/validate_data.py
"""
import json, re, sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
D = ROOT / "data"
errors = []


def err(msg):
    errors.append(msg)


def load(rel):
    return json.loads((D / rel).read_text())


holds = load("world/holds.json")["holds"]
roads = load("world/roads.json")["edges"]
res = load("rules/resources.json")
fac = load("rules/factions.json")
choir = load("rules/choir.json")
subs = load("rules/subfactions.json")
for rel in ("rules/time.json", "rules/economy.json", "rules/lean.json"):
    load(rel)  # must parse

H = {h["id"]: h for h in holds}
GOODS = {r["id"] for r in res["resources"]}
SERVICES = set(res["services"])
FACTIONS = {f["id"] for f in fac["factions"]}
SUBS = {s["id"] for s in subs["subfactions"]}
RIVERS = {"Mississippi", "Ohio", "Missouri", "Tennessee", "Niagara", "Detroit"}

# --- holds ----------------------------------------------------------------------------------
if len(holds) != 130 or len(H) != 130:
    err(f"expected 130 unique holds, got {len(holds)} / {len(H)}")
tiers = Counter(h["tier"] for h in holds)
if tiers != Counter({"seat": 8, "major": 38, "hold": 66, "outpost": 18}):
    err(f"tier counts {dict(tiers)}")
REQ = ["id", "name", "region", "layer", "lat", "lon", "tier", "boss", "faction", "economy", "services",
       "needs", "population", "gang", "walls", "buildings", "lean", "subfactions", "crossing"]
for h in holds:
    hid = h["id"]
    for k in REQ:
        if k not in h:
            err(f"{hid}: missing {k}")
    if not (17.8 <= h["lat"] <= 46.0 and -104.5 <= h["lon"] <= -75.5):
        err(f"{hid}: coordinates outside the map")
    if h["faction"] not in FACTIONS | {None, "choir"}:
        err(f"{hid}: unknown faction {h['faction']}")
    eco = h["economy"]
    s, w = eco["surplus"], eco["want"]
    for g, lvl in {**s, **w}.items():
        if g not in GOODS:
            err(f"{hid}: unknown good {g}")
        if lvl not in (1, 2, 3):
            err(f"{hid}: level {lvl} for {g}")
    if set(s) & set(w):
        err(f"{hid}: {set(s) & set(w)} both surplus and want")
    if not set(eco["stock"]) <= set(s):
        err(f"{hid}: stock for goods that aren't surplus")
    for x in h["services"] + h["needs"]:
        if x not in SERVICES:
            err(f"{hid}: unknown service {x}")
    if h.get("silenced"):
        if h["lean"] is not None:
            err(f"{hid}: silenced but has lean")
    else:
        lean = h["lean"]
        if sum(lean.values()) != 100:
            err(f"{hid}: lean sums to {sum(lean.values())}")
        for k in lean:
            if k not in FACTIONS | {"independent", "choir"}:
                err(f"{hid}: lean key {k}")
            if k == "choir" and not h.get("via_tum_tum"):
                err(f"{hid}: choir lean outside Tum Tum's holds")
        leader = max(lean, key=lean.get)
        expect = h["faction"] or "independent"
        if leader != expect:
            err(f"{hid}: leans to {leader} but faction is {expect}")
    for sid, p in h["subfactions"].items():
        if sid not in SUBS:
            err(f"{hid}: unknown sub-faction {sid}")
        if p["presence"] not in (1, 2, 3):
            err(f"{hid}: presence {p['presence']}")
    for r in h["crossing"]:
        if r not in RIVERS:
            err(f"{hid}: unknown river {r}")

# --- consistency with the gazetteer -----------------------------------------------------------
gaz = (ROOT / "docs/design/16-gazetteer.md").read_text()
TIER = {"S": "seat", "M": "major", "H": "hold", "O": "outpost"}
LEAN = {"Ind": None, "Lighthouse": "lighthouse", "Sweetwell": "sweetwell", "Highwater": "highwater",
        "Exchange": "exchange", "Burning Water": "burning_water", "Cerro": "cerro", "Choir": "choir",
        "Choir (Tum Tum)": "choir"}
by_name = {h["name"]: h for h in holds}
seen = 0
for line in gaz.splitlines():
    if not line.startswith("| **"):
        continue
    c = [x.strip() for x in line.strip().strip("|").split("|")]
    name = re.sub(r"\s+", " ", c[0].replace("*", "").replace("✕", "")).strip()
    seen += 1
    h = by_name.get(name)
    if not h:
        err(f"gazetteer hold {name} missing from data"); continue
    if TIER[c[2]] != h["tier"]:
        err(f"{name}: tier {h['tier']} vs gazetteer {c[2]}")
    if c[3].replace("*", "").strip() != h["boss"]:
        err(f"{name}: boss {h['boss']} vs gazetteer {c[3]}")
    if LEAN.get(c[6], "?") != h["faction"]:
        err(f"{name}: faction {h['faction']} vs gazetteer {c[6]}")
if seen != 130:
    err(f"gazetteer has {seen} holds")

# --- roads ----------------------------------------------------------------------------------
g = defaultdict(set)
for e in roads:
    for k in ("a", "b"):
        if e[k] not in H:
            err(f"road edge references unknown hold {e[k]}")
    if e["km"] <= 0:
        err(f"edge {e['a']}-{e['b']} has km {e['km']}")
    if e["crossing"] and not H.get(e["crossing"], {}).get("crossing"):
        err(f"edge {e['a']}-{e['b']} uses non-crossing {e['crossing']}")
    if e.get("season") != "winter":
        g[e["a"]].add(e["b"]); g[e["b"]].add(e["a"])
seen_r, stack = {"lighthouse"}, ["lighthouse"]
while stack:
    for n in g[stack.pop()]:
        if n not in seen_r:
            seen_r.add(n); stack.append(n)
if seen_r != set(H):
    err(f"unreachable from the Lighthouse year-round: {sorted(set(H) - seen_r)}")
used = {e["crossing"] for e in roads if e["crossing"]}
for h in holds:
    if h["crossing"] and h["id"] not in used:
        err(f"crossing hold {h['id']} carries no road over its river")

# --- factions, Choir, sub-factions -------------------------------------------------------------
for f in fac["factions"]:
    seat = H.get(f["seat"])
    if not seat or seat["tier"] != "seat" or seat["faction"] != f["id"]:
        err(f"faction {f['id']}: bad seat {f['seat']}")
    if seat and seat["boss"] != f["hardholder"]:
        err(f"faction {f['id']}: hardholder {f['hardholder']} isn't the seat's boss {seat['boss']}")
    for lt in f["lieutenants"]:
        if lt["hold"] not in H or H[lt["hold"]]["boss"] != lt["name"]:
            err(f"faction {f['id']}: lieutenant {lt['name']} doesn't run {lt['hold']}")
    for t in f["expansion_targets"]:
        if t not in H:
            err(f"faction {f['id']}: unknown expansion target {t}")
for a, row in fac["relations"].items():
    if a.startswith("_"):
        continue
    for b in row:
        if a not in FACTIONS or (b not in FACTIONS and b != "_doc"):
            err(f"relations: {a}-{b}")
for s in choir["seats"]:
    if s not in H or H[s]["tier"] != "seat":
        err(f"choir seat {s}")
for s in subs["subfactions"]:
    if s["home"] not in H:
        err(f"sub-faction {s['id']}: unknown home {s['home']}")
    elif H[s["home"]]["subfactions"].get(s["id"], {}).get("presence") != 3:
        err(f"sub-faction {s['id']}: home {s['home']} lacks presence 3")
    if s.get("backs") not in FACTIONS | {None, "highest_bidder"}:
        err(f"sub-faction {s['id']}: backs {s['backs']}")
    for lt in s.get("lieutenants", []):
        if H.get(lt["hold"], {}).get("boss") != lt["name"]:
            err(f"sub-faction {s['id']}: lieutenant {lt['name']} doesn't run {lt['hold']}")

if errors:
    print(f"{len(errors)} error(s):")
    for e in errors:
        print("  -", e)
    sys.exit(1)
print(f"data OK: {len(holds)} holds, {len(roads)} road edges, {len(GOODS)} goods, "
      f"{len(FACTIONS)} factions + the Choir, {len(SUBS)} sub-factions")
