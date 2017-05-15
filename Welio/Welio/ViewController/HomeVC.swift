//
//  HomeVC.swift
//  Welio
//
//  Created by Hoa on 4/11/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    @IBOutlet weak var btSignUp: UIButton!
    @IBOutlet weak var btSignIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initLanguage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goSignUp(_ sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ProfileSignUpVC") as! ProfileSignUpVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionSignIn(_ sender: Any) {
        if Common.getFromUserDefaults(KEY_USDEFAULT.PIN) != nil {
            var check = false
            
            for vc in (self.navigationController?.viewControllers)! {
                if vc is EnterPINVC {
                    check = true
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
            if !check {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterPINVC") as! EnterPINVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            var check = false
            
            for vc in (self.navigationController?.viewControllers)! {
                if vc is SignInVC {
                    check = true
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
            if !check {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }

}

extension HomeVC {
    func initUI() {
        self.navigationController?.isNavigationBarHidden = true
        btSignUp.bolderc(UIColor.white)
    }
    
    func initLanguage() {
        btSignIn.setTitle("txt_sign_in".localized, for: .normal)
        btSignUp.setTitle("txt_new_user".localized, for: .normal)
    }
}
