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
    
    
    /// 测试私钥地址
    func testPrivateKeyAddress() {
        
        //导入未压缩的私钥
        var address = "5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS"
        guard let addr = try? BTCPrivateKeyAddress(string: address) else {
            XCTAssert(false, "addr data isEmpty")
            return
        }
        guard let privateKeyData = addr.data else {
            XCTAssert(false, "addr data isEmpty")
            return
        }
        
        print("input = \(address)")
        print("output = \(privateKeyData.hex)")
        XCTAssert("c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a" == privateKeyData.hex, "hex = \(privateKeyData.hex)");
        
        //导入压缩
        let hex = "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a"
        guard let address2 = try? BTCPrivateKeyAddress(data: hex.hexData!, compressed: true) else {
            XCTAssert(false, "addr data isEmpty")
            return
        }
        print("input = \(hex)")
        print("output = \(address2.string)")
        XCTAssert("L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu" == address2.string, "address = \(address2.string)");
        
        //导入压缩地址base58
        address = "L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu"
        guard let addr3 = try? BTCPrivateKeyAddress(string: address) else {
            XCTAssert(false, "addr data isEmpty")
            return
        }
        XCTAssert(addr3.compressed, "address compressed is false");
        
        print("input = \(address)")
        print("output = \(addr3.data!.hex)")
        XCTAssert("c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a" == addr3.data!.hex, "hex = \(addr3.data!.hex)");
    }
}
