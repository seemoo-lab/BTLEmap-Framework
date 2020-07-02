//
//  DecoderProtocol.swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 06.03.20.
//

import Foundation

public struct ManufacturerDataDissector {
    public static func dissect(data: Data) -> DissectedEntry {
        var manufacturerData = DissectedEntry(name: "Manufacturer Data", value: data, data: data, byteRange: data.startIndex...data.endIndex, subEntries: [], explanatoryText: nil)
        
        
        //Check if this is matches Apple's company id
        
        let companyId = data.subdata(in: data.startIndex..<data.startIndex+2)
        if companyId == Data([0x4c, 00]) {
            let appleAdvertisement = data[(data.startIndex+2)...]
            let entries = AppleMDataDissector.dissect(data: appleAdvertisement)
            manufacturerData.subEntries.append(contentsOf: entries)
        }
        
        return manufacturerData
    }
}

struct AppleMDataDissector {
    static func dissect(data: Data) -> [DissectedEntry] {
        //Decode TLV
        var entries = [DissectedEntry]()
        var dI = data.startIndex
        while dI < data.endIndex {
            let advType = data[dI]
            dI += 1
            let advLength = data[dI]
            dI += 1
            guard advLength > 0 && Int(advLength) + dI <= data.endIndex else {break}
            let range = dI...dI+Int(advLength)-1
            let advData = data[range]
            dI += Int(advLength)
            
            entries.append(self.dissectPart(advertisementType: advType, advData: advData, range: range))
        }
        
        return entries
    }
    
    fileprivate static func dissectPart(advertisementType: UInt8, advData: Data, range: ClosedRange<Data.Index>) -> DissectedEntry {
        if advertisementType == 0x12 {
            return OfflineFindingDissector.dissect(data: advData)
        }
        
        do {
            //get the decoder and decode
            let decoder = try AppleBLEDecoding.decoder(forType: advertisementType)
            let decodedAdvertisement = try decoder.decode(advData)
            
            //Convert to dissected entry
            let advertisementTEnum = AppleAdvertisementType(rawValue: UInt(advertisementType)) ?? .unknown
            
            let sortedEntries = decodedAdvertisement.map({($0.key, $0.value)}).sorted { (lhs, rhs) -> Bool in
                if lhs.1.byteRange.lowerBound < rhs.1.byteRange.lowerBound {
                    return true
                }
                
                return lhs.1.byteRange.lowerBound == rhs.1.byteRange.lowerBound && lhs.1.description.lowercased() < rhs.1.description.lowercased()
            }
            
            var entry = DissectedEntry(name: advertisementTEnum.description, value: advData, data: advData, byteRange: range, subEntries: [])
            
            for (description, decodedEntry) in sortedEntries {
                
                var bRange = Int(decodedEntry.byteRange.lowerBound)...Int(decodedEntry.byteRange.upperBound)
                
                if bRange.upperBound >= advData.endIndex {
                    bRange = bRange.lowerBound...advData.endIndex-1
                }
                if bRange.lowerBound < advData.startIndex {
                    bRange = advData.startIndex...bRange.upperBound
                }
                
                let subEntry = DissectedEntry(name: description, value: decodedEntry.value, data: advData[bRange], byteRange: bRange, subEntries: [])
                
                entry.subEntries.append(subEntry)
            }
            
            
            return entry
            
        }catch {
            return DissectedEntry(name: AppleAdvertisementType.unknown.description, value: advData, data: advData, byteRange: range, subEntries: [])
        }
        
    }
    
}

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
        public var byteRange: ClosedRange<Data.Index>
        
        init(value: Any, byteRange: ClosedRange<Data.Index>) {
            self.value = value
            self.byteRange = byteRange
        }
        
        init(value: Any, dataRange: ClosedRange<Data.Index>, data: Data) {
            self.value = value
            self.byteRange = dataRange
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



