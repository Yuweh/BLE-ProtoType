//
//  PeripheralViewController.swift
//  Test01
//
//

import UIKit
import CoreBluetooth

struct ServiceAndCharacteristics {
    var serviceName: CBService
    var serviceCharacteristics: [CBCharacteristic] = []
}

class PeripheralViewController: UIViewController {
    
    @IBOutlet weak var bluetoothLogo: UIImageView!
    @IBOutlet weak var connectedDeviceName: UILabel!
    @IBOutlet weak var connectedDeviceRSSI: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bluetoothBtn: UIButton!
    
    var peripheral: CBPeripheral!
    var centralManager: CBCentralManager!
    var services: [CBService] = []
    var characteristics: [CBService : [CBCharacteristic]] = [:]
    var deviceConnected: Bool = true
    var deviceCharacteristics: [ServiceAndCharacteristics] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheral.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        title = peripheral.name
        tableView.register(UINib(nibName:"ScannedServicesCell", bundle: nil), forCellReuseIdentifier: "ScannedServicesCell")
        //centralManager = CBCentralManager(delegate: self, queue: nil)
        self.bluetoothLogo.layer.cornerRadius = 5
        self.bluetoothLogo.clipsToBounds = true
        self.bluetoothLogo.layer.borderWidth = 3
        self.bluetoothLogo.layer.borderColor = UIColor.orange.cgColor
        print(services)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.connectedDeviceName.text = peripheral.name
        self.connectedDeviceRSSI.text = "- - -"
        self.deviceConnected = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.centralManager.cancelPeripheralConnection(peripheral)
        services.removeAll()
        print("Device Disconnected")
    }
    
    
    func setupBLEInfo(manager: CBCentralManager, peripheral: CBPeripheral) {
        self.centralManager = manager
        self.peripheral = peripheral
    }
    
    //Alert to Check if Bluetooth.isON
    func showAlertSettings(message: String) {
        let alert = UIAlertController(title: "Notice".localized, message: message.localized, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Ok".localized, style: .default, handler: nil)
        alert.addAction(okay)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func connectBtnPressed(_ sender: Any) {
        if deviceConnected {
            self.services.removeAll()
            self.connectedDeviceRSSI.text = "Device Disconnected"
            self.bluetoothBtn.setTitle("Connect?", for: .normal)
            self.bluetoothLogo.image = UIImage(named: "No.png")
            self.deviceConnected = false
            centralManager.cancelPeripheralConnection(peripheral)
        } else if !deviceConnected {
            self.connectedDeviceRSSI.text = "Connection Restored "
            self.bluetoothBtn.setTitle("Disonnect?", for: .normal)
            self.bluetoothLogo.image = UIImage(named: "Yes.png")
            self.deviceConnected = true
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    
    
}

extension PeripheralViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOn:
            //bluetoothLogo.image = UIImage(cgImage: #imageLiteral(resourceName: "Yes") as! CGImage)
            connectedDeviceRSSI.text = "Bluetooth ON - Now Connected".localized
            connectedDeviceRSSI.textColor = UIColor.green
            break
        case .poweredOff:
            //bluetoothLogo.image = UIImage(cgImage: #imageLiteral(resourceName: "No") as! CGImage)
            connectedDeviceRSSI.text = "Bluetooth OFF - Now Disconnected".localized
            connectedDeviceRSSI.textColor = UIColor.red
            showAlertSettings(message: "Please turn on you Bluetooth")
            break
        default:
            break
        }
    }
    
}

extension PeripheralViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if services.count == 0 {
            return 1
        } else {
            let sections = services.count
            return sections //self.deviceCharacteristics.count //services.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if services.count == 0 {
            return "Service Name"
            
        } else {
            let sectionName = "\(self.services[section].uuid)" //"\(self.deviceCharacteristics[section].serviceName)"  //
            return sectionName
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if services.count == 0 { //services.count
            return 1
        } else {
            let rows = services.count //self.deviceCharacteristics[section].serviceCharacteristics.count
            return rows
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScannedServicesCell", for: indexPath) as! ScannedServicesCell
        
        if services.count == 0 {
            cell.scannedServicesTitle.text = "Service Name"
            return cell
        } else {
            let characteristics = "Ready for Testing"
            cell.scannedServicesTitle.text = characteristics
            return cell
        }
    }
}

extension PeripheralViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                self.services.append(service)
                tableView.reloadData()
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                //self.characteristics[service] = [characteristic]
//                let deviceInfo = ServiceAndCharacteristics(serviceName: service, serviceCharacteristics: characteristics)
//                self.deviceCharacteristics.append(deviceInfo)
            }
            let deviceInfo = ServiceAndCharacteristics(serviceName: service, serviceCharacteristics: characteristics)
            self.deviceCharacteristics.append(deviceInfo)
            tableView.reloadData()
        }
    }
    
}






