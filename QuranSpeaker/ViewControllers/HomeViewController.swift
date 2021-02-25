//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit
import CoreBluetooth

var defaults = UserDefaults.standard

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XMLParserDelegate, CBCentralManagerDelegate, CBPeripheralDelegate
{
    @IBOutlet weak var quranView: UIView!
    @IBOutlet weak var chaptersTblView: UITableView!
    @IBOutlet weak var lblVerse: UILabel!
    @IBOutlet weak var verseTblView: UITableView!
    
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var txtView: UITextView!
    
    var sura = String()
    var suraTitle: [AyatObj] = []
    var ayaTitle: [AyatObj] = []
    var suraDict = [String: [AyatObj]]()
    var aya = String()
    var indexArray:[String] = []
    
    var quranFlag = false
    var chapterNo = 0
    var verseCount = 0
    
    var test = false
    
    //BLE
    var manager : CBCentralManager!
    var myBluetoothPeripheral : CBPeripheral!
    var myCharacteristic : CBCharacteristic!
    
    var isMyPeripheralConected = false
    
    override func viewDidLoad() {
        
        manager = CBCentralManager(delegate: self, queue: nil)
        
        quranView.layer.borderWidth = 1
        quranView.layer.borderColor = UIColor.darkGray.cgColor
        quranView.layer.shadowColor = UIColor.black.cgColor
        quranView.layer.shadowOpacity = 0.8
        quranView.layer.shadowRadius = 2
        quranView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        if let path = Bundle.main.url(forResource: "quran-simple", withExtension: "xml") {
                if let parser = XMLParser(contentsOf: path) {
                    parser.delegate = self
                    parser.parse()
                }
            }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        if elementName == "sura"
        {
            sura = String()
            
            for string in attributeDict
            {
                if string.key == "name"
                {
                    sura = string.value
                }
            }
                            
                          
        }
        else if elementName == "aya"
        {
            aya = String()
//            print(attributeDict)
            
            let ayatObj = AyatObj()
            
            for string in attributeDict
            {
                if string.key == "ndex"
                {
                    ayatObj.ayat = Int(string.value)
                }
                else if string.key == "page"
                {
                    ayatObj.page = Int(string.value)
                }
                else if string.key == "start"
                {
                    ayatObj.start = Int(string.value)
                }
                else if string.key == "end"
                {
                    ayatObj.end = Int(string.value)
                }
            }
            suraTitle.append(ayatObj)
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "sura"
        {
            indexArray.append(sura)
            suraDict[sura] = suraTitle
            suraTitle = []
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
    }

    @IBAction func quranBtnAction(_ sender: Any) {
        
        if quranFlag
        {
            leading.constant = -160
            quranFlag = false
        }
        else
        {
            chaptersTblView.alpha = 1
            leading.constant = 3
            quranFlag = true
        }
    }
    
    @IBAction func volumeBtnAction(_ sender: Any)
    {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        leading.constant = -160
        quranFlag = false
    }
    
    @IBAction func menuBtnAction(_ button: UIButton)
    {
        if button.tag == 1002
        {
            let lightVC = self.storyboard?.instantiateViewController(withIdentifier: "LightViewController") as! LightViewController
            self.navigationController?.pushViewController(lightVC, animated: false)
        }
        else if button.tag == 1003
        {
            let prayerVC = self.storyboard?.instantiateViewController(withIdentifier: "PrayerViewController") as! PrayerViewController
            self.navigationController?.pushViewController(prayerVC, animated: false)
        }
        else if button.tag == 1004
        {
            let setVC = self.storyboard?.instantiateViewController(withIdentifier: "SetViewController") as! SetViewController
            self.navigationController?.pushViewController(setVC, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView.tag == 1001
        {
            return indexArray.count
        }
        else
        {
            return verseCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:TableCell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableCell
        
        if tableView.tag == 1001
        {
            cell.lblName.text = String(format: "سورة %@",indexArray[indexPath.row])
        }
        else
        {
            cell.lblName.text = String(format: "%i:%i", chapterNo, indexPath.row + 1)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView.tag == 1001
        {
            chaptersTblView.alpha = 0
            chapterNo = indexPath.row + 1
            lblVerse.text = String(format: "سورة %@",indexArray[indexPath.row])
            ayaTitle = suraDict[indexArray[indexPath.row]] ?? []
            verseCount = ayaTitle.count
            verseTblView.reloadData()
        }
        else
        {
            let ayatObj = ayaTitle[indexPath.row]
            
            var prefix = "KSF"
            
            if ayatObj.page <= 2
            {
                prefix.append("00")
            }
            else if ayatObj.page < 10
            {
                prefix.append("P00")
            }
            
            print(String(format:"%@%d", prefix, ayatObj.page))
            txtView.font = UIFont(name: String(format:"%@%d", prefix, ayatObj.page), size:50)
            txtView.text = asciiToString(start: ayatObj.start, end: ayatObj.end)
            leading.constant = -160
            quranFlag = false
        }
    }
    
    func asciiToString(start: Int, end: Int) -> String
    {
        var resultStr = ""
        
        var code = end
        
        for _ in start...end
        {
            resultStr.append(Character(UnicodeScalar(code)!))
            code -= 1
        }
        
        return resultStr
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
        
        print("STATE: " + msg)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Name: \(peripheral.name)")
       
        if peripheral.name != nil || peripheral.name == "AC692x_BLE" {
            
            self.myBluetoothPeripheral = peripheral
            self.myBluetoothPeripheral.delegate = self
            
            manager.stopScan()
            manager.connect(myBluetoothPeripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("BLE device connected")
        isMyPeripheralConected = true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isMyPeripheralConected = false
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print ("00000000")
        if let servicePeripheral = peripheral.services as [CBService]? {
            
            for service in servicePeripheral {
                
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let characterArray = service.characteristics as [CBCharacteristic]? {
            
            for cc in characterArray {
                print(cc.uuid.uuidString)
                if(cc.uuid.uuidString == "AE01") {
                    myCharacteristic = cc
//                    peripheral.readValue(for: cc)
                    writeValue()
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print ("22222222")
        if (characteristic.uuid.uuidString == "AE01") {
            
            let readValue = characteristic.value
            
            let value = (readValue! as NSData).bytes.bindMemory(to: Int.self, capacity: readValue!.count).pointee //used to read an Int value
            
            print ("Value: \(value)")
        }
    }
    
    func writeValue() {
        
        if isMyPeripheralConected
        {
            let dataToSend: Data = "Hello World!".data(using: String.Encoding.utf8)!
            
            myBluetoothPeripheral.writeValue(dataToSend, for: myCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            print("value written")
        }
        else
        {
            print("Not connected")
        }
    }
}
