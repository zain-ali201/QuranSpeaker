//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit

class SetViewController: UIViewController
{
    override func viewDidLoad() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func clickBtnAction(_ button: UIButton)
    {
        if button.tag == 1001
        {
            
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
}
