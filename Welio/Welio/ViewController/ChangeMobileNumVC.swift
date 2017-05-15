//
//  ChangeMobileNumVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/12/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class ChangeMobileNumVC: UIViewController {
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var btContinue: UIButton!
    @IBOutlet weak var tfMobileNumber: UITextField!
    
    var patient = WPatient()
    
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
    
    @IBAction func actionChangePhone(_ sender: Any) {
        self.view.endEditing(true)
        if valid() {
            let urlCheckPhone = "\(API.MAIN_VALIDPHONE)\(tfMobileNumber.text!)\(API.typeValidPhone)"
            
            WebService.shareInstance.getAuthorization(urlCheckPhone, isShowLoader: true, success: { (respone) in
                let urlSignIn = "\(API.MAIN_PATIENT)\(API.UpdatePhoneOfPatient)"
                let param = ["PatientId" : self.patient.PatientId, "Phone" : self.tfMobileNumber.strTrim()]
                
                WebService.shareInstance.postWebServiceCall(urlSignIn, params: param as Any as? [String : Any], isShowLoader: true, success: { (respone) in
                    let errorCode = respone["ErrorCode"].intValue
                    let Result = respone["Result"].boolValue
                    if Result {
                        Common.getAppDelegate().loginUser.Phone = self.tfMobileNumber.strTrim()
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        if errorCode == ERRORCODE.FAILURE_EMAIL_OR_PHONE_EXISTED {
                            Common.showAlert("txt_phone_already".localized, self)
                        }
                    }
                }) { (error) in
                    Common.showAlert("err_connect_server".localized, self)
                }
            }) { (error) in
                self.lbMessage.isHidden = false
            }
        }
    }
    
    @IBAction func editingChange(_ sender: Any) {
        lbMessage.isHidden = true
    }
}

extension ChangeMobileNumVC {
    func initUI() {
        tfMobileNumber.becomeFirstResponder()
        lbMessage.isHidden = true
    }
    
    func initLanguage() {
        lbMessage.text = "txt_mobile_invalid".localized
        lbTitle.text = "txt_enter_mobile".localized
        lbTitleNav.text = "txt_change_mobile".localized
        btContinue.setTitle("txt_continue".localized, for: .normal)
    }
    
    func valid() -> Bool {
        if tfMobileNumber.isValidNotEmty() {
            return true
        }else{
            Common.showAlert("txt_mobile_validate".localized, self)
            return false
        }
    }
}
