//
//  File.swift
//  
//
//  Created by Alex - SEEMOO on 22.05.20.
//

import Foundation

//TODO: Move dissectiing to this class:

//public struct ManufacturerDataDissectors {
//
//    /// Dissect the manufacturer data
//    /// - Parameter data: manufacturer data
//    /// - Returns: Dissected entries with optional sub entries
//    public static func dissect(data: Data) -> DissectedEntry {
//        //Parse the manufacturer at first
//        let companyRange = data.startIndex..<data.startIndex+2
//        let companyID = data.subdata(in: companyRange)
//        let manufacturer = BLEManufacturer.fromCompanyId(companyID)
//
//        let bleData = data.subdata(in: 2..<data.endIndex)
//
//        var dissectedEntry = DissectedEntry(name: "Manufacturer", value: manufacturer, data: companyID, byteRange: 0..<2, subEntries: [])
//
//        switch manufacturer {
//        case .apple:
//            // Apple dissectors are available
//            self.decodeAppleManufacturerData(bleData)
//
//        default:
//            break
//        }
//    }
//
////    static func decodeAppleManufacturerData(_ bleData: Data) -> DissectedEntry {
////        // Apple uses TLVs for many advertisements, but not for all of them.
////
////        let advType = bleData[0]
////        let lengthByte = bleData[1]
////
////        do {
////            let decoder = AppleBLEDecoding.decoder(forType: advType)
////
////        }catch {
////
////        }
////
////
////    }
//}
