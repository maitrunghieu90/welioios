//
//  File.swift
//  Test
//
//  Created by Hoa on 1/10/17.
//  Copyright © 2017 Hoa. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SystemConfiguration
import KRProgressHUD

class WebService: NSObject {
    static let shareInstance = WebService()
    var sessionManager = SessionManager()
    
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // seconds
        configuration.timeoutIntervalForResource = 30
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    typealias SuccessHandler = (JSON) -> Void
    typealias FailureHandler = (Error) -> Void
    
    // MARK: - Internet Connectivity
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    // MARK: - Helper Methods
    
    func getWebServiceCall(_ strURL : String, isShowLoader : Bool, success : @escaping SuccessHandler, failure : @escaping FailureHandler)
    {
        if isConnectedToNetwork() {
            if isShowLoader {
                KRProgressHUD.show()
            }
            print(strURL)
            
            sessionManager.request(strURL).responseJSON { (resObj) -> Void in
                if isShowLoader {
                    KRProgressHUD.dismiss()
                }
                print(resObj)
                
                if resObj.result.isSuccess {
                    let resJson = JSON(resObj.result.value!)
                    
                    debugPrint(resJson)
                    success(resJson)
                }
                if resObj.result.isFailure {
                    let error : Error = resObj.result.error!
                    
                    debugPrint(error)
                    failure(error)
                }
            }
        }else {
            Common.showAlert("err_network_available".localized, rootViewController!)
        }
    }
    
    func getWebServiceCall(_ strURL : String, params : [String : AnyObject]?, isShowLoader : Bool, success : @escaping SuccessHandler,  failure :@escaping FailureHandler){
        if isConnectedToNetwork() {
            if isShowLoader {
                KRProgressHUD.show()
            }
            
            sessionManager.request(strURL, method: .get, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {(resObj) -> Void in
                if isShowLoader {
                    KRProgressHUD.dismiss()
                }
                print(resObj)
                
                if resObj.result.isSuccess {
                    let resJson = JSON(resObj.result.value!)
                    
                    success(resJson)
                }
                if resObj.result.isFailure {
                    let error : Error = resObj.result.error!
                    
                    failure(error)
                }
                
            })
        }
        else {
            Common.showAlert("err_network_available".localized, rootViewController!)
        }
        
    }
    
    func getWebServiceCallWithHeader(_ strURL : String, params : [String : AnyObject]?, isShowLoader : Bool, success : @escaping SuccessHandler,  failure :@escaping FailureHandler){
        if isConnectedToNetwork() {
            if isShowLoader {
                KRProgressHUD.show()
            }
            
            sessionManager.request(strURL, method: .get, parameters: params, encoding: JSONEncoding.default, headers: ["SessionId": Common.getFromUserDefaults(KEY_USDEFAULT.SessionId) as! String]).responseJSON(completionHandler: {(resObj) -> Void in
                if isShowLoader {
                    KRProgressHUD.dismiss()
                }
                print(resObj)
                
                if resObj.result.isSuccess {
                    let resJson = JSON(resObj.result.value!)
                    
                    success(resJson)
                }
                if resObj.result.isFailure {
                    let error : Error = resObj.result.error!
                    
                    failure(error)
                }
                
            })
        }
        else {
            Common.showAlert("err_network_available".localized, rootViewController!)
        }
        
    }
    
    
    
    func postWebServiceCall(_ strURL : String, params : [String : Any]?, isShowLoader : Bool, success : @escaping SuccessHandler, failure :@escaping FailureHandler)
    {
        if isConnectedToNetwork()
        {
            if isShowLoader {
                KRProgressHUD.show()
            }
            sessionManager.request(strURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: {(resObj) -> Void in
                if isShowLoader {
                    KRProgressHUD.dismiss()
                }
                print(resObj)
                
                if resObj.result.isSuccess
                {
                    let resJson = JSON(resObj.result.value!)
                    
                    success(resJson)
                }
                
                if resObj.result.isFailure
                {
                    let error : Error = resObj.result.error!
                    
                    failure(error)
                }
            })
        }else {
            Common.showAlert("err_network_available".localized, rootViewController!)
        }
    }
    
    func postWebServiceCallWithHeader(_ strURL : String, params : [String : Any]?, isShowLoader : Bool, success : @escaping SuccessHandler, failure :@escaping FailureHandler)
    {
        if isConnectedToNetwork()
        {
            if isShowLoader {
                KRProgressHUD.show()
            }
            sessionManager.request(strURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["SessionId": Common.getFromUserDefaults(KEY_USDEFAULT.SessionId) as! String]).responseJSON(completionHandler: {(resObj) -> Void in
                if isShowLoader {
                    KRProgressHUD.dismiss()
                }
                print(resObj)
                
                if resObj.result.isSuccess
                {
                    let resJson = JSON(resObj.result.value!)
                    
                    success(resJson)
                }
                
                if resObj.result.isFailure
                {
                    let error : Error = resObj.result.error!
                    
                    failure(error)
                }
            })
        }else {
            Common.showAlert("err_network_available".localized, rootViewController!)
        }
    }
    
