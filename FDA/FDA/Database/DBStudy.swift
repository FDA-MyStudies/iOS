//
//  DBStudy.swift
//  FDA
//
//  Created by Surender Rathore on 3/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import RealmSwift

class DBStudy: Object {
    
    dynamic var studyId:String!
    dynamic var name:String?
    dynamic var version:String?
    dynamic var updatedVersion:String?
    dynamic var identifer:String?
    dynamic var category:String?
    dynamic var startDate:String?
    dynamic var endEnd:String?
    dynamic var status:String?
    dynamic var sponserName:String?
    dynamic var tagLine:String?
    dynamic var brandingConfiguration:String?
    dynamic var logoURL:String?
    dynamic var websiteLink:String?
    dynamic var bookmarked:Bool = false
    dynamic var updateResources : Bool = false
    dynamic var updateActivities : Bool = false
    dynamic var updateConsent : Bool = false
    dynamic var updateInfo : Bool = false
    dynamic var enrolling : Bool = false
    dynamic var platform:String?
    dynamic var rejoin : Bool = false
    
    dynamic var signedConsentVersion:String?
    dynamic var signedConsentFilePath:String?
    
    //study state info
    dynamic var participatedStatus:Int = 0
    dynamic var participatedId:String?
    dynamic var joiningDate:Date?
    dynamic var completion:Int = 0
    dynamic var adherence:Int = 0
    
    //anchor date values
    dynamic var anchorDate:Date?
    dynamic var anchorDateType:String?
    dynamic var anchorDateActivityId:String?
    dynamic var anchorDateActivityVersion:String?
    dynamic var anchorDateQuestionKey:String?
    dynamic var activitiesLocalNotificationUpdated = false
    
    
    //withdrawalConfigration
    
    dynamic var withdrawalConfigrationMessage:String?
    dynamic var withdrawalConfigrationType:String?
    
    var sections = List<DBOverviewSection>()
    
    override static func primaryKey() -> String? {
        return "studyId"
    }
    
}

class DBOverviewSection: Object {
    
    dynamic  var title:String?
    dynamic  var type:String?
    dynamic  var imageURL:String?
    dynamic  var text:String?
    dynamic  var link:String?
    dynamic var  studyId:String!
    dynamic var  sectionId:String!
    
    override static func primaryKey() -> String? {
        return "sectionId"
    }
}

class DBStatistics : Object {
    
    dynamic var  studyId:String!
    dynamic var  statisticsId:String!
    dynamic var title:String?
    dynamic var displayName:String?
    dynamic var unit:String?
    dynamic var calculation:String?
    dynamic var statType:String?
    dynamic var activityId:String?
    dynamic var activityVersion:String?
    dynamic var dataSourceType:String?
    dynamic var dataSourceKey:String?
    var statisticsData = List<DBStatisticsData>()
    
    override static func primaryKey() -> String? {
        return "statisticsId"
    }
    
}
class DBCharts :Object {
    
    //basic
    dynamic  var chartId:String?
    dynamic var studyId:String?
    dynamic var title:String?
    dynamic var displayName:String?
    dynamic var chartType:String?
    
    //datasource
    dynamic var activityId:String?
    dynamic var activityVersion:String?
    dynamic var dataSourceType:String?
    dynamic var dataSourceKey:String?
    dynamic var dataSourceTimeRange:String?
    dynamic var startTime:Date?
    dynamic var endTime:Date?
    
    
    //settings
    dynamic var barColor:String?
    dynamic var numberOfPoints:Int = 0
    dynamic var chartSubType:String?
    
    var statisticsData = List<DBStatisticsData>()
    
    override static func primaryKey() -> String? {
        return "chartId"
    }

}
class DBStatisticsData : Object {
    dynamic var startDate:Date?
    dynamic var data:Float = 0.0
}

class DBResources:Object {
    
   dynamic  var studyId:String?
   dynamic  var level:String?
   dynamic  var key:String?
   dynamic  var type:String?
   dynamic  var audience:String?
   dynamic  var resourceId:String?
   dynamic  var startDate:Date?
   dynamic  var endDate:Date?
   dynamic  var anchorDateStartDays:Int = 0
   dynamic  var anchorDateEndDays:Int = 0
   dynamic  var title:String?
   dynamic  var serverUrl:String?
   dynamic  var localPath:String?
   dynamic  var povAvailable:Bool = false
    
    override static func primaryKey() -> String? {
        return "resourceId"
    }
}
