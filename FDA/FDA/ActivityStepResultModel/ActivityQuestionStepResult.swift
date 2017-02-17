//
//  ActivityQuestionStepResult.swift
//  FDA
//
//  Created by Arun Kumar on 2/14/17.
//  Copyright © 2017 BTC. All rights reserved.
//


/*
import Foundation

class ActivityQuestionStepResult: ActivityStepResult {
    
    var resultType:QuestionStepType?
  
    var value: Any?
    override init() {
        super.init()
        resultType = .boolean
        skipped = false
        value = 0
    }
    
    override func initWithDict(stepDict: Dictionary<String, Any>) {
        if Utilities.isValidObject(someObject: stepDict as AnyObject?){
            
            super.initWithDict(stepDict: stepDict)
            
            if Utilities.isValidValue(someObject: stepDict[kActivityStepResultType] as AnyObject ){
                self.resultType = stepDict[kActivityStepResultType] as? QuestionStepType
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepSkippable] as AnyObject ){
                self.skipped = stepDict[kActivityStepSkippable] as? Bool
            }
            
            if   Utilities.isValidObject(someObject: stepDict[kStepQuestionTypeValue] as AnyObject) || Utilities.isValidValue(someObject: stepDict[kStepQuestionTypeValue] as AnyObject ) {
                
                switch stepDict[kActivityStepResultType] as! QuestionStepType {
                    
                case .scale:
                    self.value = stepDict[kStepQuestionTypeValue] as? Double
                case .continuousScale:
                    self.value = stepDict[kStepQuestionTypeValue] as? Double
                    
                case .textscale:
                    self.value = stepDict[kStepQuestionTypeValue] as? String
                    
                case .valuePicker:
                    self.value = stepDict[kStepQuestionTypeValue] as? String
                    
                case .imageChoice:
                    self.value = stepDict[kStepQuestionTypeValue] as? [String]
                    
                case .textChoice:
                    self.value = stepDict[kStepQuestionTypeValue] as? Bool
                    
                case .numeric:
                    self.value = stepDict[kStepQuestionTypeValue] as? Double
                    
                case .date:
                    self.value = stepDict[kStepQuestionTypeValue] as? String
                    
                case .text:
                    self.value = stepDict[kStepQuestionTypeValue] as? String
                    
                case .email:
                    self.value = stepDict[kStepQuestionTypeValue] as? String
                    
                case .timeInterval:
                    self.value = stepDict[kStepQuestionTypeValue] as? Double
                    
                case .height:
                    self.value = stepDict[kStepQuestionTypeValue] as? Double
                    
                case .location:
                    self.value = stepDict[kStepQuestionTypeValue] as? Dictionary<String,Any>
                    
                default:break
                    
                }
                
                
                
                
                // self.value = (stepDict[kStepQuestionTypeValue] as? Dictionary)!
            }
        }
        else{
            Logger.sharedInstance.debug("Question Step Dictionary is null:\(stepDict)")
        }
        
    }
    
}
*/
