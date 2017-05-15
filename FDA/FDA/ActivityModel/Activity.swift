//
//  Activity.swift
//  FDA
//
//  Created by Arun Kumar on 2/15/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit

//MARK:Api Constants
let kActivityType = "type"
let kActivityInfoMetaData = "metadata"

let kActivityInfo = "info"

let kActivityResponseData = "data"

let kActivityStudyId = "studyId"
let kActivityActivityId = "qId"
let kActivityName = "name"



let kActivityConfiguration = "configuration"

let kActivityFrequency = "frequency"
let kActivityFrequencyRuns = "runs"
let kActivityFrequencyType = "type"

let kActivityStartTime = "startTime"
let kActivityEndTime = "endTime"

let kActivitySteps = "steps"

// schedule Api Keys

let kActivityLifetime = "lifetime"
let kActivityRunLifetime = "runLifetime"


//questionnaireConfiguration
let kActivityBranching = "branching"
let kActivityRandomization = "randomization"


let kActivityLastModified = "lastModified"


enum ActivityType:String{
    case Questionnaire = "questionnaire"
    case activeTask = "task"
    //case questionnaireAndActiveTask = "QuestionnaireAndActiveTask"
}

enum Frequency:String {
    case One_Time = "One time"
    case Daily = "Daily"
    case Weekly = "Weekly"
    case Monthly = "Monthly"
    case Scheduled = "Manually Schedule"
    
    var description:String{
        switch self {
        case .One_Time:
            return "One Time"
        case .Daily:
            return "Daily"
        case .Weekly:
            return "Weekly"
        case .Monthly:
            return "Monthly"
        case .Scheduled:
            return "As Scheduled"
        
        }
    }
    
}

class Activity{
    
    var type:ActivityType?
    var actvityId:String?
    
    var studyId:String?
    var name:String? //this will come in activity list used to display
    var shortName:String? //this will come in meta data
    
    var version:String?
    var lastModified:Date?
    var userStatus:UserActivityStatus.ActivityStatus = .yetToJoin
    var startDate:Date?
    var endDate:Date?
    var branching:Bool?
    var randomization:Bool?
    
    var schedule:Schedule?
    var steps:Array<Dictionary<String,Any>>? = []
    var orkSteps:Array<ORKStep>? = []
    var activitySteps:Array<ActivityStep>? = []
    
    
    var frequencyRuns:Array<Dictionary<String, Any>>? = []
    var frequencyType:Frequency = .One_Time
    
    var result:ActivityResult?

    var restortionData:Data?
    var totalRuns = 0
    var currentRunId = 1
    var compeltedRuns = 0
    var incompletedRuns = 0
    var activityRuns:Array<ActivityRun>! = []
    var currentRun:ActivityRun! = nil
    var userParticipationStatus:UserActivityStatus! = nil
    
    init() {
        //Default Initializer
        self.type = .Questionnaire
        
        self.actvityId = ""
        // info
        self.studyId = ""
        self.name = ""
        //self.version = "0"
        self.lastModified = nil
        self.userStatus = .yetToJoin
        self.startDate = nil
        self.endDate = nil
        
        self.shortName = ""
        
        
        // questionnaireConfigurations
        self.branching = false
        self.randomization = false
        
        // Steps
        self.steps = Array()
        
        self.schedule = nil
        self.result = nil
        self.restortionData = Data()
        self.orkSteps =  Array<ORKStep>()
        
        self.activitySteps = Array<ActivityStep>()
        
        self.frequencyRuns = Array<Dictionary<String, Any>>()
        self.frequencyType = .One_Time
    }
    
    //MARK:Initializer Methods
    
