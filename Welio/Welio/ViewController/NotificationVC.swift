//
//  NotificationVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/12/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController {
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbItTime: UILabel!
    @IBOutlet weak var lbNow: UILabel!
    @IBOutlet weak var btContinute: UIButton!
    @IBOutlet weak var viewMessage: UIView!
    
    var signUpObj = WPatient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initLanguage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionContinute(_ sender: Any) {
        let alert = UIAlertController(title: "txt_welio_send_notification".localized, message: "txt_notifications_settings".localized, preferredStyle: UIAlertControllerStyle.alert)
        let okAction: UIAlertAction = UIAlertAction(title: "txt_ok".localized, style: .default) { action -> Void in
            let notificationType = UIApplication.shared.currentUserNotificationSettings?.types
            if notificationType?.rawValue == 0 {
                Common.goSettings()
            } else {
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "VerifyCodeVC") as! VerifyCodeVC
                vc.patient = self.signUpObj
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        let notAllow: UIAlertAction = UIAlertAction(title: "txt_dont_allow".localized, style: .cancel) { action -> Void in
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "VerifyCodeVC") as! VerifyCodeVC
            vc.patient = self.signUpObj
            self.navigationController?.pushViewController(vc, animated: true)
        }
        alert.addAction(okAction)
        alert.addAction(notAllow)
        self.present(alert, animated: true, completion: nil)
    }
}

extension NotificationVC {
    func initUI() {
        btContinute.corner()
        viewMessage.corner(10)
        viewMessage.bolder(1)
        SideMenuRootController.panningEnabled = false
    }
    
    func initLanguage() {
        lbTitleNav.text = "txt_notifications".localized
        lbItTime.text = "txt_time_appointment".localized
        lbNow.text = "txt_now".localized
        lbTitle.text = "txt_notification_appointments".localized
        btContinute.setTitle("txt_continue".localized, for: .normal)
    }
}
