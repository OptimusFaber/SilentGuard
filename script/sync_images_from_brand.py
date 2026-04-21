#!/usr/bin/env python3
"""Generate SilentGuard assets from D:\\vpn\\images (logos + white toolbar icons)."""
from __future__ import annotations

import os
import shutil
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
# Override with set SILENTGUARD_BRAND_DIR=... or place a sibling `images` folder next to SilentGuard.
IMAGES = Path(os.environ.get("SILENTGUARD_BRAND_DIR", str(ROOT.parent / "images")))
PUBLIC = ROOT / "res" / "public"
ICON_DIR = ROOT / "res" / "icon"
MATERIAL = ICON_DIR / "material"

# Toolbar icons: filename in images/ -> under res/icon/
ROOT_ICONS = [
    "dialog-question.png",
    "internet-web-browser.png",
    "network-routing.png",
    "network-server.png",
    "preferences.png",
    "system-run.png",
    "system-software-update.png",
    "system-security.png",
    "update.png",
]
MATERIAL_ICONS = [
    "cancel.png",
    "delete.png",
    "history.png",
    "lock-open-outline.png",
    "lock-outline.png",
    "swap-horizontal.png",
    "swap-vertical.png",
]


def rgba_to_white_silhouette(img: Image.Image) -> Image.Image:
    """Black/dark glyph on transparent -> white, same alpha (for dark UI)."""
    img = img.convert("RGBA")
    *_, a = img.split()
    w = Image.new("L", img.size, 255)
    return Image.merge("RGBA", (w, w, w, a))


def rgba_to_black_silhouette(img: Image.Image) -> Image.Image:
    """Light glyph on transparent -> black, same alpha (for light UI)."""
    img = img.convert("RGBA")
    *_, a = img.split()
    b = Image.new("L", img.size, 0)
    return Image.merge("RGBA", (b, b, b, a))


def main() -> int:
    if not IMAGES.is_dir():
        print(f"Missing brand folder: {IMAGES}", file=sys.stderr)
        return 1

    PUBLIC.mkdir(parents=True, exist_ok=True)
    MATERIAL.mkdir(parents=True, exist_ok=True)

    logo_src = IMAGES / "logo.png"
    mark_src = IMAGES / "logo-no-back-ground.png"
    if not logo_src.is_file():
        print(f"Missing {logo_src}", file=sys.stderr)
        return 1
    if not mark_src.is_file():
        print(f"Missing {mark_src}", file=sys.stderr)
        return 1

    shutil.copyfile(logo_src, PUBLIC / "logo.png")
    shutil.copyfile(logo_src, PUBLIC / "icon.png")

    mark = Image.open(mark_src).convert("RGBA")
    # Transparent-mark: white on dark themes
    rgba_to_white_silhouette(mark.copy()).save(PUBLIC / "logo-mark.png", "PNG")
    # Same mark in black for light themes
    rgba_to_black_silhouette(mark).save(PUBLIC / "logo-mark-light.png", "PNG")

    # Windows .ico from full logo (desktop / exe resource)
    ico_path = ROOT / "res" / "silentguard.ico"
    logo_im = Image.open(logo_src).convert("RGBA")
    # ICO: provide common sizes
    sizes = [(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)]
    images = [logo_im.resize(s, Image.Resampling.LANCZOS) for s in sizes]
    images[0].save(
        ico_path,
        format="ICO",
        sizes=[(im.width, im.height) for im in images],
        append_images=images[1:],
    )

    def process_icon(src: Path, dest: Path) -> None:
        im = Image.open(src).convert("RGBA")
        rgba_to_white_silhouette(im).save(dest, "PNG")

    for name in ROOT_ICONS:
        s = IMAGES / name
        if not s.is_file():
            print(f"skip missing {s}")
            continue
        process_icon(s, ICON_DIR / name)

    for name in MATERIAL_ICONS:
        s = IMAGES / name
        if not s.is_file():
            print(f"skip missing {s}")
            continue
        process_icon(s, MATERIAL / name)

    print("OK: public logos, logo-mark variants, silentguard.ico, white icons")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
