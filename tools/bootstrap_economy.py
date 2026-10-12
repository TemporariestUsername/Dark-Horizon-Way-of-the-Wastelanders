"""One-time bootstrap: derive each hold's economy, people, defences, buildings, starting Lean and
sub-faction Presence, and write them into data/world/holds.json.

Inputs: data/world/holds.json (from bootstrap_holds.py), data/world/roads.json (from build_roads.py),
data/rules/resources.json. Deterministic (no randomness beyond a stable hash). Kept for provenance;
after bootstrap the JSON is the source of truth and tools/validate_data.py checks it.

Usage: python3 tools/bootstrap_economy.py
"""
import hashlib, heapq, json, math, re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
HOLDS = ROOT / "data/world/holds.json"
ROADS = ROOT / "data/world/roads.json"
RES = ROOT / "data/rules/resources.json"

# Gazetteer phrase (before any parenthesis) -> market good id, or None for a service.
GOOD = {
    "drinking water": "water", "hot water": "hot_water", "meat": "meat", "salt": "salt", "grain": "grain",
    "fresh foods": "fresh_food", "fish": "fresh_food", "preserved foods": "preserved_food",
    "livestock": "livestock", "gasoline": "guzzoline", "fuel": "guzzoline", "crude": "crude",
    "power": "batteries", "batteries": "batteries", "weaponry": "weaponry", "ammo": "ammo",
    "medical supplies": "medicine", "machinery": "machinery", "vehicles": "parts", "aircraft parts": "parts",
    "scrap": "scrap", "raw materials": "raw_materials", "hides": "raw_materials", "cloth": "cloth",
    "hi‑tech": "hitech", "books": "books", "specialized goods": "goods", "drugs": "drugs",
    "luxury goods": "luxury", "liquor": "liquor", "music and art": "art",
}
SERVICE = {
    "access": "access", "burial": "burial", "cable lines": "cable_lines", "caravans": "caravans",
    "fortifications": "fortifications", "information": "information", "know‑how": "know_how",
    "labor": "labor", "leisure": "leisure", "loans": "loans", "raiders": "raiders", "repairs": "repairs",
    "scouts": "scouts", "security": "security", "shelter": "shelter", "status": "status", "tolls": "tolls",
    "trade": "trade", "vantage": "vantage",
}
SPECIAL_GOOD = {"luxury goods (glass, lenses)": "glass"}
EVERYTHING = ["grain", "fresh_food", "meat", "guzzoline", "medicine", "ammo"]

# Regional texture: level-1 surplus and want added where the gazetteer is silent.
REGION_BASE = {
    "The Crossing": (["fresh_food"], ["medicine"]),
    "The Delta": (["grain", "cloth"], ["medicine", "guzzoline"]),
    "The Twenty": (["raw_materials"], ["medicine"]),
    "The Forty": (["livestock", "grain"], ["machinery"]),
    "The Sixty‑Five": (["scrap"], ["fresh_food"]),
    "The Ten": (["guzzoline"], ["water", "medicine"]),
    "The Thirty‑Five": (["meat"], ["water", "guzzoline"]),
    "The Rag‑Wastes": (["crude", "meat"], ["water"]),
    "The Bravo": (["salt"], ["water"]),
    "The Sierra Coast": (["fresh_food"], ["ammo", "medicine"]),
    "The Seventy": (["grain"], ["guzzoline"]),
    "The Lakes": (["water", "preserved_food"], ["guzzoline", "fresh_food"]),
    "The Seventy‑Five": (["fresh_food"], ["guzzoline"]),
    "The Glass": (["luxury", "glass"], ["water"]),
    "Up: Harrowgate": ([], []),
    "Down: the Deep Lines": ([], ["batteries"]),
}
POP = {"seat": (4000, 9000), "major": (900, 2600), "hold": (180, 800), "outpost": (25, 120)}
GANG = {  # tier -> size, harm, armor
    "seat": ("large", 3, 1), "major": ("medium", 3, 1), "hold": ("small", 2, 1), "outpost": ("tiny", 1, 0)}
