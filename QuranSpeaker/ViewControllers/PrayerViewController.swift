//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit
import CoreLocation
import CoreBluetooth

class PrayerViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource//, CBCentralManagerDelegate, CBPeripheralDelegate
{
    @IBOutlet weak var fajrBtn: UIButton!
    @IBOutlet weak var dhuhrBtn: UIButton!
    @IBOutlet weak var asrBtn: UIButton!
    @IBOutlet weak var maghribBtn: UIButton!
    @IBOutlet weak var ishaBtn: UIButton!
    
    
    @IBOutlet weak var alarmMainView: UIView!
    @IBOutlet weak var alarmView: UIView!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var onBtn: UIButton!
    @IBOutlet weak var offBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblFajr: UILabel!
    @IBOutlet weak var lblSunrise: UILabel!
    @IBOutlet weak var lblDhuhr: UILabel!
    @IBOutlet weak var lblAsr: UILabel!
    @IBOutlet weak var lblSunset: UILabel!
    @IBOutlet weak var lblMaghrib: UILabel!
    @IBOutlet weak var lblIsha: UILabel!
    @IBOutlet weak var leading: NSLayoutConstraint!
    
    var menuFlag = false
    var lat = 0.0
    var lng = 0.0
    
    var locationManager = CLLocationManager()
    lazy var geocoder = CLGeocoder()
    var currentYear = 0
    var month = 1
    
    var prayer = 0
    var fajrFlag = 0
    var sunriseFlag = 0
    var dhuhrFlag = 0
    var asrFlag = 0
    var maghribFlag = 0
    var ishaFlag = 0
    
    var fajrInterval = 0
    var sunriseInterval = 0
    var dhuhrInterval = 0
    var asrInterval = 0
    var maghribInterval = 0
    var ishaInterval = 0
    
    var selectedInterval = 0
    //BLE
//    var bleManager : CBCentralManager!
//    var myBluetoothPeripheral : CBPeripheral!
//    var myCharacteristic : CBCharacteristic!
//    var quranUUID: CBUUID = CBUUID(string: "00002a00-0000-1000-8000-00805f9b34fb")
//    var isMyPeripheralConected = false
    
    override func viewDidLoad()
    {
        alarmView.layer.cornerRadius = 10.0
        alarmView.layer.masksToBounds = true
        
        
        prayersVC = self
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        lblTime.text = formatter.string(from: Date())
        
        formatter.dateFormat = "dd MMMM yyyy"
        lblDate.text = formatter.string(from: Date())
        
        formatter.dateFormat = "yyyy"
        currentYear = Int(formatter.string(from: Date()))!
        
        lblAddress.text = defaults.value(forKey: "address") as? String
        lblCity.text = defaults.value(forKey: "city") as? String
        lblCountry.text = defaults.value(forKey: "country") as? String
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        else
        {
            self.view.makeToast("Please enable your GPS location from device settings.")
        }
        
        changePrayerButtons()
        
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 550)
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        bleManager = nil
//        isMyPeripheralConected = false
//        myBluetoothPeripheral = nil
//    }
    
    func changePrayerButtons()
    {
        if (defaults.value(forKey: "fajrFlag") as? Int ?? 0) == 1
        {
            fajrBtn.setImage(UIImage(named: "alarm_on"), for: .normal)
        }
        else
        {
            fajrBtn.setImage(UIImage(named: "alarm_off"), for: .normal)
        }
        
        if (defaults.value(forKey: "dhuhrFlag") as? Int ?? 0) == 1
        {
            dhuhrBtn.setImage(UIImage(named: "alarm_on"), for: .normal)
        }
        else
        {
            dhuhrBtn.setImage(UIImage(named: "alarm_off"), for: .normal)
        }
        
        if (defaults.value(forKey: "asrFlag") as? Int ?? 0) == 1
        {
            asrBtn.setImage(UIImage(named: "alarm_on"), for: .normal)
        }
        else
        {
            asrBtn.setImage(UIImage(named: "alarm_off"), for: .normal)
        }
        
        if (defaults.value(forKey: "maghribFlag") as? Int ?? 0) == 1
        {
            maghribBtn.setImage(UIImage(named: "alarm_on"), for: .normal)
        }
        else
        {
            maghribBtn.setImage(UIImage(named: "alarm_off"), for: .normal)
        }
        
        if (defaults.value(forKey: "ishaFlag") as? Int ?? 0) == 1
        {
            ishaBtn.setImage(UIImage(named: "alarm_on"), for: .normal)
        }
        else
        {
            ishaBtn.setImage(UIImage(named: "alarm_off"), for: .normal)
        }
    }
    
