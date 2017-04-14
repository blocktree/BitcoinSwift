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
        print("//////////////////// 测试开始 ////////////////////\n")
    }
    
    override func tearDown() {
        print("//////////////////// 测试结束 ////////////////////\n")
        super.tearDown()
    }
    
    
    /// 测试创建钥匙对
    func testCreateKeys() {
        
        
        /// 随机生成
        guard let key = BTCKey() else {
            XCTAssert(false)
            return
        }
        print("随机私钥 wif = " + key.wif)
        
        //已有数据初始化私钥
        let hex = "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a"
        guard let privatekey = hex.hexData else {
            XCTAssert(false)
            return
        }
        
        guard let key2 = BTCKey(privateKey: privatekey) else {
            XCTAssert(false)
            return
        }
        
        //key2.publicKeyCompressed = true
        
        XCTAssert("5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS" == key2.wif, "wif == \(key2.wif)")
        
        //导出公钥
        guard let pubkey = key2.publicKey else {
            XCTAssert(false)
            return
        }
        
        print("输出公钥 = \(pubkey.hex)")
        
    }
    
}
