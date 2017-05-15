//
//  Message.swift
//  Test
//
//  Created by Hoa on 2/7/17.
//  Copyright © 2017 Hoa. All rights reserved.
//

import Foundation

class API {
    static let MAIN_PATIENT = "http://welioapi-staging.azurewebsites.net/api/Patients"
    static let MAIN_VALIDPHONE = "https://lookups.twilio.com/v1/PhoneNumbers/"
    static let typeValidPhone = "?Type=carrier&Type=caller-name"
    static let loginPatient = "/LoginPatient"
    static let checkMail = "/CheckPhoneEmailPatient"
    static let sigupPatient = "/SigupPatient"
    static let ActiveVerifyOTP = "/ActiveVerifyOTP"
    static let ReSendVerifyOTPForPhone = "/ReSendVerifyOTPForPhone"
    static let UpdatePhoneOfPatient = "/UpdatePhoneOfPatient"
    static let PostPatientImages = "/PostPatientImages"
    static let EditPatient = "/EditPatient"
    static let FofgotPasswordPatient = "/FofgotPasswordPatient"
    static let CheckOTPForgotPassword = "/CheckOTPForgotPassword"
    static let ResetPassword = "/ResetPassword"
    
    static let MAIN_APPOINTMENT = "http://welioapi-staging.azurewebsites.net/api/Appointments"
    static let GetMyAppointmentsOfPatient = "/GetMyAppointmentsOfPatient"
    static let GetMyAppointmentsOfPatientDetailt = "/GetMyAppointmentsOfPatientDetailt"
    
    static let MAIN_TRACKINGCALLTIME = "http://welioapi-staging.azurewebsites.net/api/TrackingCallTimes"
    static let TrackingCallTime = "/TrackingCallTime"
    static let RatingCallOfPatient = "/RatingCallOfPatient"
}

class KEY_USDEFAULT {
    static let SessionId = "SessionId"
    static let isLogin = "isLogin"
    
    static let ActivedLogin = "ActivedLogin"
    static let EmailLogin = "EmailLogin"
    static let FirstNameLogin = "FirstNameLogin"
    static let IsFoaltingLogin = "IsFoaltingLogin"
    static let LastNameLogin = "LastNameLogin"
    static let PatientIdLogin = "PatientIdLogin"
    static let PhoneLogin = "PhoneLogin"
    static let PatientAvatarLogin = "PatientAvatarLogin"
    
    static let PIN = "PIN"
}

class ERRORCODE {
    static let SUCCESS = 0
    static let FAILURE_PHONE_EXISTED = 11
    static let FAILURE_EMAIL_EXISTED = 12
    static let FAILURE_USER_NOT_FOUND = 9
    static let FAILURE_INVALID_PASSWORD = 198
    static let FAILURE_USER_ACTIVED = 157
    static let FAILURE_EMAIL_OR_PHONE_EXISTED = 169
}

class NOTIFICATION_NAME {
    static let NETWORK_NOT_REACHABLE = "NETWORK_NOT_REACHABLE"
    static let NETWORK_REACHABLE = "NETWORK_REACHABLE"
    static let GO_SETTING = "GO_SETTING"
}

class COLOR {
    static let colorSection = "#9ad8e2"
    static let switchOffColor = "#b9b9b9"
}
