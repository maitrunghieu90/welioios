//
//  WMessage.swift
//  Welio
//
//  Created by Hoa on 5/3/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import Foundation
import RealmSwift

class WMessage: Object {
    dynamic var id = ""
    dynamic var apntId = ""
    dynamic var senderId = ""
    dynamic var receviceId = ""
    dynamic var message = ""
    dynamic var callId = ""
    dynamic var startAt = 0
    dynamic var dutation = 0
    dynamic var endAt = 0
    dynamic var messageType = 0
    dynamic var isUnread = true
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
