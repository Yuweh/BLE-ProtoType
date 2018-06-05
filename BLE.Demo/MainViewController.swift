//
//  ViewController.swift
//  Test01
//
//  Created by Jay Bergonia on 29/5/2018.
//  Copyright © 2018 Tektos Limited. All rights reserved.
//
 
import UIKit
import CoreBluetooth

class MainViewController: UIViewController {
    
    @IBOutlet weak var MainLabel: UILabel!
    @IBOutlet weak var blueToothLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var centralManager: CBCentralManager!
    var isBluetoothPoweredOn: Bool = false
    var isScanning: Bool = false
    var scannedPeripheral: [String:String] = [:] //ReUsed
    var keepScanning = false
    var scannedUnits = [ScannedDevice]()
    
    // define our scanning interval times
    let timerPauseInterval:TimeInterval = 20.0
    let timerScanInterval:TimeInterval = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName:"ScannedPeripheralCell", bundle: nil), forCellReuseIdentifier: "ScannedPeripheralCell")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - NSTimer Exp
    @objc func pauseScan() {
        print("*** PAUSING SCAN...")
        self.MainLabel.text = "Pausing Scanning".localized
        _ = Timer(timeInterval: timerPauseInterval, target: self, selector: #selector(resumeScan), userInfo: nil, repeats: false)
        centralManager.stopScan()
    }
    
    @objc func resumeScan() {
        if keepScanning {
            // Start scanning again...
            print("*** RESUMING SCAN!")
            self.MainLabel.text = "Resuming Scanning".localized
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            self.MainLabel.text = "Checking".localized
        }
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        
        //stop scanning
        if centralManager.isScanning {
            self.MainLabel.text = "Scanning Stopped".localized
            self.scannedPeripheral.removeAll()
            self.tableView.reloadData()
            centralManager.stopScan()
        } else {
            self.scannedPeripheral.removeAll()
            self.tableView.reloadData()
            self.MainLabel.text = "Now Scanning".localized
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
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
        
        cell.deviceName.text = deviceName
        cell.deviceSignal.text = deviceSignal + "dBm"
        cell.ifConnectable(bool: deviceInfo.deviceConnect)
        //cell.populate(element: deviceInfo)
        
        self.MainLabel.text = String(scannedPeripheral.count) + " Devices Scanned".localized
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
    
}

extension MainViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOn:
            blueToothLabel.text = "Bluetooth ON".localized
            blueToothLabel.textColor = UIColor.green
            isBluetoothPoweredOn = true
            keepScanning = true
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
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
        
        print(advertisementData)
        let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as! Bool
        
        if let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            if self.scannedPeripheral.count <= 3 {
                let device = ScannedDevice(name: advertisementName, signal: String(describing: RSSI), services: peripheral, connect: isConnectable)
                self.scannedPeripheral[device.deviceName] = device.deviceSignal
                self.scannedUnits.append(device)
                print(device)
                tableView.reloadData()
            } else {
                self.blueToothLabel.text = "Scanning Stopped".localized
                centralManager.stopScan()
            }
            
        }

    }
    
}

extension MainViewController: CBPeripheralDelegate {

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.performSegue(withIdentifier: "connectToDeviceSegue", sender: self)
        peripheral.discoverServices(nil)
    }
    
}


extension MainViewController: PeripheralCellDelegate {

    
    
    func didTapConnect(_ cell: ScannedPeripheralCell, peripheral: CBPeripheral) {
        if peripheral.state != .connected {
            self.MainLabel.text = "Now Connecting to Device"
            peripheral.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func updateViews(text: String) {
        self.MainLabel.text = text
        self.blueToothLabel.text = text
    }
    
    
}



