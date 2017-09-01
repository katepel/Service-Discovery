
import UIKit
import CoreBluetooth

class WriteValueViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var characteristicLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var centralManager : CBCentralManager!
    var passedDevice : CBPeripheral!
    var deviceService: CBService!
    var deviceCharacteristic : CBCharacteristic!
    
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let newValue = valueTextField.text?.data(using: String.Encoding.utf8)!
        passedDevice.writeValue(newValue!, for: deviceCharacteristic, type: .withResponse)
    }
    
    convenience init(central: CBCentralManager, device: CBPeripheral, service: CBService, characteristic: CBCharacteristic) {
        self.init()
        self.centralManager = central
        self.passedDevice = device
        self.deviceService = service
        self.deviceCharacteristic = characteristic
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passedDevice.delegate = self

        var name : String
        if (passedDevice.name == nil || passedDevice.name == "") {
            name = "Unnamed device"
        } else {
            name = passedDevice.name!
        }
        deviceLabel.text = name
        serviceLabel.text = String(describing: deviceService.uuid)
        characteristicLabel.text = String(describing: deviceCharacteristic.uuid)
        if deviceCharacteristic.value != nil {
            valueTextField.text = String(bytes: deviceCharacteristic.value!, encoding: String.Encoding.utf8) as String!
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("BLE is still powered on.")
        default:
            print("BLE is not available.")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        let alert : UIAlertController
        if let error = error {
            print("Error: \(error)")
            alert = UIAlertController(title: "Writing value", message: "Error!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        peripheral.readValue(for: characteristic)
        print("Peripheral did write characteristic value!")
        alert = UIAlertController(title: "Writing value", message: "Peripheral did write characteristic value!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
