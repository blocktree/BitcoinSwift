//
//  BTCPeer_Tests.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/5/20.
//
//

import XCTest
@testable import BitcoinSwift

class BTCPeer_Tests: XCTestCase {
    
    let QUIT: String = "QUIT"
    let port: Int32 = 8333
    //    let host: String = "::ffff:7f00:0001"
    let host: String = "73.243.216.34"
    let path: String = "/tmp/server.test.socket"
    
    override func setUp() {
        super.setUp()
        print("//////////////////// 测试开始 ////////////////////\n")
    }
    
    override func tearDown() {
        print("//////////////////// 测试结束 ////////////////////\n")
        super.tearDown()
    }
    
    
    /// 测试地址转换host
    func testAddressToHost() {
        
        do {
            //测试 ipv4
            let u128: [UInt32] = [UInt32(bigEndian: 0x00),
                                  UInt32(bigEndian: 0x00),
                                  UInt32(bigEndian: 0x0000ffff),
                                  UInt32(bigEndian: 0x49f3d822)]
            let address = UInt128(u128)
            let peer = BTCPeer(address: address, port: port)
            print("host = \(peer.host)")
            XCTAssert("73.243.216.34" == peer.host, "error host = \(peer.host)")
        }
        
        do {
            let u128: [UInt32] = [UInt32(bigEndian: 0x20010db8),
                                  UInt32(bigEndian: 0x85a308d3),
                                  UInt32(bigEndian: 0x13198a2e),
                                  UInt32(bigEndian: 0x03707344)]
            let address = UInt128(u128)
            let peer = BTCPeer(address: address, port: port)
            print("host = \(peer.host)")
            XCTAssert("2001:db8:85a3:8d3:1319:8a2e:370:7344" == peer.host, "error host = \(peer.host)")
        }
    }
    
    //    func testPeerConnect() {
    //        let peer = BTCPeer(host: self.host, port: port)
    //        peer.host = self.host
    //        //peer.connect()
    //    }
    
    
    //运行一个接收监听的服务端
    
    func launchServerHelper(family: Socket.ProtocolFamily = .inet) {
        
        let queue: DispatchQueue? = DispatchQueue.global(qos: .userInteractive)
        guard let pQueue = queue else {
            
            print("Unable to access global interactive QOS queue")
            XCTFail()
            return
        }
        
        pQueue.async { [unowned self] in
            
            do {
                
                try self.serverHelper(family: family)
                
            } catch let error {
                
                guard let socketError = error as? Socket.Error else {
                    
                    print("Unexpected error...")
                    XCTFail()
                    return
                }
                
                print("launchServerHelper Error reported:\n \(socketError.description)")
                XCTFail()
            }
        }
    }
    
    func serverHelper(family: Socket.ProtocolFamily = .inet) throws {
        
        var keepRunning: Bool = true
        var listenSocket: Socket? = nil
        
        do {
            
            try listenSocket = Socket.create(family: family)
            
            guard let listener = listenSocket else {
                
                print("Unable to unwrap socket...")
                XCTFail()
                return
            }
            
            var socket: Socket
            
            // Are we setting uo a TCP or UNIX based server?
            if family == .inet || family == .inet6 {
                
                // Setting up TCP...
                try listener.listen(on: Int(port), maxBacklogSize: 10)
                
                print("Listening on port: \(port)")
                
                socket = try listener.acceptClientConnection()
                
                print("Accepted connection from: \(socket.remoteHostname) on port \(socket.remotePort), Secure? \(socket.signature!.isSecure)")
                
            } else {
                
                // Setting up UNIX...
                try listener.listen(on: path, maxBacklogSize: 10)
                
                print("Listening on path: \(path)")
                
                socket = try listener.acceptClientConnection()
                
                print("Accepted connection from: \(socket.remotePath!), Secure? \(socket.signature!.isSecure)")
                
            }
            
            try socket.write(from: "Hello, type 'QUIT' to end session\n")
            
            var bytesRead = 0
            repeat {
                
                var readData = Data()
                bytesRead = try socket.read(into: &readData)
                
                if bytesRead > 0 {
                    
                    guard let response = NSString(data: readData, encoding: String.Encoding.utf8.rawValue) else {
                        
                        print("Error decoding response...")
                        readData.count = 0
                        XCTFail()
                        break
                    }
                    
                    if response.hasPrefix(QUIT) {
                        
                        keepRunning = false
                    }
                    
                    // TCP or UNIX?
                    if family == .inet || family == .inet6 {
                        print("Server received from connection at \(socket.remoteHostname):\(socket.remotePort): \(response) ")
                    } else {
                        print("Server received from connection at \(socket.remotePath!): \(response) ")
                    }
                    
                    let reply = "Server response: \n\(response)\n"
                    try socket.write(from: reply)
                    
                }
                
                if bytesRead == 0 {
                    
                    break
                }
                
            } while keepRunning
            
            socket.close()
            XCTAssertFalse(socket.isActive)
            
        } catch let error {
            
            guard let socketError = error as? Socket.Error else {
                
                print("Unexpected error...")
                XCTFail()
                return
            }
            
            // This error is expected when we're shutting it down...
            if socketError.errorCode == Int32(Socket.SOCKET_ERR_WRITE_FAILED) {
                return
            }
            print("serverHelper Error reported: \(socketError.description)")
            XCTFail()
        }
    }
    
}
