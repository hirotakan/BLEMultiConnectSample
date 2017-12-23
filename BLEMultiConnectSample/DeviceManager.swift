//
//  DeviceManager.swift
//  BLEMultiConnectSample
//
//  Created by hirotaka on 2017/12/23.
//  Copyright © 2017 hiro. All rights reserved.
//

import Foundation
import CoreBluetooth

final class DeviceManager: NSObject {
    static let deviceUpdated = Notification.Name("deviceUpdated")
    private let centralManager: CBCentralManager
    private(set) var devices = [Device]() {
        didSet {
            NotificationCenter.default
                .post(name: DeviceManager.deviceUpdated, object: nil)
        }
    }

    override init() {
        centralManager = CBCentralManager(delegate: nil, queue: nil)
        super.init()
        centralManager.delegate = self
    }

    func scan() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func stopScan() {
        centralManager.stopScan()
    }

    func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }

    func disconnect(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }

    func removeDevices() {
        devices.removeAll()
    }
}


// MARK: - CBCentralManagerDelegate

extension DeviceManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state: \(central.state.rawValue)")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = Device(peripheral: peripheral, rssi: RSSI)
        if let index = devices.index(where: { $0.peripheral.identifier == device.peripheral.identifier }) {
            devices[index] = device
        } else {
            devices.append(device)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        devices.first { $0.peripheral == peripheral }
            .map { $0.state = .connected }

        NotificationCenter.default
            .post(name: DeviceManager.deviceUpdated, object: nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        devices.first { $0.peripheral == peripheral }
            .map { $0.state = .disconnected }

        NotificationCenter.default
            .post(name: DeviceManager.deviceUpdated, object: nil)
    }
}
