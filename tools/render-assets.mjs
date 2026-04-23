/**
 * Optional: rasterize a 256×256 PNG for silentguard.ico (Pillow in sync_images_from_brand.py).
 * Toolbar / theme assets are committed as SVG under res/brand/svg and res/theme-svg — run:
 *   cd tools && npm install && npm run render
 */
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { Resvg } from '@resvg/resvg-js'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const ROOT = path.resolve(__dirname, '..')
const BRAND = path.join(ROOT, 'res', 'brand', 'svg')

function renderPng(svgPath, outPng, width) {
  if (!fs.existsSync(svgPath)) {
    console.warn('skip missing', path.relative(ROOT, svgPath))
    return
  }
  const buf = fs.readFileSync(svgPath)
  const resvg = new Resvg(buf, {
    fitTo: { mode: 'width', value: width },
    font: { loadSystemFonts: true },
  })
  fs.mkdirSync(path.dirname(outPng), { recursive: true })
  fs.writeFileSync(outPng, resvg.render().asPng())
  console.log('ok', path.relative(ROOT, outPng))
}

function main() {
  if (!fs.existsSync(BRAND)) {
    console.error('Missing', BRAND)
    process.exit(1)
  }
  const blue = fs.existsSync(path.join(BRAND, 'logo-blue.svg'))
    ? path.join(BRAND, 'logo-blue.svg')
    : path.join(BRAND, 'logo-blue..svg')
  /* Raster for silentguard.ico — from blue mark SVG */
  renderPng(blue, path.join(ROOT, 'res/public/logo-for-ico.png'), 256)
  console.log('Done.')
}

main()
