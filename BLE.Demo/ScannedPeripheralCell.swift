//
//  ScannedPeripheralCell.swift
//  Test01
//
//

import UIKit
import CoreBluetooth

class ScannedPeripheralCell: UITableViewCell {

    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceServices: UILabel!
    @IBOutlet weak var deviceSignal: UILabel!
    @IBOutlet weak var deviceConnect: UILabel!
    
    
    var centralManager: CBCentralManager!
    weak var delegate: PeripheralCellDelegate!
    private var scannedPeripheral: ScannedDevice!
    var peripheralContainer: CBPeripheral!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    func populate(name: String, deviceSignal: String, peripheral: CBPeripheral, connect: Bool) {
        self.peripheralContainer = peripheral
        self.deviceName.text = name
        self.deviceSignal.text = deviceSignal + "dBm"
        self.deviceServices.text = String("\(peripheral)")
        self.deviceConnect.isHidden = !connect
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //possible transfer
        //delegate.didTapConnect(self, peripheral: self.peripheralContainer)
//        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ \(self.peripheralContainer) @ CellView Delegate @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    }
    
    
}
