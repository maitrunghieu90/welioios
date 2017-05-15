//
//  SettingVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/28/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class SettingVC: UIViewController {
    @IBOutlet weak var swNotifi: UISwitch!
    @IBOutlet weak var swPin: UISwitch!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var lbPin: UILabel!
    @IBOutlet weak var lbNotification: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_NAME.GO_SETTING), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkNotification), name: NSNotification.Name(rawValue: NOTIFICATION_NAME.GO_SETTING), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_NAME.GO_SETTING), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func actionHome(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppointmentVC") as! AppointmentVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionShowMenu(_ sender: Any) {
        sideMenuController()?.toggleSidePanel()
    }
    
    @IBAction func valueChange(_ sender: UISwitch) {
        if sender == swNotifi {
            Common.goSettings()
            checkNotification()
        }else{
            if sender.isOn {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPINVC") as! AddPINVC
                vc.isFromSetting = true
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                Common.removeFromUserdefaults(KEY_USDEFAULT.PIN)
            }
        }
    }
}

extension SettingVC {
    func initUI() {
        self.navigationController?.isNavigationBarHidden = true
        swNotifi.tintColor = UIColor.init(COLOR.switchOffColor)
        swNotifi.layer.cornerRadius = 16
        swNotifi.backgroundColor = UIColor.init(COLOR.switchOffColor)
        swPin.tintColor = UIColor.init(COLOR.switchOffColor)
        swPin.layer.cornerRadius = 16
        swPin.backgroundColor = UIColor.init(COLOR.switchOffColor)
        checkNotification()
        checkPIN()
    }
    
    func checkNotification() {
        let notificationType = UIApplication.shared.currentUserNotificationSettings?.types
        if notificationType?.rawValue == 0 {
            swNotifi.setOn(false, animated: true)
        }else{
            swNotifi.setOn(true, animated: true)
        }
    }
    
    func checkPIN() {
        if Common.getFromUserDefaults(KEY_USDEFAULT.PIN) == nil {
            swPin.setOn(false, animated: true)
        }else{
            swPin.setOn(true, animated: true)
        }
    }
}
