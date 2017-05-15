//
//  SignInVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/13/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import RealmSwift

class SignInVC: UIViewController {
    @IBOutlet weak var btForgot: UIButton!
    @IBOutlet weak var lbMessError: UILabel!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var btContinue: UIButton!
    @IBOutlet weak var tfPassword: MKTextField!
    @IBOutlet weak var tfEmail: MKTextField!
    @IBOutlet weak var btPin: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var ctrBtPin: NSLayoutConstraint!
    @IBOutlet weak var ctrTitle: NSLayoutConstraint!
    
    var strExistMail : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLanguage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func actionSignIn(_ sender: Any) {
        self.view.endEditing(true)
        if valid() {
            let urlSignIn = "\(API.MAIN_PATIENT)\(API.loginPatient)"
            let param = ["PhoneOrMail" : tfEmail.strTrim(), "Password" : tfPassword.strTrim()]
            
            WebService.shareInstance.postWebServiceCall(urlSignIn, params: param, isShowLoader: true, success: { (respone) in
                Common.addToUserDefaults(KEY_USDEFAULT.isLogin, pObject: "yes")
                
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
                } else if errorCode == ERRORCODE.FAILURE_USER_ACTIVED {
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "VerifyCodeVC") as! VerifyCodeVC
                    patient.Password = self.tfPassword.strTrim()
                    vc.patient = patient
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if errorCode == ERRORCODE.FAILURE_USER_NOT_FOUND {
                    self.lbMessError.isHidden = false
                }else if errorCode == ERRORCODE.FAILURE_INVALID_PASSWORD {
                    self.lbMessError.isHidden = false
                }else {
                    self.lbMessError.isHidden = false
                }
            }) { (error) in
                Common.showAlert("err_connect_server".localized, self)
            }
        }
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
    
    @IBAction func actionPin(_ sender: Any) {
        var check = false
        
        for vc in (self.navigationController?.viewControllers)! {
            if vc is EnterPINVC {
                check = true
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
        if !check {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterPINVC") as! EnterPINVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func actionForgotPass(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhoneResetPassVC") as! PhoneResetPassVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func editingChange(_ sender: Any) {
        lbMessError.isHidden = true
    }
    
    @IBAction func editingChangePass(_ sender: Any) {
        lbMessError.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SignInVC {
    func initUI() {
        tfEmail.configureTextField()
        tfPassword.configureTextField()
        btForgot.underline()
        if (strExistMail != nil) && (strExistMail?.characters.count)! > 0 {
            tfEmail.text = strExistMail
        }
        lbMessError.isHidden = true
        tfEmail.becomeFirstResponder()
        btPin.underline()
        if Common.getFromUserDefaults(KEY_USDEFAULT.PIN) != nil && (Common.getFromUserDefaults(KEY_USDEFAULT.isLogin) != nil) && Common.getFromUserDefaults(KEY_USDEFAULT.isLogin) as! String == "yes"{
            ctrBtPin.constant = 40
            ctrTitle.constant = 68
            btPin.isHidden = false
            lbTitle.isHidden = false
        }else{
            ctrBtPin.constant = 1
            ctrTitle.constant = 1
            btPin.isHidden = true
            lbTitle.isHidden = true
        }
        tfPassword.text = ""
    }
    
    func initLanguage() {
        tfEmail.placeholder = "txt_email".localized
        tfPassword.placeholder = "txt_password".localized
        lbTitleNav.text = "txt_sign_in".localized
        btContinue.setTitle("txt_continue".localized, for: .normal)
        btForgot.setTitle("txt_forgotten".localized, for: .normal)
        lbMessError.text = "txt_login_fail".localized
    }
    
    func valid() -> Bool {
        if tfEmail.isValidNotEmty() {
            if tfEmail.isValidEmail() {
                if tfPassword.isValidNotEmty() {
                    if tfPassword.isValidPass() {
                        return true
                    }else {
                        Common.showAlert("txt_length_password_validate".localized, self)
                        return false
                    }
                } else {
                    Common.showAlert("txt_password_validate".localized, self)
                    return false
                }
            } else {
                Common.showAlert("txt_email_invalid".localized, self)
                return false
            }
        }else{
            Common.showAlert("txt_email_validate".localized, self)
            return false
        }
    }
}

extension SignInVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfEmail {
            tfPassword.becomeFirstResponder()
        }else if textField == tfPassword {
            actionSignIn(textField)
        }
        return true
    }
}
