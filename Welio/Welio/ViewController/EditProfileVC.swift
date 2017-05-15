//
//  EditProfileVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/28/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import Kingfisher

class EditProfileVC: UIViewController {
    @IBOutlet weak var tfFirstName: MKTextField!
    @IBOutlet weak var tfLastName: MKTextField!
    @IBOutlet weak var tfPhone: MKTextField!
    @IBOutlet weak var tfMail: MKTextField!
    @IBOutlet weak var ctrBottomView: NSLayoutConstraint!
    @IBOutlet weak var mScrollView: UIScrollView!
    @IBOutlet weak var imvAvatar: UIImageView!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var lbTitleNav: UILabel!
    @IBOutlet weak var btSave: UIButton!
    @IBOutlet weak var btChangePhoto: UIButton!
    @IBOutlet weak var lbMydetail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionChooseAvatar(_ sender: Any) {
        let actSheet: UIAlertController = UIAlertController(title: "Welio", message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actSheet.addAction(cancelActionButton)
        
        let takePhoto = UIAlertAction(title: "Take a photo", style: .default)
        { _ in
            if isHasCamera {
                let objImagePicker = UIImagePickerController()
                objImagePicker.delegate = self
                objImagePicker.sourceType = .camera
                self.present(objImagePicker, animated: true, completion: nil)
            }else{
                Common.showAlert("err_camera".localized, self)
            }
        }
        actSheet.addAction(takePhoto)
        
        let choosePhoto = UIAlertAction(title: "Choose from gallery", style: .default)
        { _ in
            let objImagePicker = UIImagePickerController()
            objImagePicker.delegate = self
            objImagePicker.sourceType = .photoLibrary
            self.present(objImagePicker, animated: true, completion: nil)
        }
        actSheet.addAction(choosePhoto)
        self.present(actSheet, animated: true, completion: nil)
    }
    
    @IBAction func actionSave(_ sender: Any) {
        self.view.endEditing(true)
        if valid() {
                let urlSignUp = "\(API.MAIN_PATIENT)\(API.EditPatient)"
                let param = ["FirstName" : self.tfFirstName.strTrim(),
                             "LastName" : self.tfLastName.strTrim(),
                             "Phone" : self.tfPhone.strTrim(),
                             "Email" : self.tfMail.strTrim(),
                             "PatientId" : Common.getFromUserDefaults(KEY_USDEFAULT.PatientIdLogin)]
            WebService.shareInstance.postWebServiceCallWithImageHeader(urlSignUp, image: imvAvatar.image, params: param as [String : AnyObject]?, isShowLoader: true, success: { (respone) in
                let code = respone["ErrorCode"].intValue
                if code == ERRORCODE.SUCCESS {
                    let dictPatient = respone["Result"]
                    let patient = WPatient()
                    patient.parser(dictPatient)
                    patient.cacheUserDefault()
                    Common.getAppDelegate().loginUser = patient
                    
                    let alertController = UIAlertController(title: "app_name".localized, message: "txt_edited_profile_successfully".localized, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction: UIAlertAction = UIAlertAction(title: "txt_ok".localized, style: .cancel) { action -> Void in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }else if code == ERRORCODE.FAILURE_PHONE_EXISTED {
                }else if code == ERRORCODE.FAILURE_EMAIL_EXISTED {
                }else{
                    Common.showAlert("err_connect_server".localized, self)
                }
            }, failure: { (error) in
                Common.showAlert("err_connect_server".localized, self)
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
extension EditProfileVC {
    func configureMKTextField() {
        tfFirstName.configureTextField()
        tfPhone.configureTextField()
        tfMail.configureTextField()
        tfLastName.configureTextField()
    }
    
    func initUI() {
        configureMKTextField()
        SideMenuRootController.panningEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKB))
        mScrollView.addGestureRecognizer(tap)
        tfFirstName.text = Common.getAppDelegate().loginUser.FirstName
        tfLastName.text = Common.getAppDelegate().loginUser.LastName
        tfPhone.text = Common.getAppDelegate().loginUser.Phone
        tfMail.text = Common.getAppDelegate().loginUser.Email
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
    
    func initData() {
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func hideKB() {
        self.view.endEditing(true)
    }
    
    func keyboardWillAppear(_: NSNotification){
        ctrBottomView.constant = 300
        if tfFirstName.isEditing || tfLastName.isEditing {
            mScrollView.contentOffset.y = 100
        }else if tfMail.isEditing {
            mScrollView.contentOffset.y = 150
        }else if tfPhone.isEditing {
            mScrollView.contentOffset.y = 180
        }
    }
    
    func keyboardWillDisappear(_: NSNotification){
        ctrBottomView.constant = 0
        mScrollView.contentOffset.y = 0
    }
    
    func valid() -> Bool {
        if tfFirstName.isValidNotEmty() {
            if tfLastName.isValidNotEmty() {
                if tfMail.isValidNotEmty() {
                    if tfMail.isValidEmail() {
                        if tfPhone.isValidNotEmty() {
                            return true
                        }else{
                            Common.showAlert("txt_mobile_validate".localized, self)
                            return false
                        }
                    } else {
                        Common.showAlert("txt_email_invalid".localized, self)
                        return false
                    }
                }else{
                    Common.showAlert("txt_email_validate".localized, self)
                    return false
                }
            }else{
                Common.showAlert("txt_lastname_validate".localized, self)
                return false
            }
        }else{
            Common.showAlert("txt_firstname_validate".localized, self)
            return false
        }
    }
}

extension EditProfileVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfFirstName {
            tfLastName.becomeFirstResponder()
        } else if(textField == tfLastName){
            tfMail.becomeFirstResponder()
        } else if(textField == tfMail){
            tfPhone.becomeFirstResponder()
        } else{
            actionSave((Any).self)
        }
        return true
    }
}

extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let im = Toucan(image: pickedImage).resize(CGSize.init(width: 300, height: 300), fitMode: Toucan.Resize.FitMode.crop).image
            imvAvatar.image = im
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
