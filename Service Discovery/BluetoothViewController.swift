
import UIKit
import CoreBluetooth

class BluetoothViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var tableView: UITableView!
    var centralManager : CBCentralManager!
    var nearbyPeripheralsArray : [CBPeripheral] = []
    var nearbyPeripheralsAllData = [CBPeripheral:Dictionary<String, AnyObject>]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Nearby Devices"
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.61, green: 0.80, blue: 0.89, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nearbyPeripheralsArray.removeAll()
        nearbyPeripheralsAllData.removeAll()
        tableView.reloadData()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("BLE is powered on.")
            central.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            print("BLE is powered off.")
        case .resetting:
            print("BLE is resetting.")
        case .unauthorized:
            print("BLE is unauthorized.")
        case .unknown:
            print("BLE is unknown.")
        case .unsupported:
            print("BLE is unsupported.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !nearbyPeripheralsArray.contains(peripheral) {
//            print("Discovered: \(String(describing: peripheral))")
            nearbyPeripheralsArray.append(peripheral)
            nearbyPeripheralsAllData[peripheral] = ["identifier" : peripheral.identifier as AnyObject, "RSSI" : RSSI, "advertisementData" : advertisementData as AnyObject]
            
//            print(advertisementData["CBAdvertisementDataLocalNameKey"])
        } else {
            nearbyPeripheralsAllData[peripheral]?["identifier"] = peripheral.identifier as AnyObject
            nearbyPeripheralsAllData[peripheral]?["RSSI"] = RSSI
            nearbyPeripheralsAllData[peripheral]?["advertisementData"] = advertisementData as AnyObject
        }
        tableView.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)

        let newViewController = PeripheralViewController(central: centralManager, device: peripheral, deviceAllData: nearbyPeripheralsAllData[peripheral]!)
        navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("nije se spojilo")
    }
    
    // Get data values when they are updated
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("We have new valueeeees!")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    // TableView setup
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyPeripheralsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var name : String
        let cell = Bundle.main.loadNibNamed("BluetoothTableViewCell", owner: self, options: nil)?.first as! BluetoothTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.default

        let peripheral = nearbyPeripheralsArray[indexPath.row]
        let peripheralAllData = nearbyPeripheralsAllData[peripheral]

        if (peripheral.name == nil || peripheral.name == "") {
            name = "Unnamed device"
        } else {
            name = peripheral.name!
        }
        cell.cellLabel.text = name
        cell.rssiLabel.text = String(describing: peripheralAllData?["RSSI"]! as! NSNumber) + " dBm"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = nearbyPeripheralsArray[indexPath.row]
        peripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
