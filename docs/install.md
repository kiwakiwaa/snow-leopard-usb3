# Install Guide

This procedure replaces system USB kernel extensions. Use local console,
Screen Sharing etc so you are not depending only on USB
input during install.

## Build And Package

```sh
cd snow-leopard-usb3
scripts/build-on-snow.sh
scripts/package-on-snow.sh
```

Package output:

```text
packaging/SnowUSB3-FL1100-AppleXHCI/kexts/
  IOUSBFamily.kext
  AppleUSBXHCI.kext
```

`IOUSBFamily.kext` contains back-ported `AppleUSBHub.kext` and
`IOUSBUserClient.kext` in `Contents/PlugIns`.

## Install

```sh
sudo scripts/install-on-snow.sh packaging/SnowUSB3-FL1100-AppleXHCI
sudo shutdown -r now
```

The install script:

- creates `/SnowUSB3AppleXHCIRollback-<timestamp>`
- backs up existing `IOUSBFamily.kext`
- backs up existing `AppleUSBXHCI.kext` if present
- removes installed `GenericUSBXHCI.kext` if present
- installs the packaged kexts
- fixes ownership and permissions
- validates with `kextutil -nt`
- rebuilds kernel extension caches
- updates `/SnowUSB3AppleXHCIRollback` symlink

## Verify After Reboot

```sh
kextstat | egrep 'IOUSBFamily|IOUSBUserClient|AppleUSBHub|AppleUSBXHCI'
ioreg -p IOUSB -w0 -l | egrep 'XHCI Root|USB Product Name|Device Speed|PortNum'
diskutil list
```

Expected:

```text
com.apple.iokit.IOUSBFamily (5.6.0)
com.apple.iokit.IOUSBUserClient (5.5.5)
com.apple.driver.AppleUSBHub (5.5.5)
com.apple.driver.AppleUSBXHCI (5.6.0)
```

USB 3 disks should appear under:

```text
XHCI Root Hub SS Simulation
Device Speed = 3
```

Dock USB 2 devices, such as audio, should appear under:

```text
XHCI Root Hub USB 2.0 Simulation
```

## Rollback

If booted system is unhealthy:

```sh
sudo /SnowUSB3AppleXHCIRollback/rollback.sh
sudo shutdown -r now
```

If the machine will not boot normally, boot single-user or another volume, then
restore the backup from `/SnowUSB3AppleXHCIRollback-*`.
