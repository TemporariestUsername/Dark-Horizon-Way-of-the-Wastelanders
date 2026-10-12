"""One-time bootstrap: build data/world/holds.json from the gazetteer (docs/design/16-gazetteer.md)
plus authored golden-age coordinates. Kept for provenance; after bootstrap, data/world/holds.json is
the source of truth and is checked by tools/validate_data.py.

Usage: python3 tools/bootstrap_holds.py
"""
import json, re, sys, unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GAZ = ROOT / "docs/design/16-gazetteer.md"
OUT = ROOT / "data/world/holds.json"

# Golden-age coordinates (lat, lon) of each hold's site, to roughly 5 km.
COORDS = {
    # The Crossing
    "The Lighthouse": (35.152, -90.062), "Anchorage": (35.170, -90.050), "Saltlick": (35.340, -89.900),
    "Gnarly": (34.820, -89.990), "Pyramid": (35.155, -90.052), "Beale": (35.139, -90.054),
    "Haven": (34.970, -90.010), "Weigh Station": (35.150, -90.180),
    # The Delta
    "Siege": (32.315, -90.905), "Bluff": (31.560, -91.400), "Brace Win": (31.080, -91.600),
    "Barge Town": (33.410, -91.060), "Crossroads": (34.200, -90.570), "Mudflat": (33.750, -90.720),
    "Reservoir": (32.400, -90.070), "Helena": (34.530, -90.590),
    # The Twenty
    "Red": (32.510, -93.750), "Ferry": (32.510, -92.120), "Corbett": (32.360, -88.700),
    "Furnace": (33.520, -86.800), "Stadium": (33.210, -87.550), "Pines": (32.520, -92.640),
    "Partridge": (33.430, -94.050), "Derricks": (32.390, -94.880),
    # The Forty
    "Stockade": (35.470, -97.520), "Gallows": (35.390, -94.400), "Rock": (34.750, -92.290),
    "The Baths": (34.500, -93.060), "Strings": (36.160, -86.780), "Hub": (35.610, -88.810),
    "Temple": (36.150, -86.810), "Spillway": (37.010, -88.270),
    # The Sixty-Five
    "Rails": (32.380, -86.310), "Fuse": (34.710, -86.650), "Mammoth": (37.190, -86.100),
    "Derby": (38.250, -85.760), "The Vault": (37.880, -85.960), "Shoals": (34.800, -87.670),
    "Abbey": (34.180, -86.840), "Sinkhole": (36.990, -86.440),
    # The Ten
    "Dog Head": (29.730, -95.200), "Rumhouse": (29.300, -94.800), "Burning Water": (29.380, -94.920),
    "Pitch": (29.900, -93.930), "Kettle": (30.230, -93.220), "Crawdad": (30.220, -92.020),
    "Capitol": (30.450, -91.190), "Orleans": (29.950, -90.070), "Dustwich": (29.990, -90.030),
    "Casino": (30.400, -88.890), "Mobile": (30.690, -88.040), "Spindletop": (30.060, -94.100),
    "Pier": (30.370, -89.090),
    # The Thirty-Five
    "Sweetwell": (29.420, -98.490), "Mission": (29.330, -98.470), "Blue Hole": (29.880, -97.940),
    "Dome": (30.270, -97.740), "Silo": (31.550, -97.150), "The Stack": (32.920, -96.770),
    "Brand": (32.790, -97.350), "Border": (27.510, -99.510), "Pinwheel": (32.010, -97.130),
    # The Rag-Wastes
    "The Teeth": (31.900, -102.200), "Twice": (31.460, -100.440), "Nodders": (31.850, -102.370),
    "Drift": (31.650, -102.820), "Halter": (32.450, -99.730), "Long Fence": (32.470, -100.410),
    "Dry Spring": (32.250, -101.480), "Last Stop": (31.420, -103.490),
    # The Bravo
    "Gullet": (29.360, -100.900), "Gemela": (27.480, -99.520), "Falcon": (26.560, -99.170),
    "Pesca": (26.380, -98.820), "Cerro": (25.670, -100.310), "Desierto": (25.420, -101.000),
    "Soto": (23.770, -98.210), "Mouth": (25.900, -97.500),
    # The Sierra Coast
    "Tampico": (22.250, -97.860), "Tux": (20.960, -97.400), "Tajin": (20.450, -97.380),
    "The Fort": (19.210, -96.130), "Barrow": (19.540, -96.910), "The Green": (18.450, -95.200),
    "Southmost": (18.850, -97.100),
    # The Seventy
    "Pellet": (39.100, -94.600), "The Arch": (38.620, -90.180), "Fork": (37.000, -89.180),
    "Quake": (36.590, -89.530), "Campus": (38.950, -92.330), "Cross": (39.120, -88.540),
    "The Track": (39.790, -86.230), "Granary": (39.960, -83.000), "Boon": (38.970, -92.740),
    # The Lakes
    "Highwater": (43.650, -79.380), "The Loop": (41.880, -87.630), "Motor": (42.330, -83.050),
    "Burnriver": (41.500, -81.690), "The Falls": (43.090, -79.070), "Brewhouse": (43.040, -87.910),
    "Mill Town": (41.600, -87.340), "The Tunnel": (42.315, -83.030), "Pen": (44.230, -76.490),
    "Visage": (41.650, -83.540), "Forks": (42.980, -81.250),
    # The Seventy-Five
    "Span": (39.100, -84.510), "Stables": (38.040, -84.500), "The Sphere": (35.960, -83.920),
    "Lookout": (35.010, -85.340), "Spaghetti": (33.890, -84.260), "Orchard": (32.840, -83.630),
    "Hangar": (39.780, -84.110), "Kudzu": (34.500, -84.950), "Painted Barns": (34.900, -85.200),
    # The Glass
    "The Exchange": (27.950, -82.460), "Mirror Town": (28.550, -82.390), "The Kingdom": (28.420, -81.580),
    "Circus": (27.340, -82.530), "Pier Saint": (27.770, -82.640), "The Field": (30.350, -87.290),
    "Hill": (30.440, -84.280), "Sawgrass": (26.150, -80.450), "Neon": (30.180, -85.800),
    # Up: Harrowgate (Houston skyline; reached by lift-towers from the ground)
    "Harrowgate": (29.760, -95.370), "Wisher": (29.758, -95.380), "The Gondola": (29.752, -95.362),
    # Down: the Deep Lines
    "Krin's Nest": (29.900, -91.910), "Junction": (30.050, -90.850), "The Pumphouse": (29.950, -90.130),
    "The Reserve": (28.930, -95.380),
}

