//
//  PhoneResetPassVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/27/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import KRProgressHUD

class PhoneResetPassVC: UIViewController {
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var btSubmit: UIButton!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbTitle2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionSubmit(_ sender: Any) {
        if valid() {
            KRProgressHUD.show()
            let urlCheckPhone = "\(API.MAIN_VALIDPHONE)\(tfPhone.text!)\(API.typeValidPhone)"
            WebService.shareInstance.getAuthorization(urlCheckPhone, isShowLoader: false, success: { (respone) in
                let urlSignUp = "\(API.MAIN_PATIENT)\(API.FofgotPasswordPatient)"
                let param = ["Phone" : self.tfPhone.strTrim()]
                
                WebService.shareInstance.postWebServiceCall(urlSignUp, params: param as Any as? [String : Any], isShowLoader: false, success: { (respone) in
                    KRProgressHUD.dismiss()
                    let code = respone["ErrorCode"].intValue
                    if code == ERRORCODE.SUCCESS {
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "CodeResetPassVC") as! CodeResetPassVC
                        vc.phone = self.tfPhone.strTrim()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        self.lbMessage.isHidden = false
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
    
    @IBAction func editingChange(_ sender: Any) {
        lbMessage.isHidden = true
    }
}

extension PhoneResetPassVC {
    func valid() -> Bool {
        if tfPhone.isValidNotEmty() {
            return true
        }else{
            Common.showAlert("txt_mobile_validate".localized, self)
            return false
        }
    }
}

extension PhoneResetPassVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        actionSubmit(textField)
        return true
    }
}
