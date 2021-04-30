//
//  AppDelegate.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit
import CoreBluetooth

var quranUUID: CBUUID = CBUUID(string: "0000ae10-0000-1000-8000-00805f9b34fb")
var prayersUUID: CBUUID = CBUUID(string: "0000ae02-0000-1000-8000-00805f9b34fb")
var quranCharacteristic : CBCharacteristic!
var prayersCharacteristic : CBCharacteristic!
var isMyPeripheralConected = false
var myBluetoothPeripheral : CBPeripheral!
var prayersVC : PrayerViewController!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate
{
    var window: UIWindow?
    var manager : CBCentralManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Thread.sleep(forTimeInterval: 3)
        
        manager = CBCentralManager(delegate: self, queue: nil)
        return true
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
            myBluetoothPeripheral = peripheral
            myBluetoothPeripheral.delegate = self
            
            manager.stopScan()
            manager.connect(myBluetoothPeripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        isMyPeripheralConected = true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        let windowCount = UIApplication.shared.windows.count
        UIApplication.shared.windows[windowCount-1].makeToast("Bluetooth device connected")
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
                print("UUID: \(cc.uuid.uuidString)")
                if(cc.uuid == quranUUID) {
                    print("QuranUUID: \(cc.uuid.uuidString)")
                    quranCharacteristic = cc
                }
                else if(cc.uuid == prayersUUID) {
                    print("PrayersUUID: \(cc.uuid.uuidString)")
                    prayersCharacteristic = cc
                    if !UserDefaults.standard.bool(forKey: "prayersFlag")
                    {
                        prayersVC.isFirstTime = false
                        prayersVC.getYearPrayersTime()
                    }
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

