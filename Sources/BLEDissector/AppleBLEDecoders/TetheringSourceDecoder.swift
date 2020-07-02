//
//  TetheringSourceDecoder.swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 09.03.20.
//

import Foundation

public extension AppleBLEDecoding {
    struct TetheringSourceDecoder: AppleBLEDecoder {
        public var decodableType: UInt8 {0x0e}
        
        public func decode(_ data: Data) throws -> [String : DecodedEntry] {
            guard data.count >= 5 else {throw Error.incorrectLength}
            
            var i = data.startIndex
            var describingDict = [String: DecodedEntry]()
            
            describingDict["version"] = DecodedEntry(value: data[i], byteRange: i...i)
            i+=1
            describingDict["flags"] = DecodedEntry(value: data[i], byteRange: i...i)
            i+=1
            describingDict["batteryLife"] = DecodedEntry(value: data[i], byteRange: i...i)
            i+=1
            describingDict["data"] = DecodedEntry(value: data[i], byteRange: i...i)
            i+=1
            
            let cellularConnection = DecodedEntry(value: data[i], byteRange: i...i)
            
            let connectionType = CellularConnection(rawValue: cellularConnection.value as! UInt8) ?? CellularConnection.unkown
            
            describingDict["cellularConnectionType"] = DecodedEntry(value: connectionType, byteRange: cellularConnection.byteRange)
            describingDict["cellularConnectionRaw"] = cellularConnection
            i+=1
            
            describingDict["cellSignal"] = DecodedEntry(value: data[i], byteRange: i...i)
            
            return describingDict
        }
        
        public enum CellularConnection: UInt8 {
            case gsm = 0x00
            case rtt = 0x01
            case gprs = 0x02
            case edge = 0x03
            case threeGEVDO = 0x04
            case threeG = 0x05
            case fourG = 0x06
            case lte = 0x07
            case fiveG = 0x08
            case unkown = 0xff
            
            var name: String {
                switch self {
                case .gsm: return "GSM"
                case .rtt: return "1xRTT"
                case .threeGEVDO: return "3G EV-DO"
                case .threeG: return "3G"
                case .fourG: return "4G"
                case .fiveG: return "5G"
                default:
                    return String(describing: self).uppercased()
                }
            }
        }
        
        
    }
}
