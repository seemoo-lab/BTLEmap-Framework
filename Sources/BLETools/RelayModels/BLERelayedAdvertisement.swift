//
//  BLERelayedAdvertisement.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 26.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation

struct BLERelayedAdvertisement: Codable {
    var manufacturerDataHex: String
    var macAddress: String
    var rssi: Int
    var name: String?
    var flags: String?
    var addressType: String
    var connectable: Bool
}


