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
    
    public var addressData: Data {
        return addressString.replacingOccurrences(of: ":", with: "").hexadecimal!
    }
    
    init(addressString: String, addressType: BLEAddressType) {
        self.addressString = addressString
        self.addressType = addressType
    }
    
    init(addressData: Data, addressTypeInt: Int) {
        //Convert to address string
        self.addressString = addressData.hexadecimal.uppercased().separate(every: 2, with: ":")
        
        switch addressTypeInt {
        case 0:
            self.addressType = .public
        case 1:
            self.addressType = .random
        default:
            self.addressType = .unknown
        }
    }
    
    public enum BLEAddressType: String {
        case random
        case `public`
        case unknown
    }
}


