#!/usr/bin/env python3
"""Regenerate the exercise hash lookup CSV from the exercise YAMLs.

Columns: chapter, exercise, hash, prompt_start. Run from the repo root after any
renumbering — the hash is stored in each exercise's YAML, so the CSV's chapter
and exercise columns auto-update while each hash stays attached to its text.
"""
import csv, glob, re, yaml
rows = []
for f in sorted(glob.glob("exercises/[0-9][0-9].yml")):
    ch = int(re.search(r"(\d\d)\.yml$", f).group(1))
    for e in yaml.safe_load(open(f)).get("exercises", []):
        prompt = " ".join(str(e.get("prompt", "")).split())
        rows.append([ch, e["ex_num"], e.get("hash", ""), prompt[:80]])
rows.sort(key=lambda r: (r[0], r[1]))
with open("exercises/exercise_hashes.csv", "w", newline="") as fh:
    w = csv.writer(fh)
    w.writerow(["chapter", "exercise", "hash", "prompt_start"])
    w.writerows(rows)
print(f"wrote exercises/exercise_hashes.csv ({len(rows)} exercises)")
