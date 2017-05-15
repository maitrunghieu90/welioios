//
//  CompleteCallVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/14/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import Cosmos
import MessageUI
import KRProgressHUD

class CompleteCallVC: UIViewController {
    @IBOutlet weak var lbDuration: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var btSuggestMail: UIButton!
    @IBOutlet weak var viewDuration: UIView!
    @IBOutlet weak var viewFee: UIView!
    
    var call = WCall()
    var messageCall = WMessage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        endTrackingTime()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionSendMail(_ sender: Any) {
        if( MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(["matthew.vlachos@welio.com"])
            mailComposer.setSubject("Welio Suggestions")
            self.present(mailComposer, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "app_name".localized, message: "You haven't had email in device yet. Please set up email before using this function!", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "txt_cancel".localized, style: .cancel) { action -> Void in
                
            }
            
            let okAction: UIAlertAction = UIAlertAction(title: "txt_ok".localized, style: .default) { action -> Void in
                let mailURL = URL(string: "message://")!
                if UIApplication.shared.canOpenURL(mailURL) {
                    UIApplication.shared.openURL(mailURL)
                }
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionClose(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for vc in viewControllers {
            if vc is AppointmentDetailVC {
                self.navigationController!.popToViewController(vc, animated: true)
            }
        }
    }
}

extension CompleteCallVC {
    func initUI() {
        ratingView.settings.fillMode = .full
        ratingView.didFinishTouchingCosmos = { rate in
            self.rating("\(Int(rate))")
        }
        showInfoCall()
        SideMenuRootController.panningEnabled = false
        viewFee.corner()
        viewDuration.corner()
    }
    
    func showInfoCall() {
        if call.Fee != nil {
            lbPrice.text = "$\(Int(call.Fee!))"
        }else{
            lbPrice.text = "$22"
        }
        
        if call.Duration != nil {
            let (day, h, m, s) = Int(call.Duration!).second()
            print("\(day), \(h), \(m), \(s)")
            
            
            let attDuration = NSMutableAttributedString()
            if m > 0 && s > 0{
                attDuration.append(NSMutableAttributedString().changeFont(text: "\(m)", font: UIFont.systemFont(ofSize: 26, weight: UIFontWeightBold), fontColor: UIColor.white))
                attDuration.append(NSMutableAttributedString().changeFont(text: "m", font: UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold), fontColor: UIColor.white))
                attDuration.append(NSMutableAttributedString().changeFont(text: "\(s)", font: UIFont.systemFont(ofSize: 26, weight: UIFontWeightBold), fontColor: UIColor.white))
                attDuration.append(NSMutableAttributedString().changeFont(text: "s", font: UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold), fontColor: UIColor.white))
                lbDuration.attributedText = attDuration
            }else if m > 0 {
                attDuration.append(NSMutableAttributedString().changeFont(text: "\(m)", font: UIFont.systemFont(ofSize: 26, weight: UIFontWeightBold), fontColor: UIColor.white))
                attDuration.append(NSMutableAttributedString().changeFont(text: "m", font: UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold), fontColor: UIColor.white))
                lbDuration.attributedText = attDuration
            }else{
                attDuration.append(NSMutableAttributedString().changeFont(text: "\(s)", font: UIFont.systemFont(ofSize: 26, weight: UIFontWeightBold), fontColor: UIColor.white))
                attDuration.append(NSMutableAttributedString().changeFont(text: "s", font: UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold), fontColor: UIColor.white))
                lbDuration.attributedText = attDuration
            }
            
        }else{
            let attDuration = NSMutableAttributedString()
            attDuration.append(NSMutableAttributedString().changeFont(text: "0", font: UIFont.systemFont(ofSize: 26, weight: UIFontWeightBold), fontColor: UIColor.white))
            attDuration.append(NSMutableAttributedString().changeFont(text: "s", font: UIFont.systemFont(ofSize: 17, weight: UIFontWeightBold), fontColor: UIColor.white))
            lbDuration.attributedText = attDuration
        }
    }
    
    func rating(_ rate : String) {
        if self.ratingView.settings.updateOnTouch {
            if call.CallId != nil {
                let urlSignUp = "\(API.MAIN_TRACKINGCALLTIME)\(API.RatingCallOfPatient)"
                let param = ["AppointmentId" : call.AppointmentId,
                             "CallId" : call.CallId,
                             "PatientRate" : rate]
                
                WebService.shareInstance.postWebServiceCallWithHeader(urlSignUp, params: param as Any as? [String : Any], isShowLoader: true, success: { (respone) in
                    let code = respone["ErrorCode"].intValue
                    if code == ERRORCODE.SUCCESS {
                        Common.showAlert("Rated successfully", self)
                        self.ratingView.settings.updateOnTouch = false
                    }
                }) { (error) in
                }
            }
        }
    }
    
    func endTrackingTime() {
        if call.CallId != nil {
            let urlSignUp = "\(API.MAIN_TRACKINGCALLTIME)\(API.TrackingCallTime)"
            let param = ["AppointmentId" : call.AppointmentId,
                         "CallId" : call.CallId,
                         "Type" : "END"]
            WebService.shareInstance.postWebServiceCallWithHeader(urlSignUp, params: param as Any as? [String : Any], isShowLoader: true, success: { (respone) in
                let code = respone["ErrorCode"].intValue
                if code == ERRORCODE.SUCCESS {
                    self.call.parser(respone["Result"])
                    self.showInfoCall()
                    let msg =  WMessage()
                    msg.id = self.messageCall.id
                    msg.apntId = self.messageCall.apntId
                    msg.senderId = self.messageCall.senderId
                    msg.receviceId = self.messageCall.receviceId
                    msg.callId = self.messageCall.callId
                    msg.startAt = self.messageCall.startAt
                    msg.isUnread = true
                    msg.messageType = 1
                    msg.dutation = Int(self.call.Duration!)
                    msg.endAt = Date().millisecondsSince1970
                    RealmManager.sharedInstance.update(msg)
                }
            }) { (error) in
            }
        }
    }
}

extension CompleteCallVC : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sent failure: \(String(describing: error?.localizedDescription))")
        }
        dismiss(animated: true, completion: nil)
    }
}
