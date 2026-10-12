"""Quick tuning sim for the Choir's creep (no player): runs the Hum seep and the Choir's monthly
actions over the real road network, and reports Silenced holds by month. A stand-in until the M1
Godot sim; it reads the same data/rules/choir.json.

Usage: python3 tools/sim_choir.py [--months 72] [--seeds 50]
"""
import argparse, heapq, json, random, statistics
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
D = ROOT / "data"


def load(rel):
    return json.loads((D / rel).read_text())


def neighbours_within(src, graph, limit):
    dist, pq = {src: 0.0}, [(0.0, src)]
    while pq:
        d, v = heapq.heappop(pq)
        if d > dist[v] or d > limit:
            continue
        for u, w in graph[v]:
            nd = d + w
            if nd <= limit and nd < dist.get(u, 1e18):
                dist[u] = nd
                heapq.heappush(pq, (nd, u))
    dist.pop(src)
    return dist


def run(seed, months, C, holds, graph, near):
    rng = random.Random(seed)
    hum = defaultdict(float, C["hum"]["start"])
    voices = C["voices"]["start"]
    deaf = {"lighthouse", "sweetwell", "highwater", "exchange", "cerro"}
    seep = C["hum"]["seep"]
    defs = C["hum"]["defences"]
    silenced_by_month = []
    for m in range(1, months + 1):
        silenced = [h for h in holds if hum[h] >= 100]
        marked = [h for h in holds if 60 <= hum[h] < 100]
        gain = defaultdict(float)
        vm = 1 + voices / float(seep['voices_multiplier'].split('/')[1])
        for src, factor in [(s, 1.0) for s in silenced] + [(s, seep["marked_factor"]) for s in marked]:
            for tgt, km in near[src].items():
                if hum[tgt] < 100:
                    gain[tgt] += seep["seep_silenced"] * factor * (1 - km / seep["seep_range_km"]) * vm
        for tgt, g in gain.items():
            h = holds[tgt]
            mult = 1.0
            if h["faction"] in deaf:
                mult *= defs["deaf_faction_leans"]
            if h["faction"] == "burning_water":
                mult *= 1.0  # contested
            for sub, p in h["subfactions"].items():
                if sub in ("keepers", "watchers"):
                    mult *= defs[sub + "_presence_each"] ** p["presence"]
            hum[tgt] = min(100, hum[tgt] + g * mult)
        for h in holds:
            if hum[h] < 100 and h not in gain and hum[h] > 0 and h not in C["hum"]["start"]:
                hum[h] = max(0, hum[h] - C["hum"]["decay_per_month_without_source"])
        n_sil = sum(1 for h in holds if hum[h] >= 100)
        actions = max(t["actions"] for t in C["actions"]["per_month_by_reach"] if n_sil >= t["from_silenced"])
        for _ in range(actions):
            r = rng.random()
            if r < 0.45:  # press a touched/marked hold
                cands = [h for h in holds if 30 <= hum[h] < 100]
                if cands:
                    t = rng.choice(cands)
                    hum[t] = min(100, hum[t] + 12)
            elif r < 0.8:  # coffle (delivered with some loss)
                if rng.random() < 0.75:
                    voices = min(C["voices"]["max"], voices + C["voices"]["per_coffle_delivered"])
        if n_sil >= C["actions"]["march_from_silenced"]:
            cands = [h for h in holds if 60 <= hum[h] < 100]
            if cands and rng.random() < C['actions']['march_chance_per_month']:
                hum[rng.choice(cands)] = 100
        new_sil = sum(1 for h in holds if hum[h] >= 100)
        voices = min(C["voices"]["max"], voices + (new_sil - n_sil) * C["voices"]["per_hold_silenced"])
        silenced_by_month.append(new_sil)
    return silenced_by_month


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--months", type=int, default=72)
    ap.add_argument("--seeds", type=int, default=50)
    a = ap.parse_args()
    C = load("rules/choir.json")
    holds = {h["id"]: h for h in load("world/holds.json")["holds"]}
    graph = defaultdict(list)
    for e in load("world/roads.json")["edges"]:
        if e.get("season") == "winter":
            continue
        graph[e["a"]].append((e["b"], e["km"])); graph[e["b"]].append((e["a"], e["km"]))
    near = {h: neighbours_within(h, graph, C["hum"]["seep"]["seep_range_km"]) for h in holds}
    runs = [run(s, a.months, C, holds, graph, near) for s in range(a.seeds)]
    for m in (12, 24, 36, 48, 60, 72, 96, 120):
        if m <= a.months:
            vals = [r[m - 1] for r in runs]
            print(f"month {m:3d}: Silenced median {statistics.median(vals):5.1f}  min {min(vals):3d}  max {max(vals):3d}")


if __name__ == "__main__":
    main()
