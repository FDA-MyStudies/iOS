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
let kActivityInfo = "info"

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
    case questionnaire = "questionnaire"
    case activeTask = "active task"
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
    var result:ActivityResult?
    
    
    init() {
        //Default Initializer
        self.type = .questionnaire
        
        self.actvityId = ""
        // info
        self.studyId = ""
        self.name = ""
        self.version = "0"
        self.lastModified = Date()
        self.userStatus = .yetToJoin
        self.startDate = Date()
        self.endDate = Date()
        
        // questionnaireConfiguration
        self.branching = false
        self.randomization = false
        
        // Steps
        self.steps = Array()
        
        self.schedule = Schedule()
        self.result = ActivityResult()
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
                self.type = activityDict[kActivityType] as? ActivityType
            }
            
            
            self.setInfo(infoDict: activityDict[kActivityInfo] as! Dictionary<String,Any>)
            
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
    
    func setStepArray(stepArray:Array<Any>) {
        //method to set step array
        
        if Utilities.isValidObject(someObject: stepArray as AnyObject?){
            self.steps? = stepArray as! Array<Dictionary<String,Any>>
        }
        else{
            Logger.sharedInstance.debug("stepArray is null:\(stepArray)")
        }
    }
    
    func getNativeTask() -> ORKTask? {
        
        let orkTask:ORKTask?
        
        if Utilities.isValidObject(someObject: self.steps as AnyObject?) && Utilities.isValidValue(someObject: self.type as AnyObject?){
            
            var orkStepArray:[ORKStep]?
            
            switch self.type! as ActivityType{
                
            case .questionnaire:
                
                for var stepDict in self.steps! {
                    
                    if Utilities.isValidObject(someObject: stepDict as AnyObject?) {
                        
                        if Utilities.isValidValue(someObject: stepDict[kActivityStepType] as AnyObject ){
                            
                            switch stepDict[kActivityStepType] as! ActivityStepType {
                            case .instructionStep:
                                
                                let instructionStep:ActivityInstructionStep? = ActivityInstructionStep()
                                instructionStep?.initWithDict(stepDict: stepDict)
                                orkStepArray?.append((instructionStep?.getInstructionStep())!)
                                
                            case .questionStep:
                                
                                let questionStep:ActivityQuestionStep? = ActivityQuestionStep()
                                questionStep?.initWithDict(stepDict: stepDict)
                                orkStepArray?.append((questionStep?.getQuestionStep())!)
                                
                            case .formStep: break
                                
                                
                            default: break
                                
                            }
                            
                            
                        }
                    }
                    else{
                        Logger.sharedInstance.debug("Activity:stepDict is null:\(stepDict)")
                        break;
                    }
                }
                
                if (orkStepArray?.count)! > 0 {
                    
                   
                    
                    
                }
                
                
                
            case .activeTask: break
                
            default: break
                
            }
            
        }
        else{
            Logger.sharedInstance.debug("ActivityModel:steps Array is null:\(self.steps)")
        }
        
        return nil
    }
    
    
}









