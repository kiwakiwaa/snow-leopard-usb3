#!/bin/sh
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC="$ROOT/src/IOUSBFamily-560-SnowUSB3"
CONFIGURATION=${CONFIGURATION:-Deployment}
BUILD="$SRC/build/$CONFIGURATION"
STOCK_IOUSB=${STOCK_IOUSB:-/System/Library/Extensions/IOUSBFamily.kext}
PKG=${1:-"$ROOT/packaging/SnowUSB3-FL1100-AppleXHCI"}
KEXTS="$PKG/kexts"

need_kext() {
  if [ ! -d "$1" ]; then
    echo "missing kext: $1" >&2
    echo "run scripts/build-on-snow.sh first" >&2
    exit 1
  fi
}

need_kext "$BUILD/IOUSBFamily.kext"
need_kext "$BUILD/AppleUSBHub.kext"
need_kext "$BUILD/IOUSBUserClient.kext"
need_kext "$BUILD/AppleUSBXHCI.kext"
need_kext "$STOCK_IOUSB"

rm -rf "$PKG"
mkdir -p "$KEXTS"

ditto "$STOCK_IOUSB" "$KEXTS/IOUSBFamily.kext"
ditto "$BUILD/IOUSBFamily.kext/Contents/MacOS/IOUSBFamily" \
  "$KEXTS/IOUSBFamily.kext/Contents/MacOS/IOUSBFamily"
cp "$BUILD/IOUSBFamily.kext/Contents/Info.plist" \
  "$KEXTS/IOUSBFamily.kext/Contents/Info.plist"
ditto "$BUILD/AppleUSBHub.kext" \
  "$KEXTS/IOUSBFamily.kext/Contents/PlugIns/AppleUSBHub.kext"
ditto "$BUILD/IOUSBUserClient.kext" \
  "$KEXTS/IOUSBFamily.kext/Contents/PlugIns/IOUSBUserClient.kext"
ditto "$BUILD/AppleUSBXHCI.kext" "$KEXTS/AppleUSBXHCI.kext"

chmod -R go-w "$KEXTS"/*.kext
chmod -R a+rX "$KEXTS"/*.kext

echo "package created: $PKG"
find "$KEXTS" -maxdepth 2 -type d -name '*.kext' -print | sort
