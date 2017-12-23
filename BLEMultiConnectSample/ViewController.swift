//
//  ViewController.swift
//  BLEMultiConnectSample
//
//  Created by hirotaka on 2017/12/23.
//  Copyright © 2017 hiro. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    private let deviceManager = DeviceManager()
    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureScanButton()
        configureTableView()
        NotificationCenter.default
            .addObserver(self, selector: #selector(reloadData), name: DeviceManager.deviceUpdated, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func configureScanButton() {
        let button = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(scan))
        navigationItem.setRightBarButton(button, animated: false)
    }

    private func configureTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        let cell = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }

    private func toggleButton(title: String, action: Selector) {
        navigationItem.rightBarButtonItem?.title = title
        navigationItem.rightBarButtonItem?.action = action
    }

    @objc private func scan() {
        deviceManager.removeDevices()
        deviceManager.scan()
        toggleButton(title: "Stop", action: #selector(stopScan))
    }

    @objc private func stopScan() {
        deviceManager.stopScan()
        toggleButton(title: "Scan", action: #selector(scan))
    }

    @objc private func reloadData() {
        tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceManager.devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! TableViewCell
        let device = deviceManager.devices[indexPath.row]
        cell.nameLabel.text = device.peripheral.name ?? "none"
        cell.rssiLabel.text = String(describing: device.rssi)
        cell.stateLabel.text = device.state.description
        return cell
    }
}


// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = deviceManager.devices[indexPath.row]
        switch device.state {
        case .connected:
            deviceManager.disconnect(peripheral: device.peripheral)
        case .disconnected:
            deviceManager.connect(peripheral: device.peripheral)
        }
    }
}
