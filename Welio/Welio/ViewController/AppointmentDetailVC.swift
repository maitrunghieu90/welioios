//
//  AppointmentDetailVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/13/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import AVFoundation

class AppointmentDetailVC: UIViewController {
    @IBOutlet weak var lbTabMessage: UILabel!
    @IBOutlet weak var lbTabAppointment: UILabel!
    @IBOutlet weak var lbTitleCountdown: UILabel!
    @IBOutlet weak var lbTitleDial: UILabel!
    @IBOutlet weak var lbTitlePhone: UILabel!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbPatient: UILabel!
    @IBOutlet weak var lbDoctor: UILabel!
    @IBOutlet weak var lbMessNumber: UILabel!
    @IBOutlet weak var viewCountDown: UIView!
    @IBOutlet weak var viewCall: UIView!
    @IBOutlet weak var viewDial: UIView!
    @IBOutlet weak var lbNotifiStatus: UILabel!
    @IBOutlet weak var viewAppointmentClose: UIView!
    @IBOutlet weak var ctrTopViewDetail: NSLayoutConstraint!
    @IBOutlet weak var btDial: UIButton!
    @IBOutlet weak var lbCountdown: UILabel!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var viewDetail: UIView!
    @IBOutlet weak var btPhoneNumber: UIButton!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbMoney: UILabel!
    @IBOutlet weak var viewMessageShow: UIView!
    @IBOutlet weak var viewDetailShow: UIView!
    @IBOutlet weak var tbChat: UITableView!
    @IBOutlet weak var viewNoMessage: UIView!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbStartTime: UILabel!
    @IBOutlet weak var lbDuration: UILabel!
    @IBOutlet weak var lbFee: UILabel!
    @IBOutlet weak var ctrHeightTitle: NSLayoutConstraint!
    
    var appointment = WAppointment()
    var timer : Timer?
    var dictMessage = [String : [WMessage]]()
    var arrMessage = [WMessage]()
    var arrSortedKey = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
        getDetailAppointment()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        stopTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionShowMessage(_ sender: Any) {
        viewMessage.backgroundColor = navColor
        viewDetail.backgroundColor = grayBgColor
        viewMessageShow.isHidden = false
        viewDetailShow.isHidden = true
    }
    
    @IBAction func actionShowDetail(_ sender: Any) {
        viewMessage.backgroundColor = grayBgColor
        viewDetail.backgroundColor = navColor
        viewMessageShow.isHidden = true
        viewDetailShow.isHidden = false
    }
    
    @IBAction func actionGoHome(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
//        var check = false
//        
//        for vc in (self.navigationController?.viewControllers)! {
//            if vc is AppointmentVC {
//                check = true
//                self .navigationController?.popToViewController(vc, animated: true)
//            }
//        }
//        if !check {
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppointmentVC") as! AppointmentVC
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        
    }
    
    @IBAction func actionCall(_ sender: Any) {
        if WebService.shareInstance.isConnectedToNetwork() {
            if checkMicroPhone() {
                checkCamera()
            }else{
                showAlertSetting()
            }
        }else{
            Common.showAlert("txt_check_connect".localized, self)
        }
    }
    
