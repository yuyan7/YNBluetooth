//
//  YNPCharacteristic.swift
//  YNBluetooth
//
//  Created by yuyan7 on 2017/07/08.
//  Copyright © 2017年 yuyan7. All rights reserved.
//
import CoreBluetooth

/// YNPCharacteristic
public class YNPCharacteristic {

    /// My Characteristic
    public let characteristic: CBMutableCharacteristic

    /// Descriptors
    public private(set) var descriptors: [YNPDescriptor]

    /// subscribed central
    private var subscribedCentrals: Set<CBCentral>

    /// Value
    public var value: Data? {
        return characteristic.value
    }

    /// initializer
    ///
    /// - Parameters:
    ///   - uuid: UUID
    ///   - properties: Property
    ///   - permissions: Permission
    ///   - value: Data
    public init(uuid: String, properties: CBCharacteristicProperties, permissions: CBAttributePermissions, value: Data?) {
        self.characteristic = CBMutableCharacteristic(type: CBUUID(string:uuid),
                                                      properties: properties,
                                                      value: value,
                                                      permissions: permissions)
        self.subscribedCentrals = Set<CBCentral>()
        self.descriptors = [YNPDescriptor]()
    }

    ///  add subscribe central
    ///
    /// - Parameter central: subscribe central
    func setSubscribeCentral(central: CBCentral) {
        self.subscribedCentrals.insert(central)
    }

    /// remove subscribe central
    ///
    /// - Parameter central: subscribed central
    func removeSubscribeCentral(central: CBCentral) {
        self.subscribedCentrals.remove(central)
    }

    /// add Descriptor
    ///
    /// - Parameter descriptor: descriptor
    public func setDescriptor(descriptor: YNPDescriptor) {
        self.descriptors.append(descriptor)
        let list = self.descriptors.map { (obj) -> CBMutableDescriptor in
            return obj.descriptor
        }
        self.characteristic.descriptors = list
    }

    /// update value
    ///
    /// - Parameters:
    ///   - newValue: data
    ///   - manager: manager
    public func updateValue(value newValue: Data, forPeripheral manager: YNPeripheralManager) {
        characteristic.value = newValue
        manager.updateValue(value: newValue, for: characteristic, onSubscribedCentrals: subscribedCentrals)
    }
}
