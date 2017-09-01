
import UIKit
import CoreBluetooth

class BluetoothDeviceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var servicesTableView: UITableView!
    var centralManager : CBCentralManager!
    var passedDevice : CBPeripheral!
    var statusOfDevice : String!
    var deviceCharacteristics: CBCharacteristic!
    
    var lastAdvertisementData : Dictionary<String, AnyObject>?

    
//    convenience init(central: CBCentralManager, device: CBPeripheral) {
//        self.init()
//        self.passedDevice = device
//        self.centralManager = central
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        servicesTableView.delegate = self
        servicesTableView.dataSource = self
        passedDevice.discoverServices(nil)
//        centralManager = CBCentralManager(delegate: self, queue: nil)

        passedDevice.delegate = self
        deviceLabel.text = passedDevice.name
        uuidLabel.text = String(describing: passedDevice.identifier)
        switch passedDevice.state.rawValue {
        case 0:
            statusOfDevice = "disconnected"
        case 1:
            statusOfDevice = "connecting"
        case 2:
            statusOfDevice = "connected"
        case 3:
            statusOfDevice = "disconnecting"
        default:
            statusOfDevice = "disconnected"
        }
        statusLabel.text = statusOfDevice
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("BLE is still powered on.")
            centralManager.connect(passedDevice, options: nil)
        default:
            print("BLE is not available.")
        }
    }
    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        peripheral.discoverServices(nil)
//    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
            print("Discovered Service for \(String(describing: peripheral.name)) :")
            print(service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for charateristic in service.characteristics! {
            peripheral.setNotifyValue(true, for: charateristic)
            deviceCharacteristics = charateristic
            print(service.uuid)
            print(charateristic)
        }
    }
    
    // Get data values when they are updated
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("We have new valueeeees!")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //ovo je sve bezvezeeeee - zaminit!
        let cell = Bundle.main.loadNibNamed("BluetoothTableViewCell", owner: self, options: nil)?.first as! BluetoothTableViewCell
//        if indexPath.section == 0 {
//            
//        } else {
//            
//        }
        cell.cellLabel.text =  "No name"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // staviti onliko kolika ima services taj peripheral
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        if (connectionButton.title(for: .normal) == "Connect") {
//            connectionButton.setTitle("Disconnect", for: .normal)
//            statusLabel.text = "connected"
//        } else {
//            connectionButton.setTitle("Connect", for: .normal)
//            statusLabel.text = "disconnected"
//        }
//        print("Connected to \(String(describing: peripheral.name))")
//        passedDevice.discoverServices(nil)
//    }
    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        for service in peripheral.services! {
//            peripheral.discoverCharacteristics(nil, for: service)
//            print(service)
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        for charateristic in service.characteristics! {
//            peripheral.setNotifyValue(true, for: charateristic)
//            deviceCharacteristics = charateristic
//        }
//    }
}
