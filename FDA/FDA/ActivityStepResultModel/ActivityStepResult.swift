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

let kActivityActiveKeyResultType = "resultType" // to be used specifically for Active Task

let kActivityActiveStepKey = "key"

let kSpatialSpanMemoryKeyScore = "score"
let kSpatialSpanMemoryKeyNumberOfGames = "numberOfGames"
let kSpatialSpanMemoryKeyNumberOfFailures = "numberOfFailures"





let kTowerOfHanoiKeyPuzzleWasSolved = "puzzleWasSolved"
let kTowerOfHanoiKeyNumberOfMoves = "numberOfMoves"

let kFetalKickCounterDuration = "duration" // not in use presentlly...Need to be used
let kFetalKickCounterCount = "count" // not in use presentlly...Need to be used

enum ActiveStepResultType:String{
    case boolean = "boolean"
    case numeric = "numeric"
}

enum SpatialSpanMemoryType:Int{
    case score = 0
    case numberOfGames = 1
    case numberOfFailures = 2
}

enum TowerOfHanoiResultType:Int{
    case puzzleWasSolved = 0
    case numberOfMoves = 1
}

enum ActvityStepResultType:String{
    case formOrActiveTask = "grouped"
    case questionnaire = "questionnaire"
    
}

class ActivityStepResult{
    
    var type:ActivityStepType?
    weak var step:ActivityStep?
    var key:String? // Identifier
    var startTime:Date?
    var endTime:Date?
    var skipped:Bool?
    var value:Any?
    
    /* default initializer method
     */
    
    init() {
        step = ActivityStep()
        self.type = .question
        self.key = ""
        self.startTime = Date.init(timeIntervalSinceNow: 0)
        self.endTime = Date.init(timeIntervalSinceNow: 0)
        self.skipped = false
        self.value = 0
        
        
    }
    //MARK: Utility Method
    
