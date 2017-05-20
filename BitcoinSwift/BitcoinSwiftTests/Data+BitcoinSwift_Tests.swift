//
//  Data+BitcoinSwift_Test.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/5/20.
//
//

import XCTest
@testable import BitcoinSwift

class Data_BitcoinSwift_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        print("//////////////////// 测试开始 ////////////////////\n")
    }
    
    override func tearDown() {
        print("//////////////////// 测试结束 ////////////////////\n")
        super.tearDown()
    }
    
    func testBytes() {
        do {
            let data = "00000000000000000000FFFF0A000001".hexData!
            let u8 = data.u8
            print("u8 = \(u8)")
        }
        
        do {
            let data = "00000000000000000000FFFF0A000001".hexData!
            let u16 = data.u16
            print("u16 = \(u16)")
        }
        
        do {
            let data = "00000000000000000000FFFF0A000001".hexData!
            let u32 = data.u32
            print("u32 = \(u32)")
        }
    }
    
}
