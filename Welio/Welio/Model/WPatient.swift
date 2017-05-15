//
//  Wself.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/14/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import SwiftyJSON

class WPatient: NSObject {
    var Actived : Bool?
    var Email : String?
    var FirstName : String?
    var PatientAvatar : String?
    var IsFoalting : Bool?
    var LastName : String?
    var Password : String?
    var PatientId : String?
    var Phone : String?
    var VerifyOTP : String?
    
    override init() {
        super.init()
    }
    
    func parser(_ data: JSON) {
        self.Actived = (data["Actived"].bool != nil ? data["Actived"].boolValue : false)
        self.Email = (data["Email"].string != nil ? data["Email"].string : "")
        self.FirstName = (data["FirstName"].string != nil ? data["FirstName"].string : "")
        self.PatientAvatar = (data["PatientAvatar"].string != nil ? data["PatientAvatar"].string : "")
        self.IsFoalting = (data["IsFoalting"].bool != nil ? data["IsFoalting"].bool : false)
        self.LastName = (data["LastName"].string != nil ? data["LastName"].string : "")
        self.PatientId = (data["PatientId"].string != nil ? data["PatientId"].string : "")
        self.Phone = (data["Phone"].string != nil ? data["Phone"].string : "")
        self.VerifyOTP = (data["VerifyOTP"].string != nil ? data["VerifyOTP"].string : "")
    }
    
    func cacheUserDefault() {
        Common.addToUserDefaults(KEY_USDEFAULT.ActivedLogin, pObject: (self.Actived! ? "yes" : "no"))
        Common.addToUserDefaults(KEY_USDEFAULT.EmailLogin, pObject: self.Email!)
        Common.addToUserDefaults(KEY_USDEFAULT.FirstNameLogin, pObject: self.FirstName!)
        Common.addToUserDefaults(KEY_USDEFAULT.IsFoaltingLogin, pObject: (self.IsFoalting! ? "yes" : "no"))
        Common.addToUserDefaults(KEY_USDEFAULT.LastNameLogin, pObject: self.LastName!)
        Common.addToUserDefaults(KEY_USDEFAULT.PatientIdLogin, pObject: self.PatientId!)
        Common.addToUserDefaults(KEY_USDEFAULT.PhoneLogin, pObject: self.Phone!)
        Common.addToUserDefaults(KEY_USDEFAULT.PatientAvatarLogin, pObject: self.PatientAvatar!)
    }
}
