//
//  BitcoinSwiftIOSTests.swift
//  BitcoinSwiftIOSTests
//
//  Created by Chance on 2017/4/8.
//
//

import XCTest
@testable import BitcoinSwift

class BTCKey_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    /// 测试创建钥匙对
    func testCreateKeys() {
        print("//////////////////// 测试开始 ////////////////////")
        do {
            let key = try BTCKey()
            print("随机私钥 wif = " + key.wif)
            let hex = "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a"
            guard let privatekey = hex.hexData else {
                XCTAssert(false)
                return
            }
            
            let key2 = try BTCKey(privateKey: privatekey)
            XCTAssert("5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS" == key2.wif, "wif == \(key2.wif)")
        } catch {
            
        }
        
        print("//////////////////// 测试结束 ////////////////////")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
