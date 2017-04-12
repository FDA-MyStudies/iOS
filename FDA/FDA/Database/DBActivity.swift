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
    var branching:Bool?
    var randomization:Bool?
    
    //dynamic var schedule:Schedule?
    // var steps = List()
    //dynamic var orkSteps:Array<ORKStep>?
    //dynamic var activitySteps:Array<ActivityStep>?
    
    
    // var frequencyRuns = List()
    dynamic var frequencyType:String?
    
    //dynamic var result:ActivityResult?
    
     var restortionData:Data?
    
    override static func primaryKey() -> String? {
        return "actvityId"
    }
    
}
