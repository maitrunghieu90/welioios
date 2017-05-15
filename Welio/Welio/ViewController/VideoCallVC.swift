//
//  VideoCallVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/18/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import GLKit
import SkypeForBusiness
import Kingfisher

class VideoCallVC: UIViewController {
    @IBOutlet weak var imvAvatar: UIImageView!
    @IBOutlet var videoView: GLKView!
    @IBOutlet weak var btEndVideo: UIButton!
    @IBOutlet weak var myVideoView: UIView!
    @IBOutlet weak var lbDoctor: UILabel!
    @IBOutlet weak var lbCallTime: UILabel!
    @IBOutlet weak var btEndCall: UIButton!
    @IBOutlet weak var tvMessage: UITextView!
    @IBOutlet weak var tbMessage: UITableView!
    @IBOutlet weak var ctrHeightTextViewMessage: NSLayoutConstraint!
    @IBOutlet weak var ctrBottomTextViewMessage: NSLayoutConstraint!
    @IBOutlet weak var btSendMessage: UIButton!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var viewNoMessage: UIView!
    @IBOutlet weak var viewNew: GLKView!
    @IBOutlet weak var lbTitleNav: UILabel!
    
    let DisplayNameInfo:String = "displayName"
    var conversationHelper:SfBConversationHelper? = nil
    var conversation:SfBConversation? = nil
    var chatHandler:ChatHandler? = nil
    var devicesManager: SfBDevicesManager? = nil
    var clickHideCamera = false
    var appointment = WAppointment()
    var call = WCall()
    var hasOb = false
    var isConnected = false
    var selfVideoTimer : Timer?
    var callTimer : Timer?
    var checkMuteTimer : Timer?
    var duration = 0
    var name : String!
    var isClickEndVideo = false
    var dictMessage = [String : [WMessage]]()
    var arrMessage = [WMessage]()
    var arrSortedKey = [String]()
    var messCall = WMessage()
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.conversationHelper?.conversation.observationInfo != nil {
            self.conversationHelper?.conversation.removeObserver(self, forKeyPath: "canLeave")
        }
        Common.getAppDelegate().conversation = nil
        if (leaveMeetingWithSuccess((conversationHelper?.conversation)!)){
            
        }
        self.stopCallTimer()
        UIApplication.shared.isIdleTimerDisabled = false
        conversationHelper?.remove()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "canLeave") {
            self.btEndCall.isEnabled = (self.conversationHelper?.conversation.canLeave)!
        }
    }
    
    @IBAction func startVideo(_ sender: Any) {
        isClickEndVideo = true
        if (conversationHelper?.conversation.selfParticipant.video.isPaused)! {
            do{
                try conversationHelper?.conversation.videoService.setPaused(false)
                myVideoView.isHidden = false
                btEndVideo.setBackgroundImage(UIImage.init(named: "ic_call"), for: .normal)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }else{
            do{
                try conversationHelper?.conversation.videoService.setPaused(true)
                myVideoView.isHidden = true
                btEndVideo.setBackgroundImage(UIImage.init(named: "ic_video"), for: .normal)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func actionShowMessage(_ sender: Any) {
        viewMessage.isHidden = false
        tvMessage.becomeFirstResponder()
//        conversationHelper?.subcribe(viewNew.layer as! CAEAGLLayer)
    }
    
    @IBAction func actionHideMessage(_ sender: Any) {
        viewMessage.isHidden = true
        endEditing()
    }
    
    @IBAction func actionSendMessage(_ sender: Any) {
        if tvMessage.text.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
            var error: NSError? = nil
            let strMess = tvMessage.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            self.tvMessage.text = ""
            conversationHelper?.sendMessage(strMess, error: &error)
            if (error != nil) {
                Common.showAlert("Can't send message. Please check your connection and try again", self)
            }
            else {
                let msg = WMessage()
                msg.id = "Welio-\(UUID().uuidString)"
                msg.apntId = appointment.AppointmentId!
                msg.senderId = Common.getAppDelegate().loginUser.PatientId!
                msg.receviceId = appointment.doctor.DoctorId!
                msg.isUnread = false
                msg.startAt = Date().millisecondsSince1970
                msg.messageType = 0
                msg.message = strMess
                RealmManager.sharedInstance.insert(msg)
                arrMessage.append(msg)
                createSection()
            }
        }
    }
    
    @IBAction func actionEndCall(_ sender: Any) {
        let alert = UIAlertController(title: "txt_msg_call".localized, message: "txt_msg_end".localized, preferredStyle: UIAlertControllerStyle.alert)
        let noAction: UIAlertAction = UIAlertAction(title: "txt_continue_call".localized, style: .default) { action -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        let yesAction: UIAlertAction = UIAlertAction(title: "txt_end_call".localized, style: .cancel) { action -> Void in
            if let conversation = self.conversationHelper?.conversation{
                if leaveMeetingWithSuccess(conversation) {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CompleteCallVC") as! CompleteCallVC
                    vc.call = self.call
                    vc.messageCall = self.messCall
                    self.navigationController!.pushViewController(vc, animated: true)
                }
            }
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension VideoCallVC {
    func initUI() {
        UIApplication.shared.isIdleTimerDisabled = true
        lbDoctor.text = "\(appointment.doctor.FirstName!) \(appointment.doctor.LastName!)"
        lbTitleNav.text = "\(appointment.doctor.FirstName!) \(appointment.doctor.LastName!)"
        btEndVideo.setBackgroundImage(UIImage.init(named: "ic_call"), for: .normal)
        tvMessage.corner(5)
        self.an_subscribeKeyboard(animations: { (rect, time, isShow) in
            if isShow {
                UIView.animate(withDuration: 1, animations: {
                    self.ctrBottomTextViewMessage.constant = rect.height
                })
            }else{
                self.ctrBottomTextViewMessage.constant = 0
            }
        }, completion: nil)
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(endEditing))
        tbMessage.addGestureRecognizer(tap)
        tbMessage.bounces = false
        
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
        joinMeeting()
        startCallTimer()
        startTrackingTime()
        loadDataMessage()
        createSection()
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
    
    func loadDataMessage() {
        arrMessage = RealmManager.sharedInstance.getAllMessage(appointment.AppointmentId!)
        arrMessage.sort(by: { (first: WMessage, second: WMessage) -> Bool in
            first.startAt < second.startAt
        })
    }
    
    func createSection() {
        dictMessage.removeAll()
        if arrMessage.count > 0 {
            for msg in arrMessage {
                if var arr = dictMessage["\(Date.init(msg.startAt).string("dd/MM/yyyy"))"] {
                    arr.append(msg)
                    dictMessage["\(Date.init(msg.startAt).string("dd/MM/yyyy"))"] = arr
                }else{
                    var arr = [WMessage]()
                    arr.append(msg)
                    dictMessage["\(Date.init(msg.startAt).string("dd/MM/yyyy"))"] = arr
                }
            }
            let df = DateFormatter()
            df.dateFormat = "MM-dd-yyyy"
            arrSortedKey = dictMessage.sortedKeys(<)
            viewNoMessage.isHidden = true
            tbMessage.reloadData()
            scrollToBottom()
        }else{
            viewNoMessage.isHidden = false
        }
    }
    
    func startTrackingTime() {
        let urlSignUp = "\(API.MAIN_TRACKINGCALLTIME)\(API.TrackingCallTime)"
        let param = ["AppointmentId" : appointment.AppointmentId,
                     "Type" : "START"]
        
        WebService.shareInstance.postWebServiceCallWithHeader(urlSignUp, params: param as Any as? [String : Any], isShowLoader: false, success: { (respone) in
            let code = respone["ErrorCode"].intValue
            if code == ERRORCODE.SUCCESS {
                self.call.parser(respone["Result"])
                self.messCall.id = "Welio-\(UUID().uuidString)"
                self.messCall.apntId = self.appointment.AppointmentId!
                self.messCall.senderId = Common.getAppDelegate().loginUser.PatientId!
                self.messCall.receviceId = self.appointment.doctor.DoctorId!
                self.messCall.callId = self.call.CallId!
                self.messCall.isUnread = true
                self.messCall.startAt = Date().millisecondsSince1970
                self.messCall.messageType = 1
                RealmManager.sharedInstance.insert(self.messCall)
            }
        }) { (error) in
        }
    }
    
    func updateTrackingTime() {
        if call.CallId != nil {
            let urlSignUp = "\(API.MAIN_TRACKINGCALLTIME)\(API.TrackingCallTime)"
            let param = ["AppointmentId" : call.AppointmentId,
                         "CallId" : call.CallId,
                         "Type" : "UPDATE"]
            
            WebService.shareInstance.postWebServiceCallWithHeader(urlSignUp, params: param as Any as? [String : Any], isShowLoader: false, success: { (respone) in
                let code = respone["ErrorCode"].intValue
                if code == ERRORCODE.SUCCESS {
                    self.call.parser(respone["Result"])
                    let msg =  WMessage()
                    msg.id = self.messCall.id
                    msg.apntId = self.messCall.apntId
                    msg.senderId = self.messCall.senderId
                    msg.receviceId = self.messCall.receviceId
                    msg.callId = self.messCall.callId
                    msg.startAt = self.messCall.startAt
                    msg.isUnread = true
                    msg.messageType = 1
                    msg.dutation = Int(self.call.Duration!)
                    RealmManager.sharedInstance.update(msg)
                }
            }) { (error) in
            }
        }else{
            startTrackingTime()
        }
    }
    
    func joinMeeting() {
        conversation!.alertDelegate = self
        self.conversationHelper = SfBConversationHelper(conversation: conversation!,
                                                        delegate: self,
                                                        devicesManager: devicesManager!,
                                                        outgoingVideoView: self.myVideoView,
                                                        incomingVideoLayer: self.videoView.layer as! CAEAGLLayer,
                                                        userInfo: [DisplayNameInfo:name!])
        conversation!.addObserver(self, forKeyPath: "canLeave", options: .initial , context: nil)
    }
    
    func startCheckMuteTimer() {
        if checkMuteTimer == nil {
            checkMuteTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startCheckMute), userInfo: nil, repeats: true)
        }
    }
    
    func stopCheckMuteTimer() {
        if checkMuteTimer != nil {
            checkMuteTimer?.invalidate()
            checkMuteTimer = nil
        }
    }
    
    func startCheckMute() {
        if conversationHelper?.conversation.audioService.muted == .muted {
            do {
                try conversationHelper?.conversation.audioService.toggleMute()
                if conversationHelper?.conversation.audioService.muted != .muted {
                    stopCheckMuteTimer()
                }
            } catch {}
        }
    }
    
    
    func startVideoTimer() {
        if selfVideoTimer == nil {
            selfVideoTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.startVideoN), userInfo: nil, repeats: true)
        }
    }
    
    func stopVideoTimer() {
        if selfVideoTimer != nil {
            selfVideoTimer?.invalidate()
            selfVideoTimer = nil
        }
    }
    
    func startVideoN() {
        do{
            try conversationHelper?.conversation.videoService.setPaused(false)
            stopVideoTimer()
//            startCheckMuteTimer()
            myVideoView.isHidden = false
            btEndVideo.setBackgroundImage(UIImage.init(named: "ic_call"), for: .normal)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func startCallTimer() {
        if callTimer == nil {
            callTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCallTime), userInfo: nil, repeats: true)
        }
    }
    
    func stopCallTimer() {
        if callTimer != nil {
            callTimer?.invalidate()
            callTimer = nil
        }
    }
    
    func updateCallTime() {
        duration += 1
        if duration%60 == 0 {
            updateTrackingTime()
        }
        let (_, _, m, s) = duration.second()
        lbCallTime.text = "\("txt_call_time".localized) \((m < 10 ? "0\(m)":"\(m)")):\((s < 10 ? "0\(s)":"\(s)"))"
    }
    
    func updateTextView() {
        if (tvMessage.text.characters.count > 0) {
        }else{
        }
        
        let rows = round( (tvMessage.contentSize.height - tvMessage.textContainerInset.top - tvMessage.textContainerInset.bottom) / (tvMessage.font?.lineHeight)! );
        
        if (rows <= 4) {
            tvMessage.scrollRangeToVisible(NSMakeRange(0, 0))
            var textFrame = tvMessage.frame;
            textFrame.size.height = tvMessage.contentSize.height;
            tvMessage.frame = textFrame;
            ctrHeightTextViewMessage.constant = textFrame.size.height + 17;
        }else{
            ctrHeightTextViewMessage.constant = 53+17*4;
        }
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.dictMessage[self.arrSortedKey.last!]!.count-1, section: self.arrSortedKey.count - 1)
            self.tbMessage.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func sizeOfText(_ text: String,_ font: UIFont,_ width: CGFloat) -> CGSize{
        let attrs:[String : Any] = [NSFontAttributeName : font]
        let attributedText = NSMutableAttributedString(string:text, attributes:attrs)
        let rect = attributedText.boundingRect(with: CGSize.init(width: width, height: 9999), options: .usesLineFragmentOrigin, context: nil)
        return rect.size;
    }
}

extension SfBSpeakerEndpoint: CustomStringConvertible {
    public var description: String {
        switch self {
        case .loudspeaker:
            return "Loudspeaker"
        case .nonLoudspeaker:
            return "Handset"
        }
    }
}

extension SfBAudioServiceMuteState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unmuted:
            return "Unmuted"
        case .muted:
            return "Muted"
        case .unmuting:
            return "Unmuting"
        }
    }
}

