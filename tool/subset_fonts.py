"""Subset the bundled Inter fonts to the glyphs the app actually uses.

The four stock Inter files weigh 1.6 MB combined, the largest asset group in
the APK. This script keeps ASCII, Latin-1, punctuation, arrows and Latin
Extended A (enough for every shipped string plus accented names), which
shrinks each file to roughly a tenth. Anything outside that range still
renders through the Android system fallback font, so user text with emoji or
other scripts keeps working.

Run once with `python tool/subset_fonts.py`. The full fonts stay in git
history before the first subset commit, and the script is idempotent:
subsetting a subset changes nothing. Requires `pip install fonttools`.
"""

from pathlib import Path

from fontTools import subset

ROOT = Path(__file__).resolve().parent.parent
FONTS = ROOT / "assets" / "fonts"

# ASCII, Latin-1 supplement (middle dot, accented names), general
# punctuation (curly quotes, bullets, ellipsis), arrows (right arrow) and
# Latin Extended A (diacritic letters). Gaps are intentional.
UNICODES = (
    list(range(0x20, 0x7F)) + list(range(0xA0, 0x100)) +
    list(range(0x2010, 0x2028)) + list(range(0x2190, 0x21A0)) +
    list(range(0x0100, 0x0180)) + list(range(0x20A0, 0x20C0)) +
    list(range(0x2600, 0x2700)) + list(range(0x2700, 0x27C0)) +
    list(range(0x3000, 0x3040))
)

options = subset.Options()
options.layout_features = ["*"]
options.flavor = None
options.with_zopfli = False
options.no_hinting = True
options.desubroutinize = True
options.name_IDs = ["*"]
options.notdef_outline = False

for name in ["Inter-Regular.ttf", "Inter-Medium.ttf",
             "Inter-SemiBold.ttf", "Inter-Bold.ttf"]:
    src = FONTS / name
    before = src.stat().st_size
    font = subset.load_font(str(src), options)
    ss = subset.Subsetter(options)
    ss.populate(unicodes=UNICODES)
    ss.subset(font)
    font.save(str(src))
    after = src.stat().st_size
    print(f"{name}: {before} -> {after} bytes ({100 * after // before}%)")
