//
//  CBCentralManagerExtension.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 05.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import CoreBluetooth

public extension CBManagerState {
    var description: String {
        switch self {
        case .poweredOff:
            return "Powered off"
        case .poweredOn:
            return "Powered on"
        case .resetting:
            return "Resetting"
        case .unauthorized:
            return "Unauthorized"
        case .unknown:
            return "Unknown"
        case .unsupported:
            return "Unsupported"
            
        @unknown default:
            return "Unknon state"
        }
    }
}
