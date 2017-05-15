//
//  RealmManager.swift
//  Welio
//
//  Created by Hoa on 5/8/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class RealmManager: NSObject {
    
    struct Static
    {
        static var instance: RealmManager?
    }
    
    class var sharedInstance: RealmManager
    {
        if Static.instance == nil
        {
            Static.instance = RealmManager()
        }
        
        return Static.instance!
    }
    
    func dispose()
    {
        RealmManager.Static.instance = nil
    }
    
    private let realm = try? Realm()
    
    override init() {
        super.init()
    }
    
    
    
    func update(_ msgObject : WMessage) {
        try! realm?.write {
            realm?.add(msgObject, update: true)
        }
    }
    
    func getAllCallLog(_ apntId : String) -> [WMessage]{
        return realm!.objects(WMessage.self).filter("apntId = '\(apntId)' AND messageType == 1").toArray()
    }
    
    func getAllMessage(_ apntId : String) -> [WMessage]{
        return realm!.objects(WMessage.self).filter("apntId = '\(apntId)' AND messageType == 0").toArray()
    }
    
    func getCountMessage(_ apntId : String) -> Int {
        let str = "apntId = '\(apntId)'"
        return realm!.objects(WMessage.self).filter(str).count
    }
    
    func insert(_ msgObject : WMessage) {
        try! realm?.write {
            realm?.add(msgObject)
        }
    }
    
    func deleteAllMessage() {
        try! realm?.write {
            realm?.deleteAll()
        }
    }
    
    func getPath() -> String {
        //Init Data Video
        return String(describing: self.realm?.configuration.fileURL?.path)
    }
}

extension Results {
    func toArray() -> [T] {
        return self.map{$0}
    }
}

extension RealmSwift.List {
    func toArray() -> [T] {
        return self.map{$0}
    }
}
