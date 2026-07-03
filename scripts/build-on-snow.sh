#!/bin/sh
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC="$ROOT/src/IOUSBFamily-560-SnowUSB3"
CONFIGURATION=${CONFIGURATION:-Deployment}
ARCHS_VALUE=${ARCHS:-x86_64}
VALID_ARCHS_VALUE=${VALID_ARCHS:-x86_64}
STAGED_HEADERS="$SRC/build/$CONFIGURATION/include/IOKit/usb"

if [ ! -d "$SRC" ]; then
  echo "missing source tree: $SRC" >&2
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild not found; build on Mac OS X 10.6.8 with Xcode 4.2" >&2
  exit 1
fi

mkdir -p "$STAGED_HEADERS"
cp "$SRC"/IOUSBFamily/Headers/*.h "$STAGED_HEADERS"/
cp "$SRC"/IOUSBUserClient/Headers/*.h "$STAGED_HEADERS"/
cp "$SRC"/AppleUSBHub/Headers/*.h "$STAGED_HEADERS"/

cd "$SRC"
xcodebuild -project IOUSBFamily.xcodeproj \
  -target IOUSBFamily_kexts \
  -configuration "$CONFIGURATION" \
  ARCHS="$ARCHS_VALUE" \
  VALID_ARCHS="$VALID_ARCHS_VALUE" \
  build

echo "built products:"
find "$SRC/build/$CONFIGURATION" -maxdepth 1 -type d -name '*.kext' -print | sort
