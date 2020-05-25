//
//  DecoderProtocol.swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 06.03.20.
//

import Foundation

public struct AppleBLEDecoding {
    public static func decoder(forType type: UInt8) throws -> AppleBLEDecoder {
        switch type {
        case 0x07:
            return AirPodsBLEDecoder()
        case 0x10:
            return NearbyDecoder()
        case 0x05:
            return AirDropDecoder()
        case 0x09:
            return AirPlayTargetDecoder()
        case 0x08:
            return HeySiriDecoder()
        case 0x06:
            return HomeKitDecoder()
        case 0x0B:
            return MagicSwitchDecoder()
        case 0x0f:
            return NearbyActionDecoder()
        case 0x0e:
            return TetheringSourceDecoder()
        case 0x0d:
            return TetheringTargetDecoder()
        case 0x0c:
            return HandoffDecoder() 
        default:
            throw Error.decoderNotAvailable
        }
    }
    
    public struct DecodedEntry: CustomStringConvertible {
        public var description: String {
            if let data = value as? Data {
                return data.hexadecimal.separate(every: 2, with: " ")
            }
            
            if let array = value as? [Any] {
                return array.map{String(describing: $0)}.joined(separator: ", ")
            }
            
            return String(describing: value)
        }
        
        public var value: Any
        public var byteRange: ClosedRange<UInt>
        
        init(value: Any, byteRange: ClosedRange<UInt>) {
            self.value = value
            self.byteRange = byteRange
        }
        
        init(value: Any, dataRange: ClosedRange<Data.Index>, data: Data) {
            self.value = value
            self.byteRange = data.byteRange(from: dataRange.lowerBound, to: dataRange.upperBound)
        }
    }
}

public protocol AppleBLEDecoder {
    /// The type that can be decoded using this decoder
    var decodableType: UInt8 {get}
    
    /// Decode the data for the decodable type
    /// - Parameter data: BLE manufacturer data that should be decoded
    /// - returns: A dictionary describing the content 
    func decode(_ data: Data) throws -> [String: AppleBLEDecoding.DecodedEntry]
    

}

//
//
//public protocol AppleBLEMessage {
//    var data: Data {get}
//}



public extension AppleBLEDecoding {
enum Error: Swift.Error {
    case incorrectType
    case incorrectLength
    case failedDecoding
    case decoderNotAvailable
}
}



