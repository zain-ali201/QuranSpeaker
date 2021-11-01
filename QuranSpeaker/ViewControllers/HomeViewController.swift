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
var chapterNo = 1
var verseNo = 1

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XMLParserDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var booksView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMain: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var quranView: UIView!
    @IBOutlet weak var chaptersTblView: UITableView!
    @IBOutlet weak var lblVerse: UILabel!
    @IBOutlet weak var verseTblView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var volView: UIView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var volSlider: UISlider!
    @IBOutlet weak var lblVolCount: UILabel!
    @IBOutlet weak var qarisView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var booksCollectionView: UICollectionView!
    
    @IBOutlet weak var txtMainView: UIView!
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var txtView: UITextView!
    
    var sura = String()
    var suraTitle: [AyatObj] = []
    var ayaTitle: [AyatObj] = []
    var suraDict = [String: [AyatObj]]()
    var aya = String()
    var indexArray:[String] = []
    
    var qariNames:[String] = []
    var transNames:[String: String] = [:]

    var booksArray:[HomeObject] = []
    
    var qarisArray:[Any] = [Any]()
    var transArray:[Any] = [Any]()
    
    var quranFlag = false
    var volFlag = false
    var verseCount = 0
    var test = false
    var timer:Timer!
    
    //BLE
//    var manager : CBCentralManager!
//    var myBluetoothPeripheral : CBPeripheral!
//    var myCharacteristic : CBCharacteristic!
//    var quranUUID: CBUUID = CBUUID(string: "0000ae10-0000-1000-8000-00805f9b34fb")
//    var isMyPeripheralConected = false
    
    var tag = 0
    var booksFlag = false
    
    //MARK:- UIView Delegates
    
    override func viewDidLoad()
    {
        homeVC = self
        
        loadNames()
        
        let qArray = UserDefaults.standard.value(forKey: "qarisArray")
        
        if qArray != nil
        {
            qarisArray = qArray as? [Any] ?? []
        }
        
        let tArray = UserDefaults.standard.value(forKey: "transArray")
        
        if tArray != nil
        {
            transArray = tArray as? [Any] ?? []
        }
        
        sliderView.layer.cornerRadius = 10.0
        sliderView.layer.masksToBounds = true
        volSlider.value = Float(currentVolume)
        
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
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        txtMainView.addGestureRecognizer(pinchGesture)
        
        AppUtility.lockOrientation(.all)
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.readDeviceValues), userInfo: nil, repeats: true)
        changeAyat()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func hideMenu()
    {
        lblVerse.text = ""
        leading.constant = -170
        quranFlag = false
        volView.alpha = 0
        volFlag = false
        qarisView.alpha = 0
        
        UIView.animate(withDuration: 0.3) { [weak self] in
          self?.view.layoutIfNeeded()
        }
    }
    
    //MARK:- UIInterfaceOrientation Delegates
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval)
    {
        if toInterfaceOrientation == .landscapeLeft || toInterfaceOrientation == .landscapeRight
        {
            menuView.isHidden = true
            buttonsView.isHidden = true
            bottom.constant = -285
        }
        else
        {
            menuView.isHidden = false
            buttonsView.isHidden = false
            bottom.constant = 0
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        changeAyat()
    }
    
    //MARK:- UIScrollView Delegates
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x/self.view.frame.width))
        print(pageIndex)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x/self.view.frame.width))
        
        if booksArray.count > pageIndex
        {
            let key =  UInt8(booksArray[pageIndex].key ?? "0")!
            print(key)
            let dataToSend = Data([1,key])
            
            if isMyPeripheralConected
            {
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
            else
            {
                self.view.makeToast("Bluetooth device disconnected")
            }
        }
    }

    //MARK:- XMLParser Delegates

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
    
    //MARK:- Button Actions
    
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
            booksView.isHidden = true
            key = 13
            flag = true
        }
        else if button.tag == 7
        {
//            booksView.isHidden = true
            collectionView.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .left, animated: false)
            tag = 1002
            loadBooks()
        }
        else if button.tag == 8
        {
//            booksView.isHidden = true
//            if transArray.count > 0
//            {
                collectionView.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .left, animated: false)
                loader.startAnimating()
                tag = 1003
                collectionView.reloadData()
                qarisView.alpha = 1
