//
//  WAppointment.swift
//  Welio
//
//  Created by Hoa on 4/15/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import SwiftyJSON

class WAppointment: NSObject {
    var AppointmentId: String?
    var PatientFirstName: String?
    var PatientLastName: String?
    var IsCarer: Bool?
    var ExpectedDuration: String?
    var ExpectedStartDateTime: Double?
    var ExpectedFee: String?
    var ActualDuration: String?
    var ActualStartDateTime: String?
    var ActualFee: String?
    var JoinMettingUrl: String?
    var Status: String?
    var MeetingId: String?
    var MeetingUri: String?
    var doctor = WDoctor()
    var clinic = WClinic()
    
    override init() {
        super.init()
    }
    
    func parser(_ data: JSON) {
        self.AppointmentId = data["AppointmentId"].stringValue
        self.PatientFirstName = data["PatientFirstName"].stringValue
        self.PatientLastName = data["PatientLastName"].stringValue
        self.IsCarer = data["IsCarer"].boolValue
        self.ExpectedDuration = data["ExpectedDuration"].stringValue
        self.ExpectedStartDateTime = data["ExpectedStartDateTime"].doubleValue
        self.ExpectedFee = data["ExpectedFee"].stringValue
        self.ActualDuration = data["ActualDuration"].stringValue
        self.ActualStartDateTime = data["ActualStartDateTime"].stringValue
        self.ActualFee = data["ActualFee"].stringValue
        self.JoinMettingUrl = data["JoinMettingUrl"].stringValue
        self.Status = data["Status"].stringValue
        self.MeetingId = data["MeetingId"].stringValue
        self.MeetingUri = data["MeetingUri"].stringValue
        doctor.parser(data["Doctor"])
        clinic.parser(data["Clinic"])
    }
}
