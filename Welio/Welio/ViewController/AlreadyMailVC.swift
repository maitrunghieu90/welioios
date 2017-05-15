//
//  AlreadyMailVC.swift
//  Welio
//
//  Created by Hoa on 4/11/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class AlreadyMailVC: UIViewController {
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var btSignIn: UIButton!

    var strMail: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initLanguage()
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionSignIn(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        vc.strExistMail = strMail
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AlreadyMailVC {
    func initUI() {
        btSignIn.corner()
        lbEmail.text = strMail
    }
    
    func initLanguage() {
        lbTitleNav.text = "txt_your_profile".localized
        lbTitle.text = "txt_email_already".localized
        btSignIn.setTitle("txt_sign_in_email".localized, for: .normal)
    }
}
