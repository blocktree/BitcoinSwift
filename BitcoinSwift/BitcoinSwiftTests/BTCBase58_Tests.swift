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
        
        //正确的数据
        var hex = "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a"
        guard let d = hex.hexData else {
            XCTAssert(false)
            return
        }
        
        var base58 = d.base58
        print("input = \(hex)")
        print("output = \(base58)")
        XCTAssert(!base58.isEmpty, "output = \(base58)")
        
        //全部连续0数据
        hex = "0000000000000000000000000000000000000000000000000000000000000000"
        guard let t = hex.hexData else {
            XCTAssert(false, "数据无法解析")
            return
        }
        base58 = t.base58
        print("input = \(hex)")
        print("output = \(base58)")
        XCTAssert(!t.base58.isEmpty, "output = \(base58)")
        
        //空数据
        base58 = Data().base58
        print("input = ''")
        print("output = \(base58)")
        XCTAssert(!t.base58.isEmpty, "output = \(base58)")
        
    }
    
    
    /// 测试解码
    func testDecode() {
        
        //正常测试
        var base58 = "5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS"
        guard let d = BTCBase58.decode(with: base58) else {
            XCTAssert(false)
            return
        }
        
        print("input = \(base58)")
        print("output = \(d.hex)")
        XCTAssert(d.hex == "0080c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8aeb5f56e1")
        
        //测试全为0
        base58 = "11111111111111111111"
        guard let d2 = BTCBase58.decode(with: base58) else {
            XCTAssert(false)
            return
        }
        
        print("input = \(base58)")
        print("output = \(d2.hex)")
        XCTAssert(d2.hex == "0000000000000000000000000000000000000000")
        
        //测试空串
        base58 = ""
        print("input = \(base58)")
        guard let d3 = BTCBase58.decode(with: base58) else {
            XCTAssert(true)
            print("output = ")
            return
        }
        
        print("output = \(d3.hex)")
        XCTAssert(false)
        
    }
    
}
