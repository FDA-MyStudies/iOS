//
//  DBActivity.swift
//  FDA
//
//  Created by Surender Rathore on 4/12/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import RealmSwift

class DBActivity: Object {
    
    dynamic var type:String?
    dynamic var actvityId:String?
    
    dynamic var studyId:String?
    dynamic var name:String?
    dynamic var version:String?
    dynamic var lastModified:Date?
    //dynamic var userStatus:UserActivityStatus.ActivityStatus
    dynamic var startDate:Date?
    dynamic var endDate:Date?
    dynamic var branching:Bool = false
    dynamic var randomization:Bool = false
    
    
    dynamic var frequencyRunsData:Data?
    dynamic var frequencyType:String?
    
    //dynamic var result:ActivityResult?
    
    
    var activityRuns = List<DBActivityRun>()
    
    override static func primaryKey() -> String? {
        return "actvityId"
    }
    
}
class DBActivityMetaData:Object {
    
    dynamic var actvityId:String?
    dynamic var studyId:String?
    dynamic var metaData:Data?
    
}
class DBActivityRun: Object {
    
   dynamic  var startDate:Date!
   dynamic  var endDate:Date!
   dynamic  var complitionDate:Date!
   dynamic  var runId:Int = 1
   dynamic  var studyId:String!
   dynamic  var activityId:String!
   dynamic  var isCompleted:Bool = false
    dynamic var restortionData:Data?
    
}


