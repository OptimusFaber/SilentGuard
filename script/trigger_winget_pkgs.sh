#!/bin/bash

REPO_SLUG="${SILENTGUARD_GITHUB_REPO:-OptimusFaber/SilentGuard}"
APP_PUBLISHER="${WINGET_APP_PUBLISHER:-${REPO_SLUG%%/*}}"

USERNAME="${WINGET_PKGS_USERNAME:-OptimusFaber}"
REPONAME='winget-pkgs'
REPO="$USERNAME/$REPONAME"
UPSTREAM_OWNER="microsoft"
BASE_BRANCH="master"
PROGID="SilentGuard"
A="$(printf '%s' "$APP_PUBLISHER" | head -c 1 | tr '[:upper:]' '[:lower:]')"
OLDVER='OldVer'

OLD_SHA_32='OldSha32'
OLD_SHA_64='OldSha64'
OLD_SHA_ARM64='OldShaArm'
OLD_DATE='OldDate'

text="$(curl -s -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/${REPO_SLUG}/releases/tags/$INPUT_VERSION")"
asset_res="$(echo "$text"  | jq '.assets[] | select( .name | endswith("installer.exe") )')"

PATTERN="s~$OLDVER~$INPUT_VERSION~g;s~$OLD_DATE~$(date +%Y-%m-%d)~g;"

PATTERN="${PATTERN}$(echo $asset_res | jq -r '"\(.name)_\(.digest | ascii_upcase)"' | sed "s~.*windows32.*:\(.*\)~s@$OLD_SHA_32@\1@g;~g;s~.*windows-arm64.*:\(.*\)~s@$OLD_SHA_ARM64@\1@g;~g;s~.*windows64.*:\(.*\)~s@$OLD_SHA_64@\1@g;~g;" | sed ':a;N;$!ba;s/\n//g')"

MANIFEST1='# yaml-language-server: $schema=https://aka.ms/winget-manifest.version.1.10.0.schema.json

PackageIdentifier: PUBLISHER_PLACEHOLDER.SilentGuard
PackageVersion: OldVer
DefaultLocale: en-US
ManifestType: version
ManifestVersion: 1.10.0

'

MANIFEST2='# yaml-language-server: $schema=https://aka.ms/winget-manifest.installer.1.10.0.schema.json

PackageIdentifier: PUBLISHER_PLACEHOLDER.SilentGuard
PackageVersion: OldVer
InstallerLocale: en-US
InstallerType: nullsoft
Scope: user
ProductCode: SilentGuard
ReleaseDate: OldDate
AppsAndFeaturesEntries:
- ProductCode: SilentGuard
  DisplayName: SilentGuard
  Publisher: PUBLISHER_PLACEHOLDER
InstallModes:
  - silentWithProgress
  - silent
InstallerSwitches:
  Silent: "/S /NOSCRIPT=1 /WINGET=1"
  SilentWithProgress: "/S /NOSCRIPT=1 /WINGET=1"
InstallationMetadata:
  DefaultInstallLocation: '"'"'%AppData%\SilentGuard'"'"'
Installers:
- Architecture: x64
  InstallerUrl: https://github.com/GITHUB_REPO_PLACEHOLDER/releases/download/OldVer/silentguard-OldVer-windows64-installer.exe
  InstallerSha256: OldSha64
- Architecture: arm64
  InstallerUrl: https://github.com/GITHUB_REPO_PLACEHOLDER/releases/download/OldVer/silentguard-OldVer-windows-arm64-installer.exe
  InstallerSha256: OldShaArm
ManifestType: installer
ManifestVersion: 1.10.0

'

#- Architecture: x86
#  InstallerUrl: https://github.com/GITHUB_REPO_PLACEHOLDER/releases/download/OldVer/silentguard-OldVer-windows32-installer.exe
#  InstallerSha256: OldSha32

