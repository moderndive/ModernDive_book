#!/usr/bin/env python3
"""Assign a stable 4-character hash to each exercise (idempotent).

The hash is stored in the exercise YAML so it travels with the exercise across
renumbering AND prompt edits. Only exercises WITHOUT a `hash:` field get a new
one (content-derived from chapter+prompt, then frozen). Run from the repo root.
"""
import hashlib, string, glob, re, sys, yaml
ALPH = string.digits + string.ascii_lowercase  # base36

def hash4(text):
    h = int(hashlib.sha1(text.encode()).hexdigest(), 16)
    s = ""
    for _ in range(4):
        s += ALPH[h % 36]; h //= 36
    return s

# 1. collect existing hashes (for global-uniqueness when minting new ones)
files = sorted(glob.glob("exercises/[0-9][0-9].yml"))
existing = set()
for f in files:
    for e in yaml.safe_load(open(f)).get("exercises", []):
        if e.get("hash"):
            existing.add(e["hash"])

def mint(ch, prompt):
    base = f"{ch}:{prompt.strip()}"
    h = hash4(base); salt = 0
    while h in existing:                      # resolve rare collisions deterministically
        salt += 1; h = hash4(f"{base}#{salt}")
    existing.add(h)
    return h

# 2. insert `  hash: XXXX` after each `- ex_num: N` that lacks one
total_new = 0
for f in files:
    ch = int(re.search(r"(\d\d)\.yml$", f).group(1))
    doc = yaml.safe_load(open(f))
    by_num = {e["ex_num"]: e for e in doc.get("exercises", [])}
    lines = open(f).read().split("\n")
    out, i, n_new = [], 0, 0
    while i < len(lines):
        out.append(lines[i])
        m = re.match(r"^- ex_num: (\d+)\s*$", lines[i])
        if m:
            num = int(m.group(1)); ex = by_num.get(num, {})
            has_hash = (i + 1 < len(lines) and re.match(r"^  hash:", lines[i+1])) or ex.get("hash")
            if not has_hash:
                hh = mint(ch, str(ex.get("prompt", "")))
                out.append(f'  hash: "{hh}"')
                n_new += 1
        i += 1
    if n_new:
        open(f, "w").write("\n".join(out))
        total_new += n_new
        print(f"  {f}: +{n_new} hashes")
print(f"assigned {total_new} new hashes")
