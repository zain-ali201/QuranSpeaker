//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit

class CountryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var countriesTblView: UITableView!
    
    let countries = ["Afghanistan", "Azerbaijan", "Bangladesh", "Bosnia", "England", "France", "Germany", "India", "Indonesia", "Iran", "kazakistan", "Malaysia", "Pakistan", "Russia", "Somalia", "Spain", "Srilanka", "Swahili", "Turki", "Uzbekistan"]
    
    override func viewDidLoad() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backBtnAction(_ button: UIButton)
    {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func menuBtnAction(_ button: UIButton)
    {
        if button.tag == 1001
        {
            self.navigationController?.popToRootViewController(animated: false)
        }
        else if button.tag == 1002
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:TableCell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableCell
        
        cell.lblName.text = countries[indexPath.row]
        cell.imgView.image = UIImage(named: countries[indexPath.row])
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.navigationController?.popViewController(animated: false)
    }
}
