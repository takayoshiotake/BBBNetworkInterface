# BBBNetworkInterface

[![GitHub release](https://img.shields.io/github/release/takayoshiotake/BBBNetworkInterface.svg)](https://github.com/takayoshiotake/BBBNetworkInterface/releases)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Swift 3.0.x](http://img.shields.io/badge/Swift-3.0.x-orange.svg?style=flat)
![Platforms](http://img.shields.io/badge/platforms-iOS%20|%20macOS-lightgrey.svg?style=flat)

Enumrates IP address and MAC address, of each Network Interface.

```swift
if let interface = BBBNetworkInterface.listNetworkInterfaces().filter({ $0.name == "en0" }).first {
    print("\(interface.name)=\(interface.address.map({ "\($0.type)=\($0.stringValue)" }))")
    // en0=["link=xx-xx-xx-xx-xx-xx", "ipv6=xxxx::xxxx:xxxx:xxxx:xxxx", "ipv4=xxx.xxx.xx.x"]
}
```