    func fetchPrayerData(byteArray: [UInt8])
    {
        let firstBitValue = byteArray[0] & 0x02
//        print("firstBitValue: \(firstBitValue)")
        if firstBitValue != 0
        {
            let type = Character(UnicodeScalar(byteArray[0]))
            print(type)
            if type == "Z"
            {
                print("MonthNbr : \(Int(byteArray[1]))")
                let receivedMonth = Int(byteArray[1])
                if receivedMonth != month && receivedMonth > 0 && receivedMonth < 13
                {
                    month = Int(byteArray[1])
                    getYearPrayersTime()
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func alarmBtnAction(button: UIButton)
    {
        var flag = false
        prayer = button.tag
        selectedInterval = 0
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        if prayer == 1001
        {
            if (defaults.value(forKey: "fajrFlag") as? Int ?? 0) == 1
            {
                fajrFlag = 1
                flag = true
            }
            
            let fajr: Int = defaults.value(forKey: "fajrInterval") as? Int ?? 0
            
            if fajr > 0
            {
                fajrInterval = fajr
                selectedInterval = fajr
            }
            else
            {
                fajrInterval = 0
                selectedInterval = 0
            }
            
        }
        else if prayer == 1002
        {
            if (defaults.value(forKey: "sunriseFlag") as? Int ?? 0) == 1
            {
                sunriseFlag = 1
                flag = true
            }
            
            let sunrise: Int = defaults.value(forKey: "sunriseInterval") as? Int ?? 0
            
            if sunrise > 0
            {
                sunriseInterval = sunrise
                selectedInterval = sunrise
            }
            else
            {
                sunriseInterval = 0
                selectedInterval = 0
            }
        }
        else if prayer == 1003
        {
            if (defaults.value(forKey: "dhuhrFlag") as? Int ?? 0) == 1
            {
                dhuhrFlag = 1
                flag = true
            }
            
            let dhuhr: Int = defaults.value(forKey: "dhuhrInterval") as? Int ?? 0
            
            if dhuhr > 0
            {
                dhuhrInterval = dhuhr
                selectedInterval = dhuhr
            }
            else
            {
                dhuhrInterval = 0
                selectedInterval = 0
            }
        }
        else if prayer == 1004
        {
            if (defaults.value(forKey: "asrFlag") as? Int ?? 0) == 1
            {
                asrFlag = 1
                flag = true
            }
            
            let asr: Int = defaults.value(forKey: "asrInterval") as? Int ?? 0
            
            if asr > 0
            {
                asrInterval = asr
                selectedInterval = asr
            }
            else
            {
                asrInterval = 0
                selectedInterval = 0
            }
        }
        else if prayer == 1005
        {
            if (defaults.value(forKey: "maghribFlag") as? Int ?? 0) == 1
            {
                maghribFlag = 1
                flag = true
            }
            
            let maghrib: Int = defaults.value(forKey: "maghribInterval") as? Int ?? 0
            
            if maghrib > 0
            {
                maghribInterval = maghrib
                selectedInterval = maghrib
            }
            else
            {
                maghribInterval = 0
                selectedInterval = 0
            }
        }
        else if prayer == 1006
        {
            if (defaults.value(forKey: "ishaFlag") as? Int ?? 0) == 1
            {
                ishaFlag = 1
                flag = true
            }
            
            let isha: Int = defaults.value(forKey: "ishaInterval") as? Int ?? 0
            
            if isha > 0
            {
                ishaInterval = isha
                selectedInterval = isha
            }
            else
            {
                ishaInterval = 0
                selectedInterval = 0
            }
        }
        
        if flag
        {
            onBtn.setImage(UIImage(named: "on"), for: .normal)
            offBtn.setImage(UIImage(named: "off"), for: .normal)
        }
        else
        {
            onBtn.setImage(UIImage(named: "off"), for: .normal)
            offBtn.setImage(UIImage(named: "on"), for: .normal)
        }

        if selectedInterval > 0
        {
            timePicker.selectRow(selectedInterval, inComponent: 0, animated: false)
        }
        else
        {
            timePicker.selectRow(0, inComponent: 0, animated: false)
        }

        alarmMainView.alpha = 1
    }
    
    @IBAction func applyCancelBtnAction(button: UIButton)
    {
        if button.tag == 1001
        {
//            if isMyPeripheralConected
//            {
                let DLSaving = defaults.value(forKey: "daylight") as? Int ?? 0
                var dataToSend = Data([UInt8(Character("P").asciiValue!), UInt8(DLSaving)])
                
                if prayer == 1001
                {
                    dataToSend.append(UInt8(fajrFlag))
                    defaults.set(fajrFlag, forKey: "fajrFlag")
                    fajrInterval = selectedInterval
                    defaults.set(fajrInterval, forKey: "fajrInterval")
                }
                
                if prayer == 1002
                {
                    dataToSend.append(UInt8(sunriseFlag))
                    defaults.set(sunriseFlag, forKey: "sunriseFlag")
                    sunriseInterval = selectedInterval
                    defaults.set(sunriseInterval, forKey: "sunriseInterval")
                }
                
                if prayer == 1003
                {
                    dataToSend.append(UInt8(dhuhrFlag))
                    defaults.set(dhuhrFlag, forKey: "dhuhrFlag")
                    dhuhrInterval = selectedInterval
                    defaults.set(dhuhrInterval, forKey: "dhuhrInterval")
                }
                
                if prayer == 1004
                {
                    dataToSend.append(UInt8(asrFlag))
                    defaults.set(asrFlag, forKey: "asrFlag")
                    asrInterval = selectedInterval
                    defaults.set(asrInterval, forKey: "asrInterval")
                }
                
                if prayer == 1005
                {
                    dataToSend.append(UInt8(maghribFlag))
                    defaults.set(maghribFlag, forKey: "maghribFlag")
                    maghribInterval = selectedInterval
                    defaults.set(maghribInterval, forKey: "maghribInterval")
                }
                
                if prayer == 1006
                {
                    dataToSend.append(UInt8(ishaFlag))
                    defaults.set(ishaFlag, forKey: "ishaFlag")
                    ishaInterval = selectedInterval
                    defaults.set(ishaInterval, forKey: "ishaInterval")
                }
                
                dataToSend.append(UInt8(fajrInterval))
                dataToSend.append(UInt8(sunriseInterval))
                dataToSend.append(UInt8(dhuhrInterval))
                dataToSend.append(UInt8(asrInterval))
                dataToSend.append(UInt8(maghribInterval))
                dataToSend.append(UInt8(ishaInterval))
                
//                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
//            }
//            else
//            {
//                self.view.makeToast("Bluetooth device disconnected")
//            }
            
            changePrayerButtons()
        }
        else
        {
            fajrFlag = 0
            sunriseFlag = 0
            dhuhrFlag = 0
            asrFlag = 0
            maghribFlag = 0
            ishaFlag = 0
            
            fajrInterval = 0
            sunriseInterval = 0
            dhuhrInterval = 0
            asrInterval = 0
            maghribInterval = 0
            ishaInterval = 0
        }
        
        alarmMainView.alpha = 0
    }
    
    @IBAction func onofflBtnAction(button: UIButton)
    {
        if prayer == 1001 && button.tag == 1001
        {
            fajrFlag = 1
        }
        else if prayer == 1001 && button.tag == 1002
        {
            fajrFlag = 0
        }
        
        if prayer == 1002 && button.tag == 1001
        {
            sunriseFlag = 1
        }
        else if prayer == 1002 && button.tag == 1002
        {
            sunriseFlag = 0
        }
        
        if prayer == 1003 && button.tag == 1001
        {
            dhuhrFlag = 1
        }
        else if prayer == 1003 && button.tag == 1002
        {
            dhuhrFlag = 0
        }
        
        if prayer == 1004 && button.tag == 1001
        {
            asrFlag = 1
        }
        else if prayer == 1004 && button.tag == 1002
        {
            asrFlag = 0
        }
        
        if prayer == 1005 && button.tag == 1001
        {
            maghribFlag = 1
        }
        else if prayer == 1005 && button.tag == 1002
        {
            maghribFlag = 0
        }
        
        if prayer == 1006 && button.tag == 1001
        {
            ishaFlag = 1
        }
        else if prayer == 1006 && button.tag == 1002
        {
            ishaFlag = 0
        }
        
        if button.tag == 1001
        {
            onBtn.setImage(UIImage(named: "on"), for: .normal)
            offBtn.setImage(UIImage(named: "off"), for: .normal)
        }
        else
        {
            offBtn.setImage(UIImage(named: "on"), for: .normal)
            onBtn.setImage(UIImage(named: "off"), for: .normal)
        }
    }
    
    @IBAction func sidemenuBtnAction(_ sender: Any)
    {
        if menuFlag
        {
            leading.constant = -200
            menuFlag = false
        }
        else
        {
            leading.constant = 0
            menuFlag = true
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
          self?.view.layoutIfNeeded()
        }
    }
    
    @IBAction func updateBtnAction(_ sender: Any)
    {
//        bleManager = CBCentralManager(delegate: self, queue: nil)
        month = 1
        getYearPrayersTime()
    }
    
    @IBAction func clickBtnAction(_ button: UIButton)
    {
        if button.tag == 1001
        {
            if (CLLocationManager.locationServicesEnabled())
            {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
            }
            else
            {
                leading.constant = -200
                menuFlag = false
                
                UIView.animate(withDuration: 0.3) { [weak self] in
                  self?.view.layoutIfNeeded()
                }
            }
        }
        else
        {
            leading.constant = -200
            menuFlag = false
            UIView.animate(withDuration: 0.3) { [weak self] in
              self?.view.layoutIfNeeded()
            }
            let setVC = self.storyboard?.instantiateViewController(withIdentifier: "SetViewController") as! SetViewController
            self.navigationController?.pushViewController(setVC, animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        leading.constant = -200
        menuFlag = false
        
        UIView.animate(withDuration: 0.3) { [weak self] in
          self?.view.layoutIfNeeded()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLoc = locations.last
        {
            lat = currentLoc.coordinate.latitude
            lng = currentLoc.coordinate.longitude
//            print(lat)
//            print(lng)
            getCurrentPrayersTime()
            
            geocoder.reverseGeocodeLocation(currentLoc) { (placemarks, error) in
                self.processResponse(withPlacemarks: placemarks, error: error)
            }
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View

        if let error = error
        {
            print("Unable to Reverse Geocode Location (\(error))")
        }
        else
        {
            if let placemarks = placemarks, let placemark = placemarks.first
            {
                defaults.set(placemark.compactAddress, forKey: "address")
                defaults.set(placemark.currentCity, forKey: "city")
                defaults.set(placemark.currentCountry, forKey: "country")
                
                lblCity.text = placemark.currentCity
                lblCountry.text = placemark.currentCountry
                lblAddress.text = placemark.compactAddress
                
                leading.constant = -200
                menuFlag = false
                
                UIView.animate(withDuration: 0.3) { [weak self] in
                  self?.view.layoutIfNeeded()
                }
                
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    func getYearPrayersTime()
    {
        if isMyPeripheralConected && quranCharacteristic != nil
        {
            homeVC.setDeviceTime()
            
            let prayerKit:AKPrayerTime = AKPrayerTime(lat: lat, lng: lng)
//            prayerKit.calculationMethod = .Karachi
            
            let juristic = defaults.value(forKey: "juristic") as? Int
            
            if juristic == 2
            {
                prayerKit.asrJuristic = .Hanafi
            }
            else
            {
                prayerKit.asrJuristic = .Shafii
            }
            
            let method = defaults.value(forKey: "method") as? Int
            
            if method == 2
            {
                prayerKit.calculationMethod = .ISNA
            }
            else if method == 3
            {
                prayerKit.calculationMethod = .Egypt
            }
            else if method == 4
            {
                prayerKit.calculationMethod = .Makkah
            }
            else if method == 5
            {
                prayerKit.calculationMethod = .Karachi
            }
            else if method == 6
            {
                prayerKit.calculationMethod = .Tehran
            }
            else if method == 7
            {
                prayerKit.calculationMethod = .Jafari
            }
            else
            {
                prayerKit.calculationMethod = .MWL
            }
            
            prayerKit.outputFormat = .Time24
        
            let formatter = DateFormatter()

            let zeroData = UInt8(0)
//            for month in 1...12
//            {
//                var montNr = month
                
                var dataToSend = Data([UInt8(Character("Z").asciiValue!), UInt8(month)])
//                print("//////////////////////////////////////////")
//                print("Month: \(montNr)")
                for day in 1...31
                {
                    formatter.dateFormat = "dd MM yyyy"
                    let date = formatter.date(from: String(format: "%d %d %d", day, month, currentYear))
                    
                    if date != nil
                    {
//                        let times = prayerKit.getDatePrayerTimes(date: date!)
                            let times = prayerKit.getDatePrayerTimes(year: currentYear, month: month, day: day, latitude: lat, longitude: lng, tZone: AKPrayerTime.systemTimeZone())
//                        print(" ")
//                        print("======================================")
//                        print("Date: \(date!)")
                        
//                        print("======================================")
//                        print(" ")
                        var fajr = (times[.Fajr] as? String) ?? ""
                        fajr = fajr.replacingOccurrences(of: "60", with: "59")
                        var sunrise = (times[.Sunrise] as? String) ?? ""
                        sunrise = sunrise.replacingOccurrences(of: "60", with: "59")
                        var dhuhr = (times[.Dhuhr] as? String) ?? ""
                        dhuhr = dhuhr.replacingOccurrences(of: "60", with: "59")
                        var asr = (times[.Asr] as? String) ?? ""
                        asr = asr.replacingOccurrences(of: "60", with: "59")
                        var maghrib = (times[.Maghrib] as? String) ?? ""
                        maghrib = maghrib.replacingOccurrences(of: "60", with: "59")
                        var isha = (times[.Isha] as? String) ?? ""
                        isha = isha.replacingOccurrences(of: "60", with: "59")
                        
//                        print("\(fajr), \(sunrise), \(dhuhr), \(asr), \(maghrib), \(isha)")
                        
                        formatter.dateFormat = "HH:mm"
                        let fajrTime = formatter.date(from: fajr)
                        let sunTime = formatter.date(from: sunrise)
                        let dhurTime = formatter.date(from: dhuhr)
                        let asrTime = formatter.date(from: asr)
                        let maghribTime = formatter.date(from: maghrib)
                        let ishaTime = formatter.date(from: isha)
                        formatter.dateFormat = "HH"
                        let fajrHours = UInt8(formatter.string(from: fajrTime!))!
                        let sunHours = UInt8(formatter.string(from: sunTime!))!
                        let dhuhrHours = UInt8(formatter.string(from: dhurTime!))!
                        let asrHours = UInt8(formatter.string(from: asrTime!))!
                        let maghribHours = UInt8(formatter.string(from: maghribTime!))!
                        let ishaHours = UInt8(formatter.string(from: ishaTime!))!
                        formatter.dateFormat = "mm"
                        let fajrMin = UInt8(formatter.string(from: fajrTime!))!
                        let sunMin = UInt8(formatter.string(from: sunTime!))!
                        let dhuhrMin = UInt8(formatter.string(from: dhurTime!))!
                        let asrMin = UInt8(formatter.string(from: asrTime!))!
                        let maghribMin = UInt8(formatter.string(from: maghribTime!))!
                        let ishaMin = UInt8(formatter.string(from: ishaTime!))!
                        
                        print("\(fajrHours):\(fajrMin), \(sunHours):\(sunMin), \(dhuhrHours):\(dhuhrMin), \(asrHours):\(asrMin), \(maghribHours):\(maghribMin), \(ishaHours):\(ishaMin)")
                        
                        //Fajr
                        dataToSend.append(fajrHours)
                        dataToSend.append(fajrMin)

                        //Sunrise
                        dataToSend.append(sunHours)
                        dataToSend.append(sunMin)

                        //Dhuhr
                        dataToSend.append(dhuhrHours)
                        dataToSend.append(dhuhrMin)

                        //Asr
                        dataToSend.append(asrHours)
                        dataToSend.append(asrMin)

                        //Maghrib
                        dataToSend.append(maghribHours)
                        dataToSend.append(maghribMin)

                        //Isha
                        dataToSend.append(ishaHours)
                        dataToSend.append(ishaMin)
                    }
                    else
                    {
                        print("0:0, 0:0, 0:0, 0:0, 0:0, 0:0")
                        dataToSend.append(zeroData)
                        dataToSend.append(zeroData)
                        dataToSend.append(zeroData)
                        dataToSend.append(zeroData)
                        dataToSend.append(zeroData)
                        dataToSend.append(zeroData)
                        dataToSend.append(zeroData)
                        dataToSend.append(zeroData)
                        dataToSend.append(zeroData)
                        dataToSend.append(zeroData)
                        dataToSend.append(zeroData)
                        dataToSend.append(zeroData)
                    }
                }
                print(dataToSend)
//                print("//////////////////////////////////////////")
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
//            }
        }
        else
        {
            self.view.makeToast("Bluetooth device disconnected")
        }
    }
    
    func getCurrentPrayersTime()
    {
        let prayerKit:AKPrayerTime = AKPrayerTime(lat: lat, lng: lng)
        prayerKit.calculationMethod = .Karachi
        
        let juristic = defaults.value(forKey: "juristic") as? Int
        
        if juristic == 2
        {
            prayerKit.asrJuristic = .Shafii
        }
        else
        {
            prayerKit.asrJuristic = .Hanafi
        }
        
        
        prayerKit.outputFormat = .Time12
        let times = prayerKit.getPrayerTimes()
        
        var fajr = (times?[.Fajr] as? String) ?? ""
        fajr = fajr.replacingOccurrences(of: "60", with: "59")
        var sunrise = (times?[.Sunrise] as? String) ?? ""
        sunrise = sunrise.replacingOccurrences(of: "60", with: "59")
        var dhuhr = (times?[.Dhuhr] as? String) ?? ""
        dhuhr = dhuhr.replacingOccurrences(of: "60", with: "59")
        var asr = (times?[.Asr] as? String) ?? ""
        asr = asr.replacingOccurrences(of: "60", with: "59")
        var sunset = (times?[.Sunset] as? String) ?? ""
        sunset = sunset.replacingOccurrences(of: "60", with: "59")
        var maghrib = (times?[.Maghrib] as? String) ?? ""
        maghrib = maghrib.replacingOccurrences(of: "60", with: "59")
        var isha = (times?[.Isha] as? String) ?? ""
        isha = isha.replacingOccurrences(of: "60", with: "59")

        lblFajr.text = fajr
        lblSunrise.text = sunrise
        lblDhuhr.text = dhuhr
        lblAsr.text = asr
        lblSunset.text = sunset
        lblMaghrib.text = maghrib
        lblIsha.text = isha
    }
    
    @IBAction func menuBtnAction(_ button: UIButton)
    {
        if button.tag == 1001
        {
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(homeVC, animated: false)
        }
        else if button.tag == 1002
        {
            let lightVC = self.storyboard?.instantiateViewController(withIdentifier: "LightViewController") as! LightViewController
            self.navigationController?.pushViewController(lightVC, animated: false)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 61
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return "\(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedInterval = row
    }
}

extension CLPlacemark {

    var compactAddress: String? {
        if let name = name {
            var result = name

            if let city = locality {
                result += ", \(city)"
            }
            
            if let country = country {
                result += ", \(country)"
            }

            return result
        }
        
        return nil
    }
    
    var currentCountry: String?
    {
        if let country = country
        {
            return country
        }
        return nil
    }
    
    var currentCity: String?
    {
        if let area = locality
        {
            return area
        }
        return nil
    }
}
