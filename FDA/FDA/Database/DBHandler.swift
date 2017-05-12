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

    /* Used to save user details like userid, authkey, first name , last name etc*/
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
    
    /* Used to initialize the current logged in user*/
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
    
    /* Used to delete current logged in user*/
    class func deleteCurrentUser(){
        
        let realm = try! Realm()
        let dbUsers = realm.objects(DBUser.self)
        let dbUser = dbUsers.last
        try! realm.write {
            realm.delete(dbUser!)
        }
    }
    
    
    
     //MARK:Study
    /* Save studies 
     @params: studies - Array
     */
    func saveStudies(studies:Array<Study>){
        
        let realm = try! Realm()
        let dbStudiesArray = realm.objects(DBStudy.self)
      
        var dbStudies:Array<DBStudy> = []
        for study in studies {
            
            
            //some studies are already present in db
            var dbStudy:DBStudy?
            if dbStudiesArray.count > 0 {
                 dbStudy = dbStudiesArray.filter({$0.studyId ==  study.studyId}).last
            }
            
            if dbStudy == nil {
                dbStudy = DBHandler.getDBStudy(study: study)
                dbStudies.append(dbStudy!)
            }
            else {
                
                try! realm.write({
                    dbStudy?.category = study.category
                    dbStudy?.name = study.name
                    dbStudy?.sponserName = study.sponserName
                    dbStudy?.tagLine = study.description
                    dbStudy?.logoURL = study.logoURL
                    dbStudy?.startDate = study.startDate
                    dbStudy?.endEnd = study.endEnd
                    dbStudy?.status = study.status.rawValue
                    
                    if dbStudy?.participatedStatus == UserStudyStatus.StudyStatus.inProgress.rawValue {
                        dbStudy?.updatedVersion = "2"
                    }
                    else {
                        dbStudy?.version = study.version
                        dbStudy?.updatedVersion = study.version
                    }
                    
                })
                
            }
           
        }
        
        
        print("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            realm.add(dbStudies, update: true)
            
        })
    }
    
    private class func getDBStudy(study:Study) ->DBStudy{
        
        let dbStudy = DBStudy()
        dbStudy.studyId = study.studyId
        dbStudy.category = study.category
        dbStudy.name = study.name
        dbStudy.sponserName = study.sponserName
        dbStudy.tagLine = study.description
        dbStudy.version = study.version
        dbStudy.updatedVersion = study.version
        dbStudy.logoURL = study.logoURL
        dbStudy.startDate = study.startDate
        dbStudy.endEnd = study.endEnd
        dbStudy.enrolling = study.studySettings.enrollingAllowed
        dbStudy.rejoin = study.studySettings.rejoinStudyAfterWithdrawn
        dbStudy.platform = study.studySettings.platform
        dbStudy.status = study.status.rawValue
        dbStudy.participatedStatus = study.userParticipateState.status.rawValue
        
        return dbStudy
        
    }
    
    class func loadStudyListFromDatabase(completionHandler:@escaping (Array<Study>) -> ()){
        
        
        let realm = try! Realm()
        let dbStudies = realm.objects(DBStudy.self)
        
        var studies:Array<Study> = []
        for dbStudy in dbStudies {
            
            let study = Study()
            
            study.studyId = dbStudy.studyId
            study.category = dbStudy.category
            study.name = dbStudy.name
            study.sponserName = dbStudy.sponserName
            study.description = dbStudy.tagLine
            study.version = dbStudy.version
            study.newVersion = dbStudy.updatedVersion
            study.logoURL = dbStudy.logoURL
            study.startDate = dbStudy.startDate
            study.endEnd = dbStudy.endEnd
            study.status = StudyStatus(rawValue:dbStudy.status!)!
            study.signedConsentVersion = dbStudy.signedConsentVersion
            study.signedConsentFilePath = dbStudy.signedConsentFilePath
            
            //settings
            let studySettings = StudySettings()
            studySettings.enrollingAllowed = dbStudy.enrolling
            studySettings.rejoinStudyAfterWithdrawn = dbStudy.rejoin
            studySettings.platform = dbStudy.platform!
            
            study.studySettings = studySettings
            
            //status
            let participatedStatus = UserStudyStatus()
            participatedStatus.status = UserStudyStatus.StudyStatus(rawValue:dbStudy.participatedStatus)!
            participatedStatus.bookmarked = dbStudy.bookmarked
            participatedStatus.studyId = dbStudy.studyId
            study.userParticipateState = participatedStatus
            
            studies.append(study)
        }
        
        completionHandler(studies)
        
    }
    
    /* Save study overview
     @params: overview , String
     */
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
    
    class func updateMetaDataToUpdateForStudy(study:Study , updateDetails:StudyUpdates?){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",study.studyId)
        let dbStudy = studies.last
        
        try! realm.write({
            
            dbStudy?.updateResources = StudyUpdates.studyResourcesUpdated
            dbStudy?.updateConsent = StudyUpdates.studyConsentUpdated
            dbStudy?.updateActivities = StudyUpdates.studyActivitiesUpdated
            dbStudy?.updateInfo = StudyUpdates.studyInfoUpdated
            dbStudy?.version = dbStudy?.updatedVersion//StudyUpdates.studyVersion
           // dbStudy?.updatedVersion = StudyUpdates.studyVersion
            
        })
        
    }
    
    class func updateStudyParticipationStatus(study:Study){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",study.studyId)
        let dbStudy = studies.last
        
        try! realm.write({
            
             dbStudy?.participatedStatus = study.userParticipateState.status.rawValue
            
        })
        
       

    }
    
    class func loadStudyDetailsToUpdate(studyId:String,completionHandler:@escaping (Bool) -> ()){
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",studyId)
        let dbStudy = studies.last
        
        StudyUpdates.studyActivitiesUpdated = (dbStudy?.updateActivities)!
        StudyUpdates.studyConsentUpdated = (dbStudy?.updateConsent)!
        StudyUpdates.studyResourcesUpdated = (dbStudy?.updateResources)!
        StudyUpdates.studyInfoUpdated = (dbStudy?.updateInfo)!
        
        completionHandler(true)
    }
    
    
    class func saveConsentInformation(study:Study){
        
        let realm = try! Realm()
        let studies =  realm.objects(DBStudy.self).filter("studyId == %@",study.studyId)
        let dbStudy = studies.last
        
        try! realm.write({
            
            dbStudy?.signedConsentFilePath = study.signedConsentFilePath
            dbStudy?.signedConsentVersion = study.signedConsentVersion
            
        })
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
    
    
    class func updateActivityRestortionDataFor(activity:Activity,studyId:String,restortionData:Data?){
        
        let realm = try! Realm()
        let dbActivities = realm.objects(DBActivityRun.self).filter({$0.activityId == activity.actvityId && $0.studyId == studyId && $0.runId == activity.currentRun.runId}) //.filter("studyId == %@ && actvityId == %@ && runId == %@",studyId,activity.actvityId,activity.currrentRun.runId)
        let dbActivity = dbActivities.last
        
        print("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            dbActivity?.restortionData = restortionData
            //realm.add(dbActivity!, update: true)
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
                    run.restortionData = dbRun.restortionData
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
    
    class func loadAllStudyRuns(studyId:String,completionHandler:@escaping (_ completion:Int,_ adherence:Int) -> ()){
        
        let date = Date()
        let realm = try! Realm()
        let studyRuns = realm.objects(DBActivityRun.self).filter("studyId == %@",studyId)
        let completedRuns = studyRuns.filter({$0.isCompleted == true})
        let runsBeforeToday = studyRuns.filter({($0.endDate == nil) || ($0.endDate <= date)})
        let incompleteRuns = runsBeforeToday.count - completedRuns.count
        
         let completion = ceil( Double(self.divide(lhs: (completedRuns.count + incompleteRuns)*100, rhs: studyRuns.count)) )
        let adherence = ceil (Double(self.divide(lhs: (completedRuns.count)*100, rhs: (completedRuns.count + incompleteRuns))))
        //let completion = ceil( Double((completedRuns.count + incompleteRuns)*100/studyRuns.count) )
        //let adherence = ceil (Double((completedRuns.count)*100/(completedRuns.count + incompleteRuns)))
        
        completionHandler(Int(completion),Int(adherence))
        
        
        print("complete: \(completedRuns.count) , incomplete: \(incompleteRuns)")
        
    }
    static func divide(lhs: Int, rhs: Int) -> Int {
        if rhs == 0 {
            return 0
        }
        return lhs/rhs
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

    //MARK: Dashboard
    class func saveDashBoardStatistics(studyId:String,statistics:Array<DashboardStatistics>){
        
        let realm = try! Realm()
        let dbStatisticsArray = realm.objects(DBStatistics.self).filter({$0.studyId == studyId})// "studyId == %@",study?.studyId)
        
        
        var dbStatisticsList:Array<DBStatistics> = []
        for stats in statistics {
            
            var dbStatistics:DBStatistics?
            if dbStatisticsArray.count != 0 {
                dbStatistics = dbStatisticsArray.filter({$0.activityId == stats.activityId!}).last!
                
                if dbStatistics == nil {
                    
                    dbStatistics = DBHandler.getDBStatistics(stats: stats)
                    dbStatisticsList.append(dbStatistics!)
                }
                else {
                    
                    try! realm.write({
                        
                        dbStatistics?.activityId = stats.activityId
                        dbStatistics?.activityVersion = stats.activityVersion
                        dbStatistics?.calculation = stats.calculation
                        dbStatistics?.dataSourceKey = stats.dataSourceKey
                        dbStatistics?.dataSourceType = stats.dataSourceType
                        dbStatistics?.displayName = stats.displayName
                        dbStatistics?.title = stats.title
                        dbStatistics?.statType = stats.statType
                        dbStatistics?.studyId = stats.studyId
                        dbStatistics?.unit = stats.unit
                        
                    })
                    
                }
            }
            else {
                
                dbStatistics = DBHandler.getDBStatistics(stats: stats)
                dbStatisticsList.append(dbStatistics!)
            }
            
        }
        
        
        print("DBPath : \(realm.configuration.fileURL)")
        if dbStatisticsList.count > 0 {
            try! realm.write({
                realm.add(dbStatisticsList, update: true)
                
            })
        }
    }
    
    private class func getDBStatistics(stats:DashboardStatistics)->DBStatistics{
        
        let dbStatistics = DBStatistics()
        dbStatistics.activityId = stats.activityId
        dbStatistics.activityVersion = stats.activityVersion
        dbStatistics.calculation = stats.calculation
        dbStatistics.dataSourceKey = stats.dataSourceKey
        dbStatistics.dataSourceType = stats.dataSourceType
        dbStatistics.displayName = stats.displayName
        dbStatistics.title = stats.title
        dbStatistics.statType = stats.statType
        dbStatistics.studyId = stats.studyId
        dbStatistics.unit = stats.unit
        dbStatistics.statisticsId = stats.studyId! + stats.title!
        
        return dbStatistics
        
    }
    
    class func loadStatisticsForStudy(studyId:String,completionHandler:@escaping (Array<DashboardStatistics>) -> ()){
        
        
        let realm = try! Realm()
        let dbStatisticsList = realm.objects(DBStatistics.self).filter("studyId == %@",studyId)
        
        var statsList:Array<DashboardStatistics> = []
        for dbStatistics in dbStatisticsList {
            
            let stats = DashboardStatistics()
            stats.activityId =  dbStatistics.activityId
            stats.activityVersion  = dbStatistics.activityVersion
            stats.calculation = dbStatistics.calculation
            stats.dataSourceKey = dbStatistics.dataSourceKey
            stats.dataSourceType = dbStatistics.dataSourceType
            stats.displayName = dbStatistics.displayName
            stats.title = dbStatistics.title
            stats.statType = dbStatistics.statType
            stats.studyId = dbStatistics.studyId
            stats.unit = dbStatistics.unit
            stats.statList = dbStatistics.statisticsData
            
            statsList.append(stats)
        }
        completionHandler(statsList)
        
    }
    
    
    class func saveStatisticsDataFor(activityId:String,key:String,data:Float){
        
        let realm = try! Realm()
        let dbStatisticsList = realm.objects(DBStatistics.self).filter("activityId == %@ && dataSourceKey == %@",activityId,key)
        
        if dbStatisticsList.count > 0 {
            let dbStatistics = dbStatisticsList.last
            
            if dbStatistics != nil {
                
                //save data
                let statData = DBStatisticsData()
                statData.startDate = Date()
                statData.data = data
                
                try! realm.write({
                    dbStatistics?.statisticsData.append(statData)
                    
                })
            }
            
        }
     }
    
}
