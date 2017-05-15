//
//  WClinic.swift
//  Welio
//
//  Created by Hoa on 4/15/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import SwiftyJSON

class WClinic: NSObject {
    var ClinicId: String?
    var ClinicName: String?
    var Street1: String?
    var Street2: String?
    var State: String?
    var PostCode: String?
    var Phone: String?
    var Actived: Bool?
    var ClinicEmail: String?
    
    override init() {
        super.init()
    }
    
    func parser(_ data: JSON) {
        self.ClinicId = data["ClinicId"].stringValue
        self.ClinicName = data["ClinicName"].stringValue
        self.Street1 = data["Street1"].stringValue
        self.Street2 = data["Street2"].stringValue
        self.State = data["State"].stringValue
        self.PostCode = data["PostCode"].stringValue
        self.Phone = data["Phone"].stringValue
        self.Actived = data["Actived"].boolValue
        self.ClinicEmail = data["ClinicEmail"].stringValue
    }
}
