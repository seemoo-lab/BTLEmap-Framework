//
//  BLERelayCharacteristics.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 30.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BLERelayCharacteristics: Codable {
    var macAddress: String
    var service: BLERelayedService
    var characteristics: [BLERelayCharacteristic]
}


struct BLERelayCharacteristic: Codable, CustomStringConvertible {
    
    /// Characteristic UUID
    var uuid: CBUUID
    /// Common name for the chararacteristic if avaible. Otherwise UUID in a string format
    var commonName: String
    
    /// Value read from the characteristic
    var value: Data
    
    var description: String {
        "BLERelayCharacteristic:\n\(commonName) - \(String(data: value, encoding: .ascii) ?? value.hexadecimal)"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let uuidHex: String = try container.decode(String.self, forKey: .uuid)
        if let uuidData = uuidHex.hexadecimal {
            self.uuid = CBUUID(data: uuidData)
        }else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.uuid, in: container, debugDescription: "Could not convert hex to data")
        }
        let valueHex = try container.decode(String.self, forKey: .value)
        if let value = valueHex.hexadecimal {
            self.value = value
        }else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.value, in: container, debugDescription: "Could not convert hex to data")
        }
        
        self.commonName = try container.decode(String.self, forKey: .commonName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid.data.hexadecimal, forKey: .uuid)
        try container.encode(commonName, forKey: .commonName)
        try container.encode(value.hexadecimal, forKey: .value)
    }
    
    enum CodingKeys: CodingKey {
        case uuid
        case commonName
        case value
    }
}
