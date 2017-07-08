//
//  YNPDescriptor.swift
//  YNBluetooth
//
//  Created by yuyan7 on 2017/07/08.
//  Copyright © 2017年 yuyan7. All rights reserved.
//
import CoreBluetooth

/// YNPDescriptor
public class YNPDescriptor {

    /// Descriptor
    public let descriptor: CBMutableDescriptor

    /// Value
    public var value: Any? {
        return self.descriptor.value
    }

    /// Initialize
    ///
    /// - Parameters:
    ///   - uuid: Descriptor's UUID
    ///   - value: Descriptor's value
    public init(uuid: String, value: Any?) {
        self.descriptor = CBMutableDescriptor(type: CBUUID(string: uuid),
                                              value: value)
    }
}
