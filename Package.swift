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
        .package(url:"https://dev.seemoo.tu-darmstadt.de/aheinrich/apple-ble-decoder.git", .branch("master"))
    ],
    targets: [
        .target(name: "BLETools", dependencies: ["BLEDissector"]),
    ]
)
