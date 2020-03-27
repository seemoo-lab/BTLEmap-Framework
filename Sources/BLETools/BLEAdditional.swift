//
//  BLEAdditional.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 26.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct BLEMACAddress {
    public private(set) var addressString: String
    public private(set)var addressType: BLEAddressType
    
    public lazy var addressData  = {
        return addressString.replacingOccurrences(of: ":", with: "").hexadecimal!
    }()

    
    public enum BLEAddressType: String {
        case random
        case `public`
    }
}

public struct BLEService {
    public internal(set) var uuidString: String
    public internal(set) var description: String?
    public internal(set) var isPrimary: Bool
    
    init(with cbService: CBService) {
        self.uuidString = cbService.uuid.uuidString
        self.isPrimary = cbService.isPrimary
        self.description = cbService.uuid.description
    }
}
