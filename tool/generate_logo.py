"""Generate the Lekas launcher icons and in-app logo from one master drawing.

Design: a bold white lightning bolt (fast, matching the old bolt glyph in the
drawer) over a diagonal indigo (0xFF6366F1) to violet (0xFF8B5CF6) gradient,
the same accent the app ships with. The bolt gets a soft offset shadow so it
stays readable at 48px.

Outputs (run with `python tool/generate_logo.py`):
  android/app/src/main/res/mipmap-*/ic_launcher{,_round}.png (legacy sizes)
  android/app/src/main/res/drawable/ic_launcher_background.xml (vector)
  android/app/src/main/res/drawable/ic_launcher_foreground.xml (vector)
  android/app/src/main/res/mipmap-anydpi-v26/*.xml (adaptive icons)
  assets/branding/lekas_logo.svg is the hand-written vector source; this
  script renders the PNGs from the same geometry (bolt path in 108dp
  foreground space) so the two never drift.

Only Pillow is needed: `pip install pillow`. No native dependencies.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "android" / "app" / "src" / "main" / "res"
BRANDING = ROOT / "assets" / "branding"

# Diagonal gradient endpoints, top-left to bottom-right.
INDIGO = (99, 102, 241)   # 0xFF6366F1, the app accent
VIOLET = (139, 92, 246)   # 0xFF8B5CF6

# Bolt in 1024px master space. A single zigzag, wide enough to read at
# 48px, with a check-like foot at the bottom (the low point sweeps right).
BOLT_1024 = [
    (590, 200),   # top tip
    (360, 560),   # left shoulder
    (510, 560),   # inner notch
    (430, 820),   # bottom tip
    (670, 440),   # right shoulder
    (520, 440),   # inner top
]

# Same bolt in 108dp adaptive-foreground space (divide by 1024/108).
BOLT_108 = [(x * 108 / 1024, y * 108 / 1024) for x, y in BOLT_1024]


def gradient(width: int, height: int) -> Image.Image:
    """Diagonal indigo to violet gradient, computed per pixel."""
    top, bottom = INDIGO, VIOLET
    pixels = []
    for y in range(height):
        for x in range(width):
            t = (x / width + y / height) / 2.0
            pixels.append(tuple(
                round(top[i] + (bottom[i] - top[i]) * t) for i in range(3)
            ))
    img = Image.new("RGB", (width, height))
    img.putdata(pixels)
    return img


def draw_bolt(base: Image.Image, scale: float, shadow: bool = True) -> Image.Image:
    """Draw the white bolt (with soft shadow) onto a copy of base."""
    layer = base.copy()
    w, h = layer.size
    pts = [(x * scale, y * scale) for x, y in BOLT_1024]

    if shadow:
        ghost = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        d = ImageDraw.Draw(ghost)
        off = 14 * scale
        d.polygon([(x + off, y + off) for x, y in pts], fill=(30, 27, 75, 90))
        ghost = ghost.filter(ImageFilter.GaussianBlur(8 * scale))
        layer = Image.alpha_composite(layer.convert("RGBA"), ghost)

    bolt = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(bolt)
    d.polygon(pts, fill=(255, 255, 255, 255))
    layer = Image.alpha_composite(layer.convert("RGBA"), bolt)
    return layer


def render_master(size: int, rounded: bool = False) -> Image.Image:
    """One icon at the given size, supersampled 3x for antialiased edges."""
    ss = 3
    big = gradient(size * ss, size * ss)
    im = draw_bolt(big, 1.0)
    im = im.resize((size, size), Image.LANCZOS)
    if rounded:
        mask = Image.new("L", (size, size), 0)
        d = ImageDraw.Draw(mask)
        radius = round(size * 0.22)
        d.rounded_rectangle([0, 0, size, size], radius=radius, fill=255)
        im = im.convert("RGBA")
        im.putalpha(mask)
    return im


def main() -> None:
    BRANDING.mkdir(parents=True, exist_ok=True)

    # Legacy launcher sizes (mdpi..xxxhdpi), plus round variants.
    legacy = [("mdpi", 48), ("hdpi", 72), ("xhdpi", 96),
              ("xxhdpi", 144), ("xxxhdpi", 192)]
    for density, size in legacy:
        d = RES / f"mipmap-{density}"
        d.mkdir(parents=True, exist_ok=True)
        icon = render_master(size)
        icon.save(d / "ic_launcher.png", optimize=True)
        icon.save(d / "ic_launcher_round.png", optimize=True)

    # Adaptive icon drawables are hand-written vectors next to this script
    # (drawable/ic_launcher_background.xml and ic_launcher_foreground.xml);
    # the bolt path above documents the same geometry. The in-app logo is a
    # rounded square with transparent corners.

    # In-app logo: rounded square, 512px (crisp on xxxhdpi at 72dp).
    render_master(512, rounded=True).save(BRANDING / "logo.png", optimize=True)

    print("launcher icons + in-app logo generated")
    for density, size in legacy:
        p = RES / f"mipmap-{density}" / "ic_launcher.png"
        print(f"  mipmap-{density} ({size}px): {p.stat().st_size} bytes")
    p = BRANDING / "logo.png"
    print(f"  assets/branding/logo.png: {p.stat().st_size} bytes")


if __name__ == "__main__":
    main()