extension VideoCallVC: SfBConversationHelperDelegate {
    //call
    func conversationHelper(_ conversationHelper: SfBConversationHelper, didSubscribeTo video: SfBParticipantVideo?) {
//        self.videoView.isHidden = !(video?.isPaused == false)
        
    }
    
    func conversationHelper(_ conversationHelper: SfBConversationHelper, audioService: SfBAudioService, didChangeMuted muted: SfBAudioServiceMuteState) {
        if muted == .muted {
            startCheckMuteTimer()
        }
    }
    
    func conversationHelper(_ conversationHelper: SfBConversationHelper, speaker: SfBSpeaker, didChangeActiveEndpoint endpoint: SfBSpeakerEndpoint) {
        if endpoint == .nonLoudspeaker {
            speaker.activeEndpoint = .loudspeaker
        }
    }
    
    func conversationHelper(_ conversationHelper: SfBConversationHelper, videoService: SfBVideoService, didChangeCanStart canStart: Bool) {
        if (canStart) {
            do{
                try videoService.start()
            }
            catch let error as NSError {
                print(error.localizedDescription)
                
            }
        }
    }
    
    func conversationHelper(_ conversationHelper: SfBConversationHelper, selfVideo video: SfBParticipantVideo, didChangeIsPaused isPaused: Bool) {
        if !isClickEndVideo {
            if isPaused {
                do{
                    try conversationHelper.conversation.videoService.setPaused(false)
//                    startCheckMuteTimer()
                    myVideoView.isHidden = false
                    btEndVideo.setBackgroundImage(UIImage.init(named: "ic_call"), for: .normal)
                } catch let error as NSError {
                    print(error.localizedDescription)
                    startVideoTimer()
                }
            }
        }
    }
    
