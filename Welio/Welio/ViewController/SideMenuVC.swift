//
//  SideMenuVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/17/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class SideMenuVC: UIViewController {
    @IBOutlet weak var tbMenu: UITableView!
    
    var arrMenu = ["My Appointments","My profile","Payment details","History","Setting","Sign out"]
    var arrSegues = ["CenterContainment","showProfile","showPayment","showHistory","showSetting"]
    var previousIndex = IndexPath(row: 0, section: 0)
    var arrIcon = [#imageLiteral(resourceName: "ic_apm"),#imageLiteral(resourceName: "ic_my_profile"),#imageLiteral(resourceName: "ic_paypal_de"),#imageLiteral(resourceName: "ic_history"),#imageLiteral(resourceName: "ic_setting"),#imageLiteral(resourceName: "ic_signout")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionShowMenu(_ sender: Any) {
        sideMenuController()?.toggleSidePanel()
    }
}

extension SideMenuVC {
    func initUI() {
        tbMenu.separatorColor = UIColor.clear
        tbMenu.selectRow(at: previousIndex, animated: true, scrollPosition: .top)
    }
    
    func initData() {
        
    }
}

extension SideMenuVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenu.count
    }
}

extension SideMenuVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellMenu", for: indexPath) as! CellMenu
        cell.imIcon.image = arrIcon[indexPath.row]
        cell.lbTitle.text = arrMenu[indexPath.row]
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.init(COLOR.colorSection)
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            Common.showAlert("txt_coming_soon".localized, self)
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.selectRow(at: previousIndex, animated: true, scrollPosition: .top)
        case 5:
            let alert = UIAlertController(title: "app_name".localized, message: "txt_logout_message".localized, preferredStyle: UIAlertControllerStyle.alert)
            let noAction: UIAlertAction = UIAlertAction(title: "txt_no".localized, style: .cancel) { action -> Void in
                alert.dismiss(animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }
            let yesAction: UIAlertAction = UIAlertAction(title: "txt_yes".localized, style: .default) { action -> Void in
                tableView.deselectRow(at: indexPath, animated: true)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                let nav = UINavigationController.init(rootViewController: vc)
                nav.isNavigationBarHidden = true
                Common.removeFromUserdefaults(KEY_USDEFAULT.isLogin)
                Common.getAppDelegate().window?.rootViewController = nav
                Common.getAppDelegate().window?.makeKeyAndVisible()
            }
            alert.addAction(noAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: nil)
        default:
            self.sideMenuController()?.toggleSidePanel()
            self.sideMenuController()?.performSegue(withIdentifier: arrSegues[indexPath.row], sender: nil)
            previousIndex = indexPath
        }
    }
}
