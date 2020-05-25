//
//  Akr.swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 09.03.20.
//

import Foundation

public extension AppleBLEDecoding {
    struct AirPlayTargetDecoder: AppleBLEDecoder {
        public var decodableType: UInt8 {return 0x09}
        
        public func decode(_ data: Data) throws -> [String : DecodedEntry] {
            var i = data.startIndex
            var describingDict = [String: DecodedEntry]()
            guard data.count >= 6 else {throw Error.incorrectLength}
            
            let flags = data[i]
            describingDict["flags"] = DecodedEntry(value: flags, byteRange: data.byteRange(from: i, to: i))
            i+=1
            
            let configSeed = data[i]
            describingDict["configSeed"] = DecodedEntry(value: configSeed, byteRange: data.byteRange(from: i, to: i))
            i+=1
            
            let ipv4Address = data[i...i+3]
            describingDict["ipv4AddressHex"] = DecodedEntry(value: ipv4Address.hexadecimal, byteRange: data.byteRange(from: i, to: i+3))
            
            var ipArray = Array<UInt8>(ipv4Address)
            var ipString : [CChar] = Array<CChar>(repeating: 0x00, count: 32)
            if  inet_ntop(AF_INET, &ipArray, &ipString, 32) != nil {
                let ipv4AddressStirng = String(cString: &ipString)
                describingDict["ipv4Address"] = DecodedEntry(value: ipv4AddressStirng, byteRange: data.byteRange(from: i, to: i+3))
            }
            
            return describingDict
        }
        
        
    }
}
