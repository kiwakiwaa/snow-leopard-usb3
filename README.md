# Snow Leopard USB 3.0 for FL1100 Thunderbolt Docks

This repository contains a Snow Leopard back-port of Apple's open-source
`IOUSBFamily-560` USB stack plus Apple's `AppleUSBXHCI` driver made to build for
Mac OS X 10.6.8 and limited to Fresco Logic FL1100 USB 3.0 controllers.

Tested target:
- Mac OS X 10.6.8 Snow Leopard 10K549 x86_64
- Elgato Thunderbolt 2 Dock exposing `0x1b73:0x1100`

**Do not install** this before reading [docs/install.md](docs/install.md). This replaces
system USB kernel extensions.

Quick setup:
```sh
git clone <this-repo-url> snow-leopard-usb3
cd snow-leopard-usb3

scripts/build-on-snow.sh
scripts/package-on-snow.sh
sudo scripts/install-on-snow.sh packaging/SnowUSB3-FL1100-AppleXHCI
sudo shutdown -r now
```

Following is supported:
- Fresco Logic FL1100, PCI ID `0x1b73:0x1100`
- Thunderbolt-tunnelled FL1100 controller
- sleep/wake recovery for the tested FL1100 dock

Apple source files remain under the Apple open-source license included in
[licenses/APPLE_LICENSE](licenses/APPLE_LICENSE).
