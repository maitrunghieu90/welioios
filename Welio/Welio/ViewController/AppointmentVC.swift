//
//  AppointmentVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/13/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class AppointmentVC: UIViewController {
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var viewNoAppointment: UIView!
    @IBOutlet weak var viewNumber: UIView!
    @IBOutlet weak var tbAppointment: UITableView!
    
    var start = 0
    var limit = 10
    var arrayData = [WAppointment]()
    var topRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initLanguage()
        getAppointment(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SideMenuRootController.panningEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionShowMenu(_ sender: Any) {
        sideMenuController()?.toggleSidePanel()
    }
    
    @IBAction func actionRefreshData(_ sender: Any) {
        getAppointment(true)
    }
    
}

extension AppointmentVC {
    func initUI() {
        self.navigationController?.isNavigationBarHidden = true
        tbAppointment.separatorColor = UIColor.clear
        viewNumber.corner()
        viewNumber.isHidden = true
        let refreshControl = UIRefreshControl()
        refreshControl.triggerVerticalOffset = 50
        refreshControl.addTarget(self, action: #selector(loadmore), for: .valueChanged)
        tbAppointment.bottomRefreshControl = refreshControl
        topRefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tbAppointment.addSubview(topRefreshControl)
    }
    
    func loadmore(){
        start = start + limit;
        getAppointment(false)
    }
    
    func refresh(){
        start = 0;
        getAppointment(false)
    }
    
    func initLanguage() {
        lbTitleNav.text = "txt_my_appointments".localized
        lbTitle.text = "txt_no_appointment".localized
        lbMessage.text = "txt_would_make_appointment".localized
    }
    
    func getAppointment(_ isShowLoader : Bool) {
        let urlSignIn = "\(API.MAIN_APPOINTMENT)\(API.GetMyAppointmentsOfPatient)"
        let param = ["Type" : "1,2",
                     "PatientId" : Common.getAppDelegate().loginUser.PatientId,
                     "Start" : "\(start)",
                     "Limit" : "\(limit)",
                     "DateNowGMT0":Common.dateGMT0()]
        print(param)
        if !WebService.shareInstance.isConnectedToNetwork() {
            if topRefreshControl.isRefreshing {
                self.tbAppointment.setContentOffset(CGPoint.zero, animated: true)
            }
            self.topRefreshControl.endRefreshing()
            self.tbAppointment.bottomRefreshControl?.endRefreshing()
            self.tbAppointment.reloadData()
        }
        
        WebService.shareInstance.postWebServiceCallWithHeader(urlSignIn, params: param as [String : AnyObject]?, isShowLoader: isShowLoader, success: { (respone) in
            let code = respone["ErrorCode"].intValue
            let arrAppointment = respone["Result"].arrayValue
            
            if code == 0 {
                if arrAppointment.count > 0{
                    if self.start == 0 {
                        self.arrayData.removeAll()
                    }
                    for dictAppointment in arrAppointment{
                        let obj = WAppointment()
                        obj.parser(dictAppointment)
                        self.arrayData.append(obj)
                    }
                }
            }
            
            if self.arrayData.count > 0{
                self.viewNoAppointment.isHidden = true
            }else{
                self.viewNoAppointment.isHidden = false
            }
            self.topRefreshControl.endRefreshing()
            self.tbAppointment.bottomRefreshControl?.endRefreshing()
            self.tbAppointment.reloadData()
        }) { (error) in
            Common.showAlert("\("err_connect_server".localized) Error code: \((error as NSError).code)", self)
        }
    }
}

extension AppointmentVC : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayData.count
    }
}

extension AppointmentVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellAppointment", for: indexPath) as! CellAppointment
        
        let obj = arrayData[indexPath.row] as WAppointment
        
        cell.lbName.text = "Dr. \(obj.doctor.FirstName!) \(obj.doctor.LastName!)"
        cell.lbNumber.corner()
        cell.viewNumber.isHidden = true
        
        let date = Date(timeIntervalSince1970: obj.ExpectedStartDateTime!)

        cell.lbDay.text = date.string("EEE")
        cell.lbDate.text = "\(date.string("dd"))\(date.string("dd").formatDay())"
        cell.lbMonth.text = date.string("MMM")
        if obj.IsCarer! {
            cell.lbPatient.text = "\(obj.PatientFirstName!) \(obj.PatientLastName!)"
        }else{
            cell.lbPatient.text = "\(Common.getAppDelegate().loginUser.FirstName!) \(Common.getAppDelegate().loginUser.LastName!)"
        }
        
        let att = NSMutableAttributedString()
        att.append(NSMutableAttributedString().changeFont(text: date.string("hh:mm"), font: UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium), fontColor: UIColor.black))
        att.append(NSMutableAttributedString().changeFont(text: date.string("a").lowercased(), font: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium), fontColor: UIColor.black))
        att.append(NSMutableAttributedString().changeFont(text: " for ", font: UIFont.systemFont(ofSize: 15), fontColor: UIColor.lightGray))
        att.append(NSMutableAttributedString().changeFont(text: obj.ExpectedDuration!, font: UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium), fontColor: UIColor.black))
        att.append(NSMutableAttributedString().changeFont(text: "m", font: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium), fontColor: UIColor.black))
        cell.lbTime.attributedText = att
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppointmentDetailVC") as! AppointmentDetailVC
        vc.appointment = arrayData[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellDisplay = cell as! CellAppointment
        cellDisplay.lbName.restartLabel()
    }
}