# Which living rivers each crossing hold lets you cross (see 02-world.md, "Crossings").
CROSSINGS = {
    "The Lighthouse": ["Mississippi"], "Siege": ["Mississippi"], "Brace Win": ["Mississippi"],
    "Helena": ["Mississippi"], "Capitol": ["Mississippi"], "The Arch": ["Mississippi", "Missouri"],
    "Fork": ["Mississippi", "Ohio"], "Derby": ["Ohio"], "Span": ["Ohio"], "Boon": ["Missouri"],
    "Spillway": ["Tennessee"], "Shoals": ["Tennessee"], "The Falls": ["Niagara"],
    "The Tunnel": ["Detroit"], "Junction": ["Mississippi"],
}
LOUD_EDGE = {"Last Stop", "Southmost", "Sawgrass", "Pen"}
REGION_META = {  # region -> (octant, ring, layer)
    "The Crossing": ("Centre", "centre", "surface"), "The Delta": ("S", "closer", "surface"),
    "The Twenty": ("W", "closer", "surface"), "The Forty": ("W/E", "closer", "surface"),
    "The Sixty‑Five": ("E", "closer", "surface"), "The Ten": ("S", "farther", "surface"),
    "The Thirty‑Five": ("W", "farther", "surface"), "The Rag‑Wastes": ("W", "farther", "surface"),
    "The Bravo": ("S/W", "farther", "surface"), "The Sierra Coast": ("S", "farther", "surface"),
    "The Seventy": ("N", "farther", "surface"), "The Lakes": ("N", "farther", "surface"),
    "The Seventy‑Five": ("E", "farther", "surface"), "The Glass": ("E", "farther", "surface"),
    "Up: Harrowgate": ("Up", "farther", "up"), "Down: the Deep Lines": ("Down", "farther", "down"),
}
LEAN = {"Ind": None, "Lighthouse": "lighthouse", "Sweetwell": "sweetwell", "Highwater": "highwater",
        "Exchange": "exchange", "Burning Water": "burning_water", "Cerro": "cerro",
        "Choir": "choir", "Choir (Tum Tum)": "choir"}
TIER = {"S": "seat", "M": "major", "H": "hold", "O": "outpost"}


def hold_id(name):
    n = unicodedata.normalize("NFKD", name).encode("ascii", "ignore").decode().lower()
    n = re.sub(r"^the ", "", n)
    return re.sub(r"[^a-z0-9]+", "_", n).strip("_")


def clean(cell):
    return re.sub(r"\s+", " ", cell.replace("*", "").replace("✕", "")).strip()


def main():
    holds, region = [], None
    for line in GAZ.read_text().splitlines():
        m = re.match(r"^## (.+?)(?: \([^)]*\))?: \d+$", line)
        if m:
            region = m.group(1).strip()
        if not line.startswith("| **"):
            continue
        c = [x.strip() for x in line.strip().strip("|").split("|")]
        name = clean(c[0])
        if name not in COORDS:
            sys.exit(f"no coordinates for {name}")
        octant, ring, layer = REGION_META[region]
        lean = c[6]
        lat, lon = COORDS[name]
        holds.append({
            "id": hold_id(name), "name": name, "region": region, "octant": octant, "ring": ring,
            "layer": layer, "site": clean(c[1]), "lat": lat, "lon": lon, "tier": TIER[c[2]],
            "boss": clean(c[3]), "surplus_text": clean(c[4]), "want_text": clean(c[5]),
            "faction": LEAN[lean], "via_tum_tum": lean == "Choir (Tum Tum)",
            "silenced": lean == "Choir" and name in ("Harrowgate", "The Gondola"),
            "crossing": CROSSINGS.get(name, []), "loud_edge": name in LOUD_EDGE,
            "notes": clean(c[7]),
        })
    ids = [h["id"] for h in holds]
    assert len(holds) == 130 and len(set(ids)) == 130, (len(holds), len(set(ids)))
    OUT.write_text(json.dumps({"_doc": "130 holds. Source of truth after bootstrap; see docs/design/16-gazetteer.md and tools/validate_data.py.",
                               "holds": holds}, indent=1, ensure_ascii=False) + "\n")
    print(f"wrote {len(holds)} holds to {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
