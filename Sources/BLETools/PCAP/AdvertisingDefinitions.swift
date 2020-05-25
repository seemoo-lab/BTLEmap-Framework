//
//  AdvertisiingDefinitions.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 11.05.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation

enum AdvertisementType: UInt8 {
    case ADV_IND = 0x00
    case ADV_DIRECT_IND = 0x01
    case ADV_SCAN_IND = 0x02
    case ADV_NONCONN_IND = 0x03
    case SCAN_RSP = 0x04
}

enum BLE_AddressType: UInt8 {
    case `public` = 0x00
    case random = 0x01
    case publicIdentity = 0x02
    case randomStaticIdentity = 0x03
}

// https://www.bluetooth.com/specifications/assigned-numbers/generic-access-profile/
enum ADType: UInt8 {
    case flags = 0x01
    case completeServiceUUIDs16Bit = 0x03
    case completeServiceUUIDs32Bit = 0x05
    case completeServiceUUIDs128Bit = 0x07
    case shortenedLocalName = 0x08
    case completeLocalName = 0x09
    case txPowerLevel = 0x0a
    case serviceData16BitUUID = 0x16
    case serviceData32BitUUID = 0x20
    case serviceData128BitUUID = 0x21
    case manufacturerData = 0xff
}
