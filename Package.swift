//
//  Package.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 02.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "BLETools",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(name: "BLETools", targets: ["BLETools"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(name: "BLETools", dependencies: []),
        .testTarget(name: "BLEToolsTests", dependencies: ["BLETools"]),
    ]
)
