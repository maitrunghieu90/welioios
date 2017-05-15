//
//  PaypalVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/27/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class PaypalVC: UIViewController {
    @IBOutlet weak var btTerm: UIButton!
    @IBOutlet weak var btPaypal: UIButton!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var lbTitleChoose: UILabel!
    @IBOutlet weak var lbTitleCharged: UILabel!
    @IBOutlet weak var lbAgreeTerm: UILabel!
    
    var patient = WPatient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionTerm(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsVC") as! TermsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionPaypal(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentDetailVC") as! PaymentDetailVC
        vc.patient = self.patient
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PaypalVC {
    func initUI() {
        btTerm.corner(5)
        btTerm.bolder(1)
        btPaypal.corner()
        btPaypal.bolder(1)
    }
    
    func initLanguage() {
        lbTitleNav.text = "txt_add_paypal"
    }
}
