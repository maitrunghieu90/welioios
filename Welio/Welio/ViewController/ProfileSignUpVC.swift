//
//  ProfileSignUpVC.swift
//  Welio
//
//  Created by Hoa on 4/11/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import KRProgressHUD

class ProfileSignUpVC: UIViewController {
    @IBOutlet weak var btSave: UIButton!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var tfFirstName: MKTextField!
    @IBOutlet weak var tfPassword: MKTextField!
    @IBOutlet weak var tfPhone: MKTextField!
    @IBOutlet weak var tfMail: MKTextField!
    @IBOutlet weak var tfLastName: MKTextField!
    @IBOutlet weak var tfConfirmPass: MKTextField!
    
    var signUpUser = WPatient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initLanguage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionSave(_ sender: Any) {
        self.view.endEditing(true)
        if valid() {
            let urlCheckPhone = "\(API.MAIN_VALIDPHONE)\(tfPhone.text!)\(API.typeValidPhone)"
            KRProgressHUD.show()
            WebService.shareInstance.getAuthorization(urlCheckPhone, isShowLoader: false, success: { (respone) in
                let urlSignUp = "\(API.MAIN_PATIENT)\(API.sigupPatient)"
                let param = ["FirstName" : self.tfFirstName.strTrim(),
                             "LastName" : self.tfLastName.strTrim(),
                             "Phone" : self.tfPhone.strTrim(),
                             "Password" : self.tfPassword.strTrim(),
                             "Email" : self.tfMail.strTrim(),
                             "SendSMS" : "true"]
                
                WebService.shareInstance.postWebServiceCall(urlSignUp, params: param as Any as? [String : Any], isShowLoader: false, success: { (respone) in
                    KRProgressHUD.dismiss()
                    let code = respone["ErrorCode"].intValue
                    if code == ERRORCODE.SUCCESS {
                        self.signUpUser.parser(respone["Result"])
                        self.signUpUser.cacheUserDefault()
                        Common.getAppDelegate().loginUser = self.signUpUser
                        self.signUpUser.Password = self.tfPassword.strTrim()
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChoosePhotoVC") as! ChoosePhotoVC
                        vc.signUpObj = self.signUpUser
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else if code == ERRORCODE.FAILURE_PHONE_EXISTED {
                        Common.showAlert("err_phone_exist".localized, self)
                    }else if code == ERRORCODE.FAILURE_EMAIL_EXISTED {
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "AlreadyMailVC") as! AlreadyMailVC
                        vc.strMail = self.tfMail.strTrim()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        Common.showAlert("err_connect_server".localized, self)
                    }
                    
                }) { (error) in
                    KRProgressHUD.dismiss()
                    Common.showAlert("err_connect_server".localized, self)
                }
            }) { (error) in
                KRProgressHUD.dismiss()
                Common.showAlert("txt_mobile_invalid".localized, self)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ProfileSignUpVC {
    func configureMKTextField() {
        tfFirstName.configureTextField()
        tfPassword.configureTextField()
        tfPhone.configureTextField()
        tfMail.configureTextField()
        tfLastName.configureTextField()
        tfConfirmPass.configureTextField()
    }
    
    func initUI() {
        tfFirstName.becomeFirstResponder()
        configureMKTextField()
    }
    
    func initLanguage() {
        tfFirstName.placeholder = "txt_first_name".localized
        tfLastName.placeholder = "txt_last_name".localized
        tfPassword.placeholder = "txt_password".localized
        tfPhone.placeholder = "txt_mobile_number".localized
        tfMail.placeholder = "txt_email".localized
        tfConfirmPass.placeholder = "txt_confirm_password".localized
        lbTitleNav.text = "txt_your_profile".localized
        btSave.setTitle("txt_save".localized, for: .normal)
    }
    
    func valid() -> Bool {
        if tfFirstName.isValidNotEmty() {
            if tfLastName.isValidNotEmty() {
                if tfMail.isValidNotEmty() {
                    if tfMail.isValidEmail() {
                        if tfPhone.isValidNotEmty() {
                            if tfPassword.isValidNotEmty() {
                                if tfPassword.isValidPass() {
                                    if tfConfirmPass.isValidNotEmty() {
                                        if tfConfirmPass.text == tfPassword.text {
                                            return true
                                        }else {
                                            Common.showAlert("txt_confirm_password_same_validate".localized, self)
                                            return false
                                        }
                                    } else {
                                        Common.showAlert("txt_confirm_password_validate".localized, self)
                                        return false
                                    }
                                }else {
                                    Common.showAlert("txt_length_password_validate".localized, self)
                                    return false
                                }
                            } else {
                                Common.showAlert("txt_password_validate".localized, self)
                                return false
                            }
                        }else{
                            Common.showAlert("txt_mobile_validate".localized, self)
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
            }else{
                Common.showAlert("txt_lastname_validate".localized, self)
                return false
            }
        }else{
            Common.showAlert("txt_firstname_validate".localized, self)
            return false
        }
    }
}

extension ProfileSignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfFirstName {
            tfLastName.becomeFirstResponder()
        } else if(textField == tfLastName){
            tfMail.becomeFirstResponder()
        } else if(textField == tfMail){
            tfPhone.becomeFirstResponder()
        } else if(textField == tfPhone){
            tfPassword.becomeFirstResponder()
        } else if(textField == tfPassword){
            tfConfirmPass.becomeFirstResponder()
        } else{
            actionSave((Any).self)
        }
        return true
    }
}
