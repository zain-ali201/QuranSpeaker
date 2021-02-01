//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit

class HomeViewController: UIViewController
{
    @IBOutlet weak var quranBtn: UIButton!
    @IBOutlet weak var lightBtn: UIButton!
    @IBOutlet weak var prayerBtn: UIButton!
    @IBOutlet weak var setBtn: UIButton!
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func menuBtnAction(_ button: UIButton)
    {
        if button.tag == 1001
        {
            self.navigationController?.popToRootViewController(animated: false)
        }
        else if button.tag == 1002
        {
            let lightVC = self.storyboard?.instantiateViewController(identifier: "") 
        }
        else if button.tag == 1003
        {
            
        }
        else if button.tag == 1004
        {
            
        }
    }
}
