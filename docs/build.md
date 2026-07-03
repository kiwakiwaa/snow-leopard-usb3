The tested toolchain used:

```text
Mac OS X 10.6.8 Snow Leopard 10K549 x86_64
Xcode 4.2 build 4C199
```

## Build

```sh
cd snow-leopard-usb3
scripts/build-on-snow.sh
```

The script stages the back-ported USB headers into the build directory before
running Xcode. This is required because the stock 10.6 SDK headers do not expose
the USB 3 controller interfaces used by `AppleUSBXHCI`.

Built products are expected under:

```text
src/IOUSBFamily-560-SnowUSB3/build/Deployment/
  IOUSBFamily.kext
  AppleUSBHub.kext
  IOUSBUserClient.kext
  AppleUSBXHCI.kext
```

Or if you want to build manually:

```sh
cd src/IOUSBFamily-560-SnowUSB3
mkdir -p build/Deployment/include/IOKit/usb
cp IOUSBFamily/Headers/*.h build/Deployment/include/IOKit/usb/
cp IOUSBUserClient/Headers/*.h build/Deployment/include/IOKit/usb/
cp AppleUSBHub/Headers/*.h build/Deployment/include/IOKit/usb/

xcodebuild -project IOUSBFamily.xcodeproj \
  -target IOUSBFamily_kexts \
  -configuration Deployment \
  ARCHS=x86_64 VALID_ARCHS=x86_64 build
```

## Validate

```sh
sudo chown -R root:wheel src/IOUSBFamily-560-SnowUSB3/build/Deployment/*.kext
sudo chmod -R go-w src/IOUSBFamily-560-SnowUSB3/build/Deployment/*.kext

sudo kextutil -nt src/IOUSBFamily-560-SnowUSB3/build/Deployment/IOUSBFamily.kext
sudo kextutil -nt src/IOUSBFamily-560-SnowUSB3/build/Deployment/AppleUSBXHCI.kext
```

Both kexts must validate before install.
