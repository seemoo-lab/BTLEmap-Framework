//
//  BLERelayReceiver.swift
//  BLE_Relay_Receiver
//
//  Created by Alex - SEEMOO on 25.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import Combine

/// This class is used to relayed BLE advertisements from a BLE Receiver.
/// The receiver connects to this service and sends all BLE advertisements as TCP Packets.
/// The packets will be received here and can be forwarded by any application
class BLERelayReceiver: NSObject, ObservableObject, BLEReceiverProtocol {
    var delegate: BLEReceiverDelegate?
    
    var port: Int = -1
    
    var inputStreams = [InputStream]()
    var outputStreams = [OutputStream]()
    
    var receivingQueue = DispatchQueue.global(qos: .userInteractive)
    
    var service: NetService!
    
    //MARK: Published variables
    /// Messages received over the BLE relay service
    @Published var receivedMessages = [Data]()
    /// True if the receive service has been published
    @Published var servicePublished = false
    /// Set to true after the BLE receiver has connected
    @Published var connected = false
    
    override init() {
        super.init()
        
        let port = (arc4random() + 10000) % 65535
        self.service = NetService(domain: "local.", type: "_ble_relay_recv._tcp.", name: "", port: Int32(port))
        service.delegate = self
        service.includesPeerToPeer = true
    }
    
    /// Start receiving advertisements from an external source
    /// - Parameter filterDuplicates: Currently ignored for this receiver -> Always *false*
    func scanForAdvertisements(filterDuplicates: Bool) {
        self.announceService()
    }
    
    func stopScanningForAdvertisements() {
        self.service.stop()
        self.inputStreams.forEach({$0.close()})
        self.inputStreams.removeAll()
        self.outputStreams.forEach({$0.close()})
        self.outputStreams.removeAll()
    }
    
    
    /// Announce the service on all interfaces
    func announceService() {
        service.publish(options: [.listenForConnections])
    }
    
    /// Received a message from the BLE receiver (Raspberry Pi)
    /// - Parameter message: Message as Data that has been received
    func received(message: Data) {
        Log.debug(system: .BLERelay, message: "Received packet from BLE Relay\n %@", String(data: message, encoding: .ascii) ?? "nil")
        self.receivedMessages.append(message)
        
        //Decode the json to a relayed advertisement
        do {
            let adv = try JSONDecoder().decode(BLERelayedAdvertisement.self, from: message)
            
            let bleAdv = try BLEAdvertisment(relayedAdvertisement: adv)
            
            self.delegate?.didReceive(advertisement: bleAdv)
            
        }catch let error {
            Log.error(system: .BLERelay, message: "Could not decode JSON %@", String(describing: error))
        }
        
    }
    
    /// Read messages from the current input stream
    /// - Parameter inputStream: Input stream
    func read(from inputStream: InputStream) {
        
        while true {
            //Read how many bytes the next packet will have
            var lenBuffer = Array<UInt8>(repeatElement(0x00, count: 4))
            guard inputStream.read(&lenBuffer, maxLength: lenBuffer.count) > 0 else {
                Log.error(system: .BLERelay, message: "Did not receive bytes. Waiting until new bytes are available")
                break
            }
            //Read packet
            let packetLength = UInt32(littleEndian: unsafeBitCast((lenBuffer[0], lenBuffer[1], lenBuffer[2], lenBuffer[3]), to: UInt32.self))
            var packetBuffer = Array<UInt8>(repeatElement(0x00, count: Int(packetLength)))
            guard  inputStream.read(&packetBuffer, maxLength: packetBuffer.count) > 0 else {
                Log.error(system: .BLERelay, message: "Did not receive bytes that have been expected. Stopping.")
                inputStream.close()
                break
            }
            
            //Call receive method
            let message = Data(packetBuffer)
            DispatchQueue.main.async {
                self.received(message: message)
            }
        }
    }
}

//MARK:- Net Service Delegate
extension BLERelayReceiver: NetServiceDelegate {
    func netServiceDidPublish(_ sender: NetService) {
        self.port = sender.port
    }
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
//        inputStream.delegate = self
        
        self.connected = true
        
        //Open the streams
        inputStream.open()
        outputStream.open()
        
        Log.default(system: .BLERelay, message: "Connection opened")
        
        inputStreams.append(inputStream)
        outputStreams.append(outputStream)
        
        self.receivingQueue.async {
            self.read(from: inputStream)
        }
    }
}

extension BLERelayReceiver: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if let inputStream = aStream as? InputStream {
            switch eventCode {
//            case .hasBytesAvailable:
//                //Start reading
////                self.receivingQueue.async {
////                    self.read(from: inputStream)
////                }
            case .errorOccurred:
                let error = inputStream.streamError
                Log.error(system: .BLERelay, message: "Stream error: %@", String(describing: error))
//            case .openCompleted:
//                Log.info(system: .BLERelay, message: "Stream opened")
//                if inputStream.hasBytesAvailable {
////                    self.receivingQueue.async {
////                        self.read(from: inputStream)
////                    }
//                }
                
            default:
                Log.info(system: .BLERelay, message: "Stream received event %@", String(describing: eventCode))
            }
        }
    }
}
