//
//  UInt+Bitcoin_Tests.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/5/29.
//
//

import XCTest
@testable import BitcoinSwift

class UInt_Bitcoin_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        print("//////////////////// 测试开始 ////////////////////\n")
    }
    
    override func tearDown() {
        print("//////////////////// 测试结束 ////////////////////\n")
        super.tearDown()
    }
    
    
    /// 测试UInt128结构体
    func testUInt128() {
        
        let result = "112233445566778899aabbccddeeff00" //用例结果
        
        do {
            //通过UInt8数组初始化
            let values: [UInt8] = [0x11,0x22,0x33,0x44,
                                    0x55,0x66,0x77,0x88,
                                    0x99,0xaa,0xbb,0xcc,
                                    0xdd,0xee,0xff,0x00]
            
            let u128 = UInt128(values)
            print("UInt8.u8 = \(u128.u8)")
            let u8hex = u128.u8.map { Data($0).hex }.joined()
            let u16hex = u128.u16.map { Data($0).hex }.joined()
            let u32hex = u128.u32.map { Data($0).hex }.joined()
            let u64hex = u128.u64.map { Data($0).hex }.joined()
            XCTAssert(u8hex == result, "error hex = \(u8hex)")
            XCTAssert(u16hex == result, "error hex = \(u16hex)")
            XCTAssert(u32hex == result, "error hex = \(u32hex)")
            XCTAssert(u64hex == result, "error hex = \(u64hex)")
        }
        
        do {
            //通过UInt16数组初始化
            let values: [UInt16] = [UInt16(bigEndian: 0x1122),UInt16(bigEndian: 0x3344),
                                    UInt16(bigEndian: 0x5566),UInt16(bigEndian: 0x7788),
                                    UInt16(bigEndian: 0x99aa),UInt16(bigEndian: 0xbbcc),
                                    UInt16(bigEndian: 0xddee),UInt16(bigEndian: 0xff00)]
            
            let u128 = UInt128(values)
            print("UInt16.u8 = \(u128.u8)")
            let u8hex = u128.u8.map { Data($0).hex }.joined()
            let u16hex = u128.u16.map { Data($0).hex }.joined()
            let u32hex = u128.u32.map { Data($0).hex }.joined()
            let u64hex = u128.u64.map { Data($0).hex }.joined()
            XCTAssert(u8hex == result, "error hex = \(u8hex)")
            XCTAssert(u16hex == result, "error hex = \(u16hex)")
            XCTAssert(u32hex == result, "error hex = \(u32hex)")
            XCTAssert(u64hex == result, "error hex = \(u64hex)")
        }
        
        do {
            //通过UInt32数组初始化
            let values: [UInt32] = [UInt32(bigEndian: 0x11223344),
                                    UInt32(bigEndian: 0x55667788),
                                    UInt32(bigEndian: 0x99aabbcc),
                                    UInt32(bigEndian: 0xddeeff00)]
            let u128 = UInt128(values)
            print("UInt32.u8 = \(u128.u8)")
            let u8hex = u128.u8.map { Data($0).hex }.joined()
            let u16hex = u128.u16.map { Data($0).hex }.joined()
            let u32hex = u128.u32.map { Data($0).hex }.joined()
            let u64hex = u128.u64.map { Data($0).hex }.joined()
            XCTAssert(u8hex == result, "error hex = \(u8hex)")
            XCTAssert(u16hex == result, "error hex = \(u16hex)")
            XCTAssert(u32hex == result, "error hex = \(u32hex)")
            XCTAssert(u64hex == result, "error hex = \(u64hex)")
        }
        
        do {
            //通过UInt64数组初始化
            let values: [UInt64] = [UInt64(bigEndian: 0x1122334455667788),
                                    UInt64(bigEndian: 0x99aabbccddeeff00)]
            let u128 = UInt128(values)
            print("UInt64.u8 = \(u128.u8)")
            let u8hex = u128.u8.map { Data($0).hex }.joined()
            let u16hex = u128.u16.map { Data($0).hex }.joined()
            let u32hex = u128.u32.map { Data($0).hex }.joined()
            let u64hex = u128.u64.map { Data($0).hex }.joined()
            XCTAssert(u8hex == result, "error hex = \(u8hex)")
            XCTAssert(u16hex == result, "error hex = \(u16hex)")
            XCTAssert(u32hex == result, "error hex = \(u32hex)")
            XCTAssert(u64hex == result, "error hex = \(u64hex)")
        }
    }
    
}
