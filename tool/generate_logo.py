"""Generate the Lekas launcher icons and in-app logo from one master drawing.

Design: a bold white checkmark (a finished task, quick) over a diagonal
indigo (0xFF6366F1) to violet (0xFF8B5CF6) gradient, the same accent the
app ships with. The check gets a soft offset shadow so it stays readable
at 48px. (The first version used a bolt; the check replaced it in v1.5.1
because it reads better at small sizes.)

Outputs (run with `python tool/generate_logo.py`):
  android/app/src/main/res/mipmap-*/ic_launcher{,_round}.png (legacy sizes)
  assets/branding/logo.png (in-app, rounded square with transparency)
  assets/branding/lekas_logo.svg is the hand-written vector source; the
  adaptive icon drawables (drawable/ic_launcher_background.xml and
  ic_launcher_foreground.xml) carry the same geometry, so the three never
  drift.

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

# Check polyline in 1024px master space. A single two-stroke check with
# round caps, wide enough to read at 48px, with a short first arm.
CHECK_1024 = [
    (275, 540),   # left tip
    (455, 725),   # low point
    (765, 315),   # right tip
]
CHECK_WIDTH = 128


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


def _check(d: ImageDraw.ImageDraw, scale: float, fill, offset: int = 0) -> None:
    """Draw the check as a thick polyline with round joints and caps."""
    # Joint circle first so the low bend is round, then both segments.
    pts = [(x * scale + offset, y * scale + offset) for x, y in CHECK_1024]
    # Shadow copy, offset down right, used beneath the white check.
    d.line(pts, fill=fill, width=round(CHECK_WIDTH * scale), joint="curve")
    r = CHECK_WIDTH * scale / 2
    for x, y in pts:
        d.ellipse([x - r, y - r, x + r, y + r], fill=fill)


def draw_check(base: Image.Image, scale: float, shadow: bool = True) -> Image.Image:
    """Draw the white check (with soft shadow) onto a copy of base."""
    layer = base.copy()
    w, h = layer.size

    if shadow:
        ghost = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        d = ImageDraw.Draw(ghost)
        _check(d, scale, (30, 27, 75, 90), offset=round(14 * scale))
        ghost = ghost.filter(ImageFilter.GaussianBlur(8 * scale))
        layer = Image.alpha_composite(layer.convert("RGBA"), ghost)

    mark = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(mark)
    _check(d, scale, (255, 255, 255, 255))
    layer = Image.alpha_composite(layer.convert("RGBA"), mark)
    return layer


def render_master(size: int, rounded: bool = False) -> Image.Image:
    """One icon at the given size, supersampled 3x for antialiased edges."""
    ss = 3
    big = gradient(size * ss, size * ss)
    im = draw_check(big, (size * ss) / 1024)
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
    # CHECK_1024 documents the same geometry in 1024px space. The in-app
    # logo is a rounded square with transparent corners.

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
