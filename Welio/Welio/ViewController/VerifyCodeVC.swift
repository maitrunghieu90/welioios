//
//  VerifyCodeVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/12/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class VerifyCodeVC: UIViewController {
    @IBOutlet weak var lbMessDialog: UILabel!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var btChangeMobie: UIButton!
    @IBOutlet weak var btSendNew: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var vCheckMess: UIView!
    @IBOutlet weak var tfCode: UITextField!
    
    var patient = WPatient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initLanguage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tfCode.text = ""
        tfCode.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionChangeMobie(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangeMobileNumVC") as! ChangeMobileNumVC
        vc.patient = patient
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionSendNew(_ sender: Any) {
        self.view.endEditing(true)
        let url = "\(API.MAIN_PATIENT)\(API.ReSendVerifyOTPForPhone)"
        let param = ["Phone" : patient.Phone]
        
        WebService.shareInstance.postWebServiceCall(url, params: param as Any as? [String : Any], isShowLoader: true, success: { (respone) in
            let code = respone["ErrorCode"].intValue
            if code == 0 {
                self.showMessage()
            }
        }) { (error) in
            Common.showAlert("err_connect_server".localized, self)
        }
    }
    
    @IBAction func valueChange(_ sender: UITextField) {
        lbMessage.isHidden = true
        if sender.text?.characters.count == 6 {
            self.view.endEditing(true)
            let url = "\(API.MAIN_PATIENT)\(API.ActiveVerifyOTP)"
            let param = ["PatientId" : patient.PatientId,
                         "OTPCode" : tfCode.strTrim()]
            
            WebService.shareInstance.postWebServiceCall(url, params: param as Any as? [String : Any], isShowLoader: true, success: { (respone) in
                let code = respone["ErrorCode"].intValue
                if code == 0 {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPINVC") as! AddPINVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self.tfCode.text = ""
                    self.lbMessage.isHidden = false
                }
            }) { (error) in
                Common.showAlert("err_connect_server".localized, self)
            }
        }
    }
}

extension VerifyCodeVC {
    func initUI() {
        btSendNew.underline()
        btChangeMobie.underline()
        viewMessage.isHidden = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hideMessage))
        viewMessage.addGestureRecognizer(tap)
        vCheckMess.corner(10)
        lbMessage.isHidden = true
    }
    
    func hideMessage() {
        UIView.animate(withDuration: 0.5) {
            self.viewMessage.isHidden = true
            self.tfCode.becomeFirstResponder()
        }
    }
    
    func showMessage() {
        UIView.animate(withDuration: 0.5) {
            self.viewMessage.isHidden = false
            self.perform(#selector(self.hideMessage), with: nil, afterDelay: 1.0)
        }
    }
    
    func initLanguage() {
        lbMessage.text = "txt_code_incorrect".localized
        lbTitleNav.text = "txt_verify_account".localized
        lbTitle.text = "\("txt_enter_code".localized) \(Common.getAppDelegate().loginUser.Phone!)"
        btChangeMobie.setTitle("txt_change_mobile".localized, for: .normal)
        btSendNew.setTitle("txt_send_new_code".localized, for: .normal)
        lbMessDialog.text = "txt_code_sent".localized
    }
}