    func conversationHelper(_ conversationHelper: SfBConversationHelper, conversation: SfBConversation, didChange state: SfBConversationState) {
        if state == .idle {
            if leaveMeetingWithSuccess(conversation) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CompleteCallVC") as! CompleteCallVC
                vc.call = call
                vc.messageCall = messCall
                self.navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
    
    func conversationHelper(_ conversationHelper: SfBConversationHelper, conversationLeave conversation: SfBConversation) {
        if leaveMeetingWithSuccess(conversation) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CompleteCallVC") as! CompleteCallVC
            vc.call = call
            vc.messageCall = messCall
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    //message
    
    func conversationHelper(_ conversationHelper: SfBConversationHelper, chatService: SfBChatService, didChangeCanSendMessage canSendMessage: Bool) {
//        btSendMessage.isEnabled = canSendMessage
    }
    
    func conversationHelper(_ conversationHelper: SfBConversationHelper, didReceiveMessage message: SfBMessageActivityItem) {
        let msg = WMessage()
        msg.id = "Welio-\(UUID().uuidString)"
        msg.apntId = appointment.AppointmentId!
        msg.senderId = appointment.doctor.DoctorId!
        msg.receviceId = Common.getAppDelegate().loginUser.PatientId!
        msg.isUnread = false
        msg.startAt = Date().millisecondsSince1970
        msg.messageType = 0
        msg.message = message.text.replacingOccurrences(of: "\r\n", with: "")
        RealmManager.sharedInstance.insert(msg)
        arrMessage.append(msg)
        createSection()
    }
}

extension VideoCallVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.perform(#selector(updateTextView), with: nil, afterDelay: 0.5)
    }
}

extension VideoCallVC: SfBAlertDelegate {
    func didReceive(_ alert: SfBAlert) {
    }
}

extension VideoCallVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrSortedKey.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dictMessage[arrSortedKey[section]]?.count)!
    }
}

