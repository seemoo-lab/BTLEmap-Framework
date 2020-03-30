//
//  BLERelayedServices.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 30.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BLERelayedServices: Codable {
    var macAddress: String
    var services: [BLERelayedService]
}

struct BLERelayedService: Codable {
    /// Service UUID
    var uuid:CBUUID
    /// Common name for the service if avaible. Otherwise UUID in a string format
    var commonName: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let uuidHex: String = try container.decode(String.self, forKey: .uuid)
        if let uuidData = uuidHex.hexadecimal {
            self.uuid = CBUUID(data: uuidData)
        }else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.uuid, in: container, debugDescription: "Could not convert hex to data")
        }
        self.commonName = try container.decode(String.self, forKey: .commonName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid.data.hexadecimal, forKey: .uuid)
        try container.encode(commonName, forKey: .commonName)
    }
    
    enum CodingKeys: CodingKey {
        case uuid
        case commonName
    }
}