FACTION_GANG = {  # seat/aligned overrides: armor bonus, tags
    "sweetwell": (1, ["well-disciplined"]), "highwater": (1, ["well-disciplined"]),
    "cerro": (1, ["siege"]), "burning_water": (1, ["fire"]), "exchange": (0, ["mercenary"]),
    "lighthouse": (0, ["defend-only"]), "choir": (0, ["opened"]),
}
FACTION_SEATS = {"lighthouse": "lighthouse", "sweetwell": "sweetwell", "highwater": "highwater",
                 "exchange": "exchange", "burning_water": "burning_water", "cerro": "cerro"}
INFLUENCE_PEAK, INFLUENCE_FALLOFF_KM, INFLUENCE_MIN, INFLUENCE_CAP = 25, 350, 3, 35
WAR = json.loads((ROOT / "data/rules/war.json").read_text())
TROOPS, WAR_TAGS = WAR["troops_by_size"], WAR["tags"]
TRAINING = {"seat": 60, "major": 45, "hold": 30, "outpost": 15}
# Seat gangs from the faction sheets (docs/design/10 and 17): size, harm, armor, tags.
SEAT_GANG = {
    "lighthouse": ("small", 2, 1, ["defend-only", "well-disciplined"]),
    "sweetwell": ("medium", 3, 2, ["well-disciplined"]),
    "highwater": ("large", 2, 2, ["well-disciplined"]),
    "exchange": ("medium", 3, 1, ["mercenary"]),
    "burning_water": ("small", 2, 2, ["fire"]),
    "cerro": ("medium", 3, 2, ["siege"]),
    "pellet": ("medium", 2, 1, ["catchers"]),
    "harrowgate": ("huge", 2, 0, ["opened"]),
}
# Golden-age medical caches: hospitals, universities, the spa town.
MEDICINE_SOURCES = {"baths": 3, "highwater": 2, "dome": 2, "campus": 2, "exchange": 1, "kingdom": 1, "loop": 1}
MEDICINE_WANT_SHARE = 0.65  # share of holds with a standing medicine want of 1

# Sub-faction chapters (docs/design/18-sub-factions.md, "Chapters"). home = presence 3, chapter = 2.
CHAPTERS = {
    "keepers": ("lighthouse", ["helena", "fork", "spillway", "siege", "derby", "span", "shoals", "arch"], False),
    "watchers": ("tajin", ["southmost", "fort", "green", "barrow"], False),
    "cross_folk": ("cross", ["boon", "campus", "granary", "arch"], False),
    "mourners": ("barrow", ["fort", "tux", "tajin"], False),
    "teeth": ("teeth", ["twice", "drift", "brand", "stack", "gullet", "rumhouse"], False),
    "gar": ("barge_town", ["crawdad", "bluff", "helena", "kettle"], False),
    "twister_riders": ("stockade", ["rock", "gallows", "hub"], False),
    "whiteout": ("mill_town", ["loop", "brewhouse", "burnriver"], False),
    "wheelwrights": ("motor", ["gnarly", "track", "sinkhole", "rails", "spaghetti"], False),
    "tankermen": ("partridge", ["burning_water", "sweetwell", "highwater", "falcon", "tampico", "lighthouse"], False),
    "players": ("beale", ["crossroads", "strings", "orleans", "shoals", "pier_saint", "circus"], False),
    "diggers": ("fuse", ["vault", "hangar", "dustwich"], False),
    "news": ("lighthouse", ["orleans", "highwater", "exchange"], False),
    "family": ("krin_s_nest", ["junction", "reserve", "pumphouse", "mammoth", "anchorage", "barge_town", "loop"], True),
    "waking": ("junction", ["hangar", "dome", "fuse"], True),
    "odd_lot": ("dog_head", ["rumhouse", "casino", "mobile", "haven", "gemela"], True),
}


