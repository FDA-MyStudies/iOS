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

let kActivityStudyId = "studyId"
let kActivityActivityId = "qId"
let kActivityName = "name"
let kActivityConfiguration = "configuration"
let kActivityStartTime = "startTime"
let kActivityEndTime = "endTime"

let kActivitySteps = "steps"

// schedule Api Keys

let kActivityLifetime = "lifetime"
let kActivityRunLifetime = "runLifetime"


//questionnaireConfiguration
let kActivityBranching = "branching"
let kActivityRandomization = "randomization"
let kActivityFrequency = "frequency"

let kActivityLastModified = "lastModified"


enum ActivityType:String{
    case Questionnaire = "Questionnaire"
    case activeTask = "task"
    
    case questionnaireAndActiveTask = "QuestionnaireAndActiveTask"
}



class Activity{
    
    var type:ActivityType?
    var actvityId:String?
    
    var studyId:String?
    var name:String?
    var version:String?
    var lastModified:Date?
    var userStatus:UserStudyStatus.StudyStatus?
    var startDate:Date?
    var endDate:Date?
    var branching:Bool?
    var randomization:Bool?
    
    var schedule:Schedule?
    var steps:Array<Dictionary<String,Any>>?
    var orkSteps:Array<ORKStep>?
    var activitySteps:Array<ActivityStep>?
    
    var result:ActivityResult?
    
    var restortionData:Data?
    
    init() {
        //Default Initializer
        self.type = .Questionnaire
        
        self.actvityId = ""
        // info
        self.studyId = ""
        self.name = ""
        self.version = "0"
        self.lastModified = nil
        self.userStatus = .yetToJoin
        self.startDate = nil
        self.endDate = nil
        
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
    }
    
    //MARK:Initializer Methods
    
    func initWithStudyActivityList(infoDict:Dictionary<String, Any>) {
        // initializer for basic data from StudyActivitylist
        
        
        //Need to reCheck with actual dictionary when passed
        if Utilities.isValidObject(someObject: infoDict as AnyObject?){
            
            if Utilities.isValidValue(someObject: infoDict[kActivityId] as AnyObject ){
                self.actvityId = infoDict[kActivityId] as! String?
            }
            if Utilities.isValidValue(someObject: infoDict[kActivityVersion] as AnyObject ){
                self.version = infoDict[kActivityVersion] as! String?
            }
            if Utilities.isValidValue(someObject: infoDict[kActivityName] as AnyObject ){
                self.name = infoDict[kActivityName] as! String?
            }
            if Utilities.isValidValue(someObject: infoDict[kActivityType] as AnyObject ){
                self.type = infoDict[kActivityType] as? ActivityType
            }
            
            if Utilities.isValidObject(someObject: infoDict[kActivityConfiguration] as AnyObject?){
                //Need to reCheck with actual dictionary when passed
                
                let configurationDict:Dictionary = infoDict[kActivityConfiguration] as! Dictionary<String, Any>
                
                if Utilities.isValidValue(someObject: configurationDict[kActivityStartTime] as AnyObject ){
                    self.startDate =  Utilities.getDateFromString(dateString: (configurationDict[kActivityStartTime] as! String?)!)
                }
                
                if Utilities.isValidValue(someObject: infoDict[kActivityEndTime] as AnyObject ){
                    self.endDate =  Utilities.getDateFromString(dateString: (configurationDict[kActivityEndTime] as! String?)!)
                }
                
                //Lifetime and runlife time will be used for scheduling -----PENDING
                
                
            }
            
            
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
            
            self.setConfiguration(configurationDict:activityDict[kActivityConfiguration] as! Dictionary<String,Any> )
            self.setStepArray(stepArray:activityDict[kActivitySteps] as! Array )
            
        }
        else{
            Logger.sharedInstance.debug("infoDict is null:\(activityDict)")
        }
    }
    
    
    
    func setInfo(infoDict:Dictionary<String,Any>) {
        
        // method to set info part of activity from ActivityMetaData
        
        if Utilities.isValidObject(someObject: infoDict as AnyObject?){
            if Utilities.isValidValue(someObject: infoDict[kActivityStudyId] as AnyObject ){
                self.studyId =   infoDict[kActivityStudyId] as? String
            }
            if Utilities.isValidValue(someObject: infoDict[kActivityId] as AnyObject ){
                self.actvityId =   infoDict[kActivityId] as? String
            }
            
            if Utilities.isValidValue(someObject: infoDict[kActivityName] as AnyObject ){
                self.name =   infoDict[kActivityName] as? String
            }
            
            if Utilities.isValidValue(someObject: infoDict[kActivityVersion] as AnyObject ){
                self.version =  infoDict[kActivityVersion] as? String
            }
            if Utilities.isValidValue(someObject: infoDict[kActivityStartTime] as AnyObject ){
                self.startDate =  Utilities.getDateFromString(dateString: (infoDict[kActivityStartTime] as! String?)!)
            }
            if Utilities.isValidValue(someObject: infoDict[kActivityEndTime] as AnyObject ){
                self.endDate =   Utilities.getDateFromString(dateString: (infoDict[kActivityEndTime] as! String?)!)
            }
            if Utilities.isValidValue(someObject: infoDict[kActivityLastModified] as AnyObject ){
                self.lastModified =   Utilities.getDateFromString(dateString: (infoDict[kActivityLastModified] as! String?)!)
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
    
    
    
    
    func getRestortionData() -> Data {
       return self.restortionData!
    }
    func setRestortionData(restortionData:Data)  {
        self.restortionData = restortionData
    }
    
 
}









