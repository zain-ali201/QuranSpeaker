//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit
import CoreBluetooth

var defaults = UserDefaults.standard
var currentVolume = 10

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XMLParserDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, UICollectionViewDelegate, UICollectionViewDataSource
{
    @IBOutlet weak var lblMain: UILabel!
    @IBOutlet weak var quranView: UIView!
    @IBOutlet weak var chaptersTblView: UITableView!
    @IBOutlet weak var lblVerse: UILabel!
    @IBOutlet weak var verseTblView: UITableView!
    
    @IBOutlet weak var volView: UIView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var volSlider: UISlider!
    @IBOutlet weak var lblVolCount: UILabel!
    
    @IBOutlet weak var qarisView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var txtMainView: UIView!
    
    @IBOutlet weak var leading: NSLayoutConstraint!
    
    var sura = String()
    var suraTitle: [AyatObj] = []
    var ayaTitle: [AyatObj] = []
    var suraDict = [String: [AyatObj]]()
    var aya = String()
    var indexArray:[String] = []
    
    var qarisArray:[HomeObject] = []
    var booksArray:[HomeObject] = []
    
    var quranFlag = false
    var volFlag = false
    var chapterNo = 1
    var verseNo = 1
    var verseCount = 0
    var test = false
    
    //BLE
    var manager : CBCentralManager!
    var myBluetoothPeripheral : CBPeripheral!
    var myCharacteristic : CBCharacteristic!
    var quranUUID: CBUUID = CBUUID(string: "0000ae10-0000-1000-8000-00805f9b34fb")
    var isMyPeripheralConected = false
    
    var tag = 0
    
    override func viewDidLoad()
    {
        sliderView.layer.cornerRadius = 10.0
        sliderView.layer.masksToBounds = true
        volSlider.value = Float(currentVolume)
        
        manager = CBCentralManager(delegate: self, queue: nil)
        
        quranView.layer.borderWidth = 1
        quranView.layer.borderColor = UIColor.darkGray.cgColor
        quranView.layer.shadowColor = UIColor.black.cgColor
        quranView.layer.shadowOpacity = 0.8
        quranView.layer.shadowRadius = 2
        quranView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        if let path = Bundle.main.url(forResource: "quran", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerRight.direction = .right
        
        let swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerLeft.direction = .left
        
        txtMainView.addGestureRecognizer(swipeGestureRecognizerRight)
        txtMainView.addGestureRecognizer(swipeGestureRecognizerLeft)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loadQaris()
    {
        let qariNames:[String] = [
            "Abdul Rahman Al Sudais",
            "Abdul Basit           ",
            "Maher Almuaiqly       ",
            "Ahmed Bin Ali Ajmi",
            "Saad Al-Ghamidi       ",
            "Muhammad Siddiq al-Minshawi",
            "Mishary Rashid Alafasy",
            "Mahmoud Khalil Al Hussary",
            "Abdur Rahman al Hudhaifi",
            "Muhammad Ayub       ",
            "Abdullah Basfar     ",
            "Abu Bakr Al Shatri  ",
            "Hani Ar Rifai       ",
            "Muhammad Jebril     ",
            "Ibrahim Al Akhdar",
            "Saleh Albudair",
            "Qari Barakatullah Saleem"]
//            "Abdurrashid Sufi",
//            "Abdulmohsen Al Qasim",
//            "Abdur Rahman Bukhatir",
//            "MUHAMMAD Al Tablawy",
//            "Wahid Zafar Qasmi",
//            "Sadaqat Ali",
//            "Minshawi with Children",
//            "Mahmoud Khalil Hussary with Chiled",
//            "Abdul Basit Mujawid",
//            "Abdullah Awwad Aljuhany",
//            "Ayman Swad",
//            "Yasir Quresi",
//            "Raad Alkurd",
//            "Default"]
        
        for i in 1...qariNames.count
        {
            //Simple usage example with NSData
            print(i)
            let filePath = Bundle.main.path(forResource: String(format: "reader%d", i), ofType: "webp")!
            var fileData:NSData? = nil
            do {
                fileData = try NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.uncached)
            }
            catch {
                print("Error loading WebP file")
            }
            
            let homeObj = HomeObject()
            let image:UIImage = UIImage(webpWithData: fileData!)
            homeObj.name = qariNames[i]
            homeObj.img = image
            qarisArray.append(homeObj)
        }
        
        collectionView.reloadData()
        qarisView.alpha = 1
    }
    
    func loadBooks()
    {
        let bookNames:[String] = [
                "Tarixi Muhammadiy",
                "Asma ul Husna",
                "Ruqya Sharya",
                "Qaida Nooranya",
                "Sahih Bukhari",
                "Sahih Muslim",
                "Hisnul Muslim",
                "40 Ahdith"]
        
        for i in 1...bookNames.count
        {
            //Simple usage example with NSData
            let filePath = Bundle.main.path(forResource: String(format: "Book%d", i), ofType: "webp")!
            var fileData:NSData? = nil
            do {
                fileData = try NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.uncached)
            }
            catch {
                print("Error loading WebP file")
            }
            let homeObj = HomeObject()
            let image:UIImage = UIImage(webpWithData: fileData!)
            homeObj.name = bookNames[i-1]
            homeObj.img = image
            booksArray.append(homeObj)
        }
        print("Count: \(booksArray.count)")
        collectionView.reloadData()
        qarisView.alpha = 1
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {

        var flag = false
        
        if sender.direction == .left
        {
            if chapterNo > 1
            {
                if verseNo == 1
                {
                    chapterNo -= 1
                    let ayatsArray = suraDict[indexArray[chapterNo - 1]] ?? []
                    verseNo = ayatsArray.count
                }
                else
                {
                    verseNo -= 1
                }
                flag = true
            }
            else
            {
                if verseNo > 1
                {
                    verseNo -= 1
                    flag = true
                }
            }
        }
        else
        {
            if chapterNo <= 114
            {
                let ayatsArray = suraDict[indexArray[chapterNo - 1]] ?? []
                
                if ayatsArray.count == verseNo
                {
                    chapterNo += 1
                    verseNo = 1
                }
                else
                {
                    verseNo += 1
                }
                flag = true
            }
        }
        
        if chapterNo > 114
        {
            return
        }
        else if flag
        {
            let ayatsArray = suraDict[indexArray[chapterNo - 1]] ?? []
            let ayatObj = ayatsArray[verseNo - 1]
            
            var prefix = "KSF"
            
            if ayatObj.page < 3
            {
                prefix.append("00")
            }
            else if ayatObj.page < 10
            {
                prefix.append("P00")
            }
            else if ayatObj.page < 100
            {
                prefix.append("P0")
            }
            else
            {
                prefix.append("P")
            }
            
            if lblMain != nil
            {
                lblMain.alpha = 0
            }
            
            for view in txtMainView.subviews
            {
                view.removeFromSuperview()
            }
            
            var resultStr = ""
            let screensWidth = UIScreen.main.bounds.width
            var xAxis:CGFloat =  screensWidth - 80
            var yAxis:CGFloat = 10.0
            
            for i in ayatObj.start...ayatObj.end
            {
                resultStr = String(Character(UnicodeScalar(i)!))
                
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
                let img = renderer.image { ctx in
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center

                    let attrs = [NSAttributedString.Key.font: UIFont(name: String(format:"%@%d", prefix, ayatObj.page), size: 50)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]

                    let string = resultStr
                    string.draw(with: CGRect(x: 0, y: 0, width: 70, height: 70), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
                    print(string)
                }
                
                let imgView = UIImageView(frame: CGRect(x: xAxis, y: yAxis, width: img.size.width, height: img.size.height))
                imgView.image = img
                txtMainView.addSubview(imgView)
                print(img.size.width)
                xAxis -= 75
                
                if xAxis <= 60
                {
                    xAxis = 300.0
                    yAxis += 70.0
                }
            }
            
            
            if isMyPeripheralConected
            {
                let dataToSend = NSMutableData()
                 
                var division = verseNo / 255
                var remainder = verseNo % 255
                
                print("Surat: \(chapterNo)")
                print("Ayat: \(verseNo)")
                print("Division: \(division)")
                print("Remainder: \(remainder)")
                
                let surat = Data(bytes: &chapterNo, count: MemoryLayout.size(ofValue: chapterNo))
                let div = Data(bytes: &division, count: MemoryLayout.size(ofValue: division))
                let rem = Data(bytes: &remainder, count: MemoryLayout.size(ofValue: remainder))
                
                dataToSend.append("S".data(using: String.Encoding.ascii)!)
                dataToSend.append(surat)
                dataToSend.append(rem)
                dataToSend.append(div)
                
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: myCharacteristic, type: CBCharacteristicWriteType.withResponse)
                print("value written")
            }
            else
            {
                self.view.makeToast("Bluetooth device disconnected")
            }
        }
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
        
        UIView.animate(withDuration: 0.3) { [weak self] in
          self?.view.layoutIfNeeded()
        }
    }
    
    @IBAction func volumeBtnAction(_ sender: Any)
    {
        if volFlag
        {
            volView.alpha = 0
            volFlag = false
        }
        else
        {
            volView.alpha = 1
            volFlag = true
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
          self?.view.layoutIfNeeded()
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider)
    {
        let currentValue = Int(sender.value)
            
        lblVolCount.text = "\(currentValue)"
        
        var key = ""
        
        if currentValue < currentVolume
        {
            key = "10"
        }
        else
        {
            key = "6"
        }
        
        if isMyPeripheralConected
        {
            let dataToSend: Data = key.data(using: String.Encoding.utf8)!
            myBluetoothPeripheral.writeValue(dataToSend, for: myCharacteristic, type: CBCharacteristicWriteType.withResponse)
            print("value written")
        }
        else
        {
            self.view.makeToast("Bluetooth device disconnected")
        }
    }
    
    @IBAction func clickBtnAction(_ button: UIButton)
    {
        var key = ""
        var flag = false
        
        if button.tag == 1
        {
            key = "8"
            flag = true
        }
        else if button.tag == 2
        {
        
        }
        else if button.tag == 3
        {
           
        }
        else if button.tag == 4
        {
            manager = CBCentralManager(delegate: self, queue: nil)
        }
        else if button.tag == 5
        {
            key = ""
        }
        else if button.tag == 6
        {
            key = "13"
            flag = true
        }
        else if button.tag == 7
        {
            loadBooks()
        }
        else if button.tag == 8
        {
            key = ""
        }
        else if button.tag == 9
        {
            key = "14"
            flag = true
        }
        else if button.tag == 10
        {
            key = "15"
            flag = true
        }
        else if button.tag == 11
        {
            key = "16"
            flag = true
        }
        else if button.tag == 12
        {
            key = "4"
            flag = true
        }
        else if button.tag == 13
        {
            tag = 1001
            loadQaris()
        }
        else if button.tag == 14
        {
            key = "17"
            flag = true
        }
        else if button.tag == 15
        {
            key = ""
        }
        else if button.tag == 16
        {
            key = "1"
            flag = true
        }
        
        if flag
        {
            if isMyPeripheralConected
            {
                let dataToSend: Data = key.data(using: String.Encoding.utf8)!
                myBluetoothPeripheral.writeValue(dataToSend, for: myCharacteristic, type: CBCharacteristicWriteType.withResponse)
                print("value written: \(key)")
            }
            else
            {
                self.view.makeToast("Bluetooth device disconnected")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        leading.constant = -160
        quranFlag = false
        volView.alpha = 0
        volFlag = false
        qarisView.alpha = 0
        
        UIView.animate(withDuration: 0.3) { [weak self] in
          self?.view.layoutIfNeeded()
        }
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
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if tag == 1001
        {
            return qarisArray.count
        }
        else
        {
            print("--------------")
            return booksArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        
        if tag == 1001
        {
            cell.lblName.text = qarisArray[indexPath.row].name
            cell.imgView.image = qarisArray[indexPath.row].img
        }
        else
        {
            cell.lblName.text = booksArray[indexPath.row].name
            cell.imgView.image = booksArray[indexPath.row].img
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        if tag == 1001
        {
            
        }
        else
        {
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isMyPeripheralConected
        {
            let dataToSend = NSMutableData()
            
            let qari = indexPath.row + 1
            
            dataToSend.append("Q".data(using: String.Encoding.ascii)!)
            
            myBluetoothPeripheral.writeValue(dataToSend as Data, for: myCharacteristic, type: CBCharacteristicWriteType.withResponse)
            print("value written")
        }
        else
        {
            self.view.makeToast("Bluetooth device disconnected")
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
            verseNo = indexPath.row + 1
            let ayatObj = ayaTitle[indexPath.row]
            
            var prefix = "KSF"
            
            if ayatObj.page < 3
            {
                prefix.append("00")
            }
            else if ayatObj.page < 10
            {
                prefix.append("P00")
            }
            else if ayatObj.page < 100
            {
                prefix.append("P0")
            }
            else
            {
                prefix.append("P")
            }
            
            if lblMain != nil
            {
                lblMain.alpha = 0
            }
            
            let fontName = String(format:"%@%d", prefix, ayatObj.page)
            
            print(fontName)
            
            for view in txtMainView.subviews
            {
                view.removeFromSuperview()
            }
            
            var resultStr = ""
            let screensWidth = UIScreen.main.bounds.width
            var xAxis:CGFloat =  screensWidth - 80
            var yAxis:CGFloat = 10.0
            
            for i in ayatObj.start...ayatObj.end
            {
                resultStr = String(Character(UnicodeScalar(i)!))
                
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
                let img = renderer.image { ctx in
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center

                    let attrs = [NSAttributedString.Key.font: UIFont(name: String(format:"%@%d", prefix, ayatObj.page), size: 50)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]

                    let string = resultStr
                    string.draw(with: CGRect(x: 0, y: 0, width: 70, height: 70), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
                    print(string)
                }
                
                let imgView = UIImageView(frame: CGRect(x: xAxis, y: yAxis, width: img.size.width, height: img.size.height))
                imgView.image = img
                txtMainView.addSubview(imgView)
                print(img.size.width)
                xAxis -= 75
                
                if xAxis <= 60
                {
                    xAxis = 300.0
                    yAxis += 70.0
                }
            }

            leading.constant = -160
            quranFlag = false
            
            if isMyPeripheralConected
            {
                let dataToSend = NSMutableData()
                
                let ayat = indexPath.row + 1
                var division = 5
                var remainder = 5
                
                print("Surat: \(chapterNo)")
                print("Ayat: \(ayat)")
                print("Division: \(division)")
                print("Remainder: \(remainder)")
                
                let surat = Data(bytes: &chapterNo, count: MemoryLayout.size(ofValue: chapterNo))
                let div = Data(bytes: &division, count: MemoryLayout.size(ofValue: division))
                let rem = Data(bytes: &remainder, count: MemoryLayout.size(ofValue: remainder))
                
                dataToSend.append("S".data(using: String.Encoding.ascii)!)
                dataToSend.append(surat)
                dataToSend.append(rem)
                dataToSend.append(div)
                
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: myCharacteristic, type: CBCharacteristicWriteType.withResponse)
                print("value written")
            }
            else
            {
                self.view.makeToast("Bluetooth device disconnected")
            }
        }
    }
    
    func asciiToString(start: Int, end: Int) -> String
    {
        var resultStr = ""
        var code = start
        
        for _ in start...end
        {
            resultStr.append(Character(UnicodeScalar(code)!))
            resultStr.append("  ")
            code += 1
        }
        print(resultStr)
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
        
//        self.view.makeToast(msg)
        print("STATE: " + msg)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Name: \(peripheral.name)")
       
        if peripheral.name != nil || peripheral.name == "AC692x_BLE"
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
        self.view.makeToast("Bluetooth device connected")
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
            
            for cc in characterArray {
                print(cc.uuid)
                if(cc.uuid == quranUUID) {
                    print(cc.uuid.uuidString)
                    myCharacteristic = cc
                    print("characteristics")
//                    peripheral.readValue(for: cc)
//                    writeValue()
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print ("22222222")
        if (characteristic.uuid == quranUUID) {
            
            let readValue = characteristic.value
            let value = (readValue! as NSData).bytes.bindMemory(to: Int.self, capacity: readValue!.count).pointee //used to read an Int value
            print ("Value: \(value)")
        }
    }
}


class TableCell: UITableViewCell
{
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgView:UIImageView!
}

class CollectionCell: UICollectionViewCell
{
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var imgView:UIImageView!
}

class HomeObject: NSObject
{
    var name: String!
    var img:UIImage!
}
