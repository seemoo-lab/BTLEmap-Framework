//
//  BLEManufacturer.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 03.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation


public enum BLEManufacturer: String, CaseIterable {
    case apple
    case unknown
    case samsung
    case microsoft
    case google
    case elgato
    case sonos
    case huawei
    case oppo
    case sony
    case sonyEricsson
    case nokia
    case ericsson
    case intel
    case ibm
    case motorola
    case broadcom
    case amazon
    case seemoo
    
    public var name: String {
        switch self {
        case .apple:
            return "Apple"
        case .unknown:
            return "Unknown"
        default:
            return self.rawValue
        }
        
    }
    
    public static func fromCompanyId(_ companyID: Data) -> BLEManufacturer {
        guard companyID.count == 2 else {return .unknown}
        
        switch Array(companyID) {
        case [0x4c,0x00]:
            return .apple
        case [0x75, 0x00]:
            return .samsung
        case [0x06,0x00]:
            return .microsoft
        case [0xe0, 0x00]:
            return .google
        case [0xa7,0x05]:
            return .sonos
        case [0xce,00]:
            return .elgato
        case [0x7d, 0x02]:
            return .huawei
        case [0x9a, 0x07]:
            return .oppo
        case [0x2d, 0x01]:
            return .sony
        case [0x56, 0x00]:
            return .sonyEricsson
        case [0x01,0x00]:
            return .nokia
        case [0x00,0x00]:
            return .ericsson
        case [0x02,0x00]:
            return .intel
        case [0x03,0x00]:
            return .ibm
        case [0x08,0x00]:
            return .motorola
        case [0x00,0x0f]:
            return .broadcom
        case [0x71,0x01]:
            return .amazon
        case [0x5e,0x00]:
            return .seemoo
        default:
            return .unknown
        }
    }
}
