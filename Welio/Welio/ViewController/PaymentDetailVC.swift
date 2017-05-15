//
//  PaymentDetailVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/27/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class PaymentDetailVC: UIViewController {
    @IBOutlet weak var btChange: UIButton!
    @IBOutlet weak var btBack: UIButton!
    @IBOutlet weak var btMenu: UIButton!
    @IBOutlet weak var btHome: UIButton!
    @IBOutlet weak var btContinue: UIButton!
    @IBOutlet weak var viewDetail: UIView!
    @IBOutlet weak var lbTitleNav: UILabel!
    
    var patient = WPatient()
    var isFromMenu = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionChange(_ sender: Any) {
    }
    
    @IBAction func actionHome(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppointmentVC") as! AppointmentVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionShowMenu(_ sender: Any) {
        sideMenuController()?.toggleSidePanel()
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionContinue(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC") as! VerifyCodeVC
        vc.patient = patient
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PaymentDetailVC {
    func initUI() {
        btChange.corner()
        viewDetail.corner(10)
        viewDetail.bolder(1)
        self.navigationController?.isNavigationBarHidden = true
        if isFromMenu {
            btBack.isHidden = true
            btContinue.isHidden = true
            btHome.isHidden = false
            btMenu.isHidden = false
        }else{
            btBack.isHidden = false
            btContinue.isHidden = false
            btHome.isHidden = true
            btMenu.isHidden = true
        }
    }
}
