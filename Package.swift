// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "BLETools",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(name: "BLEDissector", targets: ["BLEDissector"]),
        .library(name: "BLETools", targets: ["BLETools"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "BLEDissector", dependencies: []),
        .target(name: "BLETools", dependencies: ["BLEDissector"]),
        // Tests 
        .testTarget(name: "BLEDissectorTests", dependencies: ["BLEDissector"])
    ]
)
