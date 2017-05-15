//
//  WCall.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 5/4/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import SwiftyJSON

class WCall: NSObject {
    var CallId : String?
    var AppointmentId : String?
    var StartAt : Double?
    var Duration : Double?
    var EndAt : Double?
    var Fee : Double?
    override init() {
        super.init()
    }
    
    func parser(_ data: JSON) {
        self.AppointmentId = data["AppointmentId"].stringValue
        self.CallId = data["CallId"].stringValue
        self.StartAt = data["StartAt"].doubleValue
        self.Duration = data["Duration"].doubleValue
        self.EndAt = data["EndAt"].doubleValue
        self.Fee = data["Fee"].doubleValue
    }
}
