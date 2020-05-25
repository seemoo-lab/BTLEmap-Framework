//
//  TetherinTargetDecoder.swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 09.03.20.
//

import Foundation

public extension AppleBLEDecoding {
    struct TetheringTargetDecoder: AppleBLEDecoder {
        
        public var decodableType: UInt8 {0x0d}
        
        public func decode(_ data: Data) throws -> [String : DecodedEntry] {
            guard data.count >= 4 else {throw Error.incorrectLength}
            
            let i = data.startIndex
            var describingDict = [String: DecodedEntry]()
            
            let identifier = data[i..<i+4]
            describingDict["identifier"] = DecodedEntry(value: identifier, byteRange: data.byteRange(from: i, to: i+3))
            
            return describingDict
        }
        
        
    }
}
