//
//  YNCDescriptor.swift
//  YNBluetooth
//
//  Created by yuyan7 on 2017/07/08.
//  Copyright © 2017年 yuyan7. All rights reserved.
//
import CoreBluetooth

/// YNCDescriptorDelegate
@objc public protocol YNCDescriptorDelegate: class {

    /// Receive Read Data
    ///
    /// - Parameter descriptor: Descriptor
    @objc optional func receiveReadDescriptor(descriptor: YNCDescriptor)

    /// Receive Write Result
    ///
    /// - Parameters:
    ///   - descriptor: Descriptor
    ///   - isSuccess: success?
    @objc optional func receiveWriteDescriptorResult(descriptor: YNCDescriptor, isSuccess: Bool)
}

/// YNCDescriptor
public class YNCDescriptor: NSObject {

    /// Descriptor
    public let descriptor: CBDescriptor

    /// Peripheral
    private let peripheral: CBPeripheral

    /// Delegate
    public weak var delegate: YNCDescriptorDelegate?

    /// Initializer
    ///
    /// - Parameters:
    ///   - peripheral: Peripheral
    ///   - descriptor: Descriptor
    init(peripheral: CBPeripheral, descriptor: CBDescriptor) {
        self.descriptor = descriptor
        self.peripheral = peripheral
        super.init()
    }

    /// Read Value Request
    public func readValue() {
        self.peripheral.readValue(for: descriptor)
    }

    /// Write Value Request
    ///
    /// - Parameter data: Data
    public func writeValue(data: Data) {
        self.peripheral.writeValue(data, for: descriptor)
    }
}