//            }
//            else
//            {
                if transArray.count == 0
                {
                    if isMyPeripheralConected && quranCharacteristic != nil
                    {
                        let dataToSend = Data([UInt8(Character("T").asciiValue!)])
                        myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
                        print("value written: \(key)")
                    }
                    else
                    {
                        self.view.makeToast("Bluetooth device disconnected")
                    }
                }
                
//            }
        }
        else if button.tag == 9
        {
            booksView.isHidden = true
            key = 60
            flag = true
        }
        else if button.tag == 10
        {
            key = 15
            flag = true
        }
        else if button.tag == 11
        {
            booksView.isHidden = true
            key = 62
            flag = true
        }
        else if button.tag == 12
        {
            key = 2
            flag = true
        }
        else if button.tag == 13
        {
            booksView.isHidden = true
//            if qarisArray.count > 0
//            {
                collectionView.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .left, animated: false)
                loader.startAnimating()
                tag = 1001
                collectionView.reloadData()
                qarisView.alpha = 1
//            }
//            else
//            {
                if qarisArray.count == 0
                {
                    if isMyPeripheralConected && quranCharacteristic != nil
                    {
                        let dataToSend = Data([UInt8(Character("R").asciiValue!)])
                        myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
                        print("value written: \(key)")
                    }
                    else
                    {
                        self.view.makeToast("Bluetooth device disconnected")
                    }
                }
