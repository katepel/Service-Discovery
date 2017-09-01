
import UIKit
import CoreBluetooth
import Foundation

class PeripheralViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var servicesTableView: UITableView!
    
    var centralManager : CBCentralManager!
    var passedDevice : CBPeripheral!
    var passedDeviceAllData : Dictionary<String, AnyObject> = [:]
    var services : [CBService] = []
    var serviceCharacteristics = Dictionary<CBService, [CBCharacteristic]>()
    var statusOfDevice : String!
    var deviceCharacteristics: [CBCharacteristic] = []
    
    convenience init(central: CBCentralManager, device : CBPeripheral, deviceAllData: Dictionary<String, AnyObject>) {
            self.init()
            self.centralManager = central
            self.passedDevice = device
            self.passedDeviceAllData = deviceAllData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        servicesTableView.delegate = self
        servicesTableView.dataSource = self
        passedDevice.delegate = self
        
        var name : String
        if (passedDevice.name == nil || passedDevice.name == "") {
            name = "Unnamed device"
        } else {
            name = passedDevice.name!
        }
        deviceLabel.text = name
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
    
    override func viewWillAppear(_ animated: Bool) {
        servicesTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if (self.isMovingFromParentViewController) {
            centralManager.cancelPeripheralConnection(passedDevice)
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
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if !services.contains(service) {
                services.append(service)
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        servicesTableView.reloadData()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            deviceCharacteristics.append(characteristic)
            passedDevice.setNotifyValue(true, for: characteristic)
            servicesTableView.reloadData()
        }
        serviceCharacteristics[service] = deviceCharacteristics
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("We have new valueeeee!")
//        if let bla = characteristic.value {
//            let valueString = String(bytes: bla, encoding: String.Encoding.utf8) as String!
//            print(valueString)
//            servicesTableView.reloadData()
//        }
    }
    
    // TableView setup
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ServicesViewCell", owner: self, options: nil)?.first as! ServicesViewCell
        // characteristics cells
        cell.serviceLabel.text = String(describing: services[indexPath.section].characteristics![indexPath.row].uuid)
        cell.isUserInteractionEnabled = false
        
        var prop : CBCharacteristicProperties
        prop = services[indexPath.section].characteristics![indexPath.row].properties
        if prop.contains(.write) || prop.contains(.writeWithoutResponse) {
            cell.isUserInteractionEnabled = true
        } else {
            cell.writeButton.isHidden = true
        }
        
        passedDevice.readValue(for: services[indexPath.section].characteristics![indexPath.row])
        if services[indexPath.section].characteristics![indexPath.row].value != nil {
            let valueString = String(bytes: services[indexPath.section].characteristics![indexPath.row].value!, encoding: String.Encoding.utf8) as String!
            cell.valueLabel.text = valueString
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newViewController = WriteValueViewController(central: centralManager, device: passedDevice, service:  services[indexPath.section], characteristic: services[indexPath.section].characteristics![indexPath.row])
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(describing: services[section].uuid)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceCharacteristics[services[section]] == nil ? 0 : (services[section].characteristics?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
