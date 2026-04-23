
if [[ "$SILENTGUARD_ENV_DEPLOYED" != yes ]]; 
then

if [[ ! -f core/server/sing-box/box.go && -d .git ]]
then
  git submodule init ||:
  git submodule update ||:
fi
[[ -f .ENV ]] && . .ENV ||: 
SRC_ROOT="${SRC_ROOT:-$PWD}"
DEPLOYMENT="${DEPLOYMENT:-$SRC_ROOT/deployment}"
BUILD="${BUILD:-$SRC_ROOT/build}"
version_standalone="silentguard-$INPUT_VERSION"
archive_standalone="silentguard-unified-source-$INPUT_VERSION"
GOCMD="${GOCMD:-go}"

fi

# deploy_linux64.sh sources this file again with SILENTGUARD_ENV_DEPLOYED=yes; the block above is
# skipped then — ensure paths are never empty (empty DEPLOYMENT makes DEST="/linux-amd64" and
# artifacts land outside the bind mount).
: "${SRC_ROOT:=${PWD:-.}}"
: "${BUILD:=$SRC_ROOT/build}"
: "${version_standalone:=silentguard-${INPUT_VERSION:-0.0.0}}"
: "${archive_standalone:=silentguard-unified-source-${INPUT_VERSION:-0.0.0}}"
# If DEPLOYMENT is empty, "/", or the same path as SRC_ROOT (e.g. bad .ENV), bundles would land in
# the repo root and `find $DEPLOYMENT -type f` would match any tracked file — checks pass but
# ./deployment stays empty. Do not force "$SRC_ROOT/deployment" when SRC_ROOT is already under
# deployment/ (unified tarball build): then DEPLOYMENT must stay the parent .../deployment.
case "${DEPLOYMENT}" in
  ''|'/'|"$SRC_ROOT")
    DEPLOYMENT="$SRC_ROOT/deployment"
    ;;
esac
