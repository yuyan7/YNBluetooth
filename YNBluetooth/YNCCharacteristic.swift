//
//  YNCCharacteristic.swift
//  YNBluetooth
//
//  Created by yuyan7 on 2017/07/08.
//  Copyright © 2017年 yuyan7. All rights reserved.
//
import CoreBluetooth

/// YNCCharacteristicDelegate
@objc public protocol YNCCharacteristicDelegate: class {

    /// Found Descriptor
    ///
    /// - Parameters:
    ///   - characteristic: Charactersitic
    ///   - descriptor: Found Descriptor
    @objc optional func findDescriptor(characteristic: YNCCharacteristic, descriptor: YNCDescriptor)

    /// Receive Read Data
    ///
    /// - Parameter characteristic: Characteristic
    @objc optional func receiveReadCharacteristic(characteristic: YNCCharacteristic)

    /// Receive Write Result
    ///
    /// - Parameters:
    ///   - characteristic: Charactersitic
    ///   - isSuccess: success?
    @objc optional func receiveWriteCharacteristicResult(characteristic: YNCCharacteristic, isSuccess: Bool)
}

/// YNCCharacteristic
public class YNCCharacteristic: NSObject {

    /// Characterstic
    public let characteristic: CBCharacteristic

    /// Peripheral
    private let peripheral: CBPeripheral

    /// Descriptors
    public internal(set) var descriptors: [WeakRef<YNCDescriptor>]

    /// Delegate
    public weak var delegate: YNCCharacteristicDelegate?

    /// Initializer
    ///
    /// - Parameters:
    ///   - peripheral: Periphearl
    ///   - characteristic: Charactersitic
    init(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        self.peripheral = peripheral
        self.characteristic = characteristic
        self.descriptors = [WeakRef<YNCDescriptor>]()
        super.init()
    }

    /// Read Value Request
    public func readValue() {
        self.peripheral.readValue(for: characteristic)
    }

    /// Write Value Request
    ///
    /// - Parameters:
    ///   - data: Data
    ///   - writeType: Write Type
    public func writeValue(data: Data, writeType: CBCharacteristicWriteType) {
        self.peripheral.writeValue(data, for: characteristic, type: writeType)
    }

    /// Setting Notify
    public func setNotify() {
        self.peripheral.setNotifyValue(true, for: characteristic)
    }

    /// DiscoverDescriptor
    public func discoverDescriptors() {
        self.peripheral.discoverDescriptors(for: characteristic)
    }

    /// Search input YNCDescriptor
    ///
    /// - Parameter descriptor: target
    /// - Returns: Found YNCDescriptor
    func getTargetDescriptor(descriptor: CBDescriptor) -> YNCDescriptor? {
        return descriptors.first { (inner) -> Bool in
            return inner.value?.descriptor.uuid == descriptor.uuid
        }?.value
    }
}