    func postWebServiceCallWithImageHeader(_ strURL : String, image : UIImage!, params : [String : AnyObject]?, isShowLoader : Bool, success : @escaping SuccessHandler, failure : @escaping FailureHandler)
    {
        if isConnectedToNetwork() {
            if isShowLoader {
                KRProgressHUD.show()
            }
            
            sessionManager.upload(multipartFormData: { (multipartFormData) in
                if let imageData = UIImageJPEGRepresentation(image, 1) {
                    multipartFormData.append(imageData, withName: "Image", fileName: "image.jpeg", mimeType: "image/jpeg")
                }
                
                for (key, value) in params! {
                    
                    let data = value as! String
                    
                    multipartFormData.append(data.data(using: String.Encoding.utf8)!, withName: key)
                    print(multipartFormData)
                }
            }, usingThreshold: UInt64.init(), to: strURL, method: .post, headers: ["SessionId": Common.getFromUserDefaults(KEY_USDEFAULT.SessionId) as! String], encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    
                    let error : NSError = encodingError as NSError
                    failure(error)
                }
                
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { (response) -> Void in
                        if isShowLoader {
                            KRProgressHUD.dismiss()
                        }
                        if response.result.isSuccess
                        {
                            let resJson = JSON(response.result.value!)
                            
                            success(resJson)
                        }
                        
                        if response.result.isFailure
                        {
                            let error : Error = response.result.error! as Error
                            
                            failure(error)
                        }
                        
                    }
                case .failure(let encodingError):
                    if isShowLoader {
                        KRProgressHUD.dismiss()
                    }
                    let error : NSError = encodingError as NSError
                    failure(error)
                }
            })
        }
        else
        {
            Common.showAlert("err_network_available".localized, rootViewController!)
        }
    }
    
    
    
    func postWebServiceCallWithImage(_ strURL : String, image : UIImage!, params : [String : AnyObject]?, isShowLoader : Bool, success : @escaping SuccessHandler, failure : @escaping FailureHandler)
    {
        if isConnectedToNetwork() {
            if isShowLoader {
                KRProgressHUD.show()
            }
            sessionManager.upload(
                multipartFormData: { multipartFormData in
                    if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                        multipartFormData.append(imageData, withName: "Image", fileName: "image.jpeg", mimeType: "image/jpeg")
                    }
                    
                    for (key, value) in params! {
                        
                        let data = value as! String
                        
                        multipartFormData.append(data.data(using: String.Encoding.utf8)!, withName: key)
                        print(multipartFormData)
                    }
            },
                to: strURL,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                        
                        let error : NSError = encodingError as NSError
                        failure(error)
                    }
                    
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { (response) -> Void in
                            if isShowLoader {
                                KRProgressHUD.dismiss()
                            }
                            if response.result.isSuccess
                            {
                                let resJson = JSON(response.result.value!)
                                
                                success(resJson)
                            }
                            
                            if response.result.isFailure
                            {
                                let error : Error = response.result.error! as Error
                                
                                failure(error)
                            }
                            
                        }
                    case .failure(let encodingError):
                        if isShowLoader {
                            KRProgressHUD.dismiss()
                        }
                        let error : NSError = encodingError as NSError
                        failure(error)
                    }
            }
            )
        }
        else
        {
            Common.showAlert("err_network_available".localized, rootViewController!)
        }
    }
    
    func getAuthorization(_ strURL : String, isShowLoader : Bool, success : @escaping SuccessHandler, failure : @escaping FailureHandler)
    {
        if isConnectedToNetwork() {
            if isShowLoader {
                KRProgressHUD.show()
            }
            let user = "ACc900118847807d2feaac9e92fc1c563f"
            let password = "9d8bbc87e23308c28c4cc07f8f240179"
            let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
            let base64Credentials = credentialData.base64EncodedString(options: [])
            let headers = ["Authorization": "Basic \(base64Credentials)"]
            
            sessionManager.request(strURL,
                                   method: .get,
                                   parameters: nil,
                                   encoding: URLEncoding.default,
                                   headers:headers)
                .validate()
                .responseJSON { resObj in
                    if isShowLoader {
                        KRProgressHUD.dismiss()
                    }
                    if resObj.result.isSuccess
                    {
                        let resJson = JSON(resObj.result.value!)
                        
                        success(resJson)
                    }
                    
                    if resObj.result.isFailure
                    {
                        let error : Error = resObj.result.error!
                        
                        failure(error)
                    }
            }
        }
        else
        {
            Common.showAlert("err_network_available".localized, rootViewController!)
        }
    }
}
