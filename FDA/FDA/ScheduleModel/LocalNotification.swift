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
        let date = Date()
        for activity in activities {
            
            var runsBeforeToday:Array<ActivityRun> = []
            if activity.frequencyType == Frequency.One_Time && activity.endDate == nil {
                //runsBeforeToday = runs
                runsBeforeToday = activity.activityRuns
            }
            else {
                
                runsBeforeToday = activity.activityRuns.filter({$0.endDate >= date})
                
            }
           
            
            for run in runsBeforeToday {
                
                print("Notification \(activity.actvityId) run: \(run.runId)")
                
                switch activity.frequencyType {
                case .One_Time:
                    
                    
                    if run.endDate != nil {
                        let date = run.endDate.addingTimeInterval(-24*3600) // 24 hours before
                        let message = "The activity " + activity.name! + " will expire in 24 hours. Your participation is important! Please visit the app to complete it now."
                        let userInfo = [kStudyId:run.studyId,
                                        kActivityId:run.activityId]
                        
                        LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    }
                    
                    
                case .Daily:
                    
                    
                    if activity.frequencyRuns?.count == 1 {
                        
                        let date = run.startDate! // 24 hours before
                        let message = "A new run of the daily activity " + activity.name! + ", is now available and is valid for today. Your participation is important! Visit the app to complete it now."
                        let userInfo = [kStudyId:run.studyId,
                                        kActivityId:run.activityId]
                        
                        LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    }
                    else {
                        
                        let date = run.startDate! // 24 hours before
                        let message1 = "A new run of the daily activity " + activity.name!
                        let message2 = ", is now available and is valid only until " + LocalNotification.timeFormatter.string(from: run.endDate!)
                        let messgge3 = ". Your participation is important! Visit the app to complete it now."
                        let message = message1 + message2 + messgge3
                        let userInfo = [kStudyId:run.studyId,
                                        kActivityId:run.activityId]
                        
                        LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    }
                    
                    
                case .Weekly:
                    
                    let date = run.endDate.addingTimeInterval(-24*3600)
                    let message = "The current run of the weekly activity " + activity.name! + " will expire in 24 hours. Your participation is important! Please visit the app to complete it now. "
                    let userInfo = [kStudyId:run.studyId,
                                    kActivityId:run.activityId]
                    
                    LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    
                case .Monthly:
                    
                    let date = run.endDate.addingTimeInterval(-72*3600)
                    let message = ":  The current run of the monthly activity " + activity.name! + " will expire in 3 days. Your participation is important! Please visit the app to complete it now."
                    let userInfo = [kStudyId:run.studyId,
                                    kActivityId:run.activityId]
                    
                    LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    
                case .Scheduled:
                    
                    let date = run.startDate! // 24 hours before
                    let message1 = "A new run of the scheduled activity " + activity.name!
                    let message2 = ", is now available and is valid only until " + "\(run.endDate!)"
                    let message3 = ". Your participation is important! Visit the app to complete it now."
                    let message = message1 + message2 + message3
                    let userInfo = [kStudyId:run.studyId,
                                    kActivityId:run.activityId]
                    
                    LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                
                }
                
            }
        }
    
        completionHandler(true)
    }
    
    
   class func scheduleNotificationOn(date:Date,message:String,userInfo:Dictionary<String,Any>){
    
        print("NotificationMessage\(message)")
    
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.alertBody = message
        notification.alertAction = "Ok"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = userInfo
        UIApplication.shared.scheduleLocalNotification(notification)

    }
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        //formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
    
}
