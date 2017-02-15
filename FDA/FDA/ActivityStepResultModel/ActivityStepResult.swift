//
//  ActivityStepResult.swift
//  FDA
//
//  Created by Arun Kumar on 2/14/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation


let kActivityStepStartTime = "startTime"
let kActivityStepEndTime = "endTime"

let kActivityStepSkipped = "skipped"

class ActivityStepResult{
    
    var type:ActivityStepType?
    var step:ActivityStep?
    
    var key:String? // Identifier
    var startTime:Date?
    var endTime:Date?
    var skipped:Bool?
    var value:Any?
    
    init() {
        step = ActivityStep()
        self.type = .questionStep
        self.key = ""
        self.startTime = Date()
        self.endTime = Date()
        self.skipped = false
        self.value = 0
    
}
    
    func initWithDict(stepDict:Dictionary<String, Any>){
        
        // setter method with Dictionary
        if Utilities.isValidObject(someObject: stepDict as AnyObject?){
            
            
            if Utilities.isValidValue(someObject: stepDict[kActivityStepType] as AnyObject ){
                self.type = stepDict[kActivityStepType] as? ActivityStepType
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepKey] as AnyObject ){
                self.key = stepDict[kActivityStepKey] as? String
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepStartTime] as AnyObject ) {
                
                if Utilities.isValidValue(someObject: Utilities.getDateFromString(dateString:(stepDict[kActivityStepStartTime] as? String)!) as AnyObject?) {
                     self.startTime =  Utilities.getDateFromString(dateString:(stepDict[kActivityStepStartTime] as? String)!)
                }
                else{
                    Logger.sharedInstance.debug("Date Conversion is null:\(stepDict)")
                }
                
               
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepEndTime] as AnyObject ){
                
                if Utilities.isValidValue(someObject: Utilities.getDateFromString(dateString:(stepDict[kActivityStepEndTime] as? String)!) as AnyObject?) {
                    self.endTime =  Utilities.getDateFromString(dateString:(stepDict[kActivityStepEndTime] as? String)!)
                }
                else{
                    Logger.sharedInstance.debug("Date Conversion is null:\(stepDict)")
                }
        }
            
            if Utilities.isValidValue(someObject: stepDict[kActivityStepSkipped] as AnyObject ){
                self.skipped = stepDict[kActivityStepSkipped] as? Bool
            }
            
        }
        else{
            Logger.sharedInstance.debug("Step Result Dictionary is null:\(stepDict)")
        }
        
    }

    func setStep(step:ActivityStep)  {
        self.step = step
    }
    
    func getStep()-> ActivityStep {
       return self.step!
    }
}
       
