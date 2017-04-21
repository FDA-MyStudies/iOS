//
//  DBHandler.swift
//  FDA
//
//  Created by Surender Rathore on 3/22/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import RealmSwift

class DBHandler: NSObject {

    
    func saveCurrentUser(user:User){
        
        let dbUser = DBUser()
        dbUser.userType = (user.userType?.rawValue)!
        dbUser.emailId = user.emailId!
        dbUser.authToken = user.authToken
        dbUser.userId = user.userId
        dbUser.firstName = user.firstName!
        dbUser.lastName = user.lastName!
        dbUser.verified = user.verified
        
        let realm = try! Realm()
        print("DBPath : varealm.configuration.fileURL)")
        try! realm.write({
            realm.add(dbUser, update: true)
            
        })
    }
    
    func initilizeCurrentUser(){
        
        let realm = try! Realm()
        let dbUsers = realm.objects(DBUser.self)
        let dbUser = dbUsers.last
        
        if dbUser != nil {
            let currentUser = User.currentUser
            currentUser.firstName = dbUser?.firstName
            currentUser.lastName  = dbUser?.lastName
            currentUser.verified = dbUser?.verified
            currentUser.authToken = dbUser?.authToken
            currentUser.userId = dbUser?.userId
            currentUser.emailId = dbUser?.emailId
            currentUser.userType =  (dbUser?.userType).map { UserType(rawValue: $0) }!
        }
        
    }
    
   class func deleteCurrentUser(){
        
        let realm = try! Realm()
        let dbUsers = realm.objects(DBUser.self)
        let dbUser = dbUsers.last
        try! realm.write {
            realm.delete(dbUser!)
        }
    }
    
    
    
