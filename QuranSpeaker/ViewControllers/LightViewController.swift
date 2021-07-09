//
//  HomeViewController.swift
//  QuranSpeaker
//
//  Created by Apple on 19/01/2021.
//

import UIKit
import Colorful
import CoreBluetooth

class LightViewController: UIViewController
{
    @IBOutlet weak var quranBtn: UIButton!
    @IBOutlet weak var colorView: ColorPicker!
    
    var contrast = 0
    
    override func viewDidLoad() {
        
        colorView.addTarget(self, action: #selector(selectColor), for: .touchUpInside)
        colorView.set(color: .red, colorSpace: .extendedSRGB)
        
        AppUtility.lockOrientation(.portrait)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func selectColor()
    {
        let red = colorView.color.components.red * 255 > 0 ? colorView.color.components.red * 255 : 0
        let green = colorView.color.components.green * 255 > 0 ? colorView.color.components.green * 255 : 0
        let blue = colorView.color.components.blue * 255 > 0 ? colorView.color.components.blue * 255 : 0
        print(colorView.contrast)
        
        if isMyPeripheralConected && myBluetoothPeripheral != nil
        {
            let dataToSend = Data([UInt8(Character("L").asciiValue!), UInt8(red/2), UInt8(green/2), UInt8(blue/2)])
            myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
            
            let sendContrast = Data([UInt8(Character("c").asciiValue!), UInt8(colorView.contrast)])
            myBluetoothPeripheral.writeValue(sendContrast as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
        else
        {
            self.view.makeToast("Bluetooth device disconnected")
        }
    }
    
    @IBAction func colorsBtnAction(_ button: UIButton)
    {
        var red = 0
        var green = 0
        var blue = 0
        
        if button.tag == 1001
        {
            red = 10
            green = 88
            blue = 207
        }
        else if button.tag == 1002
        {
            red = 237
            green = 13
            blue = 234
        }
        else if button.tag == 1003
        {
            red = 55
            green = 179
            blue = 86
        }
        else if button.tag == 1004
        {
            red = 194
            green = 18
        }
        else if button.tag == 1005
        {
            red = 122
            green = 203
        }
        else if button.tag == 1006
        {
            red = 78
            green = 210
        }
        else if button.tag == 1007
        {
            red = 76
            green = 145
            blue = 209
        }
        else if button.tag == 1008
        {
            red = 7
            green = 70
            blue = 165
        }
        
        if isMyPeripheralConected && quranCharacteristic != nil
        {
            let dataToSend = Data([UInt8(Character("L").asciiValue!), UInt8(red/2), UInt8(green/2), UInt8(blue/2)])
            myBluetoothPeripheral.writeValue(dataToSend as Data, for: quranCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
        else
        {
            self.view.makeToast("Bluetooth device disconnected")
        }
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
    }
}

extension String {

    var toColor: UIColor {
        var cString: String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}
