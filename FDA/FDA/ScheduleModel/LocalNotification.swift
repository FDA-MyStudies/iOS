//
//  LocalNotification.swift
//  FDA
//
//  Created by Surender Rathore on 5/16/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class LocalNotification: NSObject {

    static var studies:Array<Study> = []
    static var notificationList:Array<AppLocalNotification> = []
    static var handler:((Bool) -> ()) = {_ in }
    class func registerLocalNotificationForJoinedStudies(completionHandler:@escaping (Bool) -> ()){
        
         studies = (Gateway.instance.studies?.filter({$0.userParticipateState.status == UserStudyStatus.StudyStatus.inProgress && $0.status == .Active}))!
        
        handler = completionHandler
       
        LocalNotification.registerForStudy()
        
        
    }
    
    class func registerForStudy(){
        
        if studies.count > 0 {
            
            let study = studies.first
            LocalNotification.registerForStudy(study: study!) { (done) in
                if done {
                    if (studies.count) > 0 {
                        studies.removeFirst()
                        LocalNotification.registerForStudy()
                    }
                    
                }
            }
        }
        else {
            handler(true)
        }
        
       
    }
    
    class func registerForStudy(study:Study,completionHandler:@escaping (Bool) -> ()){
    
        DBHandler.loadActivityListFromDatabase(studyId: study.studyId) { (activities) in
            if activities.count > 0 {
                LocalNotification.registerAllLocalNotificationFor(activities: activities, completionHandler: { (done) in
                    completionHandler(true)
                })
            }
            else {
                 completionHandler(true)
            }
        }
    }
    
   class func registerAllLocalNotificationFor(activities:Array<Activity>,completionHandler:@escaping (Bool,Array<AppLocalNotification>) -> ()){
    
//    let date = Date().addingTimeInterval(15) // 24 hours before
//    let message = "Activity will expire in 24 hours"
//    let userInfo = [kStudyId:"1",
//                    kActivityId:"2"]
    
//    LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
    
        LocalNotification.notificationList.removeAll()
    
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
                
              
                switch activity.frequencyType {
                case .One_Time:
                    
                    
                    if run.endDate != nil {
                        let date = run.endDate.addingTimeInterval(-24*3600) // 24 hours before
                        let message = "The activity " + activity.name! + " will expire in 24 hours. Your participation is important. Please visit the study to complete it now."
                       // let userInfo = [kStudyId:run.studyId,
                        //kActivityId:run.activityId] as [String:String]
                        
                        //LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                        
                        LocalNotification.composeRunNotification(startDate: date, endDate: run.endDate, message: message, run: run)
                    }
                    
                    
                case .Daily:
                    
                    
                    if activity.frequencyRuns?.count == 1 {
                        
                        let date = run.startDate! // 24 hours before
                        let message = "A new run of the daily activity " + activity.name! + ", is now available. Your participation is important. Please visit the study to complete it now."
                        let userInfo = [kStudyId:run.studyId,
                                        kActivityId:run.activityId]
                        
                        LocalNotification.composeRunNotification(startDate: date, endDate: run.endDate, message: message, run: run)
                        
                        //LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    }
                    else {
                        
                        let date = run.startDate! // 24 hours before
                        let message1 = "A new run of the daily activity " + activity.name!
                        let message2 = ", is now available and is valid until " + LocalNotification.timeFormatter.string(from: run.endDate!)
                        let messgge3 = ". Your participation is important. Please visit the study to complete it now."
                        let message = message1 + message2 + messgge3
                        let userInfo = [kStudyId:run.studyId,
                                        kActivityId:run.activityId]
                        
                         LocalNotification.composeRunNotification(startDate: date, endDate: run.endDate, message: message, run: run)
                        
                       // LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    }
                    
                    
                case .Weekly:
                    
                    //expiry notificaiton
                    let date = run.endDate.addingTimeInterval(-24*3600)
                    let message = "The current run of the weekly activity " + activity.name! + " will expire in 24 hours. Your participation is important. Please visit the study to complete it now."
                    let userInfo = [kStudyId:run.studyId,
                                    kActivityId:run.activityId]
                    
                   // LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    
                   LocalNotification.composeRunNotification(startDate: date, endDate: run.endDate, message: message, run: run)
                    
                    //start notification
                    let startMessage = "A new run of the weekly activity " + activity.name! + ", is now available. Please visit the study to complete it now."
                    //LocalNotification.scheduleNotificationOn(date: run.startDate!, message: startMessage, userInfo: userInfo)
                    
                     LocalNotification.composeRunNotification(startDate: run.startDate!, endDate: run.endDate, message: startMessage, run: run)
                    
                case .Monthly:
                    
                    let date = run.endDate.addingTimeInterval(-72*3600)
                    let message = "The current run of the monthly activity " + activity.name! + " will expire in 3 days. Your participation is important. Please visit the study to complete it now."
                    let userInfo = [kStudyId:run.studyId,
                                    kActivityId:run.activityId]
                    
                    //LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                    
                    LocalNotification.composeRunNotification(startDate: date, endDate: run.endDate, message: message, run: run)
                    
                    //start notification
                    let startMessage = "A new run of the monthly activity " + activity.name! + ", is now available. Please visit the study to complete it now."
                    //LocalNotification.scheduleNotificationOn(date: run.startDate!, message: startMessage, userInfo: userInfo)
                    
                     LocalNotification.composeRunNotification(startDate: run.startDate!, endDate: run.endDate, message: startMessage, run: run)
                    
                case .Scheduled:
                    
                    let date = run.startDate! // 24 hours before
                    let endDate = LocalNotification.oneTimeFormatter.string(from: run.endDate!)
                    let message1 = "A new run of the scheduled activity " + activity.name!
                    let message2 = ", is now available and is valid until " + "\(endDate)"
                    let message3 = ". Your participation is important. Please visit the study to complete it now."
                    let message = message1 + message2 + message3
                    let userInfo = [kStudyId:run.studyId,
                                    kActivityId:run.activityId]
                    
                    //LocalNotification.scheduleNotificationOn(date: date, message: message, userInfo: userInfo)
                
                     LocalNotification.composeRunNotification(startDate: date, endDate: run.endDate, message: message, run: run)
                }
                
            }
        }
    
        completionHandler(true,LocalNotification.notificationList)
    }
    
    class func composeRunNotification(startDate:Date,endDate:Date,message:String,run:ActivityRun){
        
        let userInfo = [kStudyId:run.studyId,
                        kActivityId:run.activityId] as [String:String]
        
        LocalNotification.scheduleNotificationOn(date: startDate, message: message, userInfo: userInfo)
        
        
        //create App local notification object
        
        let randomString = Utilities.randomString(length: 5)
        
        let notification = AppLocalNotification()
        notification.id =  String(run.runId) + run.activityId + run.studyId + randomString
        notification.message = message
        notification.title = ""
        notification.startDate = startDate
        notification.endDate = endDate
        notification.type = AppNotification.NotificationType.Study
        notification.subType = AppNotification.NotificationSubType.Activity
        notification.audience = Audience.Limited
        notification.studyId = (Study.currentStudy?.studyId)!
        
        LocalNotification.notificationList.append(notification)

        
    }
    
    class func scheduleNotificationOn(date:Date,message:String,userInfo:Dictionary<String,Any>){
        
        ///print("NotificationMessage\(message) ** date \(date.description(with: Locale.current))" )
        
        if date > Date() {
            print("NotificationMessage\(message) ** date \(date.description(with: Locale.current))" )
            let notification = UILocalNotification()
            notification.fireDate = date
            notification.alertBody = message
            notification.alertAction = "Ok"
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = userInfo
            //notification.timeZone = NSTimeZone.system
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        
    }
    
    
    class func removeLocalNotificationfor(studyId:String,activityid:String) {
        
        let allNotificaiton = UIApplication.shared.scheduledLocalNotifications
       
        for notification in allNotificaiton! {
            let userInfo = notification.userInfo
            if userInfo?[kStudyId] != nil && userInfo?[kActivityId] != nil{
                if (userInfo![kStudyId] as! String == studyId && userInfo![kActivityId] as! String == activityid) {
                    UIApplication.shared.cancelLocalNotification(notification)
                }
            }
        }
        
    }
    
    class func removeLocalNotificationfor(studyId:String) {
        
        let allNotificaiton = UIApplication.shared.scheduledLocalNotifications
      
        for notification in allNotificaiton! {
            let userInfo = notification.userInfo
            if userInfo?[kStudyId] != nil {
                if (userInfo![kStudyId] as! String == studyId) {
                    UIApplication.shared.cancelLocalNotification(notification)
                }
            }
        }
        
    }
    
    class func cancelAllLocalNotification() {
        
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
    
    class func registerReopenAppNotification(){
        
        let userInfo = ["registerApp":"mystudies",
                        ]
        let date = Date().addingTimeInterval(60*60*24*14)
        
        let message = "It’s been a while since you visited the FDA My Studies app. Please consider continuing your participation in any studies in which you’re enrolled."
        
        
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.alertBody = message
        notification.alertAction = "Ok"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = userInfo
        notification.repeatInterval = NSCalendar.Unit.day
        UIApplication.shared.scheduleLocalNotification(notification)
        
    }
    class func removeReopenAppNotification(){
        
        let allNotificaiton = UIApplication.shared.scheduledLocalNotifications
        
        for notification in allNotificaiton! {
            let userInfo = notification.userInfo
            if userInfo?["registerApp"] != nil {
                if (userInfo!["registerApp"] as! String == "mystudies") {
                    UIApplication.shared.cancelLocalNotification(notification)
                }
            }
        }
    }
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        //formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
    private static let oneTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma, MMM dd YYYY"
        //formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
    
}

class NotificationHandler: NSObject {
    var studyId:String! = ""
    var activityId:String! = ""
    var appOpenFromNotification = false
    static var instance = NotificationHandler()
}
