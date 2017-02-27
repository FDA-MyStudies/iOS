//
//  ActivityStep.swift
//  FDA
//
//  Created by Arun Kumar on 2/13/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit

//MARK: Api Constants

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



//MARK:Enum for ActivityStepType
enum ActivityStepType:String{
    case form = "form"
    case instruction = "instruction"
    case question = "question"
    case active = "task" // active step
    
    
    case taskSpatialSpanMemory = "task-spatialSpanMemory"
    case taskTowerOfHanoi = "task-towerOfHanoi"
    
}





class ActivityStep{
    
    var activityId:String?
    var type:ActivityStepType?
    
    var resultType:Any?
    var key:String? // Identifier
    var title:String?
    var text:String?
    var  skippable:Bool?
    var groupName:String?
    var repeatable:Bool?
    var repeatableText:String?
    
    var destinations:Dictionary<String,Any>?
    
    
    init() {
        /* default Intalizer method */
        
        self.activityId = ""
        self.type = .question
        self.resultType = ""
        self.key = ""
        self.title = ""
        self.text = ""
        self.skippable = false
        self.groupName = ""
        self.repeatable = false
        self.repeatableText = ""
        self.destinations = Dictionary()
        
    }
    
    
    init(activityId:String,type:ActivityStepType,resultType:String,key:String,title:String,text:String,skippable:Bool,groupName:String,repeatable:Bool,repeatableText:String, destinations:Dictionary<String,Any>) {
        /* initializer method with all params
         */
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
        
        /* setter method which initializes all params
         @stepDict:contains as key:Value pair for all the properties of ActiveStep
         */
        
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
            if Utilities.isValidValue(someObject: stepDict[kActivityStepTitle] as AnyObject ) {
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
                self.destinations = stepDict[kActivityStepDestinations] as? Dictionary<String, Any>
            }
            
        }
        else{
            Logger.sharedInstance.debug("Step Dictionary is null:\(stepDict)")
        }
        
    }
    
    func getNativeStep() -> ORKStep? {
        
        /* method the create ORKStep
         returns ORKstep
         NOTE:Currently not in Use
         */
        
        if Utilities.isValidValue(someObject: self.key as AnyObject?){
            return ORKStep(identifier:self.key! )
        }
        else{
            return nil
        }
        
    }
    
    
    
    
}
