//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit
import CollapsibleTableSectionViewController

class SetViewController: CollapsibleTableSectionViewController, CollapsibleTableSectionDelegate
{
    @IBOutlet weak var tblView:UITableView!
    
    var sections: [Section] = [
        Section(name: "Juristic Method", items: [
            Item(name: "Shafii, Hanbali, Maliki", detail: ""),
            Item(name: "Hanafi", detail: "")
        ]),
        Section(name: "DayLight Saving", items: [
            Item(name: "OFF", detail: ""),
            Item(name: "ON", detail: "")
        ]),
        Section(name: "Calculation Method", items: [
            Item(name: "Jafari", detail: ""),
            Item(name: "Karachi", detail: ""),
            Item(name: "ISNA", detail: ""),
            Item(name: "MWL", detail: ""),
            Item(name: "Makkah", detail: ""),
            Item(name: "Egypt", detail: ""),
            Item(name: "Custom", detail: ""),
            Item(name: "Tehran", detail: "")
            
        ])]
    
    override func viewDidLoad() {
        
        self._tableView = tblView
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backBtnAction(_ button: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickBtnAction(_ button: UIButton)
    {
        if button.tag == 1001
        {
            let countryVC = self.storyboard?.instantiateViewController(withIdentifier: "CountryViewController") as! CountryViewController
            self.navigationController?.pushViewController(countryVC, animated: false)
        }
        else if button.tag == 1002
        {
            let cityVC = self.storyboard?.instantiateViewController(withIdentifier: "CityViewController") as! CityViewController
            self.navigationController?.pushViewController(cityVC, animated: false)
        }
        else if button.tag == 1003
        {
            let juristicVC = self.storyboard?.instantiateViewController(withIdentifier: "JuristicViewController") as! JuristicViewController
            self.navigationController?.pushViewController(juristicVC, animated: false)
        }
        else if button.tag == 1004
        {
            let daylightVC = self.storyboard?.instantiateViewController(withIdentifier: "DaylightViewController") as! DaylightViewController
            self.navigationController?.pushViewController(daylightVC, animated: false)
        }
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
        else if button.tag == 1003
        {
            let prayerVC = self.storyboard?.instantiateViewController(withIdentifier: "PrayerViewController") as! PrayerViewController
            self.navigationController?.pushViewController(prayerVC, animated: false)
        }
    }
    
    
    func numberOfSections(_ tableView: UITableView) -> Int {
        return sections.count
    }
    
    func collapsibleTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func collapsibleTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell") as UITableViewCell? ?? UITableViewCell(style: .subtitle, reuseIdentifier: "BasicCell")
        
        let item: Item = sections[indexPath.section].items[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.detail
        
        return cell
    }
    
    func collapsibleTableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }
}

public struct Item {
    public var name: String
    public var detail: String
    
    public init(name: String, detail: String) {
        self.name = name
        self.detail = detail
    }
}

public struct Section {
    public var name: String
    public var items: [Item]
    
    public init(name: String, items: [Item]) {
        self.name = name
        self.items = items
    }
}
