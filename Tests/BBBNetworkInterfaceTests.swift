//
//  BBBNetworkInterfaceTests.swift
//  BBBNetworkInterfaceTests
//
//  Created by OTAKE Takayoshi on 2016/10/14.
//
//

import XCTest
@testable import BBBNetworkInterface

class BBBNetworkInterfaceTests: XCTestCase {
    
    func testExample() {
        let interfaces = BBBNetworkInterface.listNetworkInterfaces()
        XCTAssertTrue(interfaces.count > 0)
        
        if let interface = interfaces.filter({ $0.name == "en0" }).first {
            print("DEBUG: \(interface.name)=\(interface.address.map({ "\($0.type)=\($0.stringValue)" }))")
        }
    }
    
}
