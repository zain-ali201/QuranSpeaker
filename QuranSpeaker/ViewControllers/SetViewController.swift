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
            Item(name: "Muslim World League", detail: ""),
            Item(name: "Islamic Society of North America (ISNA)", detail: ""),
            Item(name: "Egyptian General Authority of Survey", detail: ""),
            Item(name: "Umm al-Qura, Makkah", detail: ""),
            Item(name: "University of Islamic Sciences, Karachi", detail: ""),
            Item(name: "Institute of Geophysics, University of Tehran", detail: ""),
            Item(name: "Jafari", detail: "")//,
//            Item(name: "Custom", detail: "")
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
        
        if indexPath.section == 0
        {
            let juristic = defaults.value(forKey: "juristic") as? Int
            
            if juristic == indexPath.row + 1
            {
                cell.accessoryType = .checkmark
            }
            else
            {
                cell.accessoryType = .none
            }
        }
        
        if indexPath.section == 1
        {
            let daylight = defaults.value(forKey: "daylight") as? Int
            if daylight == indexPath.row + 1
            {
                cell.accessoryType = .checkmark
            }
            else
            {
                cell.accessoryType = .none
            }
        }
        
        if indexPath.section == 2
        {
            let method = defaults.value(forKey: "method") as? Int
            if method == indexPath.row + 1
            {
                cell.accessoryType = .checkmark
            }
            else
            {
                cell.accessoryType = .none
            }
            
        }
        
        return cell
    }
    
    func collapsibleTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0
        {
            defaults.set(indexPath.row + 1, forKey: "juristic")
        }
        else if indexPath.section == 1
        {
            defaults.set(indexPath.row + 1, forKey: "daylight")
        }
        else if indexPath.section == 2
        {
            defaults.set(indexPath.row + 1, forKey: "method")
        }
        tableView.reloadData()
//        self.navigationController?.popViewController(animated: true)
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
