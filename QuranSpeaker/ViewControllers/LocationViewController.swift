//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    @IBOutlet weak var autoView: UIView!
    @IBOutlet weak var manualView: UIView!
    
    @IBOutlet weak var autoBtn: UIButton!
    @IBOutlet weak var manualBtn: UIButton!
    
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var countriesView: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var countryBtn: UIButton!
    @IBOutlet weak var cityBtn: UIButton!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var menuFlag = false
    var lat = 0.0
    var lng = 0.0
    
    var locationManager = CLLocationManager()
    lazy var geocoder = CLGeocoder()
    
    var tag = 1001
    
    var countriesArray:[String]  = []
    var citiesArray:[String] = []
    
    var countriesFilterArray:[String]  = []
    var citiesFilterArray:[String] = []
    
    override func viewDidLoad()
    {
        AppUtility.lockOrientation(.portrait)
        
        let address = defaults.string(forKey: "address")
        let city = defaults.string(forKey: "city")
        let country = defaults.string(forKey: "country")
        
        if address != nil
        {
            lblAddress.text = address
        }
        
        if city != nil
        {
            lblCity.text = city
        }
        
        if country != nil
        {
            lblCountry.text = country
        }
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //MARK:- Button Actions
    
    @IBAction func backBtnAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func autoManualBtnAction(button: UIButton)
    {
        if button.tag == 1001
        {
            autoBtn.backgroundColor = UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1)
            manualBtn.backgroundColor = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1)
            autoView.alpha = 1
            manualView.alpha = 0
        }
        else
        {
            manualBtn.backgroundColor = UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1)
            autoBtn.backgroundColor = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1)
            autoView.alpha = 0
            manualView.alpha = 1
        }
    }
 
    @IBAction func locationBtnAction(_ sender: Any)
    {
        if (CLLocationManager.locationServicesEnabled())
        {
            loader.alpha = 1
            loader.startAnimating()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func clickBtnAction(button: UIButton)
    {
        countriesView.alpha = 1
        tag = button.tag
    }
    
    @IBAction func cancelBtnAction(_ sender: Any)
    {
        countriesView.alpha = 0
    }
    
    //MARK:- locationManager Delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLoc = locations.last
        {
            lat = currentLoc.coordinate.latitude
            lng = currentLoc.coordinate.longitude
            
            geocoder.reverseGeocodeLocation(currentLoc) { (placemarks, error) in
                self.processResponse(withPlacemarks: placemarks, error: error)
            }
        }
        else
        {
            loader.stopAnimating()
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
        
        loader.stopAnimating()
    }
    
    //MARK:- UITableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tag == 1001
        {
            return countriesFilterArray.count
        }
        else
        {
            return citiesFilterArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:TableCell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableCell
        
        if tag == 1001
        {
            cell.lblName.text = countriesFilterArray[indexPath.row]
        }
        else
        {
            cell.lblName.text = citiesFilterArray[indexPath.row]
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView.tag == 1001
        {
            countryBtn.setTitle("  \(countriesFilterArray[indexPath.row])", for: .normal)
        }
        else
        {
            cityBtn.setTitle("  \(citiesFilterArray[indexPath.row])", for: .normal)
        }
        
        countriesView.alpha = 0
    }
    
    //MARK:- Search Bar Delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if tag == 1001
        {
            countriesFilterArray = searchText.isEmpty ? countriesArray : countriesArray.filter { (country: String) -> Bool in
                return country.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        else
        {
            citiesFilterArray = searchText.isEmpty ? citiesArray : citiesArray.filter { (country: String) -> Bool in
                return country.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        
        tblView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
