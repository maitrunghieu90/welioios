//
//  File.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/12/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

let appleLanguages = "appleLanguages"

let rootView = Common.getAppDelegate().window!.rootViewController?.view
let rootViewController = Common.getAppDelegate().window!.rootViewController

let isHasCamera = UIImagePickerController.isSourceTypeAvailable(.camera)
let navColor = UIColor(red: 100.0/255.0, green: 199.0/255.0, blue: 207.0/255.0, alpha: 1.0)
let grayBgColor = UIColor(red: 148.0/255.0, green: 149.0/255.0, blue: 153.0/255.0, alpha: 1.0)

class Common {
    class func showAlert(_ strMessage:String, _ withTarget:UIViewController){
        let alert = UIAlertController(title: "app_name".localized, message: strMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction: UIAlertAction = UIAlertAction(title: "txt_ok".localized, style: .cancel) { action -> Void in
            
        }
        alert.addAction(okAction)
        withTarget.present(alert, animated: true, completion: nil)
    }
    
    class func getAppDelegate() -> AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    static func addToUserDefaults(_ pstrKey:String, pObject:Any) {
        
        let objUserDefaults = UserDefaults.standard
        objUserDefaults.set(pObject, forKey: pstrKey)
        objUserDefaults.synchronize()
    }
    
    static func removeFromUserdefaults(_ pstrKey:String)
    {
        let objUserDefaults = UserDefaults.standard
        objUserDefaults.removeObject(forKey: pstrKey)
        objUserDefaults.synchronize()
    }
    
    static func getFromUserDefaults(_ pstrKey:String) -> Any! {
        
        let objUserDefaults = UserDefaults.standard
        
        guard objUserDefaults.object(forKey: pstrKey) == nil else {
            
            return objUserDefaults.object(forKey: pstrKey)! as AnyObject!
        }
        return nil
        
    }
    
    static func dateGMT0() -> String {
        let date = Date()
        let strDate = "\(date.string("yyyy-MM-dd Z")) 00:00:00"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd Z hh:mm:ss"
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return "\(Int(dateFormatter.date(from: strDate)!.timeIntervalSince1970))"
    }
    
    static func goSettings() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
}
extension UIImage {
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = self.cgImage!
        
        let width = self.size.width
        let height = self.size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}

extension UIButton {
    func underline(){
        let attributes = [
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue
            ] as [String : Any]
        
        let attributedString = NSAttributedString(string: self.currentTitle!, attributes: attributes)
        
        self.setAttributedTitle(attributedString, for: .normal)
    }
}

extension NSMutableAttributedString {
    func changeFont(text:String, font:UIFont, fontColor:UIColor) -> NSMutableAttributedString {
        let attrs:[String : Any] = [NSFontAttributeName : font, NSForegroundColorAttributeName: fontColor]
        let attributedText = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        return attributedText
    }
}

extension UITextField {
    func isValidEmail() -> Bool {
        let emailRegEx = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@" + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text?.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func isValidPhone() -> Bool {
        let phoneRegEx = "^\\+[0-9]{10,13}$"
        
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: self.text?.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func isValidPass() -> Bool {
        if (self.text?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count)! >= 6{
            return true
        }else{
            return false
        }
    }
    
    func isValidNotEmty() -> Bool {
        if (self.text?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count)!>0 {
            return true
        }else {
            return false
        }
    }
    func strTrim() -> String{
        return (self.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
    }
    
    
}

extension UIView {
    func corner() {
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
    }
    func corner(_ value: CGFloat) {
        self.layer.cornerRadius = value
        self.clipsToBounds = true
    }
    func bolder(_ width: CGFloat) {
        self.layer.borderColor = navColor.cgColor
        self.layer.borderWidth = width
    }
    
    func bolderc(_ color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 0.5
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
//        let path:String = Bundle.main.path(forResource: UserDefaults.standard.object(forKey: "appleLanguages") as? String, ofType: "lproj")!
//        let pathBundle: Bundle = Bundle(path: path)!
//        return NSLocalizedString(self, tableName: nil, bundle: pathBundle, value: "", comment: "")
    }
    
    func formatDay() -> String {
        if (Int(self) == 1 || Int(self) == 21 || Int(self) == 31) {
            return "st";
        } else if (Int(self) == 2 || Int(self) == 22) {
            return "nd";
        } else if (Int(self) == 3 || Int(self) == 23) {
            return "rd";
        } else {
            return "th";
        }
    }
}

extension Int {
    func second() -> (Int, Int, Int, Int) {
        return ((self / 3600) / 24, self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
}

extension Date {
    func string(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self as Date)
    }
    
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(_ milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    init(_ str:String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self = dateFormatter.date(from: str)!
    }
}

extension UIColor {
    convenience init(_ hex:String) {
        let scanner = Scanner(string: hex)
        
        if (hex.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}

extension Dictionary {
    func sortedKeys(_ isOrderedBefore:(Key,Key) -> Bool) -> [Key] {
        return Array(self.keys).sorted(by: isOrderedBefore)
    }
    
    // Slower because of a lot of lookups, but probably takes less memory (this is equivalent to Pascals answer in an generic extension)
    func sortedKeysByValue(_ isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return sortedKeys {
            isOrderedBefore(self[$0]!, self[$1]!)
        }
    }
    
    // Faster because of no lookups, may take more memory because of duplicating contents
    func keysSortedByValue(_ isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return Array(self)
            .sorted() {
                let (_, lv) = $0
                let (_, rv) = $1
                return isOrderedBefore(lv, rv)
            }
            .map {
                let (k, _) = $0
                return k
        }
    }
}

protocol Utilities {
}

extension NSObject:Utilities{
    
    
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
    
}
