//
//  BTCCommand.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/5/21.
//
//

import Foundation


/// 比特币网络协议指令集
///
/// - version: 一个节点收到连接请求时，它立即宣告其版本。在通信双方都得到对方版本之前，不会有其他通信
/// - verack: 版本不低于209的客户端在应答version消息时发送verack消息。这个消息仅包含一个command为"verack"的消息头
/// - addr: 提供网络上已知节点的信息。一般来说3小时不进行宣告（advertise）的节点会被网络遗忘
/// - inv: 节点通过此消息可以宣告(advertise)它又拥有的对象信息。这个消息可以主动发送，也可以用于应答getbloks消息
/// - getdata: getdata用于应答inv消息来获取指定对象，它通常在接收到inv包并滤去已知元素后发送
/// - getblocks: 发送此消息以期返回一个包含编号从hash_start到hash_stop的block列表的inv消息。若hash_start到hash_stop的block数超过500，则在500处截止。欲获取后面的block散列，需要重新发送getblocks消息。
/// - getheaders: 获取包含编号hash_star到hash_stop的至多2000个block的header包。要获取之后的block散列，需要重新发送getheaders消息。这个消息用于快速下载不包含相关交易的blockchain。
/// - tx: tx消息描述一笔比特币交易，用于应答getdata消息
/// - block: block消息用于响应请求交易信息的getdata消息
/// - headers: headers消息返回block的头部以应答getheaders
/// - getaddr: getaddr消息向一个节点发送获取已知活动端的请求，以识别网络中的节点。回应这个消息的方法是发送包含已知活动端信息的addr消息。一般的，一个3小时内发送过消息的节点被认为是活动的。
/// - checkorder: 此消息用于IP Transactions，以询问对方是否接受交易并允许查看order内容。
/// - submitorder: 确认一个order已经被提交
/// - reply: IP Transactions的一般应答
/// - ping: ping消息主要用于确认TCP/IP连接的可用性。
/// - alert: alert消息用于在节点间发送通知使其传遍整个网络。如果签名验证这个alert来自Bitcoin的核心开发组，建议将这条消息显示给终端用户。交易尝试，尤其是客户端间的自动交易则建议停止。消息文字应当记入记录文件并传到每个用户。
public enum BTCCommand: String {
    
    case version = "version"
    case verack = "verack"
    case addr = "addr"
    case inv = "inv"
    case getdata = "getdata"
    case getblocks = "getblocks"
    case getheaders = "getheaders"
    case tx = "tx"
    case block = "block"
    case headers = "headers"
    case getaddr = "getaddr"
    case checkorder = "checkorder"
    case submitorder = "submitorder"
    case reply = "reply"
    case ping = "ping"
    case alert = "alert"
    
    
    /// 是否需要校验完整性
    public var isChecksum: Bool {
        // version和verack消息不包含checksum，payload的起始位置提前4个字节
        switch self {
        case .version, .verack:
            return false
        default:
            return true
        }
    }
    
    
    public func encode(value: [String: Any]) -> Data {
        var msg = Data()
        switch self {
        case .version:
            //一个节点收到连接请求时，它立即宣告其版本。在通信双方都得到对方版本之前，不会有其他通信
            msg.appendVarInt(value: 0)
//        case .verack:
//        case .addr:
//        case .inv:
//        case .getdata:
//        case .getblocks:
//        case .getheaders:
//        case .tx:
//        case .block:
//        case .headers:
//        case .getaddr:
//        case .checkorder:
//        case .submitorder:
//        case .reply:
//        case .ping:
//        case .alert:
        default:break
        }
        return msg
    }
    
    
    public static func sendVersionMessage() {
        
    }

}
