//
//  ConsentStepResult.swift
//  FDA
//
//  Created by Arun Kumar on 2/27/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit

/*

let kConsentStepStartTime = "startTime"
let kConsentStepEndTime = "endTime"

let kConsentStepSkipped = "skipped"
let kConsentStepResultValue = "value"

let kConsentActiveKeyResultType = "resultType" // to be used specifically for Active Task

let kConsentActiveStepKey = "key"


class ConsentStepResult{
    
    var type:ActivityStepType?
    weak var step:ActivityStep?
    var key:String? // Identifier
    var startTime:Date?
    var endTime:Date?
    var skipped:Bool?
    var value:Any?
    
    init() {
        step = ActivityStep()
        self.type = .question
        self.key = ""
        self.startTime = Date.init(timeIntervalSinceNow: 0)
        self.endTime = Date.init(timeIntervalSinceNow: 0)
        self.skipped = false
        self.value = 0
        
    }
    //MARK: Method
    func initWithORKStepResult(stepResult:ORKStepResult,activityType:ActivityType) {
        
        if Utilities.isValidValue(someObject: stepResult.identifier as AnyObject?) {
            self.key = stepResult.identifier
        }
        
        
        self.startTime = stepResult.startDate
        
        self.endTime = stepResult.endDate
        
        self.setResultValue(stepResult:stepResult ,activityType:activityType )
        
        
    }
    
    
    func initWithDict(stepDict:Dictionary<String, Any>){
        
        /* method create ActivityStepResult by initializing params
         @stepDict:contains all ActivityResultStep properties
         */
        
        if Utilities.isValidObject(someObject: stepDict as AnyObject?){
            
            
            if Utilities.isValidValue(someObject: stepDict[kConsentStepType] as AnyObject ){
                self.type = stepDict[kConsentStepType] as? ActivityStepType
            }
            if Utilities.isValidValue(someObject: stepDict[kConsentStepKey] as AnyObject ){
                self.key = stepDict[kConsentStepKey] as? String
            }
            if Utilities.isValidValue(someObject: stepDict[kConsentStepStartTime] as AnyObject ) {
                
                if Utilities.isValidValue(someObject: Utilities.getDateFromString(dateString:(stepDict[kConsentStepStartTime] as? String)!) as AnyObject?) {
                    self.startTime =  Utilities.getDateFromString(dateString:(stepDict[kConsentStepStartTime] as? String)!)
                }
                else{
                    Logger.sharedInstance.debug("Date Conversion is null:\(stepDict)")
                }
                
                
            }
            if Utilities.isValidValue(someObject: stepDict[kConsentStepEndTime] as AnyObject ){
                
                if Utilities.isValidValue(someObject: Utilities.getDateFromString(dateString:(stepDict[kConsentStepEndTime] as? String)!) as AnyObject?) {
                    self.endTime =  Utilities.getDateFromString(dateString:(stepDict[kConsentStepEndTime] as? String)!)
                }
                else{
                    Logger.sharedInstance.debug("Date Conversion is null:\(stepDict)")
                }
            }
            
            if Utilities.isValidValue(someObject: stepDict[kConsentStepSkipped] as AnyObject ){
                self.skipped = stepDict[kConsentStepSkipped] as? Bool
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
            stepDict?[kConsentStepResultType] = self.step?.resultType
        }
        if Utilities.isValidValue(someObject: self.key as AnyObject?){
            
            stepDict?[kConsentStepKey] = self.key
        }
        if self.startTime != nil && (Utilities.getStringFromDate(date: self.startTime!) != nil){
            
            stepDict?[kConsentStartTime] = Utilities.getStringFromDate(date: self.startTime!)
        }
        if self.endTime != nil && (Utilities.getStringFromDate(date: self.endTime!) != nil){
            
            stepDict?[kConsentEndTime] = Utilities.getStringFromDate(date: self.endTime!)
        }
        stepDict?[kConsentStepSkipped] = self.skipped
        
        if self.value != nil {
            stepDict?[kConsentStepResultValue] = self.value
        }
        
        return stepDict
    }
    
    
    
    func setResultValue(stepResult:ORKStepResult, activityType:ActivityType)  {
        /* method saves the result of Current Step
         @stepResult: stepResult which can be result of Questionstep/InstructionStep/ActiveTask
         */
        
        
        //Active task Pending
        
        if((stepResult.results?.count)! > 0){
            
            
            NSLog("step-Type: \( self.step?.type)")
            //((  stepResult.results?[0] as? ORKQuestionResult?) != nil)
            if  activityType == .Questionnaire{
                // for question Step
                
                
                if  let questionstepResult:ORKQuestionResult? = stepResult.results?[0] as? ORKQuestionResult?{
                    
                    
                    
                    
                    switch questionstepResult?.questionType.rawValue{
                        
                        
                        
                    case  ORKQuestionType.scale.rawValue? : //scale and continuos scale
                        
                        if ((questionstepResult as? ORKScaleQuestionResult) != nil){
                            let stepTypeResult = questionstepResult as! ORKScaleQuestionResult
                            
                            if Utilities.isValidValue(someObject: stepTypeResult.scaleAnswer as AnyObject?){
                                
                                self.value = stepTypeResult.scaleAnswer as! Double
                            }
                            else{
                                self.value = 0.0
                            }
                        }
                        else{
                            let stepTypeResult = questionstepResult as! ORKChoiceQuestionResult
                            if Utilities.isValidObject(someObject:stepTypeResult.choiceAnswers as AnyObject?){
                                if (stepTypeResult.choiceAnswers?.count)! > 0{
                                    self.value = stepTypeResult.choiceAnswers?[0]
                                }
                                else{
                                    self.value = ""
                                }
                                
                            }
                            else{
                                self.value = ""
                            }
                            
                        }
                        
                        
                        
                    case ORKQuestionType.singleChoice.rawValue?: //textchoice + value picker + imageChoice + textchoice
                        
                        let stepTypeResult = questionstepResult as! ORKChoiceQuestionResult
                        if Utilities.isValidObject(someObject:stepTypeResult.choiceAnswers as AnyObject?){
                            if (stepTypeResult.choiceAnswers?.count)! > 0{
                                self.value = stepTypeResult.choiceAnswers?[0]
                            }
                            else{
                                self.value = ""
                            }
                            
                        }
                        else{
                            self.value = ""
                        }
                    case ORKQuestionType.multipleChoice.rawValue?: //textchoice + value picker + imageChoice + textchoice
                        
                        let stepTypeResult = questionstepResult as! ORKChoiceQuestionResult
                        if Utilities.isValidObject(someObject:stepTypeResult.choiceAnswers as AnyObject?){
                            if (stepTypeResult.choiceAnswers?.count)! > 1{
                                self.value = stepTypeResult.choiceAnswers
                            }
                            else{
                                self.value = stepTypeResult.choiceAnswers?[0]
                            }
                            
                        }
                        else{
                            self.value = ""
                        }
                        
                        
                    case ORKQuestionType.boolean.rawValue?:
                        
                        let stepTypeResult = questionstepResult as! ORKBooleanQuestionResult
                        
                        if Utilities.isValidValue(someObject: stepTypeResult.booleanAnswer as AnyObject?){
                            self.value = stepTypeResult.booleanAnswer!
                        }
                        else{
                            self.value = 0
                        }
                        
                    case ORKQuestionType.integer.rawValue?: // numeric type
                        let stepTypeResult = questionstepResult as! ORKNumericQuestionResult
                        
                        if Utilities.isValidValue(someObject: stepTypeResult.numericAnswer as AnyObject?){
                            self.value =  "\(Double(stepTypeResult.numericAnswer!))" + stepTypeResult.unit!
                        }
                        else{
                            self.value = 0.0
                        }
                    case ORKQuestionType.decimal.rawValue?: // numeric type
                        let stepTypeResult = questionstepResult as! ORKNumericQuestionResult
                        
                        if Utilities.isValidValue(someObject: stepTypeResult.numericAnswer as AnyObject?){
                            self.value =  "\(Double(stepTypeResult.numericAnswer!))" + stepTypeResult.unit!
                        }
                        else{
                            self.value = 0.0
                        }
                    case  ORKQuestionType.timeOfDay.rawValue?:
                        
                        let stepTypeResult = questionstepResult as! ORKTimeOfDayQuestionResult
                        
                        if (stepTypeResult.dateComponentsAnswer?.isValidDate)!{
                            self.value =  "\(stepTypeResult.dateComponentsAnswer?.hour)" + ":" + "\(stepTypeResult.dateComponentsAnswer?.minute)" + ":" + "\(stepTypeResult.dateComponentsAnswer?.second)"
                        }
                        else{
                            self.value = "00:00:00"
                        }
                        
                    case ORKQuestionType.date.rawValue?:
                        let stepTypeResult = questionstepResult as! ORKDateQuestionResult
                        
                        if Utilities.isValidValue(someObject: stepTypeResult.dateAnswer as AnyObject?){
                            self.value =  Utilities.getStringFromDate(date: stepTypeResult.dateAnswer! )
                        }
                        else{
                            self.value = "00:00:0000"
                        }
                        
                    case ORKQuestionType.text.rawValue?: // text + email
                        
                        let stepTypeResult = questionstepResult as! ORKTextQuestionResult
                        
                        if Utilities.isValidValue(someObject: stepTypeResult.answer as AnyObject?){
                            self.value = stepTypeResult.answer
                        }
                        else{
                            self.value = ""
                        }
                        
                    case ORKQuestionType.timeInterval.rawValue?:
                        
                        let stepTypeResult = questionstepResult as! ORKTimeIntervalQuestionResult
                        
                        if Utilities.isValidValue(someObject: stepTypeResult.intervalAnswer as AnyObject?){
                            self.value = stepTypeResult.intervalAnswer
                        }
                        else{
                            self.value = 0
                        }
                        
                        
                    case ORKQuestionType.height.rawValue?:
                        
                        let stepTypeResult = questionstepResult as! ORKNumericQuestionResult
                        
                        if Utilities.isValidValue(someObject: stepTypeResult.numericAnswer as AnyObject?){
                            self.value = stepTypeResult.numericAnswer
                        }
                        else{
                            self.value = 0
                        }
                        
                    case ORKQuestionType.location.rawValue?:
                        let stepTypeResult = questionstepResult as! ORKLocationQuestionResult
                        
                        if CLLocationCoordinate2DIsValid((stepTypeResult.locationAnswer?.coordinate)! ){
                            self.value = "\(stepTypeResult.locationAnswer?.coordinate.latitude)" + "," + "\(stepTypeResult.locationAnswer?.coordinate.longitude)"
                        }
                        else{
                            self.value = "0.0,0.0"
                        }
                        
                        
                    default:break
                    }
                }
                else{
                    
                    // for consent step result we are storing the ORKConsentSignatureResult
                    let consentStepResult:ORKConsentSignatureResult? = (stepResult.results?[0] as? ORKConsentSignatureResult?)!
                    
                    self.value = consentStepResult;
                    
                }
            }
            else if (activityType == .activeTask){
                
                NSLog("Inside Activity")
                
                let activityResult:ORKResult? = stepResult.results?[0]
                var resultArray:Array<Dictionary<String, Any>>? =  Array()
                
                if (activityResult as? ORKSpatialSpanMemoryResult) != nil {
                    
                    let stepTypeResult:ORKSpatialSpanMemoryResult? = activityResult as? ORKSpatialSpanMemoryResult
                    
                    
                    
                    
                    if Utilities.isValidValue(someObject: stepTypeResult?.score as AnyObject?)
                        && Utilities.isValidValue(someObject: stepTypeResult?.numberOfGames as AnyObject?)
                        && Utilities.isValidValue(someObject: stepTypeResult?.numberOfFailures as AnyObject?){
                        
                        for i in 0..<3 {
                            var resultDict:Dictionary<String, Any>? =  Dictionary()
                            
                            resultDict?[kConsentActiveKeyResultType] = ActiveStepResultType.numeric
                            
                            
                            switch i {
                            case 0: // score
                                resultDict?[kConsentActiveStepKey] = kSpatialSpanMemoryKeyScore
                                resultDict?[kConsentStepResultValue] = stepTypeResult?.score
                                
                            case 1: //numberOfGames
                                resultDict?[kConsentActiveStepKey] = kSpatialSpanMemoryKeyNumberOfGames
                                resultDict?[kConsentStepResultValue] = stepTypeResult?.numberOfGames
                            case 2: // numberOfFailures
                                resultDict?[kConsentActiveStepKey] = kSpatialSpanMemoryKeyNumberOfFailures
                                resultDict?[kConsentStepResultValue] = stepTypeResult?.numberOfFailures
                                
                            default: break
                                
                            }
                            resultDict?[kConsentStepStartTime] =  self.startTime
                            resultDict?[kConsentStepEndTime] =  self.endTime
                            resultDict?[kConsentStepSkipped] =  self.skipped
                            
                            resultArray?.append(resultDict!)
                            
                        }
                        
                        self.value = resultArray
                    }
                    else{
                        self.value = 0
                    }
                }
                else if (activityResult as? ORKTowerOfHanoiResult) != nil{
                    let stepTypeResult:ORKTowerOfHanoiResult? = activityResult as? ORKTowerOfHanoiResult
                    
                    
                    for i in 0..<2 {
                        var resultDict:Dictionary<String, Any>? =  Dictionary()
                        
                        resultDict?[kConsentActiveKeyResultType] = ActiveStepResultType.numeric
                        
                        
                        if i == 0{ //puzzleWasSolved
                            resultDict?[kConsentActiveStepKey] = kTowerOfHanoiKeyPuzzleWasSolved
                            resultDict?[kConsentStepResultValue] = stepTypeResult?.puzzleWasSolved
                        }
                        else{ // numberOfMoves
                            resultDict?[kConsentActiveStepKey] = kTowerOfHanoiKeyNumberOfMoves
                            resultDict?[kConsentStepResultValue] = stepTypeResult?.moves?.count
                            
                        }
                        
                        resultDict?[kConsentStepStartTime] =  self.startTime
                        resultDict?[kConsentStepEndTime] =  self.endTime
                        resultDict?[kConsentStepSkipped] =  self.skipped
                        
                        resultArray?.append(resultDict!)
                        
                    }
                    
                    self.value = resultArray
                    
                }
                
            }
            else if (self.type == .form){
                // for form data
            }
                
            else{
                // for others
            }
        }
        else{
            
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
*/