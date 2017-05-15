//
//  AddPINVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/27/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class AddPINVC: UIViewController {
    @IBOutlet weak var tfPin1: UITextField!
    @IBOutlet weak var tfPin2: UITextField!
    @IBOutlet weak var tfPin3: UITextField!
    @IBOutlet weak var tfPin4: UITextField!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btSkip: UIButton!
    @IBOutlet weak var lbMessage: UILabel!
    
    var patient = WPatient()
    var isFromSetting = false    
    var isFromResetPass = false
    
    
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionSkip(_ sender: Any) {
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
    
    @IBAction func valueChange(_ sender: UITextField) {
        if (sender.text?.characters.count)! > 0 {
            if sender == tfPin1 {
                tfPin2.becomeFirstResponder()
            }else if sender == tfPin2 {
                tfPin3.becomeFirstResponder()
            }else if sender == tfPin3 {
                tfPin4.becomeFirstResponder()
            }else if sender == tfPin4 {
                self.view.endEditing(true)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmPINVC") as! ConfirmPINVC
                vc.patient = patient
                vc.isFromSetting = isFromSetting
                vc.isFromResetPass = isFromResetPass
                vc.PIN = "\(tfPin1.text!)\(tfPin2.text!)\(tfPin3.text!)\(tfPin4.text!)"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                
            }
        }
    }
}

extension AddPINVC {
    func initUI() {
        tfPin1.bolder(2)
        tfPin2.bolder(2)
        tfPin3.bolder(2)
        tfPin4.bolder(2)
        if isFromSetting || isFromResetPass{
            btSkip.isHidden = true
        }else{
            btSkip.isHidden = false
        }
        tfPin1.text = ""
        tfPin2.text = ""
        tfPin3.text = ""
        tfPin4.text = ""
        tfPin1.becomeFirstResponder()
    }
}
