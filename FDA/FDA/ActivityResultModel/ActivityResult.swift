//
//  ActivityResult.swift
//  FDA
//
//  Created by Arun Kumar on 2/15/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation

import ResearchKit

let kActivityResult = "result"
let kActivityResults = "results"


class ActivityResult {
    
    var type:ActivityType?
    weak var activity:Activity?
    var startTime:Date?
    var endTime:Date?
   
    var result:Array<ActivityStepResult>?
    //MARK: Initializers
    init() {
        self.type = .Questionnaire
        self.activity = Activity()
        self.startTime = Date()
        self.endTime = Date()
        
        self.result = Array()
    }
    
    
    /* Initializer method for the instance
     @param taskResult  is the task Result
     */
    
    func initWithORKTaskResult(taskResult:ORKTaskResult) {
        
        
        if Utilities.isValidObject(someObject: self.result as AnyObject?) == false && self.result?.count == 0 {
            
            var i = 0
            
            
            for stepResult in taskResult.results!{
                let activityStepResult:ActivityStepResult? = ActivityStepResult()
                
                
                if (self.activity?.activitySteps?.count )! > 0 {
                    
                    let activityStepArray = self.activity?.activitySteps?.filter({$0.key == stepResult.identifier
                    })
                    
                    if (activityStepArray?.count)! > 0 {
                        activityStepResult?.step  = activityStepArray?.first
                    }
                    
                }
                
                activityStepResult?.initWithORKStepResult(stepResult: stepResult as! ORKStepResult , activityType:(self.activity?.type)!)
                
                if stepResult.identifier != "CompletionStep"
                    && stepResult.identifier !=  kFetalKickInstructionStepIdentifier
                    && stepResult.identifier != kFetalKickIntroductionStepIdentifier
                    && stepResult.identifier != ORKInstruction0StepIdentifier
                    && stepResult.identifier != ORKInstruction1StepIdentifier
                    && stepResult.identifier != ORKConclusionStepIdentifier {
                    if activityStepResult?.step != nil && (activityStepResult?.step is ActivityInstructionStep) == false{
                        self.result?.append(activityStepResult!)
                    }
                    else{
                        
                        if self.activity?.type == .activeTask{
                            self.result?.append(activityStepResult!)
                        }
                        
                        
                    }
                    
                }
                
                print("###: \n  \(activityStepResult?.getActivityStepResultDict())")
                
                i = i + 1
            }
        }
        
        
    }
    
    
    /* Initializer method
     @param activityDict  contains all the activity related data
     */
    
    func initWithDict(activityDict:Dictionary<String, Any>){
        
        // setter method with Dictionary
        
        //Here the dictionary is assumed to have only type,startTime,endTime
        if Utilities.isValidObject(someObject: activityDict as AnyObject?){
            
            
            if Utilities.isValidValue(someObject: activityDict[kActivityType] as AnyObject ){
                self.type = activityDict[kActivityType] as? ActivityType
            }
            
            if Utilities.isValidValue(someObject: activityDict[kActivityStartTime] as AnyObject ) {
                
                if Utilities.isValidValue(someObject: Utilities.getDateFromString(dateString:(activityDict[kActivityStartTime] as? String)!) as AnyObject?) {
                    self.startTime =  Utilities.getDateFromString(dateString:(activityDict[kActivityStartTime] as? String)!)
                }
                else{
                    Logger.sharedInstance.debug("Date Conversion is null:\(activityDict)")
                }
                
                
            }
            if Utilities.isValidValue(someObject: activityDict[kActivityEndTime] as AnyObject ){
                
                if Utilities.isValidValue(someObject: Utilities.getDateFromString(dateString:(activityDict[kActivityEndTime] as? String)!) as AnyObject?) {
                    self.endTime =  Utilities.getDateFromString(dateString:(activityDict[kActivityEndTime] as? String)!)
                }
                else{
                    Logger.sharedInstance.debug("Date Conversion is null:\(activityDict)")
                }
            }
        }
        else{
            Logger.sharedInstance.debug("activityDict Result Dictionary is null:\(activityDict)")
        }
    }
    
    
    //MARK: Setter & getter methods for Activity
    func setActivity(activity:Activity)  {
        self.activity = activity
        
        self.type = activity.type
        
    }
    
    
    func getActivity() -> Activity {
        return self.activity!
    }
    
    
    //MARK: Setter & getter methods for ActivityResult
    func setActivityResult(activityStepResult:ActivityStepResult)  {
        self.result?.append(activityStepResult)
    }
    
    
    func getActivityResult() -> [ActivityStepResult] {
        return self.result!
    }
    
    
    /*
     getResultDictionary creates the dictionary for the step being used
     returns the dictionary of activitysteps
     */
    func getResultDictionary() -> Dictionary<String,Any>? {
        
        
        var activityDict:Dictionary<String,Any>? = Dictionary<String,Any>()
        
        if  self.type != nil{
            
            if self.type != .activeTask{
               // activityDict?[kActivityType] = self.type?.rawValue
                
                activityDict?[kActivityActiveKeyResultType] = self.type?.rawValue
            }
            
            //activityDict?[kActivityActiveKeyResultType] = (self.type?.rawValue == ActivityType.activeTask.rawValue ? "grouped" : self.type?.rawValue)
        }
        
        if self.startTime != nil && (Utilities.getStringFromDate(date: self.startTime!) != nil){
            
            activityDict?[kActivityStartTime] = Utilities.getStringFromDate(date: self.startTime!)
        }
        if self.endTime != nil && (Utilities.getStringFromDate(date: self.endTime!) != nil){
            
            activityDict?[kActivityEndTime] = Utilities.getStringFromDate(date: self.endTime!)
        }
        
        
        if Utilities.isValidObject(someObject: result as AnyObject?) {
            
            var activityResultArray :Array<Dictionary<String,Any>> =  Array<Dictionary<String,Any>>()
            for stepResult  in result! {
                let activityStepResult = stepResult as ActivityStepResult
                
                activityResultArray.append( (activityStepResult.getActivityStepResultDict())! as Dictionary<String,Any>)
                
            }
            
            activityDict?[kActivityResults] = activityResultArray
        }
        
        return activityDict!
    }
    
}