MANIFEST3='# yaml-language-server: $schema=https://aka.ms/winget-manifest.defaultLocale.1.10.0.schema.json
PackageIdentifier: PUBLISHER_PLACEHOLDER.SilentGuard
PackageVersion: OldVer
PackageLocale: en-US
Publisher: PUBLISHER_PLACEHOLDER
PublisherUrl: https://github.com/PUBLISHER_PLACEHOLDER
PublisherSupportUrl: https://github.com/GITHUB_REPO_PLACEHOLDER/issues
PackageName: SilentGuard
PackageUrl: https://github.com/GITHUB_REPO_PLACEHOLDER
License: GPL-3.0
LicenseUrl: https://github.com/GITHUB_REPO_PLACEHOLDER/blob/HEAD/LICENSE
ShortDescription: Cross-platform GUI proxy utility (sing-box)
Tags:
- sing-box
- v2ray
- VLESS
- Vmess
- ShadowSocks
- Tor
- Mieru
- Trojan
- Hysteria
- Wireguard
- TUIC
- SSH
- VPN
- ShadowTLS
- AnyTLS
ManifestType: defaultLocale
ManifestVersion: 1.10.0

'

MANIFEST1="$(echo "$MANIFEST1" | sed "s~PUBLISHER_PLACEHOLDER~${APP_PUBLISHER}~g;s~GITHUB_REPO_PLACEHOLDER~${REPO_SLUG}~g" | sed "$PATTERN")"
MANIFEST2="$(echo "$MANIFEST2" | sed "s~PUBLISHER_PLACEHOLDER~${APP_PUBLISHER}~g;s~GITHUB_REPO_PLACEHOLDER~${REPO_SLUG}~g" | sed "$PATTERN")"
MANIFEST3="$(echo "$MANIFEST3" | sed "s~PUBLISHER_PLACEHOLDER~${APP_PUBLISHER}~g;s~GITHUB_REPO_PLACEHOLDER~${REPO_SLUG}~g" | sed "$PATTERN")"


BRANCH_NAME="SilentGuard-branch-$INPUT_VERSION-$(date +'%Y%m%d%H%M%S')"
FILE_DIR="manifests/${A}/${APP_PUBLISHER}/${PROGID}/${INPUT_VERSION}"

BASE_SHA=$(gh api "repos/$REPO/git/refs/heads/$BASE_BRANCH" -q .object.sha)
gh api -X POST "repos/$REPO/git/refs" -f "ref=refs/heads/$BRANCH_NAME" -f "sha=$BASE_SHA" | cat

echo "FINE"

upload_gh(){
  local SHA
  local FILE_PATH="$1"
  SHA="$(gh api "repos/$REPO/contents/$FILE_PATH?ref=$BRANCH_NAME" -q .sha)" || SHA="null"
  local FILE_CONTENT="$2"
  local COMMIT_MESSAGE="update"
  local ENCODED_CONTENT="$(echo -n "$FILE_CONTENT" | base64)"
  if [ "$SHA" == "null" ]; then
    gh api -X PUT "repos/$REPO/contents/$FILE_PATH" -f message="$COMMIT_MESSAGE" -f branch="$BRANCH_NAME" -f content="$ENCODED_CONTENT" | cat
  else
    gh api -X PUT "repos/$REPO/contents/$FILE_PATH" -f message="$COMMIT_MESSAGE" -f branch="$BRANCH_NAME" -f content="$ENCODED_CONTENT" -f sha="$SHA" | cat
  fi
}

upload_gh "$FILE_DIR/${APP_PUBLISHER}.${PROGID}.yaml" "$MANIFEST1"
upload_gh "$FILE_DIR/${APP_PUBLISHER}.${PROGID}.installer.yaml" "$MANIFEST2"
upload_gh "$FILE_DIR/${APP_PUBLISHER}.${PROGID}.locale.en-US.yaml" "$MANIFEST3"

echo
echo
echo "Create Pull Request"
# Create the pull request
gh api -X POST \
  repos/$UPSTREAM_OWNER/$REPONAME/pulls \
  -f title="SilentGuard $INPUT_VERSION Pull Request" \
  -f body="Automatic pull request" \
  -f head=$USERNAME:$BRANCH_NAME \
  -f base=$BASE_BRANCH | cat


