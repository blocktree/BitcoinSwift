//
//  BTCMessageHeader.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/5/21.
//
//

import Foundation


/// 比特币网络协议消息头结构
public struct BTCMessageHeader {
    
    public static let maxHeaderLength: Int = 24               //消息头字节长度
    public static let minHeaderLength: Int = 20               //消息头字节长度
    public static let maxLength: Int = 0x02000000          //负载最大字节数
    
    /*
     Message (消息)
     字段尺寸         描述        数据类型      说明
     4              magic       uint32_t    用于识别消息的来源网络，当流状态位置时，它还用于寻找下一条消息
     12             command     char[12]	识别包内容的ASCII字串，用NULL字符补满，(使用非NULL字符填充会被拒绝)
     4              length      uint32_t	payload的字节数
     4              checksum	uint32_t	sha256(sha256(payload)) 的前4个字节(不包含在version 或 verack 中)
     ?              payload     uchar[]     实际数据
    */
    
    public var magic: UInt32 = 0
    public var command: BTCCommand
    public var length: UInt32 = 0
    public var checksum: UInt32 = 0
    public var payload: Data?
    
    
    /// 消息包的总长度：头长度+负载长度
    public var msgLength: Int {
        var headerLength = 0
        if self.command.isChecksum {
            headerLength = BTCMessageHeader.maxHeaderLength
        } else {
            headerLength = BTCMessageHeader.minHeaderLength
        }
        return headerLength + Int(length)
    }
    
    //通过字节组初始化消息头
    public init(data: Data) throws {
        
        var data = data
        
        //先检查头字节长度是否足够
        if data.count < BTCMessageHeader.minHeaderLength {
            throw BTCError.decodeError("error message header length is not enough")
        }
        
        //检查command是否用NULL填充结束，使用非NULL字符填充会被拒绝
        let isNULL = data.getUInt8(at: 15)
        guard isNULL == 0 else {
            throw BTCError.decodeError("malformed message header: \(data)")
        }
        
        /************** 【二】解析消息头 **************/
        
        /*
         
         Message Header:
         F9 BE B4 D9                                     - magic ：main 网络
         61 64 64 72  00 00 00 00 00 00 00 00            - "addr"
         1F 00 00 00                                     - payload 长度31字节
         7F 85 39 C2                                     - payload 校验和
         */
        
        let commandStr = data.getString(at: 4)
        guard let command = BTCCommand(rawValue: commandStr) else {
            throw BTCError.decodeError("error message is not bitcoin")
        }
        
        //记录头部
        self.magic = data.getUInt32(at: 0)
        self.command = command                          //类型
        self.length = data.getUInt32(at: 16)          //长度
        
        var actualLength = 0
        //version和verack消息不包含checksum，payload的起始位置提前4个字节
        if self.command.isChecksum {
            self.checksum = data.getUInt32(at: 20)        //校验
            actualLength = BTCMessageHeader.maxHeaderLength
        } else {
            actualLength = BTCMessageHeader.minHeaderLength
        }
        
        //把完成解析的字节删除
        data.removeSubrange(0..<actualLength)
        
        /************** 【三】提出负载内容 **************/
        
        guard Int(self.length) <= BTCMessageHeader.maxLength else { // 检查消息长度是否超限制
            throw BTCError.decodeError("error reading \(self.command.rawValue), message length \(self.length) is too long")
        }
        
        guard Int(self.length) <= data.count else { // 检查消息长度是否超限制
            throw BTCError.decodeError("error reading \(self.command.rawValue), message length is not match the payload length")
        }
        
        
        if self.length > 0 {
            
            //从输入流写入数据到payload缓存
            let msgPayload = Data(data.prefix(Int(self.length)))
            
            if self.command.isChecksum {
                print("sha256_2 = \(msgPayload.sha256().sha256().hex)")
                let payloadhash4bytes = msgPayload.sha256().sha256().getUInt32(at: 0)
                
                guard self.checksum == payloadhash4bytes else {
                    throw BTCError.decodeError("error reading \(self.command.rawValue), invalid checksum \(payloadhash4bytes), expected \(self.checksum), payload length:\(msgPayload.count), expected length:\(self.length)")
                }
                
            }
            
            
            self.payload = msgPayload         //取得消息主体
        }
        
        
        
    }
}


/// 消息处理器
public class BTCMessageHandler {
    
    
    
    /// 比特币网络协议消息解析
    ///
    /// - Parameter message: 消息字节编码
    /// - Returns: 消息
    /// - Throws: 解析异常
    public class func decodeMessage(readData: Data) throws -> [BTCMessageHeader] {
        
        var readData = readData
        
        //解析后的消息输出
        var messages = [BTCMessageHeader]()

        repeat {
            
            //以下程序控制在对每一个消息包的处理，因为socket存在粘包，要根据消息头协议读取完整内容
            
            /************** 【一】查找消息头 **************/
            
            //读取头4字节的内容，判断是否为比特币网络识别，一条消息必须以这个内容作为头部开始
            let magic = readData.getUInt32(at: 0)
            guard magic == BTCNodeConfig.shared.network.magic else { //找到网络识别符
                //如果不是，移除这些内容，直至找到头4字节能识别为聊天币网络位置
                readData.removeFirst()  //删除首字节，只处理符合比特币协议的消息，其它消息交给其它消息处理器
                continue
            }
            
            //找到magic进行解析数据，读取头部，协议中Message的头部不会超过24字节
            let header = try BTCMessageHeader(data: readData)
            
            //把解析好的消息放入数组
            messages.append(header)
            
            //把完成解析的字节删除
            readData.removeSubrange(0..<header.msgLength)

        } while readData.count > 0
        
        return messages
        
    }
}
