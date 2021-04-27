//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit
import Colorful
import CoreBluetooth

class LightViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate
{
    @IBOutlet weak var quranBtn: UIButton!
    @IBOutlet weak var colorView: ColorPicker!
    
    var manager : CBCentralManager!
    var myBluetoothPeripheral : CBPeripheral!
    var myCharacteristic : CBCharacteristic!
    var quranUUID: CBUUID = CBUUID(string: "0000ae10-0000-1000-8000-00805f9b34fb")
    var isMyPeripheralConected = false
    
    override func viewDidLoad() {
        
        colorView.addTarget(self, action: #selector(selectColor), for: .valueChanged)
        colorView.set(color: .red, colorSpace: .extendedSRGB)
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @objc func selectColor()
    {
        print(colorView.color.components.red * 100)
        print(colorView.color.components.green * 100)
        print(colorView.color.components.blue * 100)
        
//        var red = 0
//        var green = 0
//        var blue = 0
//
//        if isMyPeripheralConected && myBluetoothPeripheral != nil
//        {
//            let dataToSend = Data([UInt8(Character("L").asciiValue!), UInt8(red), UInt8(green), UInt8(blue)])
//            myBluetoothPeripheral.writeValue(dataToSend as Data, for: myCharacteristic, type: CBCharacteristicWriteType.withResponse)
//        }
//        else
//        {
//            self.view.makeToast("Bluetooth device disconnected")
//        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        manager = nil
        isMyPeripheralConected = false
        myBluetoothPeripheral = nil
    }
    
    @IBAction func colorsBtnAction(_ button: UIButton)
    {
        var red = 0
        var green = 0
        var blue = 0
        
        if button.tag == 1001
        {
            red = 10
            green = 88
            blue = 207
        }
        else if button.tag == 1002
        {
            red = 190
            green = 10
            blue = 187
        }
        else if button.tag == 1003
        {
            red = 55
            green = 179
            blue = 86
        }
        else if button.tag == 1004
        {
            red = 194
            green = 18
        }
        else if button.tag == 1005
        {
            red = 122
            green = 203
        }
        else if button.tag == 1006
        {
            red = 122
            green = 203
        }
        else if button.tag == 1007
        {
            red = 76
            green = 145
            blue = 209
        }
        else if button.tag == 1008
        {
            red = 7
            green = 70
            blue = 165
        }
        
        if isMyPeripheralConected && myCharacteristic != nil
        {
            let dataToSend = Data([UInt8(Character("L").asciiValue!), UInt8(red), UInt8(green), UInt8(blue)])
            myBluetoothPeripheral.writeValue(dataToSend as Data, for: myCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
        else
        {
            self.view.makeToast("Bluetooth device disconnected")
        }
    }
    
    @IBAction func menuBtnAction(_ button: UIButton)
    {
        if button.tag == 1001
        {
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(homeVC, animated: false)
        }
        else if button.tag == 1003
        {
            let prayerVC = self.storyboard?.instantiateViewController(withIdentifier: "PrayerViewController") as! PrayerViewController
            self.navigationController?.pushViewController(prayerVC, animated: false)
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var msg = ""
        
        switch central.state {
            
            case .poweredOff:
                msg = "Bluetooth is Off"
            case .poweredOn:
                msg = "Bluetooth is On"
                manager.scanForPeripherals(withServices: nil, options: nil)
            case .unsupported:
                msg = "Not Supported"
            default:
                msg = "😔"
        }
        
//        self.view.makeToast(msg)
        print("STATE: " + msg)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Name: \(peripheral.name)")
       
        if peripheral.name != nil
        {
            self.myBluetoothPeripheral = peripheral
            self.myBluetoothPeripheral.delegate = self
            
            manager.stopScan()
            manager.connect(myBluetoothPeripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        isMyPeripheralConected = true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
//        self.view.makeToast("Bluetooth device connected")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isMyPeripheralConected = false
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let servicePeripheral = peripheral.services as [CBService]? {
            
            for service in servicePeripheral {
                
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let characterArray = service.characteristics as [CBCharacteristic]? {
            
            for cc in characterArray
            {
                if(cc.uuid == quranUUID) {
                    print("UUID: \(cc.uuid.uuidString)")
                    myCharacteristic = cc
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if (characteristic.uuid == quranUUID) {
            
            let readValue = characteristic.value
            let value = (readValue! as NSData).bytes.bindMemory(to: Int.self, capacity: readValue!.count).pointee //used to read an Int value
            print ("Value: \(value)")
        }
    }
}

extension String {

    var toColor: UIColor {
        var cString: String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}
