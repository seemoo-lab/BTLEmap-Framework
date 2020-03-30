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


