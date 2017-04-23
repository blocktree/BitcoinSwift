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
        let pubkey = key2.publicKey
        
        print("输出公钥 = \(pubkey.hex)")

        print("输出公钥地址 = \(key2.address!.string)")
        
        
        //采用压缩方案
        guard let key3 = BTCKey(privateKey: privatekey, compressed: true) else {
            XCTAssert(false)
            return
        }

        print("输出压缩公钥 = \(key3.publicKey.hex)")
        
        print("输出压缩公钥地址 = \(key3.address!.string)")
        
        XCTAssert("L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu" == key3.wif, "wif == \(key3.wif)")
        
    }
    
    
    /// 测试比特币消息认证
    func testBitcoinSignedMessage() {
        
        do {
            //测试compactSignature
            let keyhex = "0000000000000000000000000000000000000000000000000000000000000001"
            let messagehex = "foo".data(using: String.Encoding.utf8)!.sha256()
            let key = BTCKey(privateKey: keyhex.hexData!, compressed: true)!
            guard let signature = key.compactSignature(for: messagehex) else {
                XCTAssert(false, "signature failed")
                return
            }
            
            print("input: messagehex = \(messagehex.hex)")
            print("output: signature = \(signature.hex)")
            XCTAssert("1f13e87558947c03ea88aa2b1f8d25a73f654f70fd2678dfb788d62a62bf8d761104950459102450c70f1dba0b499678bc300f841c97f4d2e29c7b6c6124676d82" == signature.hex, "signature not correct")
        
        }
        
        do {
            //测试bitcoinMessage签名
            let keyhex = "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a"
            let message = "My name is Chance, and I am a bitcoinSwift developer."
            
            let key = BTCKey(privateKey: keyhex.hexData!, compressed: false)!
            guard let signature = key.signature(for: message) else {
                XCTAssert(false, "signature failed")
                return
            }
            print("input: address = \(key.address!.string)")
            print("input: message = \(message)")
            print("output: base64 = \(signature.hex)")
            XCTAssert("HCFFin9nZaSKr57I5+UVrEwkYIYHrk8x/QPjuumWrFUTUrf0xzzF7Rx3x6FVEA1ABYXTmCrEpslJMn/smAL1My0=" == signature.base64EncodedString(), "signature not correct")
            
            //恢复公钥s
            guard let publicKey = BTCKey(compactSig: signature, message: message) else {
                XCTAssert(false, "recovery publickey failed")
                return
            }
            print("output: recovery publickey = \(publicKey.address!.string)")
            XCTAssert(publicKey.publicKeyAddress?.string == key.address?.string, "publickey not same as the sign key")
            
            let result = key.isValid(signature: signature, message: message)
            XCTAssert(result, "Valid Signature and message failed")
        }
        
    }
    
    
    /// 测试验证比特币消息认证功能
    func testVerifyBitcoinSignedMessage() {
//        let signature = "1c21458a7f6765a48aaf9ec8e7e515ac4c24608607ae4f31fd03e3bae996ac551352b7f4c73cc5ed1c77c7a155100d400585d3982ac4a6c949327fec9802f5332d".hexData!
//        let message = "My name is Chance, and I am a bitcoinSwift developer."
//        guard let publickey = BTCKey.verify(signature: signature, message: message) else {
//            XCTAssert(false, "Valid Signature and message failed")
//            return
//        }
        
        
    }
    
}
