#!/usr/bin/env python3
"""
Regenerate PNG/ICO assets from SVG sources committed under res/brand/svg and res/theme-svg.

The rasterization is done by Node (resvg). Run once after cloning or changing SVGs:

    cd tools && npm install && npm run render

Optional: regenerate silentguard.ico from res/public/logo-for-ico.png (requires Pillow; run tools/npm run render first):

    python3 script/sync_images_from_brand.py --ico-only
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
RENDER = TOOLS / "render-assets.mjs"


def run_render() -> int:
    if not RENDER.is_file():
        print(f"Missing {RENDER}", file=sys.stderr)
        return 1
    r = subprocess.run(
        ["npm", "run", "render"],
        cwd=str(TOOLS),
        check=False,
    )
    return r.returncode


def make_ico() -> int:
    try:
        from PIL import Image
    except ImportError:
        print("Pillow not installed; skip ICO", file=sys.stderr)
        return 0
    logo = ROOT / "res" / "public" / "logo-for-ico.png"
    if not logo.is_file():
        print(f"Missing {logo}", file=sys.stderr)
        return 1
    im = Image.open(logo).convert("RGBA")
    sizes = [(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)]
    ims = [im.resize(s, Image.Resampling.LANCZOS) for s in sizes]
    out = ROOT / "res" / "silentguard.ico"
    ims[0].save(
        out,
        format="ICO",
        sizes=[(i.width, i.height) for i in ims],
        append_images=ims[1:],
    )
    print("OK:", out)
    return 0


def main() -> int:
    if "--ico-only" in sys.argv:
        return make_ico()
    code = run_render()
    if code != 0:
        return code
    return make_ico()


if __name__ == "__main__":
    raise SystemExit(main())
