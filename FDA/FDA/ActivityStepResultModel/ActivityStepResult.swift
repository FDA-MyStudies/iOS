//
//  ActivityStepResult.swift
//  FDA
//
//  Created by Arun Kumar on 2/14/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit

let kActivityStepStartTime = "startTime"
let kActivityStepEndTime = "endTime"

let kActivityStepSkipped = "skipped"
let kActivityStepResultValue = "value"




class ActivityStepResult{
    
    var type:String?
    weak var step:ActivityStep?
    var key:String? // Identifier
    var startTime:Date?
    var endTime:Date?
    var skipped:Bool?
    var value:Any?
    
    init() {
        step = ActivityStep()
        self.type = ""
        self.key = ""
        self.startTime = Date.init(timeIntervalSinceNow: 0)
        self.endTime = Date.init(timeIntervalSinceNow: 0)
        self.skipped = false
        self.value = 0
        
    }
    //MARK: Method
    func initWithDict(stepDict:Dictionary<String, Any>){
        
        /* method create ActivityStepResult by initializing params
         @stepDict:contains all ActivityResultStep properties
         */
        
        if Utilities.isValidObject(someObject: stepDict as AnyObject?){
            
            
            if Utilities.isValidValue(someObject: stepDict[kActivityStepType] as AnyObject ){
                self.type = stepDict[kActivityStepType] as? String
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
    
    
    func getActivityStepResultDict() -> Dictionary<String, Any>? {
        /* method creates a ActivityStepDictionary from step instance
         returns ResultDictionary for storing data to Api/Local
         */
        var stepDict:Dictionary<String,Any>?
        
        if (self.step != nil){
            stepDict?[kActivityStepResultType] = self.step?.resultType
        }
        if Utilities.isValidValue(someObject: self.key as AnyObject?){
            
            stepDict?[kActivityStepKey] = self.key
        }
        if self.startTime != nil && (Utilities.getStringFromDate(date: self.startTime!) != nil){
            
            stepDict?[kActivityStartTime] = Utilities.getStringFromDate(date: self.startTime!)
        }
        if self.endTime != nil && (Utilities.getStringFromDate(date: self.endTime!) != nil){
            
            stepDict?[kActivityEndTime] = Utilities.getStringFromDate(date: self.endTime!)
        }
        stepDict?[kActivityStepSkipped] = self.skipped
        
        if self.value != nil {
            stepDict?[kActivityStepResultValue] = self.value
        }
        
        return stepDict
    }
    
    
    
    func setResultValue(stepResult:ORKResult)  {
        /* method saves the result of Current Step
         @stepResult: stepResult which can be result of Questionstep/InstructionStep/ActiveTask
         */
        
        
        //Active task Pending
        
        if (QuestionStepType(rawValue: (self.type?.replacingOccurrences(of: "Result", with: ""))!) != nil) {
            // for question Step
            
            switch  QuestionStepType(rawValue: (self.type?.replacingOccurrences(of: "Result", with: ""))!)! as QuestionStepType{
                
            case .scale :
                let stepTypeResult = stepResult as! ORKScaleQuestionResult
                
                if Utilities.isValidValue(someObject: stepTypeResult.scaleAnswer as AnyObject?){
                    self.value = stepTypeResult.scaleAnswer as! Double
                }
                else{
                    self.value = 0.0
                }
                
            case .continuousScale:
                let stepTypeResult = stepResult as! ORKScaleQuestionResult
                
                if Utilities.isValidValue(someObject: stepTypeResult.scaleAnswer as AnyObject?){
                    self.value = stepTypeResult.scaleAnswer as! Double
                }
                else{
                    self.value = 0.0
                }
                
            case .textscale:
                
                let stepTypeResult = stepResult as! ORKTextQuestionResult
                if Utilities.isValidValue(someObject: stepTypeResult.textAnswer as AnyObject?){
                    self.value = stepTypeResult.textAnswer!
                }
                else{
                    self.value = ""
                }
                
                
            case .boolean:
                
                let stepTypeResult = stepResult as! ORKBooleanQuestionResult
                
                if Utilities.isValidValue(someObject: stepTypeResult.booleanAnswer as AnyObject?){
                    self.value = stepTypeResult.booleanAnswer!
                }
                else{
                    self.value = 0
                }
                
                
            case .valuePicker:
                let stepTypeResult = stepResult as! ORKTextQuestionResult
                if Utilities.isValidValue(someObject: stepTypeResult.textAnswer as AnyObject?){
                    
                    self.value = stepTypeResult.textAnswer!
                }
                else{
                    self.value = ""
                }
                
            case .imageChoice:
                
                let stepTypeResult = stepResult as! ORKChoiceQuestionResult
                
                if Utilities.isValidValue(someObject: stepTypeResult.choiceAnswers as AnyObject?){
                    self.value =  stepTypeResult.choiceAnswers?[0] as? String
                }
                else{
                    self.value = ""
                }
            case .textChoice:
                
                let stepTypeResult = stepResult as! ORKChoiceQuestionResult
                
                if Utilities.isValidValue(someObject: stepTypeResult.choiceAnswers as AnyObject?){
                    self.value =  stepTypeResult.choiceAnswers
                }
                else{
                    self.value = Array<String>()
                }
                
            case .numeric:
                let stepTypeResult = stepResult as! ORKNumericQuestionResult
                
                if Utilities.isValidValue(someObject: stepTypeResult.numericAnswer as AnyObject?){
                    self.value =  Double(stepTypeResult.numericAnswer!)
                }
                else{
                    self.value = 0.0
                }
                
            case .timeOfDay:
                
                let stepTypeResult = stepResult as! ORKTimeOfDayQuestionResult
                
                if (stepTypeResult.dateComponentsAnswer?.isValidDate)!{
                    self.value =  "\(stepTypeResult.dateComponentsAnswer?.hour)" + ":" + "\(stepTypeResult.dateComponentsAnswer?.minute)" + ":" + "\(stepTypeResult.dateComponentsAnswer?.second)"
                }
                else{
                    self.value = "00:00:00"
                }
                
            case .date:
                let stepTypeResult = stepResult as! ORKDateQuestionResult
                
                if Utilities.isValidValue(someObject: stepTypeResult.dateAnswer as AnyObject?){
                    self.value =  Utilities.getStringFromDate(date: stepTypeResult.dateAnswer! )
                }
                else{
                    self.value = "00:00:0000"
                }
                
            case .text:
                
                let stepTypeResult = stepResult as! ORKTextQuestionResult
                
                if Utilities.isValidValue(someObject: stepTypeResult.answer as AnyObject?){
                    self.value = stepTypeResult.answer
                }
                else{
                    self.value = ""
                }
                
            case .email:
                
                let stepTypeResult = stepResult as! ORKTextQuestionResult
                
                if Utilities.isValidValue(someObject: stepTypeResult.textAnswer as AnyObject?){
                    self.value = stepTypeResult.textAnswer
                }
                else{
                    self.value = ""
                }
                
            case .timeInterval:
                
                let stepTypeResult = stepResult as! ORKTimeIntervalQuestionResult
                
                if Utilities.isValidValue(someObject: stepTypeResult.intervalAnswer as AnyObject?){
                    self.value = stepTypeResult.intervalAnswer
                }
                else{
                    self.value = 0
                }
                
                
            case .height:
                
                let stepTypeResult = stepResult as! ORKTextQuestionResult
                
                if Utilities.isValidValue(someObject: stepTypeResult.textAnswer as AnyObject?){
                    self.value = stepTypeResult.textAnswer
                }
                else{
                    self.value = 0
                }
                
            case .location:
                let stepTypeResult = stepResult as! ORKLocationQuestionResult
                
                if CLLocationCoordinate2DIsValid((stepTypeResult.locationAnswer?.coordinate)! ){
                    self.value = "\(stepTypeResult.locationAnswer?.coordinate.latitude)" + "," + "\(stepTypeResult.locationAnswer?.coordinate.longitude)"
                }
                else{
                    self.value = "0.0,0.0"
                }
                
                
            default:break
            }
            
        }
        else if (ActiveStepType(rawValue: (self.type?.replacingOccurrences(of: "Result", with: ""))!) != nil){
            // for active Step
            
            
            // switch  ActiveStepType(rawValue: (self.type?.replacingOccurrences(of: "Result", with: ""))!)! as ActiveStepType{
            
            
            
            //}
        }
        else if (self.type == "grouped"){
            // for form data
        }
        else{
            // for others
        }
    }
    
    //MARK: Setter & Getter methods for Step
    func setStep(step:ActivityStep)  {
        /* Method to Initialize step
         @step:ActivityStep instance with all properties initialized priorly
         */
        
        self.step = step
    }
    
    func getStep()-> ActivityStep {
        /* Method to get ActivityStep
         returns current step
         */
        return self.step!
    }
}

