//
//  MyProfileVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/28/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import Kingfisher

class MyProfileVC: UIViewController {
    @IBOutlet weak var lbFullName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var lbPhone: UILabel!
    @IBOutlet weak var imvAvatar: UIImageView!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var btEdit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionHome(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppointmentVC") as! AppointmentVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionShowMenu(_ sender: Any) {
        sideMenuController()?.toggleSidePanel()
    }
    
    @IBAction func actionEditProfile(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MyProfileVC {
    func initUI() {
        self.navigationController?.isNavigationBarHidden = true
        SideMenuRootController.panningEnabled = true
        lbFullName.text = "\(Common.getAppDelegate().loginUser.FirstName!) \(Common.getAppDelegate().loginUser.LastName!)"
        lbPhone.text = Common.getAppDelegate().loginUser.Phone
        lbEmail.text = Common.getAppDelegate().loginUser.Email
        if Common.getAppDelegate().loginUser.PatientAvatar != nil {
            if (Common.getAppDelegate().loginUser.PatientAvatar?.characters.count)! > 0{
                let url = URL(string: Common.getAppDelegate().loginUser.PatientAvatar!)
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
}
