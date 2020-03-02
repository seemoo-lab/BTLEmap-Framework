//
//  InttoData.swift
//  Handoff-Swift
//
//  Created by Alexander Heinrich on 11.07.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Foundation

extension Int {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int>.size)
    }
}

extension Int8 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int8>.size)
    }
}

extension Int16 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int16>.size)
    }
}

extension Int32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int32>.size)
    }
}

extension Int64 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int64>.size)
    }
}

extension UInt8 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt8>.size)
    }
}

extension UInt16 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
    }
}

extension UInt32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
    }
    
    var byteArrayLittleEndian: [UInt8] {
        return [
            UInt8((self & 0xFF000000) >> 24),
            UInt8((self & 0x00FF0000) >> 16),
            UInt8((self & 0x0000FF00) >> 8),
            UInt8(self & 0x000000FF)
        ]
    }
}

extension UInt {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt>.size)
    }
}

extension UInt64 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt>.size)
    }
}

extension Data {
    var uint: UInt? {
        guard self.count <= MemoryLayout<UInt>.size else {return nil}
        switch self.count {
        case 1:
            return UInt(self[self.startIndex])
        case 2:
            var value: UInt16 = 0
            _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
            return UInt(value)
        case 4:
            var value: UInt32 = 0
            _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
            return UInt(value)
        case 8:
            var value: UInt64 = 0
            _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
            return UInt(value)
        default:
            return nil
        }
    }
}
