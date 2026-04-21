
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
