//
//  ActivityStep.swift
//  FDA
//
//  Created by Arun Kumar on 2/13/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit

//Api Constants

let kActivityStepType = "type"

let kActivityStepActivityId = "activityId"
let kActivityStepResultType = "resultType"
let kActivityStepKey = "key"
let kActivityStepTitle = "title"
let kActivityStepText = "text"
let kActivityStepSkippable = "skippable"
let kActivityStepGroupName = "groupName"
let kActivityStepRepeatable = "repeatable"
let kActivityStepRepeatableText = "repeatableText"
let kActivityStepDestinations = "destinations"




enum ActivityStepType:String{
    case formStep = "form"
    case instructionStep = "instruction"
    case questionStep = "question"
    case activeStep = "task" // active step
    case noneStep = "none"
}


class ActivityStep{
    
    var activityId:String?
    var type:ActivityStepType?
    
    var resultType:Any?
    var key:String?
    var title:String?
    var text:String?
    var  skippable:Bool?
    var groupName:String?
    var repeatable:Bool?
    var repeatableText:String?
    
    var destinations:Array<Any>?
    
    
    init() {
        self.activityId = ""
        self.type = .noneStep
        self.resultType = ""
        self.key = ""
        self.title = ""
        self.text = ""
        self.skippable = false
        self.groupName = ""
        self.repeatable = false
        self.repeatableText = ""
        self.destinations = Array()

    }
    
    
    init(activityId:String,type:ActivityStepType,resultType:String,key:String,title:String,text:String,skippable:Bool,groupName:String,repeatable:Bool,repeatableText:String, destinations:Array<Any>) {
        
        
        self.activityId = activityId
         self.type = type
         self.resultType = resultType
         self.key = key
         self.title = title
         self.text = text
         self.skippable = skippable
         self.groupName = groupName
         self.repeatable = repeatable
         self.repeatableText = repeatableText
         self.destinations = destinations
    }
    
    func initWithDict(stepDict:Dictionary<String, Any>){
        if Utilities.isValidObject(someObject: stepDict as AnyObject?){
            
            if Utilities.isValidValue(someObject: stepDict[kActivityStepActivityId] as AnyObject ){
                self.activityId = stepDict[kActivityStepActivityId] as? String
            }
            
            if Utilities.isValidValue(someObject: stepDict[kActivityStepType] as AnyObject ){
                self.type = stepDict[kActivityStepType] as? ActivityStepType
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepResultType] as AnyObject ){
                self.resultType = stepDict[kActivityStepResultType] as? String
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepKey] as AnyObject ){
                self.key = stepDict[kActivityStepKey] as? String
            }
            if Utilities.isValidObject(someObject: stepDict[kActivityStepTitle] as AnyObject ) {
                 self.title = stepDict[kActivityStepTitle] as? String
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepText] as AnyObject )  {
                self.text = stepDict[kActivityStepText] as? String
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepSkippable] as AnyObject )  {
                self.skippable = stepDict[kActivityStepSkippable] as? Bool
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepGroupName] as AnyObject )  {
                self.groupName = stepDict[kActivityStepGroupName] as? String
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepRepeatable] as AnyObject )  {
                self.repeatable = stepDict[kActivityStepRepeatable] as? Bool
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepRepeatableText] as AnyObject )  {
                self.repeatableText = stepDict[kActivityStepRepeatableText] as? String
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepDestinations] as AnyObject )  {
                self.destinations = stepDict[kActivityStepDestinations] as? Array
            }
        
        }
        else{
            Logger.sharedInstance.debug("Step Dictionary is null:\(stepDict)")
        }

    }
    
    
    
    
    
}
