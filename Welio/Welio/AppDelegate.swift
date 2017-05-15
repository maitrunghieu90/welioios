//
//  AppDelegate.swift
//  Welio
//
//  Created by Hoa on 4/11/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import AVFoundation
import Fabric
import Crashlytics
import SkypeForBusiness
import ReachabilitySwift
import KRProgressHUD
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var loginUser = WPatient()
    var window: UIWindow?
    var conversation : SfBConversation? = nil
    let reachability = Reachability()!
    var isReachable = false
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if Common.getFromUserDefaults(KEY_USDEFAULT.PIN) != nil && (Common.getFromUserDefaults(KEY_USDEFAULT.isLogin) != nil) && Common.getFromUserDefaults(KEY_USDEFAULT.isLogin) as! String == "yes" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "EnterPINVC") as! EnterPINVC
            let nav = UINavigationController.init(rootViewController: vc)
            nav.isNavigationBarHidden = true
            window?.rootViewController = nav
        }else if (Common.getFromUserDefaults(KEY_USDEFAULT.isLogin) != nil) && Common.getFromUserDefaults(KEY_USDEFAULT.isLogin) as! String == "yes" {
            Common.getAppDelegate().loginUser.Actived = (Common.getFromUserDefaults(KEY_USDEFAULT.ActivedLogin) as! String == "yes" ? true : false)
            Common.getAppDelegate().loginUser.Email = Common.getFromUserDefaults(KEY_USDEFAULT.EmailLogin) as? String
            Common.getAppDelegate().loginUser.FirstName = Common.getFromUserDefaults(KEY_USDEFAULT.FirstNameLogin) as? String
            Common.getAppDelegate().loginUser.IsFoalting = (Common.getFromUserDefaults(KEY_USDEFAULT.IsFoaltingLogin) as! String == "yes" ? true : false)
            Common.getAppDelegate().loginUser.LastName = Common.getFromUserDefaults(KEY_USDEFAULT.LastNameLogin) as? String
            Common.getAppDelegate().loginUser.PatientId = Common.getFromUserDefaults(KEY_USDEFAULT.PatientIdLogin) as? String
            Common.getAppDelegate().loginUser.Phone = Common.getFromUserDefaults(KEY_USDEFAULT.PhoneLogin) as? String
            Common.getAppDelegate().loginUser.PatientAvatar = Common.getFromUserDefaults(KEY_USDEFAULT.PatientAvatarLogin) as? String
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SideMenuRootController") as! SideMenuRootController
            let nav = UINavigationController.init(rootViewController: vc)
            nav.isNavigationBarHidden = true
            window?.rootViewController = nav
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord,
                                         with: [.allowBluetooth, .mixWithOthers, .duckOthers])
            try audioSession.setMode(AVAudioSessionModeVoiceChat)
        } catch {}
        
        Fabric.with([Crashlytics.self])
        UserDefaults.standard.setValue("en", forKey: appleLanguages)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: ReachabilityChangedNotification,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        }catch{}
        
        AVAudioSession.sharedInstance().requestRecordPermission({ (respone) in
        })
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { response in
        }
        
        KRProgressHUD.set(maskType: .black)
        KRProgressHUD.set(style: .white)
        KRProgressHUD.set(activityIndicatorStyle: .color(navColor, UIColor.init(COLOR.colorSection)))
        
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        return true
    }
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
                if !isReachable {
                    isReachable = true
                }
            } else {
                print("Reachable via Cellular")
                if !isReachable {
                    isReachable = true
                }
            }
        } else {
            print("Network not reachable")
            isReachable = false
            if conversation != nil {
                Common.showAlert("txt_check_connect".localized, rootViewController!)
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNs device token: \(deviceTokenString)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_NAME.GO_SETTING), object: nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }
}