//            }
        }
        else if button.tag == 14
        {
            booksView.isHidden = true
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
    
    @IBAction func backBtnAction(_ sender: Any) {
        lblVerse.text = ""
        if chaptersTblView.alpha == 1
        {
            leading.constant = -170
            quranFlag = false
        }
        else
        {
            chaptersTblView.alpha = 1
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
          self?.view.layoutIfNeeded()
        }
    }

    @IBAction func quranBtnAction(_ sender: Any) {
        
        if quranFlag
        {
            lblVerse.text = ""
            leading.constant = -170
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
        let value = UInt8(currentValue)
        print(value)
        if isMyPeripheralConected
        {
            let dataToSend = Data([2,value])
            myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
        else
        {
            self.view.makeToast("Bluetooth device disconnected")
        }
    }
    
    
    //MARK:- Custom Functions
    
    @objc private func didPinch(_ sender: UIPinchGestureRecognizer) {
    
        print(sender.scale)
        if fontSize < 100 && sender.scale > 1
        {
            fontSize = fontSize + sender.scale
            changeAyat()
        }
        else if fontSize > 30 && sender.scale < 1
        {
            fontSize = fontSize - sender.scale
            changeAyat()
        }
    }
    
    @objc func readDeviceValues()
    {
        if myBluetoothPeripheral != nil && quranCharacteristic != nil
        {
            myBluetoothPeripheral.readValue(for: quranCharacteristic)
        }
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer)
    {
        changeAyat(sender: sender.direction)
    }
    
    func setDeviceTime()
    {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        
        var year = components.year ?? 0
        let month = UInt8(components.month ?? 0 + 1)
        let day = UInt8(components.day ?? 0)
        let hour = UInt8(components.hour ?? 0)
        let min = UInt8(components.minute ?? 0)
        let sec = UInt8(components.second ?? 0)
        
        if year > 2000
        {
            year = year - 2000
        }
        
        let dataToSend = Data([UInt8(Character("C").asciiValue!), hour, min, sec, day, month, UInt8(year)])
        myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
        print("time updated")
    }
    
    func changeAyat()
    {
        if chapterNo == 0
        {
            chapterNo = 1
        }

        if verseNo == 0
        {
            verseNo = 1
        }
        
        lblTitle.text = String(format: "سورة %@",indexArray[chapterNo - 1])
        
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

//        if lblMain != nil
//        {
//            lblMain.alpha = 0
//        }
        
        let fontName = String(format:"%@%d", prefix, ayatObj.page)
        print(fontName)
        let font = UIFont(name: fontName, size: fontSize)!
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

//            if width == 0.3 || width > 8
//            {
                if (xAxis - width) < 0
                {
                    xAxis = txtMainView.frame.width
                    yAxis += fontSize + 20
                }

                let lbl = UILabel(frame: CGRect(x: xAxis - width, y: yAxis, width: width, height: fontSize + 20))
                lbl.font = font
                lbl.text = string
                if (i%2 == 0)
                {
                    lbl.textColor = UIColor(red: 52.0/255.0, green: 150.0/255.0, blue: 89.0/255.0, alpha: 1.0)
                }
                else
                {
                    lbl.textColor = .black
                }
                
                if i == ayatObj.end
                {
                    lbl.textColor = UIColor.systemYellow
                }
                txtMainView.addSubview(lbl)
                xAxis -= width + 5
//            }
        }
//            print("//////////////////////////////////////////////")
//            print("\(lblTitle.text!), Ayat no: \(verseNo - 1)")
//            print("Font: \(fontName)")
//            print(printResult)
//            print("//////////////////////////////////////////////")
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: yAxis + fontSize + 20)
    }
    
    func loadNames()
    {
        qariNames = [
            "",
            "Abdullah Basfar",
            "Muhammad Ibraheem",
            "Saad Al-Ghamidi",
            "Mishary Rashid Alafasy",
            "Maher Almuaiqly",
            "Abdur Rahman al Hudhaifi",
            "Muhammad Siddiq al-Minshawi",
            "Abdulmohsen Al Qasim",
            "Abdul Basit",
            "Muhammad Jebril",
            "Muhammad Ayub",
            "Ahmed Bin Ali Ajmi",
            "Mahmoud Khalil Al Hussary",
            "Abdul Rahman Al Sudais",
            "Abu Bakr Al Shatri",
            "Qari Barakatullah Saleem",
            "Abdullah Awwad Aljuhany",
            "Abdurrashid SufiOther",
            "Minshawi with Children",
            "Abdur Rahman Bukhatir",
            "Sadaqat Ali",
            "Abdul Basit Mujawid",
            "Other",
            "Ibrahim Al Akhdar",
            "WBW",
            "Hani Ar Rifai",
            "Other",
            "Other",
            "Other",
            "Saleh Albudair",
            "Other",
            "Muhammad Al Tablawy",
            "Wahid Zafar Qasmi",
            "Other",
            "Other",
            "Other",
            "Other",
            "Other",
            "Other",
            "Other",
            "Raad Alkurdi",
            "Other ",
            "Ibraheem Jamal",
            "Ahmed Deban",
            "Alsultani Riwayah Hasham ibne amir",
            "Yaqoob al hazarmi",
            "Other",
            "Other",
            "Ayman Swad",
            "Other",
        ]
        
        transNames = [
            "0" :"Other",
            "52" :"Farsi",
            "54" :"Shayx Muhammad Sodiq",
            "55" :"English",
            "56" :"Urdu",
            "57" :"French",
            "58" :"Turkish",
            "59" :"Kyrgyz",
            "60" :"Marathi",
            "61" :"Tamil",
            "62" :"Somali",
            "63" :"Dari",
            "64" :"Pashto",
            "65" :"Bangla",
            "66" :"Bosnian",
            "67" :"Gujrati",
            "68" :"Portugese",
            "69" :"Russian",
            "70" :"German",
            "71" :"Kazakh",
            "72" :"Malaysian",
            "74" :"Spanish",
            "75" :"Thai",
            "76" :"Malyalam",
            "77" :"Kurdish",
            "78" :"Indonesian",
            "80" :"Swahili",
            "81" :"Italian",
            "82" :"Hindi",
            "83" :"Tatar",
            "84" :"Abdul Aziz",
            "85" :"Abdul Aziz Full Surah",
            "86" :"Jalalain"
        ]
    }
    
    func loadBooks()
    {
        let bookNames:[String] = [
                "Tarixi Muhammadiy",
                "Asma ul Husna",
                "Ruqya Sharya",
                "Muallim Sani",
                "Sahih Bukhari",
                "Sahih Muslim",
                "Hisnul Muslim",
                "40 Ahdith"
        ]
        
        let bookKeys:[Int] = [5,28,10,6,7,8,9,27]
        
        for i in 1...bookNames.count
        {
            let filePath = Bundle.main.path(forResource: String(format: "Book%d", i), ofType: "webp")!
            var fileData:NSData? = nil
            do
            {
                fileData = try NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.uncached)
            }
            catch
            {
                print("Error loading WebP file")
            }
            
            let image:UIImage = UIImage(webpWithData: fileData!)
            let homeObj = HomeObject(name: bookNames[i-1], img: image, key: "\(bookKeys[i-1])")
            booksArray.append(homeObj)
        }
        
        collectionView.reloadData()
        booksCollectionView.reloadData()
        qarisView.alpha = 1
    }
    
    func changeAyat(sender: UISwipeGestureRecognizer.Direction)
    {
        var flag = false
        
        if sender == .left
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
            getSurahAyat(ayatObj: ayatObj)
        }
    }
    
    func getSurahAyat(ayatObj: AyatObj)
    {
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
        
        let fontName = String(format:"%@%d", prefix, ayatObj.page)
        
        let font = UIFont(name: fontName, size: fontSize)!
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

        var printResult = ""
        var count = 0

        for i in ayatObj.start...ayatObj.end
        {
            var code = i
            if code == 127
            {
                code = 254
            }
            
            resultStr = String(Character(UnicodeScalar(code)!))
            var width:CGFloat = 0.0

            let string = resultStr
            let size:CGSize = string.sizeOfString(usingFont: attrs)
            width = size.width
            
            if width > 8
            {
                if (xAxis - width) < 0
                {
                    xAxis = txtMainView.frame.width
                    yAxis += fontSize + 20
                }

                let lbl = UILabel(frame: CGRect(x: xAxis - width, y: yAxis, width: width, height: fontSize + 20))
                lbl.font = font
                lbl.text = string
                if (i%2 == 0)
                {
                    lbl.textColor = UIColor(red: 52.0/255.0, green: 150.0/255.0, blue: 89.0/255.0, alpha: 1.0)
                }
                else
                {
                    lbl.textColor = .black
                }
                
                printResult += "[\(resultStr), \(code), \(width), \(lbl.text ?? "")]"
                
                if i == ayatObj.end
                {
                    lbl.textColor = UIColor.systemYellow
                }
                txtMainView.addSubview(lbl)
                xAxis -= width + 5
                count += 1
            }
            else
            {
                print("Width: \(width)")
                print("Missing word: \(resultStr)")
            }
        }
        print("//////////////////////////////////////////////")
        print("\(lblTitle.text!), Ayat no: \(verseNo - 1)")
        print("Font: \(fontName)")
        print(printResult)
        print("count: \(count)")
        print("//////////////////////////////////////////////")
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: yAxis + fontSize + 20)
        lblVerse.text = ""
        leading.constant = -170
        quranFlag = false
        
        if isMyPeripheralConected
        {
            let division = verseNo / 127
            let remainder = verseNo % 127

            let surat = UInt8(chapterNo)
            let div = UInt8(division)
            let rem = UInt8(remainder)
            
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.readDeviceValues), userInfo: nil, repeats: true)

            let dataToSend = Data([UInt8(Character("S").asciiValue!), surat, div, rem])
            myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
        else
        {
            self.view.makeToast("Bluetooth device disconnected")
        }
    }
    
    func fetchAppData(byteArray: [UInt8])
    {
        let firstBitValue = byteArray[0] & 0x01
        
        if firstBitValue != -1
        {
            let type = Character(UnicodeScalar(byteArray[0]))
            
            if type == "Q"
            {
                let bleSurah = Int(byteArray[1])
                let bleAyat = Int(byteArray[3])
                
                let totalQaris = Int(byteArray[6])
                let totalTrans = Int(byteArray[7])
                let volume = Int(byteArray[9])
                
                let ledMode = Int(byteArray[39])
                let ledContrast = Int(byteArray[40])
                let whiteContrast = Int(byteArray[41])
                let colorContrast = Int(byteArray[42])
                
                UserDefaults.standard.setValue(totalQaris, forKey: "totalQaris")
                UserDefaults.standard.setValue(totalTrans, forKey: "totalTrans")
                UserDefaults.standard.setValue(volume, forKey: "volume")
                UserDefaults.standard.setValue(ledMode, forKey: "ledMode")
                UserDefaults.standard.setValue(ledContrast, forKey: "ledContrast")
                UserDefaults.standard.setValue(whiteContrast, forKey: "whiteContrast")
                UserDefaults.standard.setValue(colorContrast, forKey: "colorContrast")
                
                print("/////////////////////////////")
                print("bleSurah: \(bleSurah)")
                print("bleAyat: \(bleAyat)")
                
                print("totalQaris: \(totalQaris)")
                print("totalTrans: \(totalTrans)")
                print("/////////////////////////////")
                
                if bleAyat != verseNo
                {
                    chapterNo = bleSurah
                    verseNo = bleAyat
                    changeAyat()
                }
            }
        }
    }
    
    func fetchQaris(byteArray: [UInt8])
    {
        print("qari")
        let firstBitValue = byteArray[0] & 0x02
        
        if firstBitValue != -1
        {
            let type = Character(UnicodeScalar(byteArray[0]))
            print(type)
            if type == "R"
            {
                qarisArray = []
                let totalQari = UserDefaults.standard.integer(forKey: "totalQaris")
                for i in 0..<totalQari
                {
                    let qari = Int(byteArray[i + 1])
                    
                    if qari <= 50
                    {
                        let dict:[String : Any] = ["Name" : qariNames[qari], "imageName": "\(qari)", "key" : "\(i)"]
                        qarisArray.append(dict)
                    }
                }

                collectionView.reloadData()
                UserDefaults.standard.setValue(qarisArray, forKey: "qarisArray")
            }
        }
    }
    
    func fetchTrans(byteArray: [UInt8])
    {
        print("trans")
        let firstBitValue = byteArray[0] & 0x01

        if firstBitValue != -1
        {
            let type = Character(UnicodeScalar(byteArray[0]))
            print(type)
            if type == "T"
            {
                transArray = []
                let totalTrans = UserDefaults.standard.integer(forKey: "totalTrans")
                for i in 0..<totalTrans
                {
                    let trans = Int(byteArray[i + 1])
                    print("Trans: \(trans)")
                    let dict:[String : Any] = ["Name" : transNames["\(trans)"] ?? "", "imageName": "\(trans)", "key" : "\(i)"]
                    transArray.append(dict)
                }
                
                collectionView.reloadData()
                UserDefaults.standard.setValue(transArray, forKey: "transArray")
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        hideMenu()
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

    //MARK:- UICollectionView Delegates
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView.tag == 1002
        {
            return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
        else
        {
            return CGSize(width: 128, height: 150)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if tag == 1001
        {
            if qarisArray.count > 0
            {
                loader.stopAnimating()
            }
            return qarisArray.count
        }
        else if tag == 1002
        {
            if booksArray.count > 0
            {
                loader.stopAnimating()
            }
            return booksArray.count
        }
        else if collectionView.tag == 1002
        {
            return booksArray.count
        }
        else if tag == 1003
        {
            if transArray.count > 0
            {
                loader.stopAnimating()
            }
            return transArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1002
        {
            let cell:CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
            
            cell.imgView.image = booksArray[indexPath.row].img
            
            return cell
        }
        
        let cell:CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        
        if tag == 1001
        {
            let dict:[String: Any] = qarisArray[indexPath.row] as! [String: Any]
            cell.lblName.text = dict["Name"] as? String
            
            let filePath = Bundle.main.path(forResource: dict["imageName"] as? String, ofType: "webp")!
            var fileData:NSData? = nil
            do {
                fileData = try NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.uncached)
            }
            catch {
                print("Error loading Webp file")
            }

            let image:UIImage = UIImage(webpWithData: fileData!)
            
            cell.imgView.image = image
        }
        else if tag == 1002
        {
            cell.lblName.text = booksArray[indexPath.row].name
            cell.imgView.image = booksArray[indexPath.row].img
        }
        else if tag == 1003
        {
            let dict:[String: Any] = transArray[indexPath.row] as! [String: Any]
            cell.lblName.text = dict["Name"] as? String
            
            let image:UIImage = UIImage(named: "\(dict["imageName"] as? String ?? "0")")!
            cell.imgView.image = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView.tag == 1002
        {
            let key =  UInt8(booksArray[indexPath.row].key ?? "0")!
            print(key)
            let dataToSend = Data([1,key])
            
            if isMyPeripheralConected
            {
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
            else
            {
                self.view.makeToast("Bluetooth device disconnected")
            }
            
            return
        }
        
        if tag == 1001
        {
            let dict:[String: Any] = qarisArray[indexPath.row] as! [String: Any]
            let qari = UInt8(dict["key"] as! String)!
            print(qari)
            let dataToSend = Data([3,qari])
            
            if isMyPeripheralConected
            {
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
            else
            {
                self.view.makeToast("Bluetooth device disconnected")
            }
            
//            booksView.isHidden = true
        }
        else if tag == 1002
        {
            let key =  UInt8(booksArray[indexPath.row].key ?? "0")!
            print(key)
            let dataToSend = Data([1,key])
            
            if isMyPeripheralConected
            {
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
            else
            {
                self.view.makeToast("Bluetooth device disconnected")
            }
            booksCollectionView.reloadData()
            let contentOffset = collectionView.contentOffset;
            booksCollectionView.scrollRectToVisible(CGRect(x:UIScreen.main.bounds.width * CGFloat(indexPath.row), y: contentOffset.y, width: collectionView.frame.width, height: collectionView.frame.height), animated: false)
            booksView.isHidden = false
        }
        else if tag == 1003
        {
            let dict:[String: Any] = transArray[indexPath.row] as! [String: Any]
            let trans =  UInt8(dict["key"] as! String)!
            print(trans)
            let dataToSend = Data([4,trans])
            
            if isMyPeripheralConected
            {
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
            else
            {
                self.view.makeToast("Bluetooth device disconnected")
            }
    
//            booksView.isHidden = true
        }
        qarisView.alpha = 0
    }
    
    //MARK:- UITableView Delegates
    
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
        booksView.isHidden = true
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
            getSurahAyat(ayatObj: ayatObj)
        }
        
        booksView.isHidden = true
    }
    
    //MARK:- CBCentralManager Delegates
    
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
                print("UUID: \(cc.uuid.uuidString)")
                if(cc.uuid == quranUUID) {
                    print("QuranUUID: \(cc.uuid.uuidString)")
                    quranCharacteristic = cc
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if (characteristic.uuid == quranUUID)
        {
            guard let characteristicData = characteristic.value else { return }
            let byteArray = [UInt8](characteristicData)
            
            if byteArray.count > 0
            {
                fetchAppData(byteArray: byteArray)
                fetchQaris(byteArray: byteArray)
                fetchTrans(byteArray: byteArray)
                
                if prayersVC != nil
                {
                    prayersVC.fetchPrayerData(byteArray: byteArray)
                }
            }
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

//% $ # " !
