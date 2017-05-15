//
//  NewPassVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/27/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class NewPassVC: UIViewController {
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btSave: UIButton!
    @IBOutlet weak var tfPassword: UITextField!
    
    var code : String?
    var patientID : String?
    var phone : String?
    
    
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
    
    @IBAction func actionSave(_ sender: Any) {
        if valid() {
            let urlSignUp = "\(API.MAIN_PATIENT)\(API.ResetPassword)"
            let param = ["PatientId" : patientID,
                         "OTPCode" : code,
                         "NewPassword" : tfPassword.strTrim()]
            WebService.shareInstance.postWebServiceCall(urlSignUp, params: param as Any as? [String : Any], isShowLoader: true, success: { (respone) in
                let code = respone["ErrorCode"].intValue
                if code == ERRORCODE.SUCCESS {
                    self.signIn()
                }else{
                    Common.showAlert("err_connect_server".localized, self)
                }
                
            }) { (error) in
                Common.showAlert("err_connect_server".localized, self)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension NewPassVC {
    func valid() -> Bool {
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
    }
    
    func initUI() {
        tfPassword.becomeFirstResponder()
    }
    
    func signIn() {
        let urlSignIn = "\(API.MAIN_PATIENT)\(API.loginPatient)"
        let pr = ["PhoneOrMail" : self.phone, "Password" : self.tfPassword.strTrim()]
        
        WebService.shareInstance.postWebServiceCall(urlSignIn, params: pr as Any as? [String : Any], isShowLoader: true, success: { (respone) in
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
                if Common.getFromUserDefaults(KEY_USDEFAULT.PIN) != nil {
                    let alert = UIAlertController(title: "Would you like to reset your PIN?", message: "Your PIN will be disabled if you do not reset it", preferredStyle: UIAlertControllerStyle.alert)
                    let resetAction: UIAlertAction = UIAlertAction(title: "Reset PIN", style: .cancel) { action -> Void in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPINVC") as! AddPINVC
                        vc.patient = patient
                        vc.isFromResetPass = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    alert.addAction(resetAction)
                    let disableAction: UIAlertAction = UIAlertAction(title: "Disable PIN", style: .default) { action -> Void in
                        Common.removeFromUserdefaults(KEY_USDEFAULT.PIN)
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuRootController") as! SideMenuRootController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    alert.addAction(disableAction)
                    self.present(alert, animated: true, completion: nil)
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuRootController") as! SideMenuRootController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if errorCode == ERRORCODE.FAILURE_USER_ACTIVED {
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "VerifyCodeVC") as! VerifyCodeVC
                patient.Password = self.tfPassword.strTrim()
                vc.patient = patient
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }) { (error) in
            Common.showAlert("err_connect_server".localized, self)
        }
    }
}

extension NewPassVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        actionSave(textField)
        return true
    }
}
