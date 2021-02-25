//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit
import CoreLocation

class PrayerViewController: UIViewController, CLLocationManagerDelegate
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
    
    var lat = 0.0
    var lng = 0.0
    
    var locationManager = CLLocationManager()
    lazy var geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        lblTime.text = formatter.string(from: Date())
        
        formatter.dateFormat = "dd MMMM yyyy"
        lblDate.text = formatter.string(from: Date())
        
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLoc = locations.last
        {
            lat = currentLoc.coordinate.latitude
            lng = currentLoc.coordinate.longitude
            getPrayersTime()
            
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
                
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    func getPrayersTime()
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
        else if button.tag == 1004
        {
            let setVC = self.storyboard?.instantiateViewController(withIdentifier: "SetViewController") as! SetViewController
            self.navigationController?.pushViewController(setVC, animated: false)
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
