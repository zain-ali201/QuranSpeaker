//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit
import CoreLocation
import CoreBluetooth

class PrayerViewController: UIViewController, CLLocationManagerDelegate//, CBCentralManagerDelegate, CBPeripheralDelegate
{
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
    
    //BLE
//    var bleManager : CBCentralManager!
//    var myBluetoothPeripheral : CBPeripheral!
//    var myCharacteristic : CBCharacteristic!
//    var quranUUID: CBUUID = CBUUID(string: "00002a00-0000-1000-8000-00805f9b34fb")
//    var isMyPeripheralConected = false
    
    override func viewDidLoad()
    {
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
    
    func fetchPrayerData(byteArray: [UInt8])
    {
        let firstBitValue = byteArray[0] & 0x01
        
        if firstBitValue != 0
        {
            let type = Character(UnicodeScalar(byteArray[0]))
            print(type)
            if type == "Z"
            {
                print("MonthNbr : \(Int(byteArray[1]))")
                let receivedMonth = Int(byteArray[1])
//                if receivedMonth != month && receivedMonth > 0 && receivedMonth < 13
//                {
                    month = Int(byteArray[1])
                    getYearPrayersTime()
//                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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

        lblFajr.text = times?[.Fajr] as? String
        lblSunrise.text = times?[.Sunrise] as? String
        lblDhuhr.text = times?[.Dhuhr] as? String
        lblAsr.text = times?[.Asr] as? String
        lblSunset.text = times?[.Sunset] as? String
        lblMaghrib.text = times?[.Maghrib] as? String
        lblIsha.text = times?[.Isha] as? String
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
