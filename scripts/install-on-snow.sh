#!/bin/sh
set -eu

if [ "$(id -u)" != "0" ]; then
  echo "run with sudo" >&2
  exit 1
fi

PKG=${1:-}
if [ -z "$PKG" ]; then
  echo "usage: sudo scripts/install-on-snow.sh packaging/SnowUSB3-FL1100-AppleXHCI" >&2
  exit 1
fi

KEXTS="$PKG/kexts"
SLE=/System/Library/Extensions
IOUSB_DST="$SLE/IOUSBFamily.kext"
XHCI_DST="$SLE/AppleUSBXHCI.kext"
GENERIC_DST="$SLE/GenericUSBXHCI.kext"
TS=$(date +%Y%m%d-%H%M%S)
RB="/SnowUSB3AppleXHCIRollback-$TS"

if [ ! -d "$KEXTS/IOUSBFamily.kext" ] || [ ! -d "$KEXTS/AppleUSBXHCI.kext" ]; then
  echo "package missing kexts: $KEXTS" >&2
  exit 1
fi

mkdir -p "$RB"
ditto "$IOUSB_DST" "$RB/IOUSBFamily.kext.previous"
if [ -d "$XHCI_DST" ]; then
  ditto "$XHCI_DST" "$RB/AppleUSBXHCI.kext.previous"
fi
if [ -d "$GENERIC_DST" ]; then
  ditto "$GENERIC_DST" "$RB/GenericUSBXHCI.kext.previous"
fi

cat > "$RB/rollback.sh" <<'SH'
#!/bin/sh
set -eu
SLE=/System/Library/Extensions
RB=$(cd "$(dirname "$0")" && pwd)

kextunload -b com.apple.driver.AppleUSBXHCI 2>/dev/null || true
kextunload -b net.osx86.kexts.GenericUSBXHCI 2>/dev/null || true

rm -rf "$SLE/AppleUSBXHCI.kext"
if [ -d "$RB/AppleUSBXHCI.kext.previous" ]; then
  ditto "$RB/AppleUSBXHCI.kext.previous" "$SLE/AppleUSBXHCI.kext"
fi

rm -rf "$SLE/GenericUSBXHCI.kext"
if [ -d "$RB/GenericUSBXHCI.kext.previous" ]; then
  ditto "$RB/GenericUSBXHCI.kext.previous" "$SLE/GenericUSBXHCI.kext"
fi

rm -rf "$SLE/IOUSBFamily.kext"
ditto "$RB/IOUSBFamily.kext.previous" "$SLE/IOUSBFamily.kext"

chown -R root:wheel "$SLE/IOUSBFamily.kext"
chmod -R go-w "$SLE/IOUSBFamily.kext"
chmod -R a+rX "$SLE/IOUSBFamily.kext"
if [ -d "$SLE/AppleUSBXHCI.kext" ]; then
  chown -R root:wheel "$SLE/AppleUSBXHCI.kext"
  chmod -R go-w "$SLE/AppleUSBXHCI.kext"
  chmod -R a+rX "$SLE/AppleUSBXHCI.kext"
fi
if [ -d "$SLE/GenericUSBXHCI.kext" ]; then
  chown -R root:wheel "$SLE/GenericUSBXHCI.kext"
  chmod -R go-w "$SLE/GenericUSBXHCI.kext"
  chmod -R a+rX "$SLE/GenericUSBXHCI.kext"
fi

touch "$SLE"
kextcache -system-prelinked-kernel || true
kextcache -system-caches || true
echo "rollback complete; reboot now"
SH
chmod 755 "$RB/rollback.sh"
ln -sfn "$RB" /SnowUSB3AppleXHCIRollback

kextunload -b net.osx86.kexts.GenericUSBXHCI 2>/dev/null || true
rm -rf "$GENERIC_DST"

rm -rf "$IOUSB_DST" "$XHCI_DST"
ditto "$KEXTS/IOUSBFamily.kext" "$IOUSB_DST"
ditto "$KEXTS/AppleUSBXHCI.kext" "$XHCI_DST"

chown -R root:wheel "$IOUSB_DST" "$XHCI_DST"
chmod -R go-w "$IOUSB_DST" "$XHCI_DST"
chmod -R a+rX "$IOUSB_DST" "$XHCI_DST"

kextutil -nt "$IOUSB_DST"
kextutil -nt "$XHCI_DST"

touch "$SLE"
kextcache -system-prelinked-kernel
kextcache -system-caches

echo "installed Snow USB3 AppleXHCI stack"
echo "rollback: /SnowUSB3AppleXHCIRollback/rollback.sh"
echo "reboot now"
