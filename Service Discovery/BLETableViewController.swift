
import UIKit
import CoreBluetooth

class BLETableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    @IBOutlet var tableView: UITableView!
    var centralManager : CBCentralManager!
    var peripheral : CBPeripheral!
    var nearbyPeripherals : [CBPeripheral] = []
    var nearbyPeripheralInfos : [CBPeripheral:Dictionary<String, AnyObject>] = [CBPeripheral:Dictionary<String, AnyObject>]()
    var devices: Dictionary<String, CBPeripheral> = [:]
    var devicesRSSI = [NSNumber]()
    var devicesServices: CBService!
    var deviceCharacteristics: CBCharacteristic!
    
    var serviceUUID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.61, green: 0.80, blue: 0.89, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        devices.removeAll()
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
        
        if !nearbyPeripherals.contains(peripheral) {
            nearbyPeripherals.append(peripheral)
            nearbyPeripheralInfos[peripheral] = ["RSSI": RSSI, "advertisementData": advertisementData as AnyObject]
        } else {
            nearbyPeripheralInfos[peripheral]!["RSSI"] = RSSI
            nearbyPeripheralInfos[peripheral]!["advertisementData"] = advertisementData as AnyObject?
        }
        tableView.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let newViewController = PeripheralViewController()
        let peripheralInfo = nearbyPeripheralInfos[peripheral]
        newViewController.lastAdvertisementData = peripheralInfo!["advertisementData"] as? Dictionary<String, AnyObject>
        navigationController?.pushViewController(newViewController, animated: true)
    }
    
    //    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    //        for charateristic in service.characteristics! {
    //            peripheral.setNotifyValue(true, for: charateristic)
    //            deviceCharacteristics = charateristic
    //        }
    //    }
    //
    //    // Get data values when they are updated
    //    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    //        print("We have new valueeeees!")
    //    }
    
    // TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("BluetoothTableViewCell", owner: self, options: nil)?.first as! BluetoothTableViewCell
        let peripheral = nearbyPeripherals[indexPath.row]
        let peripheralInfo = nearbyPeripheralInfos[peripheral]
        
        cell.cellLabel.text = peripheral.name == nil || peripheral.name == ""  ? "Unnamed device" : peripheral.name
        cell.rssiLabel.text = String(describing: peripheralInfo!["RSSI"]! as! NSNumber) + " dBm"
        
        let serviceUUIDs = peripheralInfo!["advertisementData"]!["kCBAdvDataServiceUUIDs"] as? NSArray
        if serviceUUIDs != nil && serviceUUIDs?.count != 0 {
            cell.serviceLabel.text = "\((serviceUUIDs?.count)!) service" + ((serviceUUIDs?.count)! > 1 ? "s" : "")
        } else {
            cell.serviceLabel.text = "No service"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = nearbyPeripherals[indexPath.row]
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
        centralManager.stopScan()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
