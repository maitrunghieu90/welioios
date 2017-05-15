//
//  WDoctor.swift
//  Welio
//
//  Created by Hoa on 4/15/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import SwiftyJSON

class WDoctor: NSObject {
    var DoctorId: String?
    var Title: String?
    var FirstName: String?
    var LastName: String?
    var Email: String?
    var Phone: String?
    var Office365: String?
    var Actived: Bool?
    var Admin: Bool?
    var Office365TempPassword: String?
    var DoctorAvatar : String?
    
    
    override init() {
        super.init()
    }
    
    func parser(_ data: JSON) {
        self.DoctorId = data["DoctorId"].stringValue
        self.Title = data["Title"].stringValue
        self.FirstName = data["FirstName"].stringValue
        self.LastName = data["LastName"].stringValue
        self.Email = data["Email"].stringValue
        self.Phone = data["Phone"].stringValue
        self.Office365 = data["Office365"].stringValue
        self.Actived = data["Actived"].boolValue
        self.Admin = data["Admin"].boolValue
        self.Office365TempPassword = data["Office365TempPassword"].stringValue
        self.DoctorAvatar = data["DoctorAvatar"].stringValue
    }
}
