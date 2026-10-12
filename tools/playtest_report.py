#!/usr/bin/env python3
"""Turn testers' playtest logs (log.jsonl, written by game/playtest_log.gd) into a report.

    python3 tools/playtest_report.py logs/                 # every *.jsonl under logs/
    python3 tools/playtest_report.py a.jsonl b.jsonl -o tools/out/playtest-report.md

For each skirmish and road war: how often players won, against the bench's target win rate for
the AI (data/rules/battle.json encounter_targets), and what testers said ("too easy / about
right / too hard"). For the event cards: what players picked, and whether checks succeed as
often as the chance shown (calibration). Stdlib only.
"""
import argparse
import json
import os
import statistics
import sys
from collections import Counter, defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VERDICTS = ["too_easy", "about_right", "too_hard"]


def load(paths):
    recs, bad = [], 0
    files = []
    for p in paths:
        if os.path.isdir(p):
            for d, _, fs in os.walk(p):
                files += [os.path.join(d, f) for f in sorted(fs) if f.endswith(".jsonl")]
        else:
            files.append(p)
    for f in files:
        with open(f, encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    r = json.loads(line)
                except json.JSONDecodeError:
                    bad += 1
                    continue
                if isinstance(r, dict) and "kind" in r:
                    r["_file"] = f
                    recs.append(r)
                else:
                    bad += 1
    # The same log sent twice (or a log sent again after more play) must not count twice.
    seen, unique = set(), []
    for r in recs:
        key = json.dumps({k: v for k, v in r.items() if k != "_file"}, sort_keys=True)
        if key not in seen:
            seen.add(key)
            unique.append(r)
    return files, unique, bad, len(recs) - len(unique)


def pct(n, d):
    return f"{round(100 * n / d)}%" if d else "–"


def median(xs):
    return statistics.median(xs) if xs else "–"


def feel_cell(c):
    total = sum(c[v] for v in VERDICTS)
    if not total:
        return "–"
    return " / ".join(str(c[v]) for v in VERDICTS)


def battle_section(md, recs, kind, id_key, names, targets):
    plays = [r for r in recs if r["kind"] == kind]
    feels = [r for r in recs if r["kind"] == "feel" and r.get("about") == kind]
    title = "Skirmishes" if kind == "skirmish" else "Road wars"
    md.append(f"## {title}")
    md.append("")
    if not plays:
        md.append("No plays logged.")
        md.append("")
        return
    md.append("Played by testers, from the menu or a journey. **Bench target** is the win rate the balance bench "
              "aims for with the AI playing the party (data/rules/battle.json). **Auto** is the share of the "
              "player's actions that handed the turn to the AI. **Feel** is too easy / about right / too hard.")
    md.append("")
    md.append("| Fight | Rating | Plays | Won | Got away | Bench target | Rounds (median) | Auto | Feel | |")
    md.append("|---|---|---|---|---|---|---|---|---|---|")
    by = defaultdict(list)
    for r in plays:
        by[r.get(id_key, "?")].append(r)
    fby = defaultdict(Counter)
    for f in feels:
        fby[f.get(id_key, "?")][f.get("verdict")] += 1
    for fid in sorted(by, key=lambda k: (-len(by[k]), k)):
        rs = by[fid]
        rating = rs[0].get("rating", "?")
        won = sum(1 for r in rs if r.get("winner") == "party")
        away = sum(1 for r in rs if r.get("winner") in ("fled", "escaped"))
        acts = Counter()
        for r in rs:
            acts.update(r.get("actions", {}))
        total_acts = sum(acts.values())
        t = targets.get(rating)
        target = f"{round(t[0] * 100)}–{round(t[1] * 100)}%" if t else "–"
        flag = ""
        if t and len(rs) >= 10:
            rate = won / len(rs)
            flag = "below" if rate < t[0] else ("above" if rate > t[1] else "in range")
        fc = fby[fid]
        votes = sum(fc[v] for v in VERDICTS)
        if votes < 3:
            pass   # too few votes to call it
        elif fc["too_hard"] > fc["about_right"] + fc["too_easy"]:
            flag = (flag + ", " if flag else "") + "**feels too hard**"
        elif fc["too_easy"] > fc["about_right"] + fc["too_hard"]:
            flag = (flag + ", " if flag else "") + "**feels too easy**"
        md.append(f"| {names.get(fid, fid)} | {rating} | {len(rs)} | {pct(won, len(rs))} | {away} | {target} | "
                  f"{median([r.get('rounds', 0) for r in rs])} | {pct(acts['auto'], total_acts)} | {feel_cell(fc)} | {flag} |")
    md.append("")
    md.append("Win rates are flagged against the target from 10 plays up, and feel from 3 votes up; fewer are too few to say.")
    md.append("")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("paths", nargs="+", help="log.jsonl files, or folders to search for *.jsonl")
    ap.add_argument("-o", "--out", help="write the report here (default: print it)")
    args = ap.parse_args()

    files, recs, bad, dupes = load(args.paths)
    with open(os.path.join(ROOT, "data/rules/battle.json"), encoding="utf-8") as fh:
        targets = json.load(fh)["encounter_targets"]
    with open(os.path.join(ROOT, "data/units/units.json"), encoding="utf-8") as fh:
        units = json.load(fh)
    with open(os.path.join(ROOT, "data/events/events.json"), encoding="utf-8") as fh:
        events = {e["id"]: e for e in json.load(fh)["events"]}
    with open(os.path.join(ROOT, "data/world/holds.json"), encoding="utf-8") as fh:
        holds = {h["id"]: h["name"] for h in json.load(fh)["holds"]}
    enc_names = {e["id"]: e["name"] for e in units["encounters"]}
    cv_names = {c["id"]: c["name"] for c in units["convoys"]}

    md = ["# Playtest report", ""]
    sessions = {r["session"] for r in recs if "session" in r}
    builds = Counter(r.get("build", "?") for r in recs if r["kind"] == "session")
    oses = Counter(r.get("os", "?") for r in recs if r["kind"] == "session")
    md.append(f"{len(files)} log file(s), {len(recs)} records, {len(sessions)} play session(s)."
              + (f" {bad} unreadable line(s) skipped." if bad else "")
              + (f" {dupes} duplicate record(s) skipped." if dupes else ""))
    if builds:
        md.append("")
        md.append("Builds: " + ", ".join(f"{b} ({n})" for b, n in builds.most_common())
                  + ". Systems: " + ", ".join(f"{o} ({n})" for o, n in oses.most_common()) + ".")
    secs = sum(r.get("seconds", 0) for r in recs if r["kind"] in ("skirmish", "road_war"))
    if secs:
        md.append("")
        md.append(f"Time in battles: {round(secs / 60)} minutes.")
    md.append("")

    battle_section(md, recs, "skirmish", "encounter", enc_names, targets)
    battle_section(md, recs, "road_war", "convoy", cv_names, targets)

    # Journeys
    md.append("## Journeys")
    md.append("")
    starts = [r for r in recs if r["kind"] == "journey_start"]
    ends = [r for r in recs if r["kind"] == "journey_end"]
    if not starts:
        md.append("No journeys logged.")
    else:
        md.append("| Route | Level | Started | Arrived | Abandoned | Days (median) | Expected days | Battles fought / auto | Defeats | Feel |")
        md.append("|---|---|---|---|---|---|---|---|---|---|")
        routes = defaultdict(lambda: {"starts": 0, "ends": [], "fought": 0, "auto": 0, "feel": Counter()})
        seeds_route = {}
        for r in starts:
            key = (r["from"], r["to"], r.get("level", 0))
            routes[key]["starts"] += 1
            seeds_route[(r["session"], r.get("seed"))] = key
        for r in ends:
            routes[(r["from"], r["to"], r.get("level", 0))]["ends"].append(r)
        for r in recs:
            if r["kind"] == "journey_battle":
                key = seeds_route.get((r["session"], r.get("journey_seed")))
                if key:
                    routes[key]["fought" if r.get("mode") == "fought" else "auto"] += 1
            elif r["kind"] == "feel" and r.get("about") == "journey":
                routes[(r["from"], r["to"], r.get("level", 0))]["feel"][r.get("verdict")] += 1
        for key in sorted(routes, key=lambda k: -routes[k]["starts"]):
            v = routes[key]
            done = [e for e in v["ends"] if not e.get("abandoned")]
            arrived = sum(1 for e in done if e.get("arrived"))
            abandoned = sum(1 for e in v["ends"] if e.get("abandoned"))
            expected = median([e.get("expected_days", 0) for e in done])
            md.append(f"| {holds.get(key[0], key[0])} to {holds.get(key[1], key[1])} | {key[2]} | {v['starts']} | {arrived} | {abandoned} | "
                      f"{median([e.get('days', 0) for e in done])} | {expected} | {v['fought']} / {v['auto']} | "
                      f"{sum(e.get('defeats', 0) for e in done)} | {feel_cell(v['feel'])} |")
    md.append("")

    # Event cards
    cards = [r for r in recs if r["kind"] == "card"]
    md.append("## Event cards")
    md.append("")
    if not cards:
        md.append("No cards logged.")
        md.append("")
    else:
        md.append("What players picked on each card (choices in the card's order), and for the choices with a "
                  "check, the chance shown against how often it actually succeeded.")
        md.append("")
        md.append("| Card | Tone | Seen | Picks | Checks taken | Chance shown (mean) | Succeeded |")
        md.append("|---|---|---|---|---|---|---|")
        by = defaultdict(list)
        for r in cards:
            by[r["event"]].append(r)
        for eid in sorted(by, key=lambda k: (-len(by[k]), k)):
            rs = by[eid]
            n_choices = max(len(r.get("chances", [])) for r in rs)
            picks = Counter(r.get("picked") for r in rs)
            checks = [r for r in rs if r.get("check")]
            shown = round(statistics.mean(r["chance"] for r in checks)) if checks else "–"
            ok = sum(1 for r in checks if r.get("success"))
            md.append(f"| {eid} | {events.get(eid, {}).get('tone', rs[0].get('tone', '?'))} | {len(rs)} | "
                      f"{' / '.join(str(picks[i]) for i in range(n_choices))} | {len(checks)} | "
                      f"{shown if shown == '–' else str(shown) + '%'} | {pct(ok, len(checks))} |")
        md.append("")
        # Calibration: are the shown chances honest?
        checks = [r for r in cards if r.get("check")]
        md.append("### Are the shown chances honest?")
        md.append("")
        if not checks:
            md.append("No checks taken yet.")
        else:
            md.append("Every check taken, grouped by the chance shown. With enough checks, each row's success rate should "
                      "sit close to its mean chance. A big, steady gap means the shown numbers mislead.")
            md.append("")
            md.append("| Chance shown | Checks | Mean shown | Succeeded |")
            md.append("|---|---|---|---|")
            buckets = defaultdict(list)
            for r in checks:
                b = min(int(r["chance"]) // 20, 4)
                buckets[b].append(r)
            for b in sorted(buckets):
                rs = buckets[b]
                hi = 100 if b == 4 else b * 20 + 19
                md.append(f"| {b * 20}–{hi}% | {len(rs)} | {round(statistics.mean(r['chance'] for r in rs))}% | "
                          f"{pct(sum(1 for r in rs if r.get('success')), len(rs))} |")
        md.append("")

    out = "\n".join(md) + "\n"
    if args.out:
        os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
        with open(args.out, "w", encoding="utf-8") as fh:
            fh.write(out)
        print(f"wrote {args.out}")
    else:
        sys.stdout.write(out)


if __name__ == "__main__":
    main()
