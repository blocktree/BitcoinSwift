//
//  BitcoinSwiftIOSTests.swift
//  BitcoinSwiftIOSTests
//
//  Created by Chance on 2017/4/8.
//
//

import XCTest
@testable import BitcoinSwiftIOS

class BitcoinSwiftIOSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let key = BTCKey()
        _ = key.wif
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}