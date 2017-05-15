//
//  CodeResetPassVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/27/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class CodeResetPassVC: UIViewController {
    @IBOutlet weak var tfCode: UITextField!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbMessage: UILabel!
    
    var phone : String?
    
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
    
    @IBAction func editingChange(_ sender: Any) {
        lbMessage.isHidden = true
        if tfCode.strTrim().characters.count == 6 {
            let urlSignUp = "\(API.MAIN_PATIENT)\(API.CheckOTPForgotPassword)"
            let param = ["Phone" : phone,
                         "OTPCode" : self.tfCode.strTrim()]
            
            WebService.shareInstance.postWebServiceCall(urlSignUp, params: param as Any as? [String : Any], isShowLoader: true, success: { (respone) in
                let code = respone["ErrorCode"].intValue
                if code == ERRORCODE.SUCCESS {
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "NewPassVC") as! NewPassVC
                    vc.patientID = respone["Result"]["PatientId"].stringValue
                    vc.code = respone["Result"]["OTPCode"].stringValue
                    vc.phone = self.phone
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self.lbMessage.isHidden = false
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

extension CodeResetPassVC {
    func initLanguage() {
        lbTitle.text = "\("txt_enter_code".localized) \(phone!)"
    }
    
    func initUI() {
        tfCode.becomeFirstResponder()
    }
}
