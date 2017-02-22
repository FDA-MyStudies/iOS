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

class ActivityResult {
    
    var type:ActivityType?
    var activity:Activity?
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
    
    func initWithORKTaskResult(taskResult:ORKTaskResult) {
        for stepResult in taskResult.results!{
            let activityStepResult:ActivityStepResult? = ActivityStepResult()
            
            
            activityStepResult?.initWithORKStepResult(stepResult: stepResult as! ORKStepResult , activityType:(self.activity?.type)!)
             self.result?.append(activityStepResult!)
            
        }
    }
    
    
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
    
    
    func getResultDictionary() -> Dictionary<String,Any>? {
        
        // method to get the dictionary for Api
        var activityDict:Dictionary<String,Any>?
        
        if Utilities.isValidValue(someObject: self.type as AnyObject?){
            activityDict?[kActivityType] = self.type
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
            
            
            activityDict?[kActivityResult] = activityResultArray
        }
        
        return activityDict!
    }
    
}
