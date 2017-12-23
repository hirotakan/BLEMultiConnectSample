//
//  Device.swift
//  BLEMultiConnectSample
//
//  Created by hirotaka on 2017/12/23.
//  Copyright © 2017 hiro. All rights reserved.
//

import Foundation
import CoreBluetooth

final class Device: NSObject {
    let peripheral: CBPeripheral
    let rssi: NSNumber
    var state = State.disconnected

    init(peripheral: CBPeripheral, rssi: NSNumber) {
        self.peripheral = peripheral
        self.rssi = rssi
        super.init()
        peripheral.delegate = self
    }
}

extension Device {

    enum State: String, CustomStringConvertible {
        case disconnected
        case connected

        var description: String {
            return rawValue
        }
    }
}


// MARK: - CBPeripheralDelegate

extension Device: CBPeripheralDelegate {}
