#  BLETools

BLETools is a Swift based framework that is used for Bluetooth Low Energy (BLE) analysis on iOS (iPadOS), macOS and watchOS.
BLETools is the main framework used in our app `BTLEmap`. 

The framework uses `Combine` for the data flow and automatically updating interfaces with `SwiftUI`. Therefore, it needs at least iOS 13 or macOS 10.15 Catalina.  

## Installation 

`BLETools` uses  the Swift Package Manager to be installed. To import it by using Xcode: Click at your project -> Swift Packages -> + Button -> Enter the GitHub URL. 

To import it by using a Swift Package file: 
```swift 
.package(url: "https://github.com/seemoo-lab/BTLEmap-Framework.git",     .upToNextMajor(from: "0.9"))
```

## Usage 
The main class is the `BLEScanner`, which can be connected to different `BLEReceivers`. By default  it uses `CoreBluetooth` to discover BLE Devices and BLE advertisements. 

The source code below shows how to setup `BLEScanner` and receive real-time updates for BLE devices. 
The BLEScanner scans until scanning is set to `false` again. The scanner updates it  devices, deviceList and advertisements from the received BLE advertisements. 


```swift
let scanner = BLEScanner(
    devicesCanTimeout: true,
    timeoutInterval: 360,
    filterDuplicates: false,
    receiverType: .coreBluetooth,
    autoconnect: true)
    
scanner.scanning = true 
```

For real-time updates the object can be observed with `@ObservedObject` in SwiftUI or one can subscribe to the subjects: `newAdvertisementSubject` and `newDeviceSubject`. 

### Integrating with SwiftUI 
```swift
struct DeviceList: View {
    @EnvironmentObject var scanner: BLEScanner
    
    var body: some View {
        List(self.scanner.deviceList) { device in
            Text(device.id)
        }
    }
}
```

### BLEAdvertisement 
The BLEAdvertisement class represents a received BLE advertising packet. The contains a object-oriented decoded BLE packet. 
All variables and methods are documented. 

### BLEDevice 
The BLEDevice class represents a BLE peripheral that send advertisements. In CoreBluetooth those are normally CBPeripherals 

## Raspberry PI support 
