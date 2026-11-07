"""Audit glyphs used by the app so Inter fonts can be subset safely."""

import pathlib

chars = set()
for p in list(pathlib.Path("lib").rglob("*.dart")) + \
        list(pathlib.Path("lib").rglob("*.arb")):
    t = p.read_text(encoding="utf-8", errors="ignore")
    for ch in t:
        if ord(ch) > 127 or (
                not ch.isalnum() and ch not in " \t\n\r\"'()[]{}<>._-/@:;,.!?#%*+=|&^~`"):
            chars.add(ch)
out = [f"distinct non-alnum chars: {len(chars)}"]
out += [f"U+{ord(ch):04X} U+{ord(ch):04X}" for ch in sorted(chars)]
pathlib.Path("tool/glyphs.txt").write_text("\n".join(out) + "\n", encoding="utf-8")
print("\n".join(out))
