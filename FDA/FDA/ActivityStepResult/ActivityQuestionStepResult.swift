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
        resultType = .booleanQuestionStep
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
                    
                case .scaleQuestionStep:
                    self.value = stepDict[kStepQuestionTypeValue] as? Double
                case .continuousScaleQuestionStep:
                    self.value = stepDict[kStepQuestionTypeValue] as? Double
                    
                case .textScaleQuestionStep:
                    self.value = stepDict[kStepQuestionTypeValue] as? String
                    
                case .valuePickerChoiceQuestionStep:
                    self.value = stepDict[kStepQuestionTypeValue] as? String
                    
                case .imageChoiceQuestionStep:
                    self.value = stepDict[kStepQuestionTypeValue] as? [String]
                    
                case .textChoiceQuestionStep:
                    self.value = stepDict[kStepQuestionTypeValue] as? Bool
                    
                case .numericQuestionStep:
                    self.value = stepDict[kStepQuestionTypeValue] as? Double
                    
                case .dateQuestionStep:
                    self.value = stepDict[kStepQuestionTypeValue] as? String
                    
                case .textQuestionStep:
                    self.value = stepDict[kStepQuestionTypeValue] as? String
                    
                case .validatedTextQuestionStepEmail:
                    self.value = stepDict[kStepQuestionTypeValue] as? String
                    
                case .timeIntervalQuestionStep:
                    self.value = stepDict[kStepQuestionTypeValue] as? Double
                    
                case .heightQuestion:
                    self.value = stepDict[kStepQuestionTypeValue] as? Double
                    
                case .locationQuestionStep:
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