    init(studyId:String,infoDict:Dictionary<String,Any>) {

    
    //func initWithStudyActivityList(infoDict:Dictionary<String, Any>) {
        // initializer for basic data from StudyActivitylist
        
        self.studyId = studyId
        
        //Need to reCheck with actual dictionary when passed
        if Utilities.isValidObject(someObject: infoDict as AnyObject?){
            
            if Utilities.isValidValue(someObject: infoDict[kActivityId] as AnyObject ){
                self.actvityId = infoDict[kActivityId] as! String?
            }
            
             if Utilities.isValidValue(someObject: infoDict[kActivityVersion] as AnyObject ){
                 self.version = infoDict[kActivityVersion] as! String?
             }
            
            
            if Utilities.isValidValue(someObject: infoDict[kActivityTitle] as AnyObject ){
                self.name = infoDict[kActivityTitle] as! String?
            }
            if Utilities.isValidValue(someObject: infoDict[kActivityType] as AnyObject ){
                self.type = ActivityType(rawValue: infoDict[kActivityType] as! String)
            }
            
            if Utilities.isValidValue(someObject: infoDict[kActivityStartTime] as AnyObject ){
                 self.startDate =  Utilities.getDateFromString(dateString: (infoDict[kActivityStartTime] as! String?)!)
            }
            else {
                self.startDate = Date()
            }
            
            if Utilities.isValidValue(someObject: infoDict[kActivityEndTime] as AnyObject ){
                self.endDate =  Utilities.getDateFromString(dateString: (infoDict[kActivityEndTime] as! String?)!)
            }
            
            if Utilities.isValidObject(someObject: infoDict[kActivityFrequency] as AnyObject?){
                //Need to reCheck with actual dictionary when passed
                
                let frequencyDict:Dictionary = infoDict[kActivityFrequency] as! Dictionary<String, Any>
                
                if Utilities.isValidObject(someObject: frequencyDict[kActivityFrequencyRuns] as AnyObject ){
                    self.frequencyRuns =  frequencyDict[kActivityFrequencyRuns] as? Array<Dictionary<String,Any>>
                }
                
                if Utilities.isValidValue(someObject: frequencyDict[kActivityFrequencyType] as AnyObject ){
                    self.frequencyType =  Frequency(rawValue:frequencyDict[kActivityFrequencyType] as! String )!
                }
                
            }
            
            self.calculateActivityRuns(studyId: self.studyId!)
        }
        else{
            Logger.sharedInstance.debug("infoDict is null:\(infoDict)")
        }
        
    }
    
    //MARK: Setter Methods
    func setActivityMetaData(activityDict:Dictionary<String,Any>) {
        // method to set  ActivityMetaData
        
        if Utilities.isValidObject(someObject: activityDict as AnyObject?){
            
            if Utilities.isValidValue(someObject: activityDict[kActivityType] as AnyObject ){
                self.type? =  ActivityType(rawValue:(activityDict[kActivityType] as? String)!)!
                print("activity type ===\(self.type) && dict value =\(activityDict[kActivityType])")
            }
            
            
            self.setInfo(infoDict: activityDict[kActivityInfoMetaData] as! Dictionary<String,Any>)
            
            
            //Next Phase Branching and Randomization
            
           // self.setConfiguration(configurationDict:activityDict[kActivityConfiguration] as! Dictionary<String,Any> )
            
            
            if Utilities.isValidObject(someObject: activityDict[kActivitySteps] as AnyObject?){
                 self.setStepArray(stepArray:activityDict[kActivitySteps] as! Array )
            }
            else{
                Logger.sharedInstance.debug("infoDict is null:\(activityDict[kActivitySteps])")
            }
        }
        else{
            Logger.sharedInstance.debug("infoDict is null:\(activityDict)")
        }
    }
    
    
    
    func setInfo(infoDict:Dictionary<String,Any>) {
        
        // method to set info part of activity from ActivityMetaData
        
        if Utilities.isValidObject(someObject: infoDict as AnyObject?){
//            if Utilities.isValidValue(someObject: infoDict[kActivityStudyId] as AnyObject ){
//                self.studyId =   infoDict[kActivityStudyId] as? String
//            }
//            if Utilities.isValidValue(someObject: infoDict[kActivityId] as AnyObject ){
//                self.actvityId =   infoDict[kActivityId] as? String
//            }
            
                        
            if Utilities.isValidValue(someObject: infoDict[kActivityTitle] as AnyObject ){
                self.shortName =   infoDict[kActivityTitle] as? String
            }
            
            if Utilities.isValidValue(someObject: infoDict[kActivityVersion] as AnyObject ){
                self.version =  infoDict[kActivityVersion] as? String
            }
            if Utilities.isValidValue(someObject: infoDict[kActivityStartTime] as AnyObject ){
                //self.startDate =  Utilities.getDateFromString(dateString: (infoDict[kActivityStartTime] as! String?)!)
            }
            if Utilities.isValidValue(someObject: infoDict[kActivityEndTime] as AnyObject ){
                //self.endDate =   Utilities.getDateFromString(dateString: (infoDict[kActivityEndTime] as! String?)!)
            }
            if Utilities.isValidValue(someObject: infoDict[kActivityLastModified] as AnyObject ){
                //self.lastModified =   Utilities.getDateFromString(dateString: (infoDict[kActivityLastModified] as! String?)!)
            }
            
        }
        else{
            Logger.sharedInstance.debug("infoDict is null:\(infoDict)")
        }
    }
    
