//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit
import CoreBluetooth

var defaults = UserDefaults.standard
var currentVolume = 20

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XMLParserDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate
{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMain: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
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
    
    @IBOutlet weak var txtView: UITextView!
    
    var sura = String()
    var suraTitle: [AyatObj] = []
    var ayaTitle: [AyatObj] = []
    var suraDict = [String: [AyatObj]]()
    var aya = String()
    var indexArray:[String] = []
    
    var qarisArray:[HomeObject] = []
    var booksArray:[HomeObject] = []
    var transArray:[HomeObject] = []
    
    var quranFlag = false
    var volFlag = false
    var chapterNo = 1
    var verseNo = 1
    var verseCount = 0
    var test = false
    
    //BLE
    var manager : CBCentralManager!
//    var myBluetoothPeripheral : CBPeripheral!
//    var myCharacteristic : CBCharacteristic!
//    var quranUUID: CBUUID = CBUUID(string: "0000ae10-0000-1000-8000-00805f9b34fb")
//    var isMyPeripheralConected = false
    
    var tag = 0
    
    override func viewDidLoad()
    {
        sliderView.layer.cornerRadius = 10.0
        sliderView.layer.masksToBounds = true
        volSlider.value = Float(currentVolume)
        
        transArray = [HomeObject(name: "Urdu", img: UIImage(named: "Pakistan")!, key: ""), HomeObject(name: "English", img: UIImage(named: "England")!, key: "") , HomeObject(name: "French", img: UIImage(named: "France")!, key: ""), HomeObject(name: "Turkish", img: UIImage(named: "Turki")!, key: "")]
        
//        manager = CBCentralManager(delegate: self, queue: nil)
        
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
    
//    override func viewWillDisappear(_ animated: Bool) {
//        manager = nil
//        isMyPeripheralConected = false
//        myBluetoothPeripheral = nil
//    }
    
    func loadQaris()
    {
        let qariNames:[String] = [
                        "Abdul Rahman Al Sudais",
                        "Abdul Basit",
                        "Maher Almuaiqly",
                        "Ahmed Bin Ali Ajmi",
                        "Saad Al-Ghamidi",
                        "Muhammad Siddiq al-Minshawi",
                        "Mishary Rashid Alafasy",
                        "Mahmoud Khalil Al Hussary",
                        "Abdur Rahman al Hudhaifi",
                        "Muhammad Ayub",
                        "Abdullah Basfar",
                        "Abu Bakr Al Shatri",
                        "Hani Ar Rifai",
                        "Muhammad Jebril",
                        "Ibrahim Al Akhdar",
                        "Other",
                        "Saleh Albudair",
                        "Other",
                        "Qari Barakatullah Saleem",
                        "Abdurrashid Sufi",
                        "Other",
                        "Other",
                        "Other",
                        "Other",
                        "WBW",
                        "Abdulmohsen Al Qasim",
                        "Abdur Rahman Bukhatir",
                        "MUHAMMAD Al Tablawy",
                        "Ibrahim Al Akhdar",
                        "Wahid Zafar Qasmi",
                        "Sadaqat Ali",
                        "Other",
                        "Other",
                        "Other",
                        "Other",
                        "Minshawi with Children",
                        "Mahmoud Khalil Hussary with Chiled",
                        "Abdul Basit Mujawid",
                        "Saleh Albudair",
                        "Abdullah Awwad Aljuhany",
                        "Ayman Swad",
                        "Other",
                        "Yasir Quresi",
                        "Ibraheem Jamal",
                        "Ahmed Deban",
                        "Raad Alkurd",
                        "Alsultani riwayah Hasham ibne amir",
                        "Alsultani riwayah Hasham ibne amir",
                        "Yaqoob al hazarmi",
        ]
        
        let qariImages:[String] = [
                    "01Sudais",
                    "02abdulbasit",
                    "03Muaqly",
                    "04ajmi",
                    "05Ghamdi",
                    "06minshawi",
                    "07Alfasey",
                    "08alhusary",
                    "09hudaify",
                    "10Ayub",
                    "11basfer",
                    "12abubakershatery",
                    "13arrifai",
                    "14jibreel",
                    "15ibraheemakhder",
                    "defaultReader",
                    "17SalehBudair",
                    "defaultReader",
                    "19qarisaleem",
                    "20rasheedsofi",
                    "defaultReader",
                    "defaultReader",
                    "defaultReader",
                    "defaultReader",
                    "defaultReader",
                    "26Muhsin",
                    "27bukhater",
                    "28Tablawy",
                    "29ibraheem",
                    "30waheedzafer",
                    "31sadaqatali",
                    "defaultReader",
                    "defaultReader",
                    "defaultReader",
                    "defaultReader",
                    "36minshawiwithchiled",
                    "37AlhusarywithChild",
                    "38AbdulBasit(Mujawed)",
                    "defaultReader",
                    "40Aljuhany",
                    "41AymanSwad",
                    "defaultReader",
                    "43YasirQuresi",
                    "defaultReader",
                    "defaultReader",
                    "46RaadAlkurd",
                    "defaultReader",
                    "defaultReader",
                    "defaultReader",
                    "defaultReader",
            ]
        
        for i in 0..<qariNames.count
        {
            //Simple usage example with NSData
            let filePath = Bundle.main.path(forResource: qariImages[i], ofType: "webp")

            if filePath != nil && filePath != ""
            {
                var fileData:NSData? = nil
                do {
                    fileData = try NSData(contentsOfFile: filePath!, options: NSData.ReadingOptions.uncached)
                }
                catch {
                    print("Error loading WebP file")
                }
                
                let image:UIImage = UIImage(webpWithData: fileData!)
                let homeObj = HomeObject(name: qariNames[i], img: image, key: "")
                qarisArray.append(homeObj)
            }
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
        
        let bookKeys:[Int] = [5,27,10,6,7,8,9,26,27]
        
        for i in 1...bookNames.count
        {
            let filePath = Bundle.main.path(forResource: String(format: "Book%d", i), ofType: "webp")!
            var fileData:NSData? = nil
            do {
                fileData = try NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.uncached)
            }
            catch {
                print("Error loading WebP file")
            }
            
            let image:UIImage = UIImage(webpWithData: fileData!)
            let homeObj = HomeObject(name: bookNames[i-1], img: image, key: "\(bookKeys[i-1])")
            booksArray.append(homeObj)
        }
        
        collectionView.reloadData()
        qarisView.alpha = 1
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return txtMainView
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
            lblTitle.text = String(format: "سورة %@",indexArray[chapterNo - 1])
            
            let ayatsArray = suraDict[indexArray[chapterNo - 1]] ?? []
            let ayatObj = ayatsArray[verseNo - 1]
            
//            txtView.text = ayatObj.text
            
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
            let font = UIFont(name: fontName, size: 50)!
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            
            for view in txtMainView.subviews
            {
                view.removeFromSuperview()
            }
            
            var resultStr = ""
            var xAxis:CGFloat =  txtMainView.frame.width
            var yAxis:CGFloat = 10.0

//            var printResult = ""

            for i in ayatObj.start...ayatObj.end
            {
                var code = i
                if code == 127
                {
                    code = 254
                }
                
                resultStr = String(Character(UnicodeScalar(code)!))
                var width:CGFloat = 0.0

//                printResult += "{\(1), \(resultStr)}, "

                let string = resultStr
                let size:CGSize = string.sizeOfString(usingFont: attrs)
                width = size.width

                if width > 17 //&& string != "·"
                {
                    if (xAxis - width) < 0
                    {
                        xAxis = txtMainView.frame.width
                        yAxis += 70.0
                    }

                    let lbl = UILabel(frame: CGRect(x: xAxis - width, y: yAxis, width: width, height: 70))
                    lbl.font = font
                    lbl.text = string
                    txtMainView.addSubview(lbl)
                    xAxis -= width + 5
                }
            }
//            print("//////////////////////////////////////////////")
//            print("\(lblTitle.text!), Ayat no: \(verseNo - 1)")
//            print("Font: \(fontName)")
//            print(printResult)
//            print("//////////////////////////////////////////////")
            
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: yAxis + 70)
            
            if isMyPeripheralConected
            {
                let division = verseNo / 127
                let remainder = verseNo % 127

                let surat = UInt8(chapterNo)
                let div = UInt8(division)
                let rem = UInt8(remainder)

                let dataToSend = Data([UInt8(Character("S").asciiValue!), surat, div, rem])
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)

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
            let ayatObj = AyatObj()
            
            for string in attributeDict
            {
                if string.key == "index"
                {
                    ayatObj.ayat = Int(string.value)
                }
                else if string.key == "text"
                {
                    ayatObj.text = string.value
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
        var value = UInt8(currentValue)
        print(value)
        if isMyPeripheralConected
        {
            var key = 2
            if value < currentVolume
            {
                let dataToSend = NSMutableData()
//                dataToSend.append("2".data(using: String.Encoding.utf8)!)
//                dataToSend.append(Data(bytes: &val, count: MemoryLayout.size(ofValue: val)))
                dataToSend.append(Data(bytes: &key, count: MemoryLayout.size(ofValue: key)))
                dataToSend.append(Data(bytes: &value, count: MemoryLayout.size(ofValue: value)))
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
                print("value written")
                currentVolume = currentValue
            }
            else if value > currentVolume
            {
                let dataToSend = NSMutableData()
//                dataToSend.append("2".data(using: String.Encoding.utf8)!)
//                dataToSend.append(Data(bytes: &val, count: MemoryLayout.size(ofValue: val)))
                dataToSend.append(Data(bytes: &key, count: MemoryLayout.size(ofValue: key)))
                dataToSend.append(Data(bytes: &value, count: MemoryLayout.size(ofValue: value)))
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
                print("value written")
                currentVolume = currentValue
            }
        }
        else
        {
            self.view.makeToast("Bluetooth device disconnected")
        }
    }
    
    @IBAction func clickBtnAction(_ button: UIButton)
    {
        var key = 0
        var flag = false
        
        if button.tag == 1
        {
            key = 18
            flag = true
        }
        else if button.tag == 2
        {
            key = 22
            flag = true
        }
        else if button.tag == 3
        {
            key = 5
            flag = true
        }
        else if button.tag == 4
        {
            manager = CBCentralManager(delegate: self, queue: nil)
        }
        else if button.tag == 5
        {
            key = 19
            flag = true
        }
        else if button.tag == 6
        {
            key = 13
            flag = true
        }
        else if button.tag == 7
        {
            tag = 1002
            loadBooks()
        }
        else if button.tag == 8
        {
            tag = 1003
            collectionView.reloadData()
            qarisView.alpha = 1
        }
        else if button.tag == 9
        {
            key = 14
            flag = true
        }
        else if button.tag == 10
        {
            key = 15
            flag = true
        }
        else if button.tag == 11
        {
            key = 16
            flag = true
        }
        else if button.tag == 12
        {
            key = 23
            flag = true
        }
        else if button.tag == 13
        {
            tag = 1001
            loadQaris()
        }
        else if button.tag == 14
        {
            key = 17
            flag = true
        }
        else if button.tag == 15
        {
            key = 4
            flag = true
        }
        else if button.tag == 16
        {
            key = 1
            flag = true
        }
        
        if flag
        {
            if isMyPeripheralConected && quranCharacteristic != nil
            {
                let dataToSend = NSMutableData()
                dataToSend.append("1".data(using: String.Encoding.ascii)!)
                dataToSend.append(Data(bytes: &key, count: MemoryLayout.size(ofValue: key)))
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
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
        else if tag == 1002
        {
            return booksArray.count
        }
        else if tag == 1003
        {
            return transArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        
        if tag == 1001
        {
            cell.lblName.text = qarisArray[indexPath.row].name
            cell.imgView.image = qarisArray[indexPath.row].img
        }
        else if tag == 1002
        {
            cell.lblName.text = booksArray[indexPath.row].name
            cell.imgView.image = booksArray[indexPath.row].img
        }
        else if tag == 1003
        {
            cell.lblName.text = transArray[indexPath.row].name
            cell.imgView.image = transArray[indexPath.row].img
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isMyPeripheralConected
        {
            if tag == 1001
            {
                let qari = UInt8(indexPath.row + 1)
                print(qari)
                let dataToSend = Data([3,qari])
                
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
            else if tag == 1002
            {
                let key =  UInt8(booksArray[indexPath.row].key ?? "0")!
                print(key)
                let dataToSend = Data([1,key])
                
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
            else if tag == 1003
            {
                let trans =  UInt8(indexPath.row + 1)
                print(trans)
                let dataToSend = Data([4,trans])
                
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
            qarisView.alpha = 0
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
            lblTitle.text = String(format: "سورة %@",indexArray[chapterNo - 1])
            verseNo = indexPath.row + 1
            let ayatObj = ayaTitle[indexPath.row]
            
//            txtView.text = ayatObj.text
            
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
            let font = UIFont(name: fontName, size: 50)!
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            
            for view in txtMainView.subviews
            {
                view.removeFromSuperview()
            }
            
            var resultStr = ""
            var xAxis:CGFloat =  txtMainView.frame.width
            var yAxis:CGFloat = 10.0

//            var printResult = ""

            for i in ayatObj.start...ayatObj.end
            {
                var code = i
                if code == 127
                {
                    code = 254
                }
                
                resultStr = String(Character(UnicodeScalar(code)!))
                var width:CGFloat = 0.0

//                printResult += "{\(1), \(resultStr)}, "

                let string = resultStr
                let size:CGSize = string.sizeOfString(usingFont: attrs)
                width = size.width

                if width > 10 //&& string != "·"
                {
                    if (xAxis - width) < 0
                    {
                        xAxis = txtMainView.frame.width
                        yAxis += 70.0
                    }

                    let lbl = UILabel(frame: CGRect(x: xAxis - width, y: yAxis, width: width, height: 70))
                    lbl.font = font
                    lbl.text = string
                    txtMainView.addSubview(lbl)
                    xAxis -= width + 5
                }
            }
//            print("//////////////////////////////////////////////")
//            print("\(lblTitle.text!), Ayat no: \(verseNo - 1)")
//            print("Font: \(fontName)")
//            print(printResult)
//            print("//////////////////////////////////////////////")
            
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: yAxis + 70)

            leading.constant = -160
            quranFlag = false
            
            if isMyPeripheralConected
            {
                let division = verseNo / 127
                let remainder = verseNo % 127

                let surat = UInt8(chapterNo)
                let div = UInt8(division)
                let rem = UInt8(remainder)

                let dataToSend = Data([UInt8(Character("S").asciiValue!), surat, div, rem])
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
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
                    print("UUID: \(cc.uuid.uuidString)")
                    quranCharacteristic = cc
                }
                else if(cc.uuid == prayersUUID) {
                    print("UUID: \(cc.uuid.uuidString)")
                    prayersCharacteristic = cc
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
    var key: String!
    
    init (name: String, img: UIImage, key: String)
    {
        self.name = name
        self.img = img
        self.key = key
    }
}

extension String {
    func sizeOfString(usingFont fontAttributes: [NSAttributedString.Key:Any]) -> CGSize {
        let size = self.size(withAttributes: fontAttributes)
        return size
    }
}

extension StringProtocol {
    var asciiValues: [UInt8] { compactMap(\.asciiValue) }
}
