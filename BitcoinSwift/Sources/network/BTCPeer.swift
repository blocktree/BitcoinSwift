//
//  BTCPeer.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/5/2.
//
//

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
//    public var address: Data = Data(repeating: 0, count: 16)    //128位地址
    public var port: Int32 = 0
    public var version: UInt32 = 0
    public var host: String = ""
    public var peerSocket: Socket? = nil
    
    //MARK: - 初始化方法
    
    public init(host: String, port: Int32) {
        self.host = host
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
    
    
    //TODO 消息接收
    
    //TODO 消息解析
}
