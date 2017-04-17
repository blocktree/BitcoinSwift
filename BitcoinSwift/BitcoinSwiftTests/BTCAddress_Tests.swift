//
//  BTCAddress_Tests.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/17.
//
//

import XCTest
@testable import BitcoinSwift

class BTCAddress_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        print("//////////////////// 测试开始 ////////////////////\n")
    }
    
    override func tearDown() {
        print("//////////////////// 测试结束 ////////////////////\n")
        super.tearDown()
    }
    
    
    /// 测试公钥地址
    func testPublicKeyAddress() {
        
        
        /// 测试地址base58解析
        let address = "1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T"
        guard let addr = try? BTCPublickeyAddress(string: address) else {
            XCTAssert(false, "addr data isEmpty")
            return
        }
        
        guard let pubkeydata = addr.data else {
            XCTAssert(false, "addr data isEmpty")
            return
        }
        print("input = \(address)")
        print("output = \(pubkeydata.hex)")
        XCTAssert("c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827" == pubkeydata.hex, "Must decode hash160 correctly.");
        
        let hex = "c4c5d791fcb4654a1ef5e03fe0ad3d9c598f9827"
        guard let addr2 = try? BTCPublickeyAddress(data: hex.hexData!) else {
            XCTAssert(false, "addr data isEmpty")
            return
        }
        print("input = \(hex)")
        print("output = \(addr2.string)")
        XCTAssert("1JwSSubhmg6iPtRjtyqhUYYH7bZg3Lfy1T" == addr2.string, "Must decode hash160 correctly.");
        
        
    }
}
