#!/bin/bash
REPO_SLUG="${SILENTGUARD_GITHUB_REPO:-OptimusFaber/SilentGuard}"
text="$(curl -s -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/${REPO_SLUG}/releases/tags/${INPUT_VERSION}")"
asset_res="$(echo "$text"  | jq '.assets[] | select(.browser_download_url | endswith(".tar.xz"))')"
url_res="$(echo "$asset_res" | jq -r '.browser_download_url' | sed "s~$INPUT_VERSION~\${pkgver}~g")"
sha_res="$(echo "$asset_res" | jq -r '.digest' | sed 's~sha256:~~g')"

curl -L -o PKGBUILD "https://raw.githubusercontent.com/${REPO_SLUG}/refs/heads/main/PKGBUILD"
sed -i "s@pkgver=.*@pkgver=${INPUT_VERSION}@g; s@sha256sums=(.*@sha256sums=(\"$sha_res\")@g; s@source=(.*@source=(\"$url_res\")@g;" ./PKGBUILD
mkdir aur_git ||:
install -Dm644 PKGBUILD aur_git/PKGBUILD
sed -i "s@sha256sums=(.*@sha256sums=()@g; s@source=(.*@source=()@g;" ./aur_git/PKGBUILD
