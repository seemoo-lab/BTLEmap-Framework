//
//  BLERelayCommand.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 07.04.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation

struct BLERelayCommand: Codable {
    var scanning: Bool?
    var autoconnect: Bool? 
}
