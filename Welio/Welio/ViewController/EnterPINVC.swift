//
//  EnterPINVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/27/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import AudioToolbox

class EnterPINVC: UIViewController {
    @IBOutlet weak var tfPin1: UITextField!
    @IBOutlet weak var tfPin2: UITextField!
    @IBOutlet weak var tfPin3: UITextField!
    @IBOutlet weak var tfPin4: UITextField!
    @IBOutlet weak var btSignIn: UIButton!
    @IBOutlet weak var lbTitleEnterPin: UILabel!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var btForgotPin: UIButton!
    @IBOutlet weak var lbMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionBack(_ sender: Any) {
        var check = false
        
        for vc in (self.navigationController?.viewControllers)! {
            if vc is HomeVC {
                check = true
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
        if !check {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func actionForgotPIN(_ sender: Any) {
    }
    
    @IBAction func actionSignIn(_ sender: UITextField) {
        var check = false
        
        for vc in (self.navigationController?.viewControllers)! {
            if vc is SignInVC {
                check = true
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
        if !check {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
                if "\(tfPin1.text!)\(tfPin2.text!)\(tfPin3.text!)\(tfPin4.text!)" == Common.getFromUserDefaults(KEY_USDEFAULT.PIN) as! String{
                    lbMessage.isHidden = true
                    if (Common.getFromUserDefaults(KEY_USDEFAULT.isLogin) != nil) && Common.getFromUserDefaults(KEY_USDEFAULT.isLogin) as! String == "yes" {
                        
                        Common.getAppDelegate().loginUser.Actived = (Common.getFromUserDefaults(KEY_USDEFAULT.ActivedLogin) as! String == "yes" ? true : false)
                        Common.getAppDelegate().loginUser.Email = Common.getFromUserDefaults(KEY_USDEFAULT.EmailLogin) as? String
                        Common.getAppDelegate().loginUser.FirstName = Common.getFromUserDefaults(KEY_USDEFAULT.FirstNameLogin) as? String
                        Common.getAppDelegate().loginUser.IsFoalting = (Common.getFromUserDefaults(KEY_USDEFAULT.IsFoaltingLogin) as! String == "yes" ? true : false)
                        Common.getAppDelegate().loginUser.LastName = Common.getFromUserDefaults(KEY_USDEFAULT.LastNameLogin) as? String
                        Common.getAppDelegate().loginUser.PatientId = Common.getFromUserDefaults(KEY_USDEFAULT.PatientIdLogin) as? String
                        Common.getAppDelegate().loginUser.Phone = Common.getFromUserDefaults(KEY_USDEFAULT.PhoneLogin) as? String
                        Common.getAppDelegate().loginUser.PatientAvatar = Common.getFromUserDefaults(KEY_USDEFAULT.PatientAvatarLogin) as? String
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuRootController") as! SideMenuRootController
                            self.navigationController?.pushViewController(vc, animated: true)
                        })
                        
                    }else{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            var check = false
                            
                            for vc in (self.navigationController?.viewControllers)!{
                                if vc is SignInVC {
                                    check = true
                                    self.navigationController?.popToViewController(vc, animated: true)
                                }
                            }
                            if !check {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        })
                    }
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

extension EnterPINVC {
    func initUI() {
        tfPin1.bolder(2)
        tfPin2.bolder(2)
        tfPin3.bolder(2)
        tfPin4.bolder(2)
        btSignIn.underline()
        tfPin1.text = ""
        tfPin2.text = ""
        tfPin3.text = ""
        tfPin4.text = ""
        tfPin1.becomeFirstResponder()
        lbMessage.isHidden = true
    }
}