    /*
     initializer method for the class
     @param stepResult  is the ORKStepResult
     @param activityType    holds the activity type
     
     */
    func initWithORKStepResult(stepResult:ORKStepResult,activityType:ActivityType) {
        
        if Utilities.isValidValue(someObject: stepResult.identifier as AnyObject?) {
            self.key = stepResult.identifier
        }
        
        
        self.startTime = stepResult.startDate
        
        self.endTime = stepResult.endDate
        
        if (stepResult.results?.count)! > 1 {
            self.type = .form
        }
        
        self.setResultValue(stepResult:stepResult ,activityType:activityType )
        
        
        
    }
    
    
    /* method create ActivityStepResult by initializing params
     @stepDict:contains all ActivityResultStep properties
     */
    func initWithDict(stepDict:Dictionary<String, Any>){
        
        
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
    
    /* method creates a ActivityStepDictionary from step instance
     returns ResultDictionary for storing data to Api/Local
     */
    func getActivityStepResultDict() -> Dictionary<String, Any>? {
        
        var stepDict:Dictionary<String,Any>? = Dictionary<String,Any>()
        
        
        
        switch self.type! as ActivityStepType {
            
        case .instruction: stepDict?[kActivityStepResultType] = "null"
            
        case .question:  stepDict?[kActivityStepResultType] = self.step?.resultType
            
        case .form: stepDict?[kActivityStepResultType] = ActvityStepResultType.formOrActiveTask.rawValue
            
            
        case .active: stepDict?[kActivityStepResultType] = self.step?.resultType
            
        default: break
            
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
    
    /* method saves the result of Current Step
     @stepResult: stepResult which can be result of Questionstep/InstructionStep/ActiveTask
     */
    
    func setResultValue(stepResult:ORKStepResult, activityType:ActivityType)  {
        
        
        //Active task Pending
        
        if((stepResult.results?.count)! > 0){
            
            
            NSLog("step-Type: \( self.step?.type)")
            //((  stepResult.results?.first as? ORKQuestionResult?) != nil)
            if  activityType == .Questionnaire{
                // for question Step
                
                
                if stepResult.results?.count == 1 {
                    
                    
                    if  let questionstepResult:ORKQuestionResult? = stepResult.results?.first as? ORKQuestionResult?{
                        
                        self.setValue(questionstepResult:questionstepResult! )
                        
                    }
                    else{
                        
                        // for consent step result we are storing the ORKConsentSignatureResult
                        let consentStepResult:ORKConsentSignatureResult? = (stepResult.results?.first as? ORKConsentSignatureResult?)!
                        
                        self.value = consentStepResult;
                        
                    }
                }
                else{
                    // for form step result
                    
                    self.value  = [ActivityStepResult]()
                    
                    var formResultArray:[Dictionary<String,Any>] = [Dictionary<String,Any>]()
                    
                    for result in stepResult.results!{
                        let activityStepResult:ActivityStepResult? = ActivityStepResult()
                        
                        activityStepResult?.startTime = self.startTime
                        activityStepResult?.key = result.identifier
                        activityStepResult?.endTime = self.endTime
                        activityStepResult?.skipped = self.skipped
                        
                        
                        if ((result as? ORKQuestionResult) != nil){
                        
                            
                        let questionResult:ORKQuestionResult? = (result as? ORKQuestionResult)
                            
                        self.setValue(questionstepResult:questionResult! )
                        
                        activityStepResult?.value = self.value
                    
                        formResultArray.append((activityStepResult?.getActivityStepResultDict()!)!)
                        }
                    }
                    self.value = formResultArray
                    
                }
            }
            else if (activityType == .activeTask){
                
                NSLog("Inside Activity")
                
                let activityResult:ORKResult? = stepResult.results?.first
                var resultArray:Array<Dictionary<String, Any>>? =  Array()
                
                if (activityResult as? ORKSpatialSpanMemoryResult) != nil {
                    
                    let stepTypeResult:ORKSpatialSpanMemoryResult? = activityResult as? ORKSpatialSpanMemoryResult
                    
                    
                    if Utilities.isValidValue(someObject: stepTypeResult?.score as AnyObject?)
                        && Utilities.isValidValue(someObject: stepTypeResult?.numberOfGames as AnyObject?)
                        && Utilities.isValidValue(someObject: stepTypeResult?.numberOfFailures as AnyObject?){
                        
                        for i in 0..<3 {
                            var resultDict:Dictionary<String, Any>? =  Dictionary()
                            
                            resultDict?[kActivityActiveKeyResultType] = ActiveStepResultType.numeric.rawValue
                            
                            
                            switch SpatialSpanMemoryType(rawValue:i)! as SpatialSpanMemoryType {
                            case .score: // score
                                resultDict?[kActivityActiveStepKey] = kSpatialSpanMemoryKeyScore
                                resultDict?[kActivityStepResultValue] = stepTypeResult?.score
                                
                            case .numberOfGames: //numberOfGames
                                resultDict?[kActivityActiveStepKey] = kSpatialSpanMemoryKeyNumberOfGames
                                resultDict?[kActivityStepResultValue] = stepTypeResult?.numberOfGames
                            case .numberOfFailures: // numberOfFailures
                                resultDict?[kActivityActiveStepKey] = kSpatialSpanMemoryKeyNumberOfFailures
                                resultDict?[kActivityStepResultValue] = stepTypeResult?.numberOfFailures
                                
                                
                                
                            }
                            resultDict?[kActivityStepStartTime] =  self.startTime
                            resultDict?[kActivityStepEndTime] =  self.endTime
                            resultDict?[kActivityStepSkipped] =  self.skipped
                            
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
                        
                        resultDict?[kActivityActiveKeyResultType] = ActiveStepResultType.numeric.rawValue
                        
                        
                        if  TowerOfHanoiResultType(rawValue:i) == .puzzleWasSolved{ //puzzleWasSolved
                            resultDict?[kActivityActiveStepKey] = kTowerOfHanoiKeyPuzzleWasSolved
                            resultDict?[kActivityStepResultValue] = stepTypeResult?.puzzleWasSolved
                        }
                        else{ // numberOfMoves
                            resultDict?[kActivityActiveStepKey] = kTowerOfHanoiKeyNumberOfMoves
                            resultDict?[kActivityStepResultValue] = stepTypeResult?.moves?.count
                            
                        }
                        
                        resultDict?[kActivityStepStartTime] =  self.startTime
                        resultDict?[kActivityStepEndTime] =  self.endTime
                        resultDict?[kActivityStepSkipped] =  self.skipped
                        
                        resultArray?.append(resultDict!)
                        
                    }
                    
                    self.value = resultArray
                    
                }
                else if (activityResult as? FetalKickCounterTaskResult) != nil{
                    let stepTypeResult:FetalKickCounterTaskResult? = activityResult as? FetalKickCounterTaskResult
                    
                    for i in 0..<2 {
                        var resultDict:Dictionary<String, Any>? =  Dictionary()
                        
                        resultDict?[kActivityActiveKeyResultType] = ActiveStepResultType.numeric
                        
                        
                        if i == 0{ //
                            resultDict?[kActivityActiveStepKey] = kFetalKickCounterDuration
                            resultDict?[kActivityStepResultValue] = stepTypeResult?.duration
                        }
                        else{ // numberOfMoves
                            resultDict?[kActivityActiveStepKey] = kFetalKickCounterCount
                            resultDict?[kActivityStepResultValue] = stepTypeResult?.totalKickCount
                            
                        }
                        
                        resultDict?[kActivityStepStartTime] =  self.startTime
                        resultDict?[kActivityStepEndTime] =  self.endTime
                        resultDict?[kActivityStepSkipped] =  self.skipped
                        
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
    
    func setValue(questionstepResult:ORKQuestionResult) {
        switch questionstepResult.questionType.rawValue{
            
            
        case  ORKQuestionType.scale.rawValue : //scale and continuos scale
            
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
                        self.value = stepTypeResult.choiceAnswers?.first
                    }
                    else{
                        self.value = ""
                    }
                    
                }
                else{
                    self.value = ""
                }
                
            }
            
            
            
        case ORKQuestionType.singleChoice.rawValue: //textchoice + value picker + imageChoice + textchoice
            
            let stepTypeResult = questionstepResult as! ORKChoiceQuestionResult
            if Utilities.isValidObject(someObject:stepTypeResult.choiceAnswers as AnyObject?){
                if (stepTypeResult.choiceAnswers?.count)! > 0{
                    self.value = stepTypeResult.choiceAnswers?.first
                }
                else{
                    self.value = ""
                }
                
            }
            else{
                self.value = ""
            }
        case ORKQuestionType.multipleChoice.rawValue: //textchoice + value picker + imageChoice + textchoice
            
            let stepTypeResult = questionstepResult as! ORKChoiceQuestionResult
            if Utilities.isValidObject(someObject:stepTypeResult.choiceAnswers as AnyObject?){
                if (stepTypeResult.choiceAnswers?.count)! > 1{
                    self.value = stepTypeResult.choiceAnswers
                }
                else{
                    self.value = stepTypeResult.choiceAnswers?.first
                }
                
            }
            else{
                self.value = ""
            }
            
            
        case ORKQuestionType.boolean.rawValue:
            
            let stepTypeResult = questionstepResult as! ORKBooleanQuestionResult
            
            if Utilities.isValidValue(someObject: stepTypeResult.booleanAnswer as AnyObject?){
                self.value = stepTypeResult.booleanAnswer!
            }
            else{
                self.value = 0
            }
            
        case ORKQuestionType.integer.rawValue: // numeric type
            let stepTypeResult = questionstepResult as! ORKNumericQuestionResult
            
            if Utilities.isValidValue(someObject: stepTypeResult.numericAnswer as AnyObject?){
                self.value =  Double(stepTypeResult.numericAnswer!)
                //"\(Double(stepTypeResult.numericAnswer!))" + stepTypeResult.unit!
            }
            else{
                self.value = 0.0
            }
        case ORKQuestionType.decimal.rawValue: // numeric type
            let stepTypeResult = questionstepResult as! ORKNumericQuestionResult
            
            if Utilities.isValidValue(someObject: stepTypeResult.numericAnswer as AnyObject?){
                self.value = Double(stepTypeResult.numericAnswer!)
                // "\(Double(stepTypeResult.numericAnswer!))" + stepTypeResult.unit!
            }
            else{
                self.value = 0.0
            }
        case  ORKQuestionType.timeOfDay.rawValue:
            
            let stepTypeResult = questionstepResult as! ORKTimeOfDayQuestionResult
            
            
            
            if stepTypeResult.dateComponentsAnswer != nil && (stepTypeResult.dateComponentsAnswer?.isValidDate)!{
                self.value =  "\(stepTypeResult.dateComponentsAnswer?.hour)" + ":" + "\(stepTypeResult.dateComponentsAnswer?.minute)" + ":" + "\(stepTypeResult.dateComponentsAnswer?.second)"
            }
            else{
                self.value = "00:00:00"
            }
            
        case ORKQuestionType.date.rawValue:
            let stepTypeResult = questionstepResult as! ORKDateQuestionResult
            
            if Utilities.isValidValue(someObject: stepTypeResult.dateAnswer as AnyObject?){
                self.value =  Utilities.getStringFromDate(date: stepTypeResult.dateAnswer! )
            }
            else{
                self.value = "00:00:0000"
            }
            
        case ORKQuestionType.text.rawValue: // text + email
            
            let stepTypeResult = questionstepResult as! ORKTextQuestionResult
            
            if Utilities.isValidValue(someObject: stepTypeResult.answer as AnyObject?){
                self.value = stepTypeResult.answer
            }
            else{
                self.value = ""
            }
            
        case ORKQuestionType.timeInterval.rawValue:
            
            let stepTypeResult = questionstepResult as! ORKTimeIntervalQuestionResult
            
            if Utilities.isValidValue(someObject: stepTypeResult.intervalAnswer as AnyObject?){
                self.value = Double(stepTypeResult.intervalAnswer!)
            }
            else{
                self.value = 0.0
            }
            
            
        case ORKQuestionType.height.rawValue:
            
            let stepTypeResult = questionstepResult as! ORKNumericQuestionResult
            
            if Utilities.isValidValue(someObject: stepTypeResult.numericAnswer as AnyObject?){
                self.value = Double(stepTypeResult.numericAnswer!)
            }
            else{
                self.value = 0.0
            }
            
        case ORKQuestionType.location.rawValue:
            let stepTypeResult = questionstepResult as! ORKLocationQuestionResult
            
            if stepTypeResult.locationAnswer != nil && CLLocationCoordinate2DIsValid((stepTypeResult.locationAnswer?.coordinate)! ){
                self.value = "\(stepTypeResult.locationAnswer?.coordinate.latitude)" + "," + "\(stepTypeResult.locationAnswer?.coordinate.longitude)"
            }
            else{
                self.value = "0.0,0.0"
            }
            
            
        default:break
        }
    }
    
    
    //MARK: Setter & Getter methods for Step
    
    /* Method to Initialize step
     @step:ActivityStep instance with all properties initialized priorly
     */
    
    func setStep(step:ActivityStep)  {
        
        
        self.step = step
    }
    
    /* Method to get ActivityStep
     returns current step
     */
    
    func getStep()-> ActivityStep {
        return self.step!
    }
}

