//
//  RandomBytesSequence.swift
//  BitcoinSwift
//
//  Created by Chance on 2017/4/12.
//
//

#if os(Linux) || os(Android) || os(FreeBSD)
    import Glibc
#else
    import Darwin
#endif


/// 随机字节序列
struct RandomBytesSequence: Sequence {
    let size: Int
    
    func makeIterator() -> AnyIterator<UInt8> {
        var count = 0
        return AnyIterator<UInt8>.init({ () -> UInt8? in
            if count >= self.size {
                return nil
            }
            count = count + 1
            //使用/dev/urandom，而不使用/dev/random的原因
            //https://sockpuppet.org/blog/2014/02/25/safely-generate-random-numbers/
            let fd = open("/dev/urandom", O_RDONLY)
            if fd <= 0 {
                return nil
            }
            
            var value: UInt8 = 0
            let result = read(fd, &value, MemoryLayout<UInt8>.size)
            precondition(result == 1)
            
            close(fd)
            return value
        })
    }
}
