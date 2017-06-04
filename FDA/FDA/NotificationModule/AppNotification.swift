//
//  Notification.swift
//  FDA
//
//  Created by Surender Rathore on 2/15/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit


enum Audience:String{
    case All
    case Participants
    case Limited
}

class AppLocalNotification:AppNotification{
    var startDate:Date?
    var endDate:Date?
}

class AppNotification {
    
    enum NotificationType:String{
        case Gateway
        case Study
    }
    
    enum NotificationSubType:String{
        case Announcement
        case Study
        case Resource
        case Activity
        case studyEvent
    }

    
    
    var id:String?
    var type:NotificationType = .Gateway
    var subType:NotificationSubType!
    var audience:Audience!
    var title:String?
    var message:String?
    var studyId:String?
    var date:Date?
    
    var activityId:String?
    var read:Bool? = false
    
    init() {
        
    }
    
    init(detail:Dictionary<String, Any>){
        
        if Utilities.isValidObject(someObject: detail as AnyObject?){
            
            if Utilities.isValidValue(someObject: detail[kNotificationId] as AnyObject ){
                self.id = detail[kNotificationId] as? String
            }
            if Utilities.isValidValue(someObject: detail[kNotificationTitle] as AnyObject ){
                self.title = detail[kNotificationTitle] as? String
            }
            if Utilities.isValidValue(someObject: detail[kNotificationMessage] as AnyObject ){
                self.message = detail[kNotificationMessage] as? String
            }
            if Utilities.isValidValue(someObject: detail[kNotificationType] as AnyObject ){
                self.type = NotificationType(rawValue: detail[kNotificationType] as! String)!
            }
            if Utilities.isValidValue(someObject: detail[kNotificationSubType] as AnyObject ) {
                 self.subType = NotificationSubType(rawValue: detail[kNotificationSubType] as! String)!
            }
            if Utilities.isValidValue(someObject: detail[kNotificationAudience] as AnyObject ) {
                self.audience = Audience(rawValue: detail[kNotificationAudience] as! String)!
            }
            
            if Utilities.isValidValue(someObject: detail[kNotificationStudyId] as AnyObject ) {
                self.studyId =  detail[kNotificationStudyId] as? String
            }
            if Utilities.isValidValue(someObject: detail["date"] as AnyObject ) {
                self.date =   Utilities.getDateFromString(dateString: (detail["date"] as? String)!)
            }
            
            if Utilities.isValidValue(someObject: detail[kNotificationActivityId] as AnyObject ) {
                self.activityId =   detail[kNotificationActivityId] as? String
            }
            
        }
        else{
            Logger.sharedInstance.debug("AppNotification Dictionary is null:\(detail)")
        }
    }
    
}