    func setConfiguration(configurationDict:Dictionary<String,Any>)  {
        // method to set Configration
        
        if Utilities.isValidObject(someObject: configurationDict as AnyObject?){
            if Utilities.isValidValue(someObject: configurationDict[kActivityBranching] as AnyObject ){
                self.branching =   configurationDict[kActivityBranching] as? Bool
            }
            if Utilities.isValidValue(someObject: configurationDict[kActivityRandomization] as AnyObject ){
                self.randomization =   configurationDict[kActivityId] as? Bool
            }
            
            if Utilities.isValidValue(someObject: configurationDict[kActivityFrequency] as AnyObject ){
                //Usage of Frequency??
                
                //self.frequency =   configurationDict[kActivityFrequency] as? String
            }
        }
        else{
            Logger.sharedInstance.debug("configurationDict is null:\(configurationDict)")
        }
    }
    
    func setStepArray(stepArray:Array<Dictionary<String,Any>>) {
        //method to set step array
        
        if Utilities.isValidObject(someObject: stepArray as AnyObject?){
            self.steps? = stepArray
        }
        else{
            Logger.sharedInstance.debug("stepArray is null:\(stepArray)")
        }
    }
    
    func setORKSteps(orkStepArray:[ORKStep])  {
        if Utilities.isValidObject(someObject: orkStepArray as AnyObject?){
            self.orkSteps = orkStepArray
        }
        else{
            Logger.sharedInstance.debug("stepArray is null:\(orkStepArray)")
        }
        
    }
    
    func setActivityStepArray(stepArray:Array<ActivityStep>) {
        //method to set step array
        
        if Utilities.isValidObject(someObject: stepArray as AnyObject?){
            self.activitySteps? = stepArray
        }
        else{
            Logger.sharedInstance.debug("stepArray is null:\(stepArray)")
        }
    }
    
    
    func calculateActivityRuns(studyId:String){
        
        Schedule().getRunsForActivity(activity: self, handler: { (runs) in
            if runs.count > 0 {
                print("activityid: \(self.actvityId) runs \(runs.count)")
                self.activityRuns = runs
                
//                let date = Date()
//                print("Current Date :\(date.description)")
//                
//                var runsBeforeToday:Array<ActivityRun>! = []
//                var run:ActivityRun!
//                if self.frequencyType == Frequency.One_Time && activity.endDate == nil {
//                    //runsBeforeToday = runs
//                    run = runs.last
//                }
//                else {
//                    
//                    runsBeforeToday = runs.filter({$0.endDate <= date})
//                    
//                    run = runs.filter({$0.startDate <= date && $0.endDate > date}).first //current run
//                    
//                }
//                
//                
//                let completedRuns = runs.filter({$0.isCompleted == true})
//                let incompleteRuns = runsBeforeToday.count - completedRuns.count
//                
//                
//                activity.compeltedRuns = completedRuns.count
//                activity.incompletedRuns = (incompleteRuns < 0) ? 0 :incompleteRuns
//                activity.currentRunId =  (run != nil) ? (run?.runId)! : runsBeforeToday.count
//                activity.totalRuns = runs.count
//                activity.currentRun = run
//                activity.activityRuns = runs
//                
//                self.updateUserRunStatus(activity: activity)
                
//                DBHandler.saveActivityRuns(activityId: (activity.actvityId)!, studyId: (Study.currentStudy?.studyId)!, runs: runs)
            }
        })
    }
    
    func getRestortionData() -> Data {
        return self.restortionData!
    }
    func setRestortionData(restortionData:Data)  {
        self.restortionData = restortionData
    }
    
    
}









