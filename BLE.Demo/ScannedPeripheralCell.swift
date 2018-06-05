//
//  ScannedPeripheralCell.swift
//  Test01
//
//  Created by Jay Bergonia on 5/6/2018.
//  Copyright © 2018 Tektos Limited. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol PeripheralCellDelegate: class {
    func didTapConnect(_ cell: ScannedPeripheralCell, peripheral: CBPeripheral)
    func updateViews(text: String)
}

struct ScannedDevice {
    //var peripheral: CBPeripheral?
    var deviceName: String
    var deviceSignal: String?
    var deviceServices: CBPeripheral?
    var deviceConnect: Bool
    var deviceRSSI = [String:String]() //Dictionary<String, String>
    
    init(name: String, signal: String, services: CBPeripheral, connect: Bool) {
        self.deviceName = name
        self.deviceSignal = signal
        self.deviceServices = services
        self.deviceConnect = connect
    }
}


class ScannedPeripheralCell: UITableViewCell {

    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceServices: UILabel!
    @IBOutlet weak var deviceSignal: UILabel!
    @IBOutlet weak var deviceConnect: UIButton!
    
    var centralManager: CBCentralManager!
    weak var delegate: PeripheralCellDelegate?
    private var displayPeripheral: ScannedDevice!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func ifConnectable(bool: Bool) {
        self.deviceConnect.isHidden = !bool
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func connectBtnPressed(_ sender: Any) {
        self.deviceServices.text = "Now Connecting"
        delegate?.didTapConnect(self, peripheral: displayPeripheral.deviceServices!)
        delegate?.updateViews(text: "Connecting")
    }
    
}