     //MARK:Study
    func saveStudies(studies:Array<Study>){
        
        
        var dbStudies:Array<DBStudy> = []
        for study in studies {
            
            let dbStudy = DBStudy()
            
            dbStudy.studyId = study.studyId
            dbStudy.category = study.category
            dbStudy.name = study.name
            dbStudy.sponserName = study.sponserName
            dbStudy.tagLine = study.description
            dbStudy.version = study.version
            dbStudy.logoURL = study.logoURL
            dbStudy.startDate = study.startDate
            dbStudy.endEnd = study.endEnd
            
            dbStudies.append(dbStudy)
        }
        
        let realm = try! Realm()
        print("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            realm.add(dbStudies, update: true)
            
        })
    }
    
    class func loadStudyListFromDatabase(completionHandler:@escaping (Array<Study>) -> ()){
        
        
        let realm = try! Realm()
        let dbStudies = realm.objects(DBStudy.self)
        
        var studies:Array<Study> = []
        for study in dbStudies {
            
            let dbStudy = Study()
            
            dbStudy.studyId = study.studyId
            dbStudy.category = study.category
            dbStudy.name = study.name
            dbStudy.sponserName = study.sponserName
            dbStudy.description = study.tagLine
            dbStudy.version = study.version
            dbStudy.logoURL = study.logoURL
            dbStudy.startDate = study.startDate
            dbStudy.endEnd = study.endEnd
            
            studies.append(dbStudy)
        }
        
        completionHandler(studies)
        
    }
    
    class func saveStudyOverview(overview:Overview , studyId:String){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",studyId)
        let dbStudy = studies.last
        
        
        
        //save overview
        let dbStudies = List<DBOverviewSection>()
        for sectionIndex in 0...(overview.sections.count-1) {
            
            let section = overview.sections[sectionIndex]
            let dbOverviewSection = DBOverviewSection()
            
            dbOverviewSection.title = section.title
            dbOverviewSection.link  = section.link
            dbOverviewSection.imageURL = section.imageURL
            dbOverviewSection.text = section.text
            dbOverviewSection.type = section.type
            dbOverviewSection.studyId = studyId
            dbOverviewSection.sectionId = studyId + "screen\(sectionIndex)"
            dbStudies.append(dbOverviewSection)
        }
        
       
        
        debugPrint("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            
            realm.add(dbStudies,update: true)
            dbStudy?.sections.append(objectsIn: dbStudies)
            dbStudy?.websiteLink = overview.websiteLink
            
            
        })
        
    }
    
    class func loadStudyOverview(studyId:String,completionHandler:@escaping (Overview?) -> ()){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",studyId)
        let dbStudy = studies.last
       
        
        if dbStudy?.sections != nil && (dbStudy?.sections.count)! > 0 {
            
            // inilize OverviewSection from database
            var overviewSections:Array<OverviewSection> = []
            for dbSection in (dbStudy?.sections)! {
                let section = OverviewSection()
                
                section.title = dbSection.title
                section.imageURL = dbSection.imageURL
                section.link = dbSection.link
                section.type = dbSection.type
                section.text = dbSection.text
                
                overviewSections.append(section)
            }
            
            //Create Overview object  
            let overview = Overview()
            overview.type = .study
            overview.websiteLink = dbStudy?.websiteLink
            overview.sections = overviewSections
            
            completionHandler(overview)
        }
        else {
            completionHandler(nil)
        }
     
        
    }
    
    
     //MARK:Activity
    class func saveActivities(activityies:Array<Activity>){
        
        let realm = try! Realm()
        let study = Study.currentStudy
        let dbActivityArray = realm.objects(DBActivity.self).filter({$0.studyId == study?.studyId})// "studyId == %@",study?.studyId)
        
        
        var dbActivities:Array<DBActivity> = []
        for activity in activityies {
          
            var dbActivity:DBActivity?
            if dbActivityArray.count != 0 {
                dbActivity = dbActivityArray.filter({$0.actvityId == activity.actvityId!}).last!
                
                if dbActivity == nil {
                    
                    dbActivity = DBHandler.getDBActivity(activity: activity)
                    dbActivities.append(dbActivity!)
                }
                else {
                    
                    try! realm.write({
                        
                        dbActivity?.type = activity.type?.rawValue
                        dbActivity?.name = activity.name
                        dbActivity?.startDate = activity.startDate
                        dbActivity?.endDate = activity.endDate
                        dbActivity?.frequencyType = activity.frequencyType.rawValue
                        do {
                            let json = ["data":activity.frequencyRuns]
                            let data =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
                            dbActivity?.frequencyRunsData = data
                        }
                        catch{
                            
                        }
                        
                    })

                }
            }
            else {
                
                dbActivity = DBHandler.getDBActivity(activity: activity)
                dbActivities.append(dbActivity!)
            }
            
        }
        
        
        print("DBPath : \(realm.configuration.fileURL)")
        if dbActivities.count > 0 {
            try! realm.write({
                realm.add(dbActivities, update: true)
                
            })
        }
       
    }
    
   private class func getDBActivity(activity:Activity)->DBActivity{
        
        let dbActivity = DBActivity()
        
        dbActivity.studyId = activity.studyId
        dbActivity.actvityId = activity.actvityId
        dbActivity.type = activity.type?.rawValue
        dbActivity.name = activity.name
        dbActivity.startDate = activity.startDate
        dbActivity.endDate = activity.endDate
        dbActivity.frequencyType = activity.frequencyType.rawValue
        do {
            let json = ["data":activity.frequencyRuns]
            let data =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            dbActivity.frequencyRunsData = data
        }
        catch{
            
        }
        return dbActivity
    }
    
    
    class func updateActivityRestortionDataFor(activityId:String,studyId:String,restortionData:Data?){
        
        let realm = try! Realm()
        let dbActivities = realm.objects(DBActivity.self).filter("studyId == %@ && actvityId == %@",studyId,activityId)
        let dbActivity = dbActivities.last
        
        print("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            dbActivity?.restortionData = restortionData
            realm.add(dbActivity!, update: true)
        })
        
        
    }
    
    
    class func loadActivityListFromDatabase(studyId:String,completionHandler:@escaping (Array<Activity>) -> ()){
        
        
        let realm = try! Realm()
        let dbActivities = realm.objects(DBActivity.self).filter("studyId == %@",studyId)
        let date = Date()
        var activities:Array<Activity> = []
        for dbActivity in dbActivities {
            
            let activity = Activity()
            activity.actvityId  = dbActivity.actvityId
            activity.studyId    = dbActivity.studyId
            activity.name       = dbActivity.name
            activity.startDate  = dbActivity.startDate
            activity.endDate    = dbActivity.endDate
            activity.type       = ActivityType(rawValue:dbActivity.type!)
            activity.frequencyType = Frequency(rawValue:dbActivity.frequencyType!)!
            activity.restortionData = dbActivity.restortionData
            activity.totalRuns = dbActivity.activityRuns.count
            
            do {
                let frequencyRuns = try JSONSerialization.jsonObject(with: dbActivity.frequencyRunsData!, options: []) as! [String:Any]
                activity.frequencyRuns = frequencyRuns["data"] as! Array<Dictionary<String, Any>>?
            }
            catch{
                
            }
            
            print("Database \(activity.totalRuns)")
            
            if activity.totalRuns != 0 {
                
                
                
                var runs:Array<ActivityRun> = []
                for dbRun in dbActivity.activityRuns {
                    let run = ActivityRun()
                    run .activityId = dbRun.activityId
                    run.complitionDate = dbRun.complitionDate
                    run.startDate = dbRun.startDate
                    run.endDate = dbRun.endDate
                    run.runId = dbRun.runId
                    run.studyId = dbRun.studyId
                    run.isCompleted = dbRun.isCompleted
                    
                    runs.append(run)
                }
                activity.activityRuns = runs
                
                
                var runsBeforeToday:Array<ActivityRun>! = []
                var run:ActivityRun!
                if activity.frequencyType == Frequency.One_Time && activity.endDate == nil {
                    //runsBeforeToday = runs
                    run = runs.last
                }
                else {
                    
                    runsBeforeToday = runs.filter({$0.endDate <= date})
                    
                    run = runs.filter({$0.startDate <= date && $0.endDate > date}).first //current run
                    
                }
                
                //var runsBeforeToday = runs.filter({$0.endDate <= date})
                
                //let run = runs.filter({$0.startDate <= date && $0.endDate > date}).first //current run
                
                let completedRuns = runs.filter({$0.isCompleted == true})
                let incompleteRuns = runsBeforeToday.count - completedRuns.count
                
                
                activity.compeltedRuns = completedRuns.count
                activity.incompletedRuns = (incompleteRuns < 0) ? 0 :incompleteRuns
                activity.currentRunId =  (run != nil) ? (run?.runId)! : runsBeforeToday.count
                activity.currentRun = run
                
                
            }
            
            
            
            activities.append(activity)
            
        }
        
        completionHandler(activities)
        
    }
    
    class func saveActivityRuns(activityId:String,studyId:String,runs:Array<ActivityRun>){
        
        let realm = try! Realm()
        let dbActivities = realm.objects(DBActivity.self).filter("studyId == %@ && actvityId == %@",studyId,activityId)
        let dbActivity = dbActivities.last
        
        //save overview
        let dbActivityRuns = List<DBActivityRun>()
        for sectionIndex in 0...(runs.count-1) {
            
            let activityRun = runs[sectionIndex]
            let dbActivityRun = DBActivityRun()
            dbActivityRun.startDate = activityRun.startDate
            dbActivityRun.endDate = activityRun.endDate
            dbActivityRun.activityId = activityId
            dbActivityRun.studyId = studyId
            dbActivityRun.runId = activityRun.runId
            dbActivityRun.isCompleted = activityRun.isCompleted
            
            dbActivityRuns.append(dbActivityRun)
        }
        debugPrint("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            
            //realm.add(dbActivityRuns)
            dbActivity?.activityRuns.append(objectsIn: dbActivityRuns)
            //dbStudy?.websiteLink = overview.websiteLink
            
            
        })
        
    }
    
    class func updateRunToComplete(runId:Int,activityId:String,studyId:String){
        
        let realm = try! Realm()
        let dbRuns = realm.objects(DBActivityRun.self).filter("studyId == %@ && activityId == %@ && runId == %d",studyId,activityId,runId)
        let dbRun = dbRuns.last
        
        try! realm.write({
            
           dbRun?.isCompleted = true
           //realm.add(dbRun!, update: true)
            
        })
        
    }

    
}
