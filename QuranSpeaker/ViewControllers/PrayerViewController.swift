//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit
import CoreLocation
import CoreBluetooth

class PrayerViewController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate
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
    
    //BLE
    var bleManager : CBCentralManager!
    var myBluetoothPeripheral : CBPeripheral!
    var myCharacteristic : CBCharacteristic!
    var quranUUID: CBUUID = CBUUID(string: "0000ae10-0000-1000-8000-00805f9b34fb")
    var isMyPeripheralConected = false
    
    override func viewDidLoad()
    {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 550)
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
        bleManager = CBCentralManager(delegate: self, queue: nil)
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
            getCurrentPrayersTime()
            
            if !UserDefaults.standard.bool(forKey: "prayersFlag")
            {
                bleManager = CBCentralManager(delegate: self, queue: nil)
                getYearPrayersTime()
            }
            
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
        if isMyPeripheralConected
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
            prayerKit.outputFormat = .Time24
        
            let formatter = DateFormatter()

            for month in 1...12
            {
                var montNr = month
                let dataToSend = NSMutableData()
                dataToSend.append("Z".data(using: String.Encoding.ascii)!)
                dataToSend.append(Data(bytes: &montNr, count: MemoryLayout.size(ofValue: montNr)))
                
//                print("//////////////////////////////////////////")
//                print("Month: \(montNr)")
                for day in 1...31
                {
                    formatter.dateFormat = "dd MM yyyy"
                    let date = formatter.date(from: String(format: "%d %d %d", day, month, currentYear))
                    
                    if date != nil
                    {
                        let times = prayerKit.getDatePrayerTimes(date: date!)
//                        print(" ")
//                        print("======================================")
//                        print("Date: \(date!)")
                        
//                        print("======================================")
//                        print(" ")
//                        dataToSend.append(Data(bytes: &key, count: MemoryLayout.size(ofValue: key)))
                        let fajr = (times?[.Fajr] as? String) ?? ""
                        let sunrise = (times?[.Sunrise] as? String) ?? ""
                        let dhuhr = (times?[.Dhuhr] as? String) ?? ""
                        let asr = (times?[.Asr] as? String) ?? ""
                        let maghrib = (times?[.Maghrib] as? String) ?? ""
                        let isha = (times?[.Isha] as? String) ?? ""
                        
                        formatter.dateFormat = "HH:mm"
                        let fajrTime = formatter.date(from: fajr)
                        let sunTime = formatter.date(from: sunrise)
                        let dhurTime = formatter.date(from: dhuhr)
                        let asrTime = formatter.date(from: asr)
                        let maghribTime = formatter.date(from: maghrib)
                        let ishaTime = formatter.date(from: isha)
                        formatter.dateFormat = "HH"
                        var fajrHours = Int(formatter.string(from: fajrTime!))!
                        var sunHours = Int(formatter.string(from: sunTime!))!
                        var dhuhrHours = Int(formatter.string(from: dhurTime!))!
                        var asrHours = Int(formatter.string(from: asrTime!))!
                        var maghribHours = Int(formatter.string(from: maghribTime!))!
                        var ishaHours = Int(formatter.string(from: ishaTime!))!
                        formatter.dateFormat = "mm"
                        var fajrMin = Int(formatter.string(from: fajrTime!))!
                        var sunMin = Int(formatter.string(from: sunTime!))!
                        var dhuhrMin = Int(formatter.string(from: dhurTime!))!
                        var asrMin = Int(formatter.string(from: asrTime!))!
                        var maghribMin = Int(formatter.string(from: maghribTime!))!
                        var ishaMin = Int(formatter.string(from: ishaTime!))!
                        
                        print("\(fajrHours):\(fajrMin), \(sunHours):\(sunMin), \(dhuhrHours):\(dhuhrMin), \(asrHours):\(asrMin), \(maghribHours):\(maghribMin), \(ishaHours):\(ishaMin)")
                        
                        //Fajr
                        dataToSend.append(Data(bytes: &fajrHours, count: MemoryLayout.size(ofValue: fajrHours)))
                        dataToSend.append(Data(bytes: &fajrMin, count: MemoryLayout.size(ofValue: fajrMin)))

                        //Sunrise
                        dataToSend.append(Data(bytes: &sunHours, count: MemoryLayout.size(ofValue: sunHours)))
                        dataToSend.append(Data(bytes: &sunMin, count: MemoryLayout.size(ofValue: sunMin)))

                        //Dhuhr
                        dataToSend.append(Data(bytes: &dhuhrHours, count: MemoryLayout.size(ofValue: dhuhrHours)))
                        dataToSend.append(Data(bytes: &dhuhrMin, count: MemoryLayout.size(ofValue: dhuhrMin)))

                        //Asr
                        dataToSend.append(Data(bytes: &asrHours, count: MemoryLayout.size(ofValue: asrHours)))
                        dataToSend.append(Data(bytes: &asrMin, count: MemoryLayout.size(ofValue: asrMin)))

                        //Maghrib
                        dataToSend.append(Data(bytes: &maghribHours, count: MemoryLayout.size(ofValue: maghribHours)))
                        dataToSend.append(Data(bytes: &maghribMin, count: MemoryLayout.size(ofValue: maghribMin)))

                        //Isha
                        dataToSend.append(Data(bytes: &ishaHours, count: MemoryLayout.size(ofValue: ishaHours)))
                        dataToSend.append(Data(bytes: &ishaMin, count: MemoryLayout.size(ofValue: ishaMin)))
                    }
                    else
                    {
                        print("0:0, 0:0, 0:0, 0:0, 0:0, 0:0")
                    }
                }
                
//                print("//////////////////////////////////////////")
                myBluetoothPeripheral.writeValue(dataToSend as Data, for: myCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
            
            UserDefaults.standard.set(true, forKey: "prayersFlag")
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
    
    //BLE delegate functions
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var msg = ""
        
        switch central.state {
            
            case .poweredOff:
                msg = "Bluetooth is Off"
            case .poweredOn:
                msg = "Bluetooth is On"
                bleManager.scanForPeripherals(withServices: nil, options: nil)
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
            
            bleManager.stopScan()
            bleManager.connect(myBluetoothPeripheral, options: nil)
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

        if (characteristic.uuid == quranUUID) {
            
            let readValue = characteristic.value
            let value = (readValue! as NSData).bytes.bindMemory(to: Int.self, capacity: readValue!.count).pointee //used to read an Int value
            print ("Value: \(value)")
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
