//
//  YNCPeripheral.swift
//  YNBluetooth
//
//  Created by yuyan7 on 2017/07/08.
//  Copyright © 2017年 yuyan7. All rights reserved.
//
import CoreBluetooth

/// YNCPeripheral Delegate
@objc public protocol YNCPeripheralDelegate: class {

    /// Found Characterstic
    ///
    /// - Parameters:
    ///   - peripheral: peripheral
    ///   - characteristic: found characteristic
    @objc optional func findCharacteristic(peripheral: YNCPeripheral, find characteristic: YNCCharacteristic)

    /// Receive Read RSSI
    ///
    /// - Parameters:
    ///   - peripheral: peripheral
    ///   - RSSI: RSSI
    @objc optional func receiveReadRSSI(peripheral: YNCPeripheral, RSSI: NSNumber)
}

/// YNCPeripheral
public class YNCPeripheral: NSObject {

    /// Delegate
    public weak var delegate: YNCPeripheralDelegate?

    /// found characteristic
    public internal(set) var characteristics: [WeakRef<YNCCharacteristic>]

    /// peripheral
    public let peripheral: CBPeripheral

    /// Services
    public internal(set) var services: [CBService]

    /// initialize
    ///
    /// - Parameter peripheral: peripheral
    init(peripheral: CBPeripheral, services: [CBService]?) {
        self.peripheral = peripheral
        self.services = services ?? [CBService]()
        self.characteristics = [WeakRef<YNCCharacteristic>]()
        super.init()
        self.peripheral.delegate = self
    }

    /// Read RSSI
    public func readRSSI() {
        self.peripheral.readRSSI()
    }

    /// DiscoverCharacteristic
    public func discoverCharacteristics(input: [String]?, for service: CBService) {
        if let uuidStrs = input {
            let uuids = uuidStrs.map({ (uuidStr) -> CBUUID in
                return CBUUID(string: uuidStr)
            })
            self.peripheral.discoverCharacteristics(uuids, for: service)
        } else {
            self.peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    /// Search Service
    ///
    /// - Parameter input: target
    /// - Returns: Found CBService
    public func findService(input: String) -> CBService? {
        let uuid = CBUUID(string: input)
        return services.first { (inner) -> Bool in
            return inner.uuid == uuid
        }
    }

    /// Search input YNCCharacteristic
    ///
    /// - Parameter characteristic: target
    /// - Returns: Found YNCCharacteristic
    func getTargetCharacteristic(characteristic: CBCharacteristic) -> YNCCharacteristic? {
        return characteristics.first { (inner) -> Bool in
            return inner.value?.characteristic.uuid == characteristic.uuid
        }?.value
    }
}

// MARK: - CBPeripheralDelegate
extension YNCPeripheral: CBPeripheralDelegate {
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {

    }

    /// Read RSSI
    ///
    /// - Parameters:
    ///   - peripheral: Peripheral
    ///   - RSSI: RSSI
    ///   - error: error
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let error = error {
            debugLog("ERROR \(error.localizedDescription)")
            return
        }
        delegate?.receiveReadRSSI?(peripheral: self, RSSI: RSSI)
    }

    /// Peripheral is Discover Characteristics
    ///
    /// - Parameters:
    ///   - peripheral: Peripheral
    ///   - service: Find Service
    ///   - error: error
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            debugLog("Discover Characteristic \(characteristic)")
            let obj = YNCCharacteristic(peripheral: peripheral, characteristic: characteristic)
            delegate?.findCharacteristic?(peripheral: self, find: obj)
            self.characteristics.append(WeakRef(value: obj))

        }
    }

    /// peripheral is Discover descriptor
    ///
    /// - Parameters:
    ///   - peripheral: Peripheral
    ///   - characteristic: Find Characteristic
    ///   - error: error
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        guard let descriptors = characteristic.descriptors else {
            return
        }

        if let ync = getTargetCharacteristic(characteristic: characteristic) {
            for descriptor in descriptors {
                debugLog("Discover Descriptor \(descriptor)")
                let obj = YNCDescriptor(peripheral: peripheral, descriptor: descriptor)
                ync.delegate?.findDescriptor?(characteristic: ync, descriptor: obj)
                ync.descriptors.append(WeakRef(value: obj))

            }
        }
    }

    /// Characteristic Value Update
    ///
    /// - Parameters:
    ///   - peripheral: Peripheral
    ///   - characteristic: Update Value's Characteristic
    ///   - error: error
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            debugLog("ERROR \(error.localizedDescription)")
            return
        }
        if let ync = getTargetCharacteristic(characteristic: characteristic) {
            ync.delegate?.receiveReadCharacteristic?(characteristic: ync)
        }
    }

    /// Descriptor Value Update
    ///
    /// - Parameters:
    ///   - peripheral: Peripheral
    ///   - descriptor: Update Value's Descriptor
    ///   - error: error
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let error = error {
            debugLog("ERROR \(error.localizedDescription)")
            return
        }
        let characteristic = getTargetCharacteristic(characteristic: descriptor.characteristic)
        if let ync = characteristic?.getTargetDescriptor(descriptor: descriptor) {
            ync.delegate?.receiveReadDescriptor?(descriptor: ync)
        }
    }

    /// Peripheral's Subscribe Notification
    ///
    /// - Parameters:
    ///   - peripheral: Peripheral
    ///   - characteristic: Notifiy Characteristic
    ///   - error: error
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            debugLog("Error changing notification state: \(error.localizedDescription)")
        }
    }

    /// Did Write Value Characteristic
    ///
    /// - Parameters:
    ///   - peripheral: Peripheral
    ///   - characteristic: Write Characteristic
    ///   - error: error
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        debugLog("Did Write \(peripheral)")
        if let ync = getTargetCharacteristic(characteristic: characteristic) {
            if let error = error {
                debugLog("Error writing characteristic value: \(error.localizedDescription)")
                ync.delegate?.receiveWriteCharacteristicResult?(characteristic: ync, isSuccess: false)
                return
            }
            ync.delegate?.receiveWriteCharacteristicResult?(characteristic: ync, isSuccess: true)
        }
    }

    /// Did Write Value Descriptor
    ///
    /// - Parameters:
    ///   - peripheral: Peripheral
    ///   - descriptor: Write Descriptor
    ///   - error: error
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        let characteristic = getTargetCharacteristic(characteristic: descriptor.characteristic)
        if let ync = characteristic?.getTargetDescriptor(descriptor: descriptor) {
            if let error = error {
                debugLog("Error writing characteristic value: \(error.localizedDescription)")
                ync.delegate?.receiveWriteDescriptorResult?(descriptor: ync, isSuccess: false)
                return
            }
            ync.delegate?.receiveWriteDescriptorResult?(descriptor: ync, isSuccess: true)
        }
    }
}
