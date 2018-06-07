//
//  ViewController.swift
//  Test01
//
//
 
import UIKit
import CoreBluetooth

class MainViewController: UIViewController {
    
    @IBOutlet weak var MainLabel: UILabel!
    @IBOutlet weak var blueToothLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var peripheralVC = PeripheralViewController()
    
    var centralManager: CBCentralManager!
    private var peripheralToPass: CBPeripheral?
    
    var isBluetoothPoweredOn: Bool = false
    var scannedPeripheral: [String:String] = [:] //ReUsed
    var scannedUnits = [ScannedDevice]() // used for connectable
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName:"ScannedPeripheralCell", bundle: nil), forCellReuseIdentifier: "ScannedPeripheralCell")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        
        //stop scanning
        if centralManager.isScanning {
            self.MainLabel.text = "Scanning Stopped".localized
            self.scannedPeripheral.removeAll()
            self.tableView.reloadData()
            centralManager.stopScan()
        } else {
            self.MainLabel.text = "Now Scanning".localized
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PeripheralViewController{
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ \(self.centralManager) @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ \(self.peripheralToPass!) @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
            destinationViewController.setupBLEInfo(manager: self.centralManager, peripheral: self.peripheralToPass!)
        } else {
            print("Ok")
        }
        
    }
    
    
    //Alert to Check if Bluetooth.isON
    func showAlertSettings() {
        let alert = UIAlertController(title: "Notice".localized, message: "Please turn on your Bluetooth".localized, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Ok".localized, style: .default, handler: nil)
        alert.addAction(okay)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannedPeripheral.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ScannedPeripheralCell", for: indexPath) as! ScannedPeripheralCell
        let deviceInfo = self.scannedUnits[indexPath.row]
        let deviceName = Array(self.scannedPeripheral.keys)[indexPath.row]
        let deviceSignal = Array(self.scannedPeripheral.values)[indexPath.row]
        
        cell.populate(name: deviceName, deviceSignal: deviceSignal, peripheral: deviceInfo.deviceServices, connect: deviceInfo.deviceConnect)
        
        self.MainLabel.text = String(scannedPeripheral.count) + " Devices Scanned".localized
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "connectToDeviceSegue", sender: self)
        let deviceInfo = self.scannedUnits[indexPath.row]
        let selectedPeripheral = deviceInfo.deviceServices
        self.peripheralToPass = selectedPeripheral
        self.peripheralVC.setupBLEInfo(manager: self.centralManager, peripheral: self.peripheralToPass!)
        centralManager.connect(self.peripheralToPass!, options: nil)
        //print(self.peripheralToPass!)
        //print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ \(String(describing: self.peripheralToPass)) @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    }
    
    
}

extension MainViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOn:
            blueToothLabel.text = "Bluetooth ON".localized
            blueToothLabel.textColor = UIColor.green
            isBluetoothPoweredOn = true
            break
        case .poweredOff:
            blueToothLabel.text = "Bluetooth OFF".localized
            blueToothLabel.textColor = UIColor.red
            isBluetoothPoweredOn = false
            showAlertSettings()
            break
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as! Bool
        if let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            let device = ScannedDevice(name: advertisementName, signal: String(describing: RSSI), services: peripheral, connect: isConnectable)
            self.scannedPeripheral[device.deviceName] = device.deviceSignal
            self.scannedUnits.append(device)
            tableView.reloadData()
            
        }

    }
    
}

extension MainViewController: CBPeripheralDelegate {

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        blueToothLabel.text = "Failed to connect"
        blueToothLabel.textColor = UIColor.red
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.performSegue(withIdentifier: "connectToDeviceSegue", sender: self)
        peripheral.discoverServices(nil)
    }
    
}

extension PeripheralViewController: PeripheralCellDelegate {
    
    func didTapConnect(_ cell: ScannedPeripheralCell, peripheral: CBPeripheral) {
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ \(peripheral) @ Main VCDelegate @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    }
    
    
}