    @IBAction func actionCallClinic(_ sender: Any) {
        let alert = UIAlertController(title: "app_name".localized, message: "\("txt_call_clinic".localized) \(appointment.clinic.Phone!)?", preferredStyle: UIAlertControllerStyle.alert)
        let noAction: UIAlertAction = UIAlertAction(title: "txt_no".localized, style: .cancel) { action -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        let yesAction: UIAlertAction = UIAlertAction(title: "txt_yes".localized, style: .default) { action -> Void in
            if (self.appointment.clinic.Phone?.characters.count)! > 0 {
                let number = URL(string: "telprompt://" + self.appointment.clinic.Phone!)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(number!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(number!)
                }
            }
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension AppointmentDetailVC {
    func checkMicroPhone() -> Bool{
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            print("Permission granted")
            return true
        case AVAudioSessionRecordPermission.denied:
            print("Pemission denied")
            return false
        case AVAudioSessionRecordPermission.undetermined:
            print("Request permission here")
            return false
        default:
            return false
        }
    }
    
    func checkCamera(){
        
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { response in
            if response {
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CallVC") as! CallVC
                    vc.appointment = self.appointment
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                self.showAlertSetting()
            }
        }
    }
    
    func showAlertSetting() {
        let alertController = UIAlertController (title: "Welio", message: "Allow Welio to access your Camera/Microphone to make the call?", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            Common.goSettings()
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func initData() {
        loadDataMessage()
        createSection()
    }
    
    func loadDataMessage() {
        arrMessage = RealmManager.sharedInstance.getAllCallLog(appointment.AppointmentId!)
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
            arrSortedKey = dictMessage.sortedKeys(<)
            viewNoMessage.isHidden = true
            tbChat.reloadData()
        }else{
            viewNoMessage.isHidden = false
        }
    }
    
    func initUI() {
        btPhoneNumber.corner()
        lbMoney.corner(5)
        btDial.corner()
        lbMessNumber.corner()
        lbMessNumber.isHidden = true
        fillData()
        SideMenuRootController.panningEnabled = false
        tbChat.bounces = false
    }
    
    func initLanguage() {
        lbTitle.text = "".localized
        lbTitleNav.text = "".localized
    }
    
    func fillData() {
        lbDoctor.text = "Dr. \(appointment.doctor.FirstName!) \(appointment.doctor.LastName!)"
        if appointment.IsCarer! {
            lbPatient.text = "\(appointment.PatientFirstName!) \(appointment.PatientLastName!)"
        }else{
            lbPatient.text = "\(Common.getAppDelegate().loginUser.FirstName!) \(Common.getAppDelegate().loginUser.LastName!)"
        }
        var date = Date(timeIntervalSince1970: appointment.ExpectedStartDateTime!)
        
        lbDate.text = "\(date.string("EEEE")), \(date.string("dd"))\(date.string("dd").formatDay()) \(date.string("MMMM yyyy"))"
        if (appointment.ExpectedFee?.characters.count)! > 0 {
            lbMoney.text = "$\(appointment.ExpectedFee!)*"
        }else{
            lbMoney.text = "$22*"
        }
        let att = NSMutableAttributedString()
        if appointment.ActualDuration != nil && (appointment.ActualDuration?.characters.count)! > 0 && Int(appointment.ActualDuration!)! > 0 && appointment.Status != "3"{
            date = Date(timeIntervalSince1970: Double(appointment.ActualStartDateTime!)!)
            lbMoney.text = "$\(appointment.ActualFee!)"
            att.append(NSMutableAttributedString().changeFont(text: date.string("hh:mm"), font: UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium), fontColor: UIColor.black))
            att.append(NSMutableAttributedString().changeFont(text: date.string("a").lowercased(), font: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium), fontColor: UIColor.black))
            att.append(NSMutableAttributedString().changeFont(text: " for ", font: UIFont.systemFont(ofSize: 15), fontColor: UIColor.lightGray))
            att.append(stringTime(Int(appointment.ActualDuration!)!))
            lbTitle.isHidden = true
            ctrHeightTitle.constant = 1
        }else{
            att.append(NSMutableAttributedString().changeFont(text: date.string("hh:mm"), font: UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium), fontColor: UIColor.black))
            att.append(NSMutableAttributedString().changeFont(text: date.string("a").lowercased(), font: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium), fontColor: UIColor.black))
            att.append(NSMutableAttributedString().changeFont(text: " for ", font: UIFont.systemFont(ofSize: 15), fontColor: UIColor.lightGray))
            att.append(NSMutableAttributedString().changeFont(text: appointment.ExpectedDuration!, font: UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium), fontColor: UIColor.black))
            att.append(NSMutableAttributedString().changeFont(text: "m", font: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium), fontColor: UIColor.black))
            lbTitle.isHidden = false
            ctrHeightTitle.constant = 15
        }
        
        lbTime.attributedText = att
        
        
        
        btPhoneNumber.setTitle(appointment.clinic.Phone, for: .normal)
        lbTitlePhone.text = "\("txt_would_like_plz_contact".localized) \(appointment.clinic.ClinicName!) \("txt_clinic_on".localized)"
        
        
        
        if appointment.Status == "3" {
            ctrTopViewDetail.constant = 40
            if appointment.ActualDuration != nil && (appointment.ActualDuration?.characters.count)! > 0 && Int(appointment.ActualDuration!)! > 0{
                lbStatus.text = "Complete"
                lbFee.text = "$\(appointment.ActualFee!)"
                lbDuration.text = "-"
                let time = Int(appointment.ActualStartDateTime!)
                
                let att = NSMutableAttributedString()
                att.append(NSMutableAttributedString().changeFont(text: Date.init(time!).string("hh:mm"), font: UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium), fontColor: UIColor.black))
                att.append(NSMutableAttributedString().changeFont(text: Date.init(time!).string("a").lowercased(), font: UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium), fontColor: UIColor.black))
                lbStartTime.attributedText = att
                lbDuration.attributedText = stringTime(Int(appointment.ActualDuration!)!)
            }else{
                lbStatus.text = "Complete"
                lbFee.text = "$\(appointment.ActualFee!)"
                lbDuration.text = "-"
                lbStartTime.text = "-"
            }
        }else{
            countDown()
            startTimer()
        }
    }
    
    func stringTime(_ duration: Int) -> NSMutableAttributedString{
        let attCountdown = NSMutableAttributedString()
        let (day, h, m, s) = duration.second()
        print("\(day), \(h), \(m), \(s)")
        
        if day > 0 {
            if day > 1 {
                attCountdown.append(NSMutableAttributedString().changeFont(text: "\(day)", font: UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium), fontColor: UIColor.black))
                attCountdown.append(NSMutableAttributedString().changeFont(text: "days", font: UIFont.systemFont(ofSize: 13, weight: UIFontWeightBold), fontColor: UIColor.black))
            }else{
                attCountdown.append(NSMutableAttributedString().changeFont(text: "\(day)", font: UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium), fontColor: UIColor.black))
                attCountdown.append(NSMutableAttributedString().changeFont(text: "day", font: UIFont.systemFont(ofSize: 13, weight: UIFontWeightBold), fontColor: UIColor.black))
            }
        }
        if h > 0{
            attCountdown.append(NSMutableAttributedString().changeFont(text: "\(h)", font: UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium), fontColor: UIColor.black))
            attCountdown.append(NSMutableAttributedString().changeFont(text: "h", font: UIFont.systemFont(ofSize: 13, weight: UIFontWeightBold), fontColor: UIColor.black))
        }
        if m > 0{
            attCountdown.append(NSMutableAttributedString().changeFont(text: "\(m)", font: UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium), fontColor: UIColor.black))
            attCountdown.append(NSMutableAttributedString().changeFont(text: "m", font: UIFont.systemFont(ofSize: 13, weight: UIFontWeightBold), fontColor: UIColor.black))
        }
        if s > 0{
            attCountdown.append(NSMutableAttributedString().changeFont(text: "\(s)", font: UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium), fontColor: UIColor.black))
            attCountdown.append(NSMutableAttributedString().changeFont(text: "s", font: UIFont.systemFont(ofSize: 13, weight: UIFontWeightBold), fontColor: UIColor.black))
        }
        return attCountdown
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func countDown(){
        let currentTime = NSDate().timeIntervalSince1970
        let attCountdown = NSMutableAttributedString()
        if appointment.ExpectedStartDateTime! > currentTime {
            showDetailCountDown()
            let (day, h, m, s) = Int(appointment.ExpectedStartDateTime! - currentTime).second()
            print("\(day), \(h), \(m), \(s)")
            
            if day > 0 {
                if day > 1 {
                    attCountdown.append(NSMutableAttributedString().changeFont(text: "\(day)", font: UIFont.systemFont(ofSize: 85, weight: UIFontWeightMedium), fontColor: UIColor.black))
                    attCountdown.append(NSMutableAttributedString().changeFont(text: "days", font: UIFont.systemFont(ofSize: 25, weight: UIFontWeightBold), fontColor: UIColor.black))
                }else{
                    attCountdown.append(NSMutableAttributedString().changeFont(text: "\(day)", font: UIFont.systemFont(ofSize: 85, weight: UIFontWeightMedium), fontColor: UIColor.black))
                    attCountdown.append(NSMutableAttributedString().changeFont(text: "day", font: UIFont.systemFont(ofSize: 25, weight: UIFontWeightBold), fontColor: UIColor.black))
                }
                
            }else if h > 0{
                attCountdown.append(NSMutableAttributedString().changeFont(text: "\(h)", font: UIFont.systemFont(ofSize: 85, weight: UIFontWeightMedium), fontColor: UIColor.black))
                attCountdown.append(NSMutableAttributedString().changeFont(text: "h", font: UIFont.systemFont(ofSize: 25, weight: UIFontWeightBold), fontColor: UIColor.black))
            }else if m > 0{
                attCountdown.append(NSMutableAttributedString().changeFont(text: "\(m)", font: UIFont.systemFont(ofSize: 85, weight: UIFontWeightMedium), fontColor: UIColor.black))
                attCountdown.append(NSMutableAttributedString().changeFont(text: "m", font: UIFont.systemFont(ofSize: 25, weight: UIFontWeightBold), fontColor: UIColor.black))
            }else if s > 0{
                attCountdown.append(NSMutableAttributedString().changeFont(text: "1", font: UIFont.systemFont(ofSize: 85, weight: UIFontWeightMedium), fontColor: UIColor.black))
                attCountdown.append(NSMutableAttributedString().changeFont(text: "m", font: UIFont.systemFont(ofSize: 25, weight: UIFontWeightBold), fontColor: UIColor.black))
            }else{
                stopTimer()
                showDetailDial()
            }
        }else{
            stopTimer()
            showDetailDial()
        }
        lbCountdown.attributedText = attCountdown
    }
    
    func showDetailCountDown() {
        lbNotifiStatus.isHidden = true
        viewCall.isHidden = false
        viewCountDown.isHidden = false
        viewDial.isHidden = true
        viewAppointmentClose.isHidden = true
        ctrTopViewDetail.constant = 0
        lbTitlePhone.text = "\("txt_would_like_plz_contact".localized) \(appointment.clinic.ClinicName!) \("txt_clinic_on".localized)"
    }
    
    func showDetailDial() {
        lbNotifiStatus.isHidden = true
        viewCall.isHidden = false
        viewCountDown.isHidden = true
        viewDial.isHidden = false
        viewAppointmentClose.isHidden = true
        ctrTopViewDetail.constant = 0
        lbTitlePhone.text = "\("txt_there_is_plz_contact".localized) \(appointment.clinic.ClinicName!) \("txt_clinic_on".localized)"
    }
    
    func showAppointmentClose() {
        lbNotifiStatus.isHidden = false
        viewCall.isHidden = true
        viewCountDown.isHidden = true
        viewDial.isHidden = true
        viewAppointmentClose.isHidden = false
        ctrTopViewDetail.constant = 40
    }
    
    func getDetailAppointment() {
        let urlSignIn = "\(API.MAIN_APPOINTMENT)\(API.GetMyAppointmentsOfPatientDetailt)/\(appointment.AppointmentId!)"
        
        WebService.shareInstance.getWebServiceCallWithHeader(urlSignIn, params: nil, isShowLoader: false, success: { (respone) in
            let code = respone["ErrorCode"].intValue
            if code == 0 {
                self.appointment.parser(respone["Result"])
                self.fillData()
            }
        }) { (error) in
            Common.showAlert("err_connect_server".localized, self)
        }
    }
    
    func sizeOfText(_ text: String,_ font: UIFont,_ width: CGFloat) -> CGSize{
        let attrs:[String : Any] = [NSFontAttributeName : font]
        let attributedText = NSMutableAttributedString(string:text, attributes:attrs)
        let rect = attributedText.boundingRect(with: CGSize.init(width: width, height: 9999), options: .usesLineFragmentOrigin, context: nil)
        return rect.size;
    }
}

