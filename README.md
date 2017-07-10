# YNBluetooth
CoreBluetooth thin wrapper Framework


## Usage

### Common

```swift
import YNBluetooth
```


### Peripheral

Start Peripheral
If update characteristic value, keep YNPCharacteristic Object Reference.

```swift
let service = YNPService(uuid: serviceUUID, primary: true)

// property READ, WRITE, NOTIFY
// permission READ, WRITE
let characteristic = YNPCharacteristic(uuid: characteristicUUID,
                                       properties: [.read, .write, .notify],
                                       permissions: [.readable, .writeable],
                                       value: nil)
service.setCharacteristic(characteristic: characteristic)
// Auto Start Advertise
let peripheral = YNPeripheralManager(input: [service])
peripheral.delegate = self
```

Update value

keeped YNPCharacteristic Object Reference.
call updateValue with YNPeripheralManager

```swift
let data = Data()
characteristic.updateValue(value: data, forPeripheral:peripheral)
```


Did Write Reqeust

delegate for YNPeripheralManagerDelegate

```swift
func didReceiveWriteRequest(written: [YNPCharacteristic]) {
    // written YNPCharacteristic
}
```


### Central


## License

MIT License.
