//
//  LocalNotification.swift
//  FDA
//
//  Created by Surender Rathore on 5/16/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class LocalNotification: NSObject {

    
   class func registerAllLocalNotificationFor(activities:Array<Activity>,completionHandler:@escaping (Bool) -> ()){
    
//    let date = Date().addingTimeInterval(15) // 24 hours before
//    let message = "Activity will expire in 24 hours"
//    let userInfo = [kStudyId:"1",
//                    kActivityId:"2"]
    
//    LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
    
        for activity in activities {
            for run in activity.activityRuns {
                
                print("Notification \(activity.actvityId) run: \(run.runId)")
                
                switch activity.frequencyType {
                case .One_Time:
                    
                    
                    if run.endDate != nil {
                        let date = run.endDate.addingTimeInterval(-24*3600) // 24 hours before
                        let message = "Activity will expire in 24 hours"
                        let userInfo = [kStudyId:run.studyId,
                                        kActivityId:run.activityId]
                        
                        LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    }
                    
                    
                case .Daily:
                    
                    
                    if activity.frequencyRuns?.count == 1 {
                        
                        let date = run.startDate! // 24 hours before
                        let message = "Activity will expire in 24 hours"
                        let userInfo = [kStudyId:run.studyId,
                                        kActivityId:run.activityId]
                        
                        LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    }
                    else {
                        
                        let date = run.startDate! // 24 hours before
                        let message = "Activity will expire in" + String(run.startDate.hours(from: run.endDate)) + "hours"
                        let userInfo = [kStudyId:run.studyId,
                                        kActivityId:run.activityId]
                        
                        LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    }
                    
                    
                case .Weekly:
                    
                    let date = run.endDate.addingTimeInterval(-24*3600)
                    let message = "Activity will expire in 24 hours"
                    let userInfo = [kStudyId:run.studyId,
                                    kActivityId:run.activityId]
                    
                    LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    
                case .Monthly:
                    
                    let date = run.endDate.addingTimeInterval(-72*3600)
                    let message = "Activity will expire in 72 hours"
                    let userInfo = [kStudyId:run.studyId,
                                    kActivityId:run.activityId]
                    
                    LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    
                case .Scheduled:
                    
                    let date = run.startDate! // 24 hours before
                    let message = "Activity will expire in" + String(run.startDate.hours(from: run.endDate)) + "hours"
                    let userInfo = [kStudyId:run.studyId,
                                    kActivityId:run.activityId]
                    
                    LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                
                }
                
            }
        }
    
        completionHandler(true)
    }
    
    
   class func scheduleNotificationOn(date:Date,message:String,userInfo:Dictionary<String,Any>){
        
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.alertBody = message
        notification.alertAction = "Ok"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = userInfo
        UIApplication.shared.scheduleLocalNotification(notification)

    }
    
}
