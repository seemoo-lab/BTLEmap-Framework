//
//  BLERelayedAdvertisement.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 26.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation

struct BLERelayedAdvertisement: Codable {
    var manufacturerDataHex: String?
    var macAddress: String
    var rssi: Int
    var name: String?
    var flags: String?
    var addressType: String
    var connectable: Bool
    var rawData: String
    var serviceUUIDs: [String]?
    var serviceData16Bit: String?
    var serviceData32Bit: String?
    var serviceData128Bit: String?
    
    /// Service Data part of the advertisement. The Key is the UUID data and the value the assigned data
    var serviceData: [Data: Data] {
        var serviceData = [Data: Data]()
        if let s16 = serviceData16Bit?.hexadecimal {
            let uuid = s16.subdata(in: 0..<2)
            let data = s16.subdata(in: 2..<s16.endIndex)
            serviceData[uuid] = data
        }
        
        if let s32 = serviceData32Bit?.hexadecimal {
            let uuid = s32.subdata(in: 0..<4)
            let data = s32.subdata(in: 4..<s32.endIndex)
            serviceData[uuid] = data
        }
        
        if let s128 = serviceData128Bit?.hexadecimal {
            let uuid = s128.subdata(in: 0..<16)
            let data = s128.subdata(in: 16..<s128.endIndex)
            serviceData[uuid] = data
        }
        
        return serviceData
    }
}


