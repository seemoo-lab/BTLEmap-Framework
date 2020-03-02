// swift-tools-version:5.1
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
    ]
)
