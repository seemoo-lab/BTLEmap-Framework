//
//  BLEManufacturer.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 03.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation


public enum BLEManufacturer: UInt8 {
    case apple = 0x4c
    case unknown = 0x00
    
    public var name: String {
        switch self {
        case .apple:
            return "Apple"
        case .unknown:
            return "Unknown"
        }
        
    }
}
