//
//  YNCentralManager.swift
//  YNBluetooth
//
//  Created by yuyan7 on 2017/07/08.
//  Copyright © 2017年 yuyan7. All rights reserved.
//
import CoreBluetooth

/// YNCentralManagerDelegate
public protocol YNCentralManagerDelegate: class {

    /// Found Peripheral
    ///
    /// - Parameters:
    ///   - central: CentralManager
    ///   - peripheral: Peripheral
    func findPeripheral(central: YNCentralManager, find peripheral: YNCPeripheral)
}

/// YNCentralManager
public class YNCentralManager: NSObject {

    /// CentralManager
    let centralManager: CBCentralManager

    /// Delegate
    public weak var delegate: YNCentralManagerDelegate?

    /// Peripherals
    public internal(set) var peripherals: [WeakRef<YNCPeripheral>]

    fileprivate var tmpPeripheral: CBPeripheral?

    /// Target Service UUID's
    let targets: [CBUUID]?

    /// Initialize
    ///
    /// - Parameters:
    ///   - input: Target Service UUID's
    ///   - queue: DispatchQueue
    ///   - options: Option
    public init(input: [String]?, queue: DispatchQueue?, options: [String: AnyObject]?) {
        centralManager = CBCentralManager(delegate: nil, queue: queue, options: options)
        if let strs = input {
            targets = strs.map({ (uuid) -> CBUUID in
                return CBUUID(string: uuid)
            })
        } else {
            targets = nil
        }
        peripherals = [WeakRef<YNCPeripheral>]()
        super.init()
        centralManager.delegate = self
    }

    /// Convenience Initialize
    ///
    /// - Parameters:
    ///   - input: Target Service UUID's
    ///   - queue: DispatchQueue
    public convenience init(input: [String]?, queue: DispatchQueue?) {
        self.init(input: input, queue: queue, options: nil)
    }

    /// Convenience Initialize
    ///
    /// - Parameter input: Target Service UUID's
    public convenience init(input: [String]?) {
        let option = [
            CBCentralManagerOptionShowPowerAlertKey: NSNumber(value: true)
        ]
        self.init(input: input, queue: nil, options: option)
    }

    /// Start Scan
    ///
    /// If Need Scan Please Call
    public func startScan() {
        debugLog("Start Scan")
        centralManager.scanForPeripherals(withServices: targets, options: nil)
    }

    /// Stop Scan
    /// 
    /// Stop Scan must call
    public func stopScan() {
        debugLog("Stop Scan")
        centralManager.stopScan()
    }

    /// Connect Peripheral
    /// 
    /// add YNCPeripheral object connect peripheral
    /// return findPeripheral Delegate
    /// please change Reference
    ///
    /// - Parameter peripheral: target connect Peripheral
    public func connectPeripheral(peripheral: YNCPeripheral) {
        centralManager.connect(peripheral.peripheral, options: nil)
    }

    /// Search input YNCPeripheral
    ///
    /// - Parameter peripheral: target
    /// - Returns: Found YNCPeripheral
    func getTargetPeripheral(peripheral: CBPeripheral) -> YNCPeripheral? {
        return peripherals.first { (inner) -> Bool in
            return inner.value?.peripheral == peripheral
        }?.value
    }
}

// MARK: - CBPeripheralDelegate
extension YNCentralManager: CBPeripheralDelegate {

    /// Discover Service
    ///
    /// - Parameters:
    ///   - peripheral: Peripheral
    ///   - error: error
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        debugLog("Discover Service \(services)")
        let obj = YNCPeripheral(peripheral: peripheral, services: services)
        delegate?.findPeripheral(central: self, find: obj)
        self.peripherals.append(WeakRef(value: obj))
    }

    /// Discover Included Service
    ///
    /// - Parameters:
    ///   - peripheral: Peripheral
    ///   - service: Service
    ///   - error: error
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {

    }

    /// Modify Service
    ///
    /// - Parameters:
    ///   - peripheral: Peripheral
    ///   - invalidatedServices: changed Service
    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {

    }
}

// MARK: - CBCentralManagerDelegate
extension YNCentralManager: CBCentralManagerDelegate {

    /// 
    ///
    /// - Parameters:
    ///   - central: centralmanager
    ///   - dict: parameter
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {

    }

    /// CentralManagerDidupdateState
    ///
    /// - Parameter central: CentralManager
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            break
        case .poweredOn:
            startScan()
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unknown:
            break
        case .unsupported:
            break
        }
    }

    /// CentralManager is Discover Peripheral
    ///
    /// - Parameters:
    ///   - central: CentralManager
    ///   - peripheral: Discover Peripheral
    ///   - advertisementData: advertisementData
    ///   - RSSI: RSSI
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        debugLog("Discovered \(peripheral)")
        self.tmpPeripheral = peripheral

        central.connect(peripheral, options: nil)
    }

    /// CentralManager is Connect Peripheral
    ///
    /// - Parameters:
    ///   - central: CentralManager
    ///   - peripheral: Connect Peripheral
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        debugLog("Connect Peripheral \(peripheral)")
        peripheral.delegate = self
        peripheral.discoverServices(targets)
    }

    /// CentralManager is Failed Connection to Peripheral
    ///
    /// - Parameters:
    ///   - central: CentralManager
    ///   - peripheral: Failed to Connect Peripheral
    ///   - error: error
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {

    }

    /// CentralManager is Disconnect Peripheral
    ///
    /// - Parameters:
    ///   - central: CentralManager
    ///   - peripheral: Disconnecte Peripheral
    ///   - error: Error
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugLog("Disconnect Peripheral \(peripheral)")
        if let error = error {
            debugLog("Error \(error.localizedDescription)")
        }
    }
}
