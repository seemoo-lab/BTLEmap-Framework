//
//  MagicSwitchDecoder.swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 09.03.20.
//

import Foundation

public extension AppleBLEDecoding {
    struct MagicSwitchDecoder: AppleBLEDecoder {
        public var decodableType: UInt8 {0x0B}
        
        public func decode(_ data: Data) throws -> [String : DecodedEntry] {
            guard data.count >= 3 else {throw Error.incorrectLength}
            
            var i = data.startIndex
            var describingDict = [String: DecodedEntry]()
            
            let magicSwitchData = data[i..<i+2]
            describingDict["magicSwitchData"] = DecodedEntry(value: magicSwitchData, byteRange: data.byteRange(from: i, to: i+1))
            i+=2
            
            let watchWristInt = data[i]
            let watchOnWrist = WatchOnWrist(rawValue: watchWristInt) ?? .unknown
            describingDict["watchOnWrist"] = DecodedEntry(value: watchOnWrist, byteRange: data.byteRange(from: i, to: i))
            
            return describingDict
        }
        
        public enum WatchOnWrist: UInt8 {
            case notOnWrist = 0x03
            case wristDetectionDisabled = 0x1f
            case onWrist = 0x3f
            case unknown = 0xff
        }
        
        
    }
}
