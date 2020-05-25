//
//  AirDropDecoder.swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 09.03.20.
//

import Foundation

public extension AppleBLEDecoding {
    struct AirDropDecoder: AppleBLEDecoder {
        public var decodableType: UInt8 {
            return 0x5
        }
        
        public func decode(_ data: Data) throws -> [String : DecodedEntry] {
            var i = data.startIndex
            var describingDict = [String: DecodedEntry]()
            guard data.count >= 11 else {throw Error.incorrectLength}
            
            let zeros = data[i...i+7]
            if zeros != Data(repeating: 0x00, count: 8) {
                Log.error(system: .ble_decoder, message: "Expected 8 bytes of zeros")
                return describingDict
            }
            describingDict["zeroPadding"] = DecodedEntry(value: zeros, byteRange: data.byteRange(from: i, to: i+7))
            
            i += 8
            
            let airDropVersion = data[i]
            describingDict["AirDropVersion"] = DecodedEntry(value: airDropVersion, byteRange: data.byteRange(from: i, to: i))
            i+=1
            
            var contactHashes = [Data]()
            var hashRange = UInt(i)...UInt(i)
            
            while i+2 <= data.endIndex {
                let hash = data[i..<i+2]
                contactHashes.append(hash)
                hashRange = hashRange.lowerBound...UInt(i+2)
                i+=2
            }
            
            describingDict["contactHashes"] = DecodedEntry(value: contactHashes, byteRange: hashRange)
                    
            
            let zero = data[i]
            if zero != 0x00 {
                Log.error(system: .ble_decoder, message: "Expected trailing zero")
                return describingDict
            }
            
            
            return describingDict
        }
        
        
    }
}
