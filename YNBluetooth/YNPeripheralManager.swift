//
//  YNPeripheralManager.swift
//  YNBluetooth
//
//  Created by yuyan7 on 2017/07/08.
//  Copyright © 2017年 yuyan7. All rights reserved.
//
import CoreBluetooth
import UIKit

/// YNPeripheralManagerDelegate
public protocol YNPeripheralManagerDelegate: class {

    /// Receive Write Request
    ///
    /// - Parameter written: written
    func didReceiveWriteRequest(written: [YNPCharacteristic])
}

/// Peripheral Manager
public class YNPeripheralManager: NSObject {

    /// PeripheralManager
    let peripheralManager: CBPeripheralManager

    /// Service UUID
    let services: [YNPService]

    /// delegate
    public weak var delegate: YNPeripheralManagerDelegate?

    /// initialize
    ///
    /// - Parameters:
    ///   - input: Service list
    ///   - queue: DispatchQueue
    ///   - options: Option
    public init(input: [YNPService], queue: DispatchQueue?, options: [String: AnyObject]?) {
        peripheralManager = CBPeripheralManager(delegate: nil, queue: queue, options: options)
        services = input
        super.init()
        peripheralManager.delegate = self
    }

    /// Convenience initialize
    ///
    /// - Parameters:
    ///   - input: Service list
    ///   - queue: DispatchQueue
    public convenience init(input: [YNPService], queue: DispatchQueue?) {
        self.init(input: input, queue: queue, options: nil)
    }

    /// Convenience initialize
    ///
    /// - Parameter input: service list
    public convenience init(input: [YNPService]) {
        let option = [
            CBPeripheralManagerOptionShowPowerAlertKey: NSNumber(value: true)
        ]
        self.init(input: input, queue: nil, options: option)
    }

    /// Stop Advertize
    public func stopAdvertise() {
        peripheralManager.stopAdvertising()
    }

    /// update value
    ///
    /// - Parameters:
    ///   - newValue: data
    ///   - charateristic: characteristic
    ///   - centrals: subscribed central
    func updateValue(value newValue: Data, for charateristic: CBMutableCharacteristic, onSubscribedCentrals centrals: Set<CBCentral>?) {
        var array: [CBCentral]?
        if let tmp = centrals {
            array = Array(tmp)
        }
        peripheralManager.updateValue(newValue, for: charateristic, onSubscribedCentrals: array)
    }

    /// get characteristic to uuid
    ///
    /// - Parameter uuid: target uuid
    /// - Returns: characteristic
    func getCharacteristic(uuid: CBUUID) -> YNPCharacteristic? {
        for service in services {
            return service.characteristics.first(where: { (inner) -> Bool in
                return inner.characteristic.uuid == uuid
            })
        }
        return nil
    }
}

// MARK: - CBPeripheralManagerDelegate
extension YNPeripheralManager: CBPeripheralManagerDelegate {

    ///
    ///
    /// - Parameter peripheral: peripheral
    public func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {

    }

    ///
    ///
    /// - Parameters:
    ///   - peripheral: peripheral
    ///   - dict: parameter
    public func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {

    }

    /// PeripheralManager State
    ///
    /// - Parameter peripheral: PeripheralManager
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOff:
            break
        case .poweredOn:
            debugLog("Create Peripheral")
            for service in services {
                peripheral.add(service.service)
            }
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

    /// PeripheralManager add Service
    ///
    /// - Parameters:
    ///   - peripheral: PeripheralManager
    ///   - service: Service
    ///   - error: error
    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            debugLog("Error publishing service: \(error.localizedDescription)")
        } else {
            let deviceName = UIDevice.current.name
            let uuids = services.map({ service -> CBUUID in
                return service.service.uuid
            })
            let advertisingData = [
                CBAdvertisementDataLocalNameKey: deviceName,
                CBAdvertisementDataServiceUUIDsKey: uuids
            ] as [String : Any]
            peripheral.startAdvertising(advertisingData)
        }
    }

    /// PeripheralManager Start Advertising
    ///
    /// - Parameters:
    ///   - peripheral: PeripheralManager
    ///   - error: error
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        debugLog("Start Advertising")
        if let error = error {
            debugLog("Error Advertising: \(error.localizedDescription)")
        }
    }

    /// PeripheralManager Receive Read Request
    ///
    /// - Parameters:
    ///   - peripheral: PeripheralManager
    ///   - requests: Read Request
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        debugLog("Read Request coming!")
        debugLog("requested service uuid:\(request.characteristic.service.uuid)")
        debugLog("characteristic uuid:\(request.characteristic.uuid)")

        if let characteristic = getCharacteristic(uuid: request.characteristic.uuid) {
            // CBMutableCharacteristicのvalueをCBATTRequestのvalueにセット
            request.value = characteristic.characteristic.value
            self.peripheralManager.respond(to: request, withResult: CBATTError.Code.success)
        }
    }

    /// PeripheralManager Receive Write Request
    ///
    /// - Parameters:
    ///   - peripheral: PeripheralManager
    ///   - requests: Write Request
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        debugLog("Write Requesst coming! \(requests.count)")

        var written = [YNPCharacteristic]()
        for request in requests {
            if let characteristic = getCharacteristic(uuid: request.characteristic.uuid) {
                characteristic.characteristic.value = request.value
                written.append(characteristic)
            }
        }
        if let request = requests.first {
            peripheralManager.respond(to: request, withResult: CBATTError.Code.success)
        }
        delegate?.didReceiveWriteRequest(written: written)
    }

    /// PeripheralManager receive subscribe request
    ///
    /// - Parameters:
    ///   - peripheral: PeripheralManager
    ///   - central: Send Request Central
    ///   - characteristic: Characteristic
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        debugLog("Central \(central) subscribe to characteristic \(characteristic)")
        if let characteristic = getCharacteristic(uuid: characteristic.uuid) {
            characteristic.setSubscribeCentral(central: central)
        }
    }

    /// PeripheralManager receive unsubscribe request
    ///
    /// - Parameters:
    ///   - peripheral: PeripheralManager
    ///   - central: Send Request Central
    ///   - characteristic: Characteristic
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        debugLog("Central \(central) unsubscribed to characteristic \(characteristic)")
        if let characteristic = getCharacteristic(uuid: characteristic.uuid) {
            characteristic.removeSubscribeCentral(central: central)
        }
    }
}
