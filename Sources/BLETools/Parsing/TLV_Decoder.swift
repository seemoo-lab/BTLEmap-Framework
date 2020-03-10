//
//  TLV_Decoder.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 10.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import Apple_BLE_Decoder

extension TLV.TLVBox {
    
    public func getDescription(for type: BLEAdvertisment.AppleAdvertisementType) -> [String: Any]? {
        guard let advData = self.getValue(forType: type.rawValue) else {return nil}
        let description =  try? AppleBLEDecoding.decoder(forType: UInt8(type.rawValue)).decode(advData)
        
        return description
    }
    
}