extension AppointmentDetailVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrSortedKey.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dictMessage[arrSortedKey[section]]?.count)!
    }
}

extension AppointmentDetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellCallChat", for: indexPath) as! CellCallChat
        let msg = dictMessage[arrSortedKey[indexPath.section]]?[indexPath.row]
        let (_, h, m, s) = Int((msg?.dutation)!).second()
        var strDuration = ""
        
        if h > 0 && s > 0 && m > 0{
            strDuration = "\(h)h\(m)m\(s)s"
        }else if m > 0 && s > 0 {
            strDuration = "\(m)m\(s)s"
        }else if s > 0 {
            strDuration = "\(s)s"
        }else{
            strDuration = "0s"
        }
        if (msg?.endAt)! > 0 {
            cell.lbCall.text = "Call - Started at \(Date.init(msg!.startAt).string("hh:mm a")) and Finished at \(Date.init(msg!.endAt).string("hh:mm a")), \(strDuration)"
        }else{
            cell.lbCall.text = "Call - Started at \(Date.init(msg!.startAt).string("hh:mm a")) for \(strDuration)"
        }
        
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "CellChat", for: indexPath) as! CellChat
        //        cell.imBg.image = UIImage(named: "ic_bubble")
        //
        //        let msg = dictMessage[arrSortedKey[indexPath.section]]?[indexPath.row]
        //        if msg?.senderId == Common.getAppDelegate().loginUser.PatientId {
        //            cell.lbName.text = "\(Common.getAppDelegate().loginUser.FirstName!) \(Common.getAppDelegate().loginUser.LastName!)"
        //        }else{
        //            cell.lbName.text = "\(appointment.doctor.FirstName!) \(appointment.doctor.LastName!)"
        //        }
        //
        //        cell.lbTime.text = Date.init(msg!.startAt).string("hh:mm a")
        //        cell.tvMessage.text = msg?.message
        //        let size = sizeOfText(msg!.message, cell.tvMessage.font!, UIScreen.main.bounds.size.width - 24)
        //        cell.ctrWidthTvMessage.constant = size.width + 15
        return cell
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