def stable(hid, salt, lo, hi):
    h = int(hashlib.sha1(f"{hid}:{salt}".encode()).hexdigest(), 16)
    return lo + h % (hi - lo + 1)


def parse(text):
    goods, services = [], []
    for raw in re.split(r",\s*(?![^()]*\))", text):
        raw = raw.strip()
        if not raw or raw == "—":
            continue
        if raw in SPECIAL_GOOD:
            goods.append(SPECIAL_GOOD[raw]); continue
        if raw in ("everything", "everything else"):
            goods.append("*"); continue
        if raw == "people":
            continue
        head = raw.split(" (")[0].strip()
        if head in GOOD:
            goods.append(GOOD[head])
        elif head in SERVICE:
            services.append(SERVICE[head])
        else:
            raise SystemExit(f"unmapped phrase: {raw!r}")
    return goods, services


def road_distances(src, edges):
    g = defaultdict(list)
    for e in edges:
        if e.get("season") == "winter":
            continue
        g[e["a"]].append((e["b"], e["km"])); g[e["b"]].append((e["a"], e["km"]))
    dist, pq = {src: 0.0}, [(0.0, src)]
    while pq:
        d, v = heapq.heappop(pq)
        if d > dist[v]:
            continue
        for u, w in g[v]:
            if d + w < dist.get(u, 1e18):
                dist[u] = d + w
                heapq.heappush(pq, (d + w, u))
    return dist