extension VideoCallVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellChat", for: indexPath) as! CellChat
        cell.imBg.image = UIImage(named: "ic_bubble")
        
        let msg = dictMessage[arrSortedKey[indexPath.section]]?[indexPath.row]
        if msg?.senderId == Common.getAppDelegate().loginUser.PatientId {
            cell.lbName.text = "\(Common.getAppDelegate().loginUser.FirstName!) \(Common.getAppDelegate().loginUser.LastName!)"
        }else{
            cell.lbName.text = "\(appointment.doctor.FirstName!) \(appointment.doctor.LastName!)"
        }
        
        cell.lbTime.text = Date.init(msg!.startAt).string("hh:mm a")
        cell.tvMessage.text = msg?.message
        let size = sizeOfText(msg!.message, cell.tvMessage.font!, UIScreen.main.bounds.size.width - 24)
        cell.ctrWidthTvMessage.constant = size.width + 15
        return cell
        //        switch indexPath.section {
        //        case 0:
        //            switch indexPath.row {
        //            case 2:
        //                let cell = tableView.dequeueReusableCell(withIdentifier: "CellCallChat", for: indexPath) as! CellCallChat
        //                cell.lbTime.text = "9:00pm"
        //                cell.lbCall.text = "Call - No answer"
        //                return cell
        //            default:
        //                let cell = tableView.dequeueReusableCell(withIdentifier: "CellChat", for: indexPath) as! CellChat
        //                cell.imBg.image = UIImage(named: "ic_bubble")
        //                cell.tvMessage.text = "Hi! How are you?"
        //                return cell
        //            }
        //        default:
        //            switch indexPath.row {
        //            case 1:
        //                let cell = tableView.dequeueReusableCell(withIdentifier: "CellCallChat", for: indexPath) as! CellCallChat
        //                cell.lbTime.text = "7:00am"
        //                cell.lbCall.text = "Call - Started"
        //                return cell
        //            case 2:
        //                let cell = tableView.dequeueReusableCell(withIdentifier: "CellCallChat", for: indexPath) as! CellCallChat
        //                cell.lbTime.text = "7:05am"
        //                cell.lbCall.text = "Call - Finished 5 minutes"
        //                return cell
        //            default:
        //                let cell = tableView.dequeueReusableCell(withIdentifier: "CellChat", for: indexPath) as! CellChat
        //                cell.imBg.image = UIImage(named: "ic_bubble")
        //                cell.tvMessage.text = "Hola todos, hoy les traigo este vídeo de The Beatles abajo mi canal para que se suscriban y mis redes sociales"
        //                return cell
        //            }
        //        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        view.backgroundColor = UIColor.init(COLOR.colorSection)
        let lbSection = UILabel(frame: view.frame)
        lbSection.textAlignment = .center
        lbSection.textColor = UIColor.white
        lbSection.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(lbSection)
        if NSCalendar.current.isDateInToday(Date.init(arrSortedKey[section])) {
            lbSection.text = "Today"
        }else if NSCalendar.current.isDateInYesterday(Date.init(arrSortedKey[section])) {
            lbSection.text = "Yesterday"
        }else{
            lbSection.text = arrSortedKey[section]
        }
        return view
    }
}
