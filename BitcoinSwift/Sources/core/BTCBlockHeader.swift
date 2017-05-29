//
//  BTCBlockHeader.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/25.
//
//

import Foundation


/// 区块头定义
/// https://en.bitcoin.it/wiki/Protocol_documentation#Block_Headers
public struct BTCBlockHeader {
    
    //MARK: - 区块头长度
    
    /// 区块头的长度定义，常量定义
    public struct BTCBlockHeaderLength {
        
        let version: Int = 4
        let previousBlockHash: Int = 32
        let merkleRoot: Int = 32
        let time: Int = 4
        let difficultyTarget: Int = 4
        let nonce: Int = 4
        
        var length: Int {
            return version + previousBlockHash + merkleRoot + time + difficultyTarget + nonce
            //
        }
    }
    
    //用一个静态结构体保存长度
    public static var headerLength =  BTCBlockHeaderLength()
    
    //MARK: - 成员变量
    
    public var version: Int32 = 0
    public var previousBlockHash: Data = Data(repeating: 0, count: 32)
    public var previousBlockID = ""
    public var merkleRootHash: Data = Data(repeating: 0, count: 32)
    public var time: UInt32 = 0
    public var difficultyTarget: UInt32 = 0
    public var nonce: UInt32 = 0
    public var blockHash: Data = Data()
    public var blockID: String = ""
    
    public var data: Data {
        return self.computePayload()
    }
    
    public var height: Int = 0
    public var confirmations: Int = 0
    
    //把时间戳转为时间
    public var date: Date {
        set {
            self.time = UInt32(newValue.timeIntervalSince1970.rounded())
        }
        get {
            return Date(timeIntervalSince1970: TimeInterval(self.time))
        }
    }
    
    //MARK: - 初始化方法
    
    /// 通过字节序列编码初始化区块头
    public init?(data: Data) {
        
        if data.count < BTCBlockHeader.headerLength.length {
            return nil
        }
        
        var offset = 0
        
        //读取版本号，UInt32类型
        guard let version = data.get(at: offset, UInt32.self) else {
            return nil
        }
        
        self.version = Int32(version[0])
        offset += BTCBlockHeader.headerLength.version   //移位到下一属性
        
        //读取上一个区块hash值，sha256类型
        guard let prevBlock = data.get(at: offset, count: BTCBlockHeader.headerLength.previousBlockHash, UInt8.self) else {
            return nil
        }
        
        self.previousBlockHash = Data(bytes: prevBlock)
        offset += BTCBlockHeader.headerLength.previousBlockHash   //移位到下一属性
        
        //读取merkleRoot的hash值，sha256类型
        guard let merkleRoot = data.get(at: offset, count: BTCBlockHeader.headerLength.merkleRoot, UInt8.self) else {
            return nil
        }
        
        self.merkleRootHash = Data(bytes: merkleRoot)
        offset += BTCBlockHeader.headerLength.merkleRoot   //移位到下一属性
        
        //读取时间戳，UInt32类型
        guard let timestamp = data.get(at: offset, count: BTCBlockHeader.headerLength.time, UInt32.self) else {
            return nil
        }
        
        self.time = timestamp[0]
        offset += BTCBlockHeader.headerLength.time   //移位到下一属性
        
        //读取区块难度，UInt32类型
        guard let target = data.get(at: offset, count: BTCBlockHeader.headerLength.difficultyTarget, UInt32.self) else {
            return nil
        }
        
        self.difficultyTarget = target[0]
        offset += BTCBlockHeader.headerLength.difficultyTarget   //移位到下一属性
        
        //读取计数，UInt32类型
        guard let nonce = data.get(at: offset, count: BTCBlockHeader.headerLength.nonce, UInt32.self) else {
            return nil
        }
        
        self.nonce = nonce[0]
        offset += BTCBlockHeader.headerLength.nonce   //移位到下一属性
        
        //计算自己的hash值
        self.blockHash = self.computePayload().sha256().sha256()
        
        
    }
    
    
    /// 组织负载字节
    ///
    /// - Returns: 
    public func computePayload() -> Data {
        
        var data = Data()
        var version = self.version.littleEndian
        data.append(Data(bytes: &version, count: MemoryLayout<UInt32>.size))
        data.append(self.previousBlockHash)
        data.append(self.merkleRootHash)
        var time = self.time.littleEndian
        data.append(Data(bytes: &time, count: MemoryLayout<UInt32>.size))
        var target = self.difficultyTarget.littleEndian
        data.append(Data(bytes: &target, count: MemoryLayout<UInt32>.size))
        var nonce = self.nonce.littleEndian
        data.append(Data(bytes: &nonce, count: MemoryLayout<UInt32>.size))
        
        return data;
    }
}