def main():
    doc = json.loads(HOLDS.read_text())
    holds = doc["holds"]
    edges = json.loads(ROADS.read_text())["edges"]
    valid = {r["id"] for r in json.loads(RES.read_text())["resources"]}
    seat_dist = {f: road_distances(sid, edges) for f, sid in FACTION_SEATS.items()}
    presence = defaultdict(dict)
    for sub, (home, chapters, hidden) in CHAPTERS.items():
        presence[home][sub] = {"presence": 3, "hidden": hidden}
        for c in chapters:
            presence[c][sub] = {"presence": 2, "hidden": hidden}

    for h in holds:
        hid, tier, region = h["id"], h["tier"], h["region"]
        sg, ss = parse(h["surplus_text"])
        wg, ws = parse(h["want_text"])
        surplus, want = {}, {}
        for i, g in enumerate(x for x in sg if x != "*"):
            surplus[g] = max(surplus.get(g, 0), 3 if i == 0 else 2)
        for i, g in enumerate(wg):
            if g == "*":
                for e in EVERYTHING:
                    if e not in surplus:
                        want.setdefault(e, 1)
            elif g not in surplus:
                want[g] = max(want.get(g, 0), 3 if i == 0 else 2)
        base_s, base_w = REGION_BASE[region]
        if tier != "outpost" and not h["silenced"]:
            for g in base_s:
                if g not in surplus and g not in want:
                    surplus[g] = 1
            for g in base_w:
                if g not in surplus and g not in want:
                    want[g] = 1
        if hid in MEDICINE_SOURCES:
            want.pop("medicine", None)
            surplus["medicine"] = max(surplus.get("medicine", 0), MEDICINE_SOURCES[hid])
        elif not surplus.get("medicine") and "medicine" not in want and not h["silenced"] \
                and stable(hid, "med", 0, 99) < MEDICINE_WANT_SHARE * 100:
            want["medicine"] = 1
        if surplus.get("weaponry", 0) >= 2 and "ammo" not in want:
            surplus.setdefault("ammo", 1)  # armouries make bullets too
        if h["silenced"]:
            surplus, want = {}, {}
        assert set(surplus) <= valid and set(want) <= valid and not (set(surplus) & set(want)), hid
        stock_mult = {"seat": 10, "major": 7, "hold": 4, "outpost": 2}[tier]
        h["economy"] = {"surplus": dict(sorted(surplus.items())), "want": dict(sorted(want.items())),
                        "stock": {g: lvl * stock_mult for g, lvl in sorted(surplus.items())}}
        h["services"] = sorted(set(ss))
        h["needs"] = sorted(set(ws))  # wanted services (labor, security...), met by gigs, not trade

        lo, hi = POP[tier]
        h["population"] = 3000 if hid == "harrowgate" else stable(hid, "pop", lo, hi)

        size, harm, armor = GANG[tier]
        tags = []
        if h["faction"] in FACTION_GANG:
            bonus, tags = FACTION_GANG[h["faction"]]
            armor += bonus
        if hid == "teeth":
            size, harm, tags = "large", 3, ["savage", "mobile"]
        if hid in SEAT_GANG:
            size, harm, armor, tags = SEAT_GANG[hid]
        # Inindo-style gang: troops, arms, training (rules/war.json).
        troops = round(TROOPS[size] * stable(hid, "troops", 80, 120) / 100)
        arms = min(95, 20 + harm * 15 + min(armor, 3) * 10)
        training = TRAINING[tier]
        for t in tags:
            arms += WAR_TAGS.get(t, {}).get("arms", 0)
            training += WAR_TAGS.get(t, {}).get("training", 0)
        h["gang"] = {"troops": troops, "arms": max(5, min(95, arms)), "training": max(5, min(95, training)), "tags": tags}
        walls = {"seat": 2, "major": 1, "hold": stable(hid, "walls", 0, 1), "outpost": 0}[tier]
        if h["faction"] == "cerro":
            walls = 2
        if hid in ("teeth", "lighthouse"):
            walls = 0 if hid == "teeth" else 1
        h["walls"] = walls

        b = {"seat": ["market", "bar", "garage", "infirmary", "notice_wall", "seat"],
             "major": ["market", "bar", "garage", "infirmary", "notice_wall"],
             "hold": ["market", "bar", "notice_wall",
                      "garage" if ({"machinery", "parts", "scrap"} & set(surplus)) or "repairs" in ss
                      else "infirmary"],
             "outpost": ["trader"]}[tier]
        if h["crossing"] and h["layer"] == "surface":
            b.append("crossing")
        if surplus.get("water", 0) >= 3:
            b.append("wells")
        if hid in ("exchange",):
            b.append("exchange")
        if hid in ("tajin", "wisher", "crossroads"):
            b.append("brainers_room")
        if hid in ("barrow", "cross", "temple", "lighthouse", "abbey"):
            b.append("congregation")
        if h["silenced"]:
            b = []
        h["buildings"] = b

        if h["silenced"]:
            h["lean"] = None
        elif tier == "seat":
            h["lean"] = {h["faction"]: 100}
        else:
            infl = {}
            for f, dist in seat_dist.items():
                d = dist.get(hid)
                if d is None or f == h["faction"]:
                    continue
                v = round(INFLUENCE_PEAK * math.exp(-d / INFLUENCE_FALLOFF_KM))
                if v >= INFLUENCE_MIN:
                    infl[f] = v
            tot = sum(infl.values())
            if tot > INFLUENCE_CAP:
                infl = {f: max(1, round(v * INFLUENCE_CAP / tot)) for f, v in infl.items()}
            if h["faction"]:
                own = 60
                rest = 100 - own
                infl = {f: min(v, rest // 2) for f, v in infl.items()}
                lean = {h["faction"]: own, **infl, "independent": rest - sum(infl.values())}
            else:
                lean = {**infl, "independent": 100 - sum(infl.values())}
            h["lean"] = {k: v for k, v in sorted(lean.items(), key=lambda kv: -kv[1]) if v > 0}
            assert sum(h["lean"].values()) == 100, (hid, h["lean"])
        h["subfactions"] = dict(sorted(presence.get(hid, {}).items()))

    doc["holds"] = holds
    HOLDS.write_text(json.dumps(doc, indent=1, ensure_ascii=False) + "\n")
    print(f"economy, people, defences, buildings, lean and presence written for {len(holds)} holds")


if __name__ == "__main__":
    main()
