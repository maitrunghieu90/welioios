//
//  CallVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/18/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import SkypeForBusiness
import Kingfisher

class CallVC: UIViewController {
    @IBOutlet weak var lbDoctor: UILabel!
    @IBOutlet weak var imvAvatar: UIImageView!
    @IBOutlet weak var lbEndCall: UILabel!
    
    var appointment = WAppointment()
    var countCreateSession = 0
    var countRemoteParticipants = 0
    var isShow = false
    var name = ""
    var isPush = false
    var kvo = 0
    var kvo2 = 1
    fileprivate var sfb: SfBApplication?
    fileprivate var conversation: SfBConversation? {
        willSet {
            conversation?.removeObserver(self, forKeyPath: "remoteParticipants", context: &kvo)
            conversation?.removeObserver(self, forKeyPath: "state", context: &kvo)
        }
    }
    var person : SfBPerson? {
        willSet {
            person?.removeObserver(self, forKeyPath: "displayName", context: &kvo2)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if conversation?.observationInfo != nil {
            conversation?.removeObserver(self, forKeyPath: "remoteParticipants", context: &kvo)
            conversation?.removeObserver(self, forKeyPath: "state", context: &kvo)
        }
        if person?.observationInfo != nil {
            person?.removeObserver(self, forKeyPath: "displayName", context: &kvo2)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionEndCall(_ sender: Any) {
        do {
            try conversation?.leave()
            Common.getAppDelegate().conversation = nil
            UIApplication.shared.isIdleTimerDisabled = false
            self.navigationController?.popViewController(animated: true)
        } catch {}
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvo{
            switch keyPath! {
            case "remoteParticipants":
                print("ok==============================")
                if (conversation?.remoteParticipants.count)! == 1 {
                    self.perform(#selector(checkRemote), with: nil, afterDelay: 1)
                    
                }
//                if (conversation?.remoteParticipants.count)! > 0 {
//                    for part in (conversation?.remoteParticipants)! {
//                        person = part.person
//                        person?.addObserver(self, forKeyPath: "displayName", options: [.initial], context: &kvo2)
//                    }
//                }
            case "state":
                if !isShow && conversation?.state != nil && conversation?.state == SfBConversationState.established{
                    isShow = true
                    self.perform(#selector(showMessN), with: nil, afterDelay: 30)
                }
            default:
                assertionFailure()
            }
        }else if context == &kvo2{
            switch keyPath! {
            case "displayName":
                for par in (conversation?.remoteParticipants)! {
                    if par.person.displayName.characters.count > 0 {
                        if par.person.displayName != name {
                            checkDoctorJoin()
                        }
                    }
                }
            default:
                assertionFailure()
            }
        }
    }
}

extension CallVC {
    func initUI() {
        if appointment.IsCarer! {
            name = "\(appointment.PatientFirstName!) \(appointment.PatientLastName!)"
        }else{
            name = "\(Common.getAppDelegate().loginUser.FirstName!) \(Common.getAppDelegate().loginUser.LastName!)"
        }
        lbDoctor.text = "\("txt_calling".localized)\nDr. \(appointment.doctor.FirstName!) \(appointment.doctor.LastName!)"
        lbEndCall.text = "txt_end_call".localized
        UIApplication.shared.isIdleTimerDisabled = true
        
        if appointment.doctor.DoctorAvatar != nil {
            if (appointment.doctor.DoctorAvatar?.characters.count)! > 0 {
                let url = URL(string: appointment.doctor.DoctorAvatar!)
                let placeholder = UIImage.init(named: "ic_defaultAvatar")
                imvAvatar.kf.setImage(with: url, placeholder: placeholder, options: [.transition(ImageTransition.fade(1))], progressBlock: { (receivedSize, totalSize) in
                    print("DownloadImage: \(receivedSize)/\(totalSize)")
                }, completionHandler: { (image, error, cacheType, imageURL) in
                    if image != nil {
                        self.imvAvatar.image = image
                    }
                })
            }
        }
    }
    
    func initData() {
        initializeSkype()
        askAgentVideo()
    }
    
    func initializeSkype(){
        sfb = SfBApplication.shared()
        if let sfb = sfb{
            sfb.configurationManager.maxVideoChannels = 5
            sfb.configurationManager.requireWifiForAudio = false
            sfb.configurationManager.requireWifiForVideo = false
            sfb.devicesManager.selectedSpeaker.activeEndpoint = .loudspeaker
            sfb.configurationManager.enablePreviewFeatures = true
            sfb.alertDelegate = self
        }
    }
    
    func askAgentVideo()  {
        if let sfb = sfb{
            let config = sfb.configurationManager
            let key = "AcceptedVideoLicense"
            let defaults = UserDefaults.standard
            
            if defaults.bool(forKey: key) {
                config.setEndUserAcceptedVideoLicense()
            }else{
                defaults.set(true, forKey: key)
                config.setEndUserAcceptedVideoLicense()
            }
            if(didJoinMeeting()){
                checkCall()
            }
        }
    }
    
    func didJoinMeeting() -> Bool {
        do {
            print("link url-link url-link url: \(appointment.JoinMettingUrl!.trimmingCharacters(in: .whitespacesAndNewlines))")
            let url = URL(string:appointment.JoinMettingUrl!.trimmingCharacters(in: .whitespacesAndNewlines))
            conversation = try sfb!.joinMeetingAnonymous(withUri: url!, displayName: name).conversation
            Common.getAppDelegate().conversation = conversation
            return true
        }
        catch  {
            print("ERROR! Joining online meeting>\(error)")
            return false
        }
        
    }
    
    func checkRemote() {
        if conversation?.remoteParticipants.count == 1 {
            checkDoctorJoin()
        }else{
            var check = false
            
            for par in (conversation?.remoteParticipants)! {
                if par.person.displayName.characters.count > 0 {
                    if par.person.displayName != name {
                        check = true
                        checkDoctorJoin()
                    }
                }
            }
            if !check {
                self.perform(#selector(checkRemote), with: nil, afterDelay: 1)
            }
        }
    }
    
    func checkCall() {
        conversation?.addObserver(self, forKeyPath: "remoteParticipants", options: [.initial], context: &kvo)
        conversation?.addObserver(self, forKeyPath: "state", options: [.initial], context: &kvo)
    }
    
    func checkDoctorJoin(){
        if (conversation?.remoteParticipants.count)! > 0 {
            if !isPush {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoCallVC") as! VideoCallVC
                vc.conversation = conversation
                vc.appointment = appointment
                vc.devicesManager = sfb?.devicesManager
                isPush = true
                vc.name = name
                conversation = nil
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func showMessN() {
        if !isPush {
            let alert = UIAlertController(title: "app_name".localized, message: "txt_wait_call".localized, preferredStyle: UIAlertControllerStyle.alert)
            let noAction: UIAlertAction = UIAlertAction(title: "txt_wait".localized, style: .default) { action -> Void in
                alert.dismiss(animated: true, completion: nil)
            }
            let yesAction: UIAlertAction = UIAlertAction(title: "txt_end".localized, style: .cancel) { action -> Void in
                do {
                    try self.conversation?.leave()
                    Common.getAppDelegate().conversation = nil
                    UIApplication.shared.isIdleTimerDisabled = false
                    self.navigationController?.popViewController(animated: true)
                } catch {}
            }
            alert.addAction(noAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension CallVC: SfBAlertDelegate {
    func didReceive(_ alert: SfBAlert) {
    }
}
