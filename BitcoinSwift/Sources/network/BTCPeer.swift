//
//  BTCPeer.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/5/2.
//
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

import Foundation


/// 节点连接状态
///
/// - disconnected: 断开
/// - connecting: 连接中
/// - connected: 已链接
public enum BTCPeerStatus: Int {
    case disconnected = 0
    case connecting
    case connected
}

public class BTCPeer {
    
    public let bufferSize = 4096
    public let socketLockQueue = DispatchQueue(label: "cc.blocktree.bitcoinswift.socketLockQueue")
    
    //MARK: - 成员变量
    
    public var status: BTCPeerStatus = .disconnected
    public var address: UInt128                         //128位，ipv6格式地址
    public var port: Int32 = 0
    public var version: UInt32 = 0
    public var peerSocket: Socket? = nil
    
    //计算host名，ipv4: 255.255.255.255，ipv6：2001:0db8:85a3:08d3:1319:8a2e:0370:7344
    public var host: String {
        
        var bufLen: Int = 0
        var buf: [CChar]
        
        //ipv4
        if self.address.u64[0] == 0 && self.address.u16[5] == 0xffff {
            bufLen = Int(INET_ADDRSTRLEN)
            buf = [CChar](repeating: 0, count: bufLen)
            let sin_addr = [self.address.u32[3]]
            inet_ntop(AF_INET, sin_addr, &buf, socklen_t(bufLen))
        }
        //ipv6
        else {
            
            bufLen = Int(INET6_ADDRSTRLEN)
            buf = [CChar](repeating: 0, count: bufLen)
            inet_ntop(AF_INET6, self.address.u8, &buf, socklen_t(bufLen))
        }
        
        if let s = String(validatingUTF8: buf) {
            return s
        } else {
            return ""
        }
        
    }
    
    
    //MARK: - 初始化方法
    
    public init(address: UInt128, port: Int32) {
        self.address = address
        self.port = port
    }
    
    deinit {
        self.disconnect()
    }
    
    //MARK: - 成员方法
    
    public func connect() {
        //断开状态下可以建立连接
        guard self.status == .disconnected else {
            return
        }
        
        //建立异步连接
        do {
            
            // Create the signature...
            let signature = try Socket.Signature(protocolFamily: .inet, socketType: .stream, proto: .tcp, hostname: self.host, port: self.port)!
            
            // Create the socket...
            let socket = try Socket.create(family: .inet)
            
            // Connect to the server helper...
            try socket.connect(using: signature)
            if !socket.isConnected {
                
                fatalError("Failed to connect to the server...")
            }
            
            print("\nConnected to host: \(self.host):\(self.port)")
            print("\tSocket signature: \(socket.signature!.description)\n")
            
            self.handleSocketMessage(socket: socket)
            
            self.peerSocket = socket
            
            
        } catch let error {
            
            // See if it's a socket error or something else...
            guard let socketError = error as? Socket.Error else {
                
                print("Unexpected error...")
    
                return
            }
            
            print("testHostnameAndPort Error reported: \(socketError.description)")
 
        }
        
    }
    
    public func disconnect() {
        self.peerSocket?.close()
    }
    
    func handleSocketMessage(socket: Socket) {
        
        // Get the global concurrent queue...
        let queue = DispatchQueue.global(qos: .default)
        
        // Create the run loop work item and dispatch to the default priority global queue...
        queue.async { [unowned self, socket] in
            
            var shouldKeepRunning = true
            
            var readData = Data(capacity: self.bufferSize)
            
            do {
                // Write the welcome string...
                try socket.write(from: "Hello, type 'QUIT' to end session\nor 'SHUTDOWN' to stop server.\n")
                
                repeat {
                    let bytesRead = try socket.read(into: &readData)
                    
                    if bytesRead > 0 {
                        
                        let messages = try BTCMessageHandler.decodeMessage(readData: readData)
                        
                        print("messages = \(messages)")
                        
                        guard let response = String(data: readData, encoding: .utf8) else {
                            
                            print("Error decoding response...")
                            readData.count = 0
                            break
                        }
                        
                        print("Server received from connection at \(socket.remoteHostname):\(socket.remotePort): \(response) ")
                        let reply = "Server response: \n\(response)\n"
                        try socket.write(from: reply)
                        
                        
                    }
                    
                    if bytesRead == 0 {
                        
                        shouldKeepRunning = false
                        break
                    }
                    
                    readData.count = 0
                    
                } while shouldKeepRunning
                
                print("Socket: \(socket.remoteHostname):\(socket.remotePort) closed...")
                self.disconnect()
            
                
            } catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error by connection at \(socket.remoteHostname):\(socket.remotePort)...")
                    return
                }
                if self.status == .connected {
                    print("Error reported by connection at \(socket.remoteHostname):\(socket.remotePort):\n \(socketError.description)")
                }
            }
        }
    }
    
    
    
    //MARK: - 消息发送
    func sendMessage(message: Data) {
        
    }
    
    func sendVersionMessage() {
        
        var msg = Data()
        
        msg.append(BTCNodeConfig.shared.protocolVersion)
        msg.append(BTCNodeConfig.shared.enableServices)
        msg.append(UInt64(Date().timeIntervalSince1970))
        msg.append(BTCNodeServices.node_network.rawValue | BTCNodeServices.node_bloom.rawValue)
        
        
//
//        NSMutableData *msg = [NSMutableData data];
//        
//        uint16_t port = CFSwapInt16HostToBig(self.port);
//        
//        [msg appendUInt32:PROTOCOL_VERSION]; // version
//        [msg appendUInt64:ENABLED_SERVICES]; // services
//        [msg appendUInt64:[NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970]; // timestamp
//        [msg appendUInt64:self.services]; // services of remote peer
//        [msg appendBytes:&_address length:sizeof(_address)]; // IPv6 address of remote peer
//        [msg appendBytes:&port length:sizeof(port)]; // port of remote peer
//        [msg appendNetAddress:LOCAL_HOST port:BITCOIN_STANDARD_PORT services:ENABLED_SERVICES]; // net address of local peer
//        self.localNonce = ((uint64_t)arc4random() << 32) | (uint64_t)arc4random(); // random nonce
//        [msg appendUInt64:self.localNonce];
//        [msg appendString:USER_AGENT]; // user agent
//        [msg appendUInt32:0]; // last block received
//        [msg appendUInt8:0]; // relay transactions (no for SPV bloom filter mode)
//        self.pingStartTime = [NSDate timeIntervalSinceReferenceDate];
//        [self sendMessage:msg type:MSG_VERSION];
        
    }
    
    
    
    //TODO 消息接收
}
