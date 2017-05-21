//
//  DBNotification.swift
//  FDA
//
//  Created by Arun Kumar on 21/05/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation


import RealmSwift

class DBNotification: Object {
    
    
    dynamic var id : String?
    dynamic var title : String?
    dynamic var message :String?
    dynamic var studyId : String?
   
    dynamic var notificationType:String?
    dynamic var subType:String?
    dynamic var audience:String?
    
    dynamic var activityId :String?
    
    dynamic var date:Date?
    
    dynamic var isRead = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
 
