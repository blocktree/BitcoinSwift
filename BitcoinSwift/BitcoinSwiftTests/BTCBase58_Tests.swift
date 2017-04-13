//
//  BitcoinSwiftIOSTests.swift
//  BitcoinSwiftIOSTests
//
//  Created by Chance on 2017/4/8.
//
//

import XCTest
@testable import BitcoinSwift

class BTCBase58_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        print("//////////////////// 测试开始 ////////////////////\n")
    }
    
    override func tearDown() {
        print("//////////////////// 测试结束 ////////////////////\n")
        super.tearDown()
    }
    
    
    /// 测试编码
    func testEncode() {
        
        do {
            var hex = "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a"
            guard let d = hex.hexData else {
                XCTAssert(false)
                return
            }
            
            print(d.base58)
            
            hex = "0000000000000000000000000000000000000000000000000000000000000000"
            guard let t = hex.hexData else {
                XCTAssert(false)
                return
            }
            
            print(t.base58)
            
        } catch {
            
        }
        
        
    }
    
    
    /// 测试解码
    func testDecode() {
        
        let base58 = "5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS"
        guard let d = BTCBase58.decode(with: base58) else {
            XCTAssert(false)
            return
        }
        
        print("Hex = " + d.hex)
        XCTAssert(d.hex == "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a")
    }
    
}
