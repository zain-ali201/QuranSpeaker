//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit

class LightViewController: UIViewController
{
    @IBOutlet weak var quranBtn: UIButton!
    
    override func viewDidLoad() {
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func menuBtnAction(_ button: UIButton)
    {
        if button.tag == 1001
        {
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(homeVC, animated: false)
        }
        else if button.tag == 1003
        {
            let prayerVC = self.storyboard?.instantiateViewController(withIdentifier: "PrayerViewController") as! PrayerViewController
            self.navigationController?.pushViewController(prayerVC, animated: false)
        }
        else if button.tag == 1004
        {
            let setVC = self.storyboard?.instantiateViewController(withIdentifier: "SetViewController") as! SetViewController
            self.navigationController?.pushViewController(setVC, animated: false)
        }
    }
}
