//
//  BTCBlockHeader_Tests.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/28.
//
//

import XCTest
@testable import BitcoinSwift

class BTCBlockHeader_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        print("//////////////////// 测试开始 ////////////////////\n")
    }
    
    override func tearDown() {
        print("//////////////////// 测试结束 ////////////////////\n")
        super.tearDown()
    }
    
    func testBTCBlockHeader() {
        let str = "Hello, playground"
        let data = str.data(using: String.Encoding.utf8)!
        let u32 = UInt32(bytes: data.bytes, fromIndex: 0)
        let u32l = data.get(at: 0, UInt32.self)
        print("hex = \(data.hex)")
        print("u32 = \(u32)")
        print("u32 little endian = \(u32l)")
    }
    
    func testConvertData() {
        let str = "Hello,playground"
        let data = str.data(using: String.Encoding.utf8)!
        print("data hex = \(data.hex)")
        //48 65 6c 6c 6f 2c 70 6c 61 79 67 72 6f 75 6e 64
        
        /// UInt32是以little-endian方式写入.
        /// 48 65 6c 6c写入到UInt32后，字序变为6c 6c 65 48，数值变为1819043144
        let u32 = Data.convert(length: data.count, data: data.bytes, UInt32.self)
        print("u32 = \(u32)")
    }
    
    
}
