//
//  YNPService.swift
//  YNBluetooth
//
//  Created by yuyan7 on 2017/07/08.
//  Copyright © 2017年 yuyan7. All rights reserved.
//

import CoreBluetooth

/// YNPService
public class YNPService {

    /// Service
    public let service: CBMutableService

    /// Characteristics
    public private(set) var characteristics: [YNPCharacteristic]

    /// initializer
    ///
    /// - Parameters:
    ///   - uuid: uuid
    ///   - primary: primary
    public init(uuid: String, primary: Bool) {
        self.service = CBMutableService(type: CBUUID(string: uuid),
                                        primary: primary)
        self.characteristics = [YNPCharacteristic]()
    }

    /// add characteristic
    ///
    /// - Parameter characteristic: characteristic
    public func setCharacteristic(characteristic: YNPCharacteristic) {
        self.characteristics.append(characteristic)
        let list = self.characteristics.map { obj -> CBMutableCharacteristic in
            return obj.characteristic
        }
        self.service.characteristics = list
    }
}
