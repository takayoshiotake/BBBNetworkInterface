//
//  BBBNetworkInterface.swift
//  BBBNetworkInterface
//
//  Created by OTAKE Takayoshi on 2016/10/14.
//
//

import Bridging

enum BBBErrorType: Error {
    case systemError(rawErrno: Int32)
    init(rawErrno: Int32) {
        self = .systemError(rawErrno: rawErrno)
    }
}

public enum NetworkInterfaceAddressType {
    case ipv4
    case ipv6
    case link
}

public struct NetworkInterfaceAddress {
    let type: NetworkInterfaceAddressType
    let stringValue: String
}

public struct NetworkInterface {
    let name: String
    var address: [NetworkInterfaceAddress]
    
    init(name: String, address: [NetworkInterfaceAddress]) {
        self.name = name
        self.address = address
    }
}

public func listNetworkInterfaces(_ verbose: Bool = false) -> [NetworkInterface] {
    let interfaceAddressSequence: InterfaceAddressSequence
    do {
        try interfaceAddressSequence = InterfaceAddressSequence()
    } catch {
        return []
    }
    
    var interfaceDict: [String: NetworkInterface] = [:]
    for ifa: UnsafeMutablePointer<ifaddrs> in interfaceAddressSequence {
        guard let name = String(validatingUTF8: ifa.pointee.ifa_name) else {
            continue
        }
        
        var interface: NetworkInterface
        if interfaceDict[name] == nil {
            interfaceDict[name] = NetworkInterface(name: name, address: [])
        }
        interface = interfaceDict[name]!
        
        let family = Int32(ifa.pointee.ifa_addr.pointee.sa_family)
        switch family {
        case AF_INET:
            let addr = UnsafeRawPointer(ifa.pointee.ifa_addr).bindMemory(to: sockaddr_in.self, capacity: 1).pointee.addrDescription()
            interface.address.append(NetworkInterfaceAddress(type: .ipv4, stringValue: addr))
            if verbose {
                print("name=\(name), family=\(family), addr=\(addr)")
            }
            break
        case AF_INET6:
            let addr = UnsafeRawPointer(ifa.pointee.ifa_addr).bindMemory(to: sockaddr_in6.self, capacity: 1).pointee.addrDescription()
            interface.address.append(NetworkInterfaceAddress(type: .ipv6, stringValue: addr))
            if verbose {
                print("name=\(name), family=\(family), addr=\(addr)")
            }
            break
        case AF_LINK:
            var link = UnsafeRawPointer(ifa.pointee.ifa_addr).bindMemory(to: sockaddr_dl.self, capacity: 1).pointee
            if link.sdl_alen == 6 {
                let data = rawPointer(&link.sdl_data).bindMemory(to: UInt8.self, capacity: Int(link.sdl_len)).advanced(by: Int(link.sdl_nlen))
                let addr = String(format: "%02x-%02x-%02x-%02x-%02x-%02x", data[0], data[1], data[2], data[3], data[4], data[5])
                interface.address.append(NetworkInterfaceAddress(type: .link, stringValue: addr))
                if verbose {
                    print("name=\(name), family=\(family), addr=\(addr)")
                }
            }
            fallthrough
        default:
            if verbose {
                print("name=\(name), family=\(family)")
            }
            break
        }
        
        interfaceDict[name] = interface
    }
    
    // Convert to [NetworkInterface]
    return interfaceDict.map({ $0.1 })
}

private func rawPointer(_ pointer: UnsafeRawPointer) -> UnsafeRawPointer {
    return pointer
}

private class InterfaceAddressSequence: Sequence {
    lazy var firstPtr: UnsafeMutablePointer<ifaddrs>? = nil
    
    init() throws {
        if getifaddrs(&firstPtr) != 0 {
            throw BBBErrorType(rawErrno: errno)
        }
    }
    
    deinit {
        if firstPtr != nil {
            freeifaddrs(firstPtr)
        }
    }
    
    fileprivate func makeIterator() -> InterfaceAddressGenerator {
        return InterfaceAddressGenerator(self.firstPtr!)
    }
}

private class InterfaceAddressGenerator: IteratorProtocol {
    var nextPtr: UnsafeMutablePointer<ifaddrs>?
    
    init(_ nextPtr: UnsafeMutablePointer<ifaddrs>) {
        self.nextPtr = nextPtr
    }
    
    func next() -> UnsafeMutablePointer<ifaddrs>? {
        if let ptr = nextPtr {
            nextPtr = ptr.pointee.ifa_next
            return ptr
        }
        else {
            nextPtr = nil
            return nil
        }
    }
}

private extension sockaddr_in {
    func addrDescription() -> String {
        var addrDescription = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
        var sin_addr = self.sin_addr
        inet_ntop(AF_INET, &sin_addr, &addrDescription, socklen_t(INET_ADDRSTRLEN))
        return String(cString: addrDescription)
    }
}

private extension sockaddr_in6 {
    func addrDescription() -> String {
        var addrDescription = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
        var sin6_addr = self.sin6_addr
        inet_ntop(AF_INET6, &sin6_addr, &addrDescription, socklen_t(INET6_ADDRSTRLEN))
        return String(cString: addrDescription)
    }
}
