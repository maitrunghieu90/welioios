//
//  ConfirmPINVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/27/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import AudioToolbox

class ConfirmPINVC: UIViewController {
    @IBOutlet weak var tfPin1: UITextField!
    @IBOutlet weak var tfPin2: UITextField!
    @IBOutlet weak var tfPin3: UITextField!
    @IBOutlet weak var tfPin4: UITextField!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var vCheckMess: UIView!
    @IBOutlet weak var btSkip: UIButton!
    @IBOutlet weak var lbMessage: UILabel!
    
    var patient = WPatient()
    var isFromSetting = false
    var isFromResetPass = false
    
    var PIN = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionSkip(_ sender: Any) {
        signIn()
    }
    
    @IBAction func valueChange(_ sender: UITextField) {
        if (sender.text?.characters.count)! > 0 {
            if sender == tfPin1 {
                lbMessage.isHidden = true
                tfPin2.becomeFirstResponder()
            }else if sender == tfPin2 {
                tfPin3.becomeFirstResponder()
            }else if sender == tfPin3 {
                tfPin4.becomeFirstResponder()
            }else if sender == tfPin4 {
                self.view.endEditing(true)
                if "\(tfPin1.text!)\(tfPin2.text!)\(tfPin3.text!)\(tfPin4.text!)" == PIN{
                    Common.addToUserDefaults(KEY_USDEFAULT.PIN, pObject: PIN)
                    showMessage()
                }else{
                    if #available(iOS 10.0, *) {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                    } else {
                        AudioServicesPlaySystemSound(1520)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        self.lbMessage.isHidden = false
                        self.tfPin1.text = ""
                        self.tfPin2.text = ""
                        self.tfPin3.text = ""
                        self.tfPin4.text = ""
                        self.tfPin1.becomeFirstResponder()
                    })
                }
            }
        }
    }
}

extension ConfirmPINVC {
    func initUI() {
        tfPin1.bolder(2)
        tfPin2.bolder(2)
        tfPin3.bolder(2)
        tfPin4.bolder(2)
        vCheckMess.corner(10)
        if isFromSetting || isFromResetPass{
            btSkip.isHidden = true
        }else{
            btSkip.isHidden = false
        }
        tfPin1.becomeFirstResponder()
    }
    
    func hideMessage() {
        UIView.animate(withDuration: 0.5) {
            self.viewMessage.isHidden = true
            if self.isFromSetting {
                for vc in (self.navigationController?.viewControllers)! {
                    if vc is SettingVC {
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                }
            }else if self.isFromResetPass {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuRootController") as! SideMenuRootController
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.signIn()
            }
        }
    }
    
    func showMessage() {
        UIView.animate(withDuration: 0.5) {
            self.viewMessage.isHidden = false
            self.perform(#selector(self.hideMessage), with: nil, afterDelay: 1.0)
        }
    }
    
    func signIn() {
        let urlSignIn = "\(API.MAIN_PATIENT)\(API.loginPatient)"
        let param = ["PhoneOrMail" : self.patient.Email, "Password" : self.patient.Password]
        
        WebService.shareInstance.postWebServiceCall(urlSignIn, params: param as Any as? [String : Any], isShowLoader: true, success: { (respone) in
            let errorCode = respone["ErrorCode"].intValue
            let dictPatient = respone["Result"]["Patient"]
            let patient = WPatient()
            patient.parser(dictPatient)
            patient.cacheUserDefault()
            Common.getAppDelegate().loginUser = patient
            let SessionId = respone["Result"]["SessionId"].stringValue
            
            if !SessionId.isEmpty {
                Common.addToUserDefaults(KEY_USDEFAULT.SessionId, pObject: SessionId)
            }
            
            if errorCode == ERRORCODE.SUCCESS {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuRootController") as! SideMenuRootController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }) { (error) in
            Common.showAlert("err_connect_server".localized, self)
        }
    }
}
