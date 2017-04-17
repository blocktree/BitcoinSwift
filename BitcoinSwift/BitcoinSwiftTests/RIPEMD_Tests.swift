//
//  RIPEMD_Tests.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/17.
//
//

import XCTest
@testable import BitcoinSwift

class RIPEMD_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        print("//////////////////// 测试开始 ////////////////////\n")
    }
    
    override func tearDown() {
        print("//////////////////// 测试结束 ////////////////////\n")
        super.tearDown()
    }
    
    
    /// 测试RIPEMD160压缩
    func testDigest() {
        
        var teststr = ""    //空数据
        print("input = \(teststr)")
        print("output = \(teststr.ripemd160())")
        XCTAssert(teststr.ripemd160() == "9c1185a5c5e9fc54612808977ee8f548b2258d31", "output = \(teststr.ripemd160())")
        
        
        teststr = "a"
        print("input = \(teststr)")
        print("output = \(teststr.ripemd160())")
        XCTAssert(teststr.ripemd160() == "0bdc9d2d256b3ee9daae347be6f4dc835a467ffe", "output = \(teststr.ripemd160())")
        
        teststr = "abc"
        print("input = \(teststr)")
        print("output = \(teststr.ripemd160())")
        XCTAssert(teststr.ripemd160() == "8eb208f7e05d987a9b044a8e98c6b087f15a0bfc", "output = \(teststr.ripemd160())")
        
        teststr = "message digest"
        print("input = \(teststr)")
        print("output = \(teststr.ripemd160())")
        XCTAssert(teststr.ripemd160() == "5d0689ef49d2fae572b881b123a85ffa21595f36", "output = \(teststr.ripemd160())")
        
        teststr = "abcdefghijklmnopqrstuvwxyz"
        print("input = \(teststr)")
        print("output = \(teststr.ripemd160())")
        XCTAssert(teststr.ripemd160() == "f71c27109c692c1b56bbdceb5b9d2865b3708dbc", "output = \(teststr.ripemd160())")
        
        teststr = "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
        print("input = \(teststr)")
        print("output = \(teststr.ripemd160())")
        XCTAssert(teststr.ripemd160() == "12a053384a9c0c88e405a06c27dcf49ada62eb2b", "output = \(teststr.ripemd160())")
        
        teststr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        print("input = \(teststr)")
        print("output = \(teststr.ripemd160())")
        XCTAssert(teststr.ripemd160() == "b0e20b6e3116640286ed3a87a5713079b21f5189", "output = \(teststr.ripemd160())")
        
        let t8 = "1234567890"  //8 times
        teststr = ""
        for _ in 1...8 {
            teststr += t8
        }
        print("input = \(teststr)")
        print("output = \(teststr.ripemd160())")
        XCTAssert(teststr.ripemd160() == "9b752e45573d4b39f4dbd3323cab82bf63326bfb", "output = \(teststr.ripemd160())")
    }
    
    
}
