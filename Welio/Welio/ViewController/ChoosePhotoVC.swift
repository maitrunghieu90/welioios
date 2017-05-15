//
//  ChoosePhotoVC.swift
//  Welio
//
//  Created by Hoa on 4/11/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class ChoosePhotoVC: UIViewController {
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var btSkip: UIButton!
    @IBOutlet weak var btPhotoLibrary: UIButton!
    @IBOutlet weak var imvAvatar: UIImageView!
    @IBOutlet weak var btRetake: UIButton!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var btContinute: UIButton!
    @IBOutlet weak var btTakePhoto: UIButton!
    
    var signUpObj : WPatient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initLanguage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func actionTakePhoto(_ sender: Any) {
        if isHasCamera {
            let objImagePicker = UIImagePickerController()
            objImagePicker.delegate = self
            objImagePicker.sourceType = .camera
            self.present(objImagePicker, animated: true, completion: nil)
        }else{
            Common.showAlert("err_camera".localized, self)
        }
    }
    
    @IBAction func actionPhotoLibrary(_ sender: Any) {
        let objImagePicker = UIImagePickerController()
        objImagePicker.delegate = self
        objImagePicker.sourceType = .photoLibrary
        self.present(objImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionSkip(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        vc.signUpObj = self.signUpObj
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func actionRetake(_ sender: Any) {
        imvAvatar.image = UIImage.init(named: "ic_defaultAvatar")
        btRetake.isHidden = true
        lbMessage.text = "\("txt_hi".localized) \(signUpObj.FirstName!), \("txt_look".localized)"
        btContinute.isHidden = true
        btTakePhoto.isHidden = false
    }
    
    @IBAction func actionContinute(_ sender: Any) {
        let url = "\(API.MAIN_PATIENT)\(API.PostPatientImages)"
        WebService.shareInstance.postWebServiceCallWithImage(url, image: imvAvatar.image, params: ["PatientId" : signUpObj.PatientId as AnyObject], isShowLoader: true, success: { (respone) in
            let code = respone["ErrorCode"].intValue
            let data = respone["Result"]
            self.signUpObj.PatientAvatar = (data["PatientAvatar"].string != nil ? data["PatientAvatar"].string : "")
            self.signUpObj.cacheUserDefault()
            Common.getAppDelegate().loginUser = self.signUpObj
            if code == ERRORCODE.SUCCESS {
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                vc.signUpObj = self.signUpObj
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }) { (error) in
            Common.showAlert("err_connect_server".localized, self)
        }
    }
}

extension ChoosePhotoVC {
    func initUI() {
        btRetake.underline()
        btPhotoLibrary.underline()
        btContinute.corner()
    }
    
    func initLanguage() {
        lbMessage.text = "\("txt_hi".localized) \(signUpObj.FirstName!), \("txt_look".localized)"
        lbTitleNav.text = "txt_my_profile".localized
        btSkip.setTitle("txt_skip".localized, for: .normal)
        btPhotoLibrary.setTitle("txt_photo_library".localized, for: .normal)
        btRetake.setTitle("txt_re_take".localized, for: .normal)
        btContinute.setTitle("txt_continue".localized, for: .normal)
    }
}

extension ChoosePhotoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let im = Toucan(image: pickedImage).resize(CGSize.init(width: 300, height: 300), fitMode: Toucan.Resize.FitMode.crop).image
            imvAvatar.image = im
            btRetake.isHidden = false
            lbMessage.text = "\("txt_looking_good".localized) \(signUpObj.FirstName!)!"
            btContinute.isHidden = false
            btTakePhoto.isHidden = true
        }else{
            btRetake.isHidden = true
            btContinute.isHidden = true
            btTakePhoto.isHidden = false
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
