//
//  ActivityBuilder.swift
//  FDA
//
//  Created by Arun Kumar on 2/16/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit


let kCondtion = "condition"
let kDestination = "destination"
let kOperator = "operator"

let kCompletionStep = "CompletionStep"

let kMinimumValue = "minValue"

enum OperatorType:String{
    case equal = "e"
    case lessThan = "lt"
    case lessThanOrEqual = "lte"
    case greaterThan = "gt"
    case greaterThanOrEqual = "gte"
    case notEqual = "ne"
    case range = "range"
}


class ActivityBuilder {
    
    
    static var currentActivityBuilder = ActivityBuilder()
    
    var activity:Activity?
    var actvityResult:ActivityResult?
    public var task: ORKTask?
    init() {
        activity = Activity()
        actvityResult = ActivityResult()
    }
    
    func initActivityWithDict(dict:Dictionary<String,Any>) {
        
        
        if Utilities.isValidObject(someObject: dict as AnyObject){
            self.activity?.setActivityMetaData(activityDict: dict)
        }
        self.actvityResult = ActivityResult()
        self.actvityResult?.setActivity(activity: self.activity!)
        NSLog("self.actvityResult? \(self.actvityResult?.activity)")
        
    }
    
    func initWithActivity(activity:Activity)  {
        if (activity.steps?.count)! > 0 {
            self.activity = activity
            self.actvityResult = ActivityResult()
            self.actvityResult?.setActivity(activity: self.activity!)
        }
        else{
            Logger.sharedInstance.debug("Activity:activity.steps is null:\(activity)")
        }
    }
    
    func setActivityResultWithORKResult(taskResult:ORKTaskResult) {
        actvityResult?.initWithORKTaskResult(taskResult:taskResult)
    }
    
    func createTask()->ORKTask?{
        
        
        
        if  ((activity?.type) != nil){
            
            var orkStepArray:[ORKStep]?
            
            
            
            orkStepArray = Array<ORKStep>()
            
            
            
            var activityStepArray:[ActivityStep]? = Array<ActivityStep>()
            
            switch (activity?.type!)! as ActivityType{
                
                
                
            case .Questionnaire:
                
                
                
                // creating step array
                
                for var stepDict in (activity?.steps!)! {
                    
                    
                    
                    if Utilities.isValidObject(someObject: stepDict as AnyObject?) {
                        
                        
                        
                        if Utilities.isValidValue(someObject: stepDict[kActivityStepType] as AnyObject ){
                            
                            
                            
                            switch ActivityStepType(rawValue:stepDict[kActivityStepType] as! String)! as  ActivityStepType {
                                
                            case .instruction:
                                
                                
                                
                                let instructionStep:ActivityInstructionStep? = ActivityInstructionStep()
                                
                                instructionStep?.initWithDict(stepDict: stepDict)
                                
                                orkStepArray?.append((instructionStep?.getInstructionStep())!)
                                
                                activityStepArray?.append(instructionStep!)
                                
                                
                                
                            case .question:
                                
                                
                                
                                let questionStep:ActivityQuestionStep? = ActivityQuestionStep()
                                
                                questionStep?.initWithDict(stepDict: stepDict)
                                
                                
                                
                                if let step = (questionStep?.getQuestionStep()){
                                    
                                    orkStepArray?.append(step)
                                    
                                    activityStepArray?.append(questionStep!)
                                    
                                }
                                
                                
                                
                            case .form:
                                
                                
                                
                                let formStep:ActivityFormStep? = ActivityFormStep()
                                
                                formStep?.initWithDict(stepDict: stepDict)
                                
                                
                                
                                orkStepArray?.append((formStep?.getFormStep())!)
                                
                                activityStepArray?.append(formStep!)
                                
                            default: break
                               
                            }
                        }
                    }
                    else{
                        Logger.sharedInstance.debug("Activity:stepDict is null:\(stepDict)")
                        break;
                    }
                    
                }
                
                if (orkStepArray?.count)! > 0 {
                    
                    self.activity?.setORKSteps(orkStepArray: orkStepArray!)
                    self.activity?.setActivityStepArray(stepArray: activityStepArray!)
                    
                    //addding completion step
                    let completionStep = ORKCompletionStep(identifier: kCompletionStep)
                    
                    completionStep.title = "Activity Completed"
                    completionStep.image = #imageLiteral(resourceName: "successBlueBig")
                    completionStep.detailText = "Thank you for your time!"
                    orkStepArray?.append(completionStep)
                    
                    //Creating oredered or navigable task
                    if (orkStepArray?.count)! > 0 {
                        
                        task =  ORKOrderedTask(identifier: (activity?.actvityId!)!, steps: orkStepArray)
                        //to be commented
                        self.activity?.branching = true
                        
                        if self.activity?.branching == true{
                            task =  ORKNavigableOrderedTask(identifier:(activity?.actvityId)!, steps: orkStepArray)
                            
                        } // comment the else part
                            
                        else{
                            task =  ORKOrderedTask(identifier:(activity?.actvityId)!, steps: orkStepArray)
                        }
                    }
                    
                    var i:Int? = 0
                    
                    //to be commented
                    //self.activity?.branching = true
                    
                    if self.activity?.branching == true{
                        
                        for step in orkStepArray!
                            
                        {
                            print("stepid \(step.identifier)")
                            
                            if step.isKind(of: ORKQuestionStep.self) || step is RepeatableFormStep || step is ORKFormStep || (step.isKind(of: ORKInstructionStep.self) && step.isKind(of: ORKCompletionStep.self) == false)  {
                                
                                let activityStep:ActivityStep?
                                
                                if step.isKind(of: ORKQuestionStep.self) || (step.isKind(of: ORKInstructionStep.self) && step.isKind(of: ORKCompletionStep.self) == false){
                                    activityStep = activityStepArray?[(i!)] as?  ActivityQuestionStep
                                }
                                else if step.isKind(of: ORKFormStep.self) || step.isKind(of: RepeatableFormStep.self){
                                    activityStep = activityStepArray?[(i!)] as?  ActivityFormStep
                                }
                                else{
                                    activityStep = activityStepArray?[(i!)] as?  ActivityInstructionStep
                                }
                                
                                if activityStep?.destinations != nil && (activityStep?.destinations?.count)! > 0{
                                    
                                    var defaultStepIdentifier:String = ""
                                    
                                    if i! + 1 < (activityStepArray?.count)!{
                                        defaultStepIdentifier = (activityStepArray?[(i!+1)].key)!
                                        
                                    }
                                    else{
                                        defaultStepIdentifier = kCompletionStep
                                    }
                                    
                                    var defaultStepExist:Bool? = false
                                    
                                    let resultSelector: ORKResultSelector?
                                    
                                    var predicateRule: ORKPredicateStepNavigationRule?
                                    
                                    //Creating Result Selector
                                    resultSelector =  ORKResultSelector(stepIdentifier: step.identifier, resultIdentifier: step.identifier)
                                    
                                    let questionStep:ORKStep?
                                    
                                    //Intializing Question Step
                                    if step.isKind(of: ORKQuestionStep.self){
                                        
                                        questionStep = step as! ORKQuestionStep
                                        
                                    }
                                    else if step is RepeatableFormStep{
                                        questionStep = step as! RepeatableFormStep
                                    }
                                    else if step is ORKFormStep{
                                        questionStep = step as! ORKFormStep
                                    }
                                    else{
                                        
                                        questionStep = step as! ORKInstructionStep
                                        
                                    }
                                    
                                    //choicearray and destination array will hold predicates & their respective destination
                                    var choicePredicate:[NSPredicate] = [NSPredicate]()
                                    
                                    var destination:Array<String>? = Array<String>()
                                    
                                    for dict in (activityStep?.destinations)!{
                                        
                                        var predicateQuestionChoiceA:NSPredicate = NSPredicate()
                                        
                                        //Condition is not nil
                                        if Utilities.isValidValue(someObject: dict[kCondtion] as AnyObject) {
                                            
                                            switch (questionStep as! ORKQuestionStep).answerFormat {
                                                
                                            case is ORKTextChoiceAnswerFormat, is ORKTextScaleAnswerFormat, is ORKImageChoiceAnswerFormat:
                                                
                                                predicateQuestionChoiceA = ORKResultPredicate.predicateForChoiceQuestionResult(with:resultSelector! , expectedAnswerValue: dict[kCondtion] as! NSCoding & NSCopying & NSObjectProtocol)
                                                
                                                choicePredicate.append(predicateQuestionChoiceA)
                                                
                                                
                                                if dict[kCondtion] != nil && dict[kDestination] != nil && (dict[kDestination] as! String) == "" {
                                                    
                                                    // this means c = value & d = ""
                                                    destination?.append( kCompletionStep )
                                                }
                                                else{
                                                    // this means c = value && d =  value
                                                    destination?.append( dict[kDestination]! as! String)
                                                    
                                                }
                                                
                                            case is ORKNumericAnswerFormat ,is ORKScaleAnswerFormat,is ORKTimeIntervalAnswerFormat,is ORKHeightAnswerFormat, is ORKContinuousScaleAnswerFormat:
                                                
                                                if let operatorValue = dict[kOperator] as? String{
                                                    
                                                    let condition:String = dict[kCondtion] as! String
                                                    let  conditionValue = condition.components(separatedBy: CharacterSet.init(charactersIn: ","))
                                                    
                                                    var lhs:Double? = 0.0
                                                    var rhs:Double? = 0.0
                                                    
                                                    lhs = Double(conditionValue.first!)
                                                    if conditionValue.count == 2{
                                                        rhs = Double(conditionValue.last!)
                                                    }
                                                    let operatorType:OperatorType = OperatorType(rawValue: operatorValue)!
                                                    
                                                    switch((questionStep as! ORKQuestionStep).answerFormat){
                                                    case is ORKNumericAnswerFormat,is ORKHeightAnswerFormat: //Height & Numeric Question
                                                        
                                                        var minimumValue = (activityStep as! ActivityQuestionStep).formatDict![kMinimumValue] as? Float
                                                        
                                                        if ((questionStep as! ORKQuestionStep).answerFormat! is ORKHeightAnswerFormat ){
                                                            
                                                            minimumValue = 0
                                                        }
                                                        
                                                        predicateQuestionChoiceA = self.getPredicateForNumeric(resultSelector: resultSelector!, lhs: lhs!, minimumValue: minimumValue!, operatorType: operatorType)
                                                        
                                                    case is ORKTimeIntervalAnswerFormat: //TimeInterval
                                                        
                                                       predicateQuestionChoiceA = self.getPredicateForTimeInterval(resultSelector: resultSelector!, lhs: lhs!, minimumValue: 0.0, operatorType: operatorType)
                                                        
                                                    case is ORKScaleAnswerFormat, is ORKContinuousScaleAnswerFormat: //Scale & Continuos Scale
                                                        
                                                        let minimumValue = (activityStep as! ActivityQuestionStep).formatDict![kMinimumValue] as? Float
                                                        
                                                        predicateQuestionChoiceA = self.getPredicateForScale(resultSelector: resultSelector!, lhs: lhs!, minimumValue: minimumValue!, operatorType: operatorType,rhs: rhs!, resultType: ((questionStep as! ORKQuestionStep).answerFormat)!,activityStep:activityStep!)
                                                        
                                                    case .none: break
                                                        
                                                    case .some(_): break
                                                        
                                                    }
                                                    choicePredicate.append(predicateQuestionChoiceA)
                                                    
                                                    if dict[kCondtion] != nil && dict[kDestination] != nil && (dict[kDestination] as! String) == "" {
                                                        // this means c = value & d = ""
                                                        destination?.append( kCompletionStep )
                                                    }
                                                    else{
                                                        // this means c = value && d =  value
                                                        destination?.append( dict[kDestination]! as! String)
                                                    }
                                                }
                                                else{
                                                }
                                                
                                            case is ORKBooleanAnswerFormat :
                                                
                                                var boolValue:Bool? = false
                                                
                                                if (dict[kCondtion] as! String).caseInsensitiveCompare("true") ==  ComparisonResult.orderedSame{
                                                    boolValue = true
                                                }
                                                else{
                                                    if (dict[kCondtion] as! String).caseInsensitiveCompare("false") ==  ComparisonResult.orderedSame{
                                                        boolValue = false
                                                    }
                                                    else if (dict[kCondtion] as! String) == ""{
                                                        boolValue = nil
                                                        if Utilities.isValidValue(someObject: dict[kDestination] as AnyObject? ){
                                                            
                                                            defaultStepIdentifier = dict[kDestination]! as! String
                                                        }
                                                    }
                                                }
                                                
                                                if  boolValue != nil {
                                                    
                                                    predicateQuestionChoiceA = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector!, expectedAnswer: boolValue!)
                                                }
                                                
                                                choicePredicate.append(predicateQuestionChoiceA)
                                                
                                                if dict[kCondtion] != nil && dict[kDestination] != nil && (dict[kDestination] as! String) == "" {
                                                    // this means c = value & d = ""
                                                    destination?.append( kCompletionStep )
                                                }
                                                else{
                                                    // this means c = value && d =  value
                                                    destination?.append( dict[kDestination]! as! String)
                                                }
                                            default:break
                                                
                                            }
                                        }
                                            
                                        else{
                                            // it means condition is empty
                                            if dict[kCondtion] != nil && dict[kCondtion] as! String == ""{
                                                
                                                defaultStepExist = true
                                                
                                                if Utilities.isValidValue(someObject: dict[kDestination] as AnyObject? ){
                                                    // means we ahave valid destination
                                                    defaultStepIdentifier = dict[kDestination]! as! String
                                                    
                                                }
                                                else{
                                                    // invalid destination i.e condition = "" && destination = ""
                                                    defaultStepIdentifier = kCompletionStep
                                                }
                                            }
                                        }
                                    }
                                    
                                    if choicePredicate.count == 0{
                                        
                                        // if condition is empty
                                        
                                        if (destination?.count)! > 0 {
                                            
                                            // if destination is not empty but condition is empty
                                            
                                            for destinationId in destination!{
                                                
                                                if destinationId.characters.count != 0 {
                                                    
                                                    let  directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: destinationId)
                                                    
                                                    (task as! ORKNavigableOrderedTask).setNavigationRule(directRule, forTriggerStepIdentifier:step.identifier)
                                                }
                                            }
                                        }
                                        else{
                                            // if both destination and condition are empty
                                            let  directRule:ORKDirectStepNavigationRule!
                                            
                                            if defaultStepExist == false{
                                                directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: kCompletionStep)
                                            }
                                            else{
                                                directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: defaultStepIdentifier)
                                            }
                                            
                                            (task as! ORKNavigableOrderedTask).setNavigationRule(directRule!, forTriggerStepIdentifier:step.identifier)
                                        }
                                    }
                                    else{
                                        
                                        if defaultStepExist!{
                                            //                                            destination =  destination?.filter({ $0 != defaultStepIdentifier
                                            
                                            //
                                            
                                            //                                            })
                                        }
                                        
                                        print("choices \(choicePredicate) destination \(destination)")
                                        // FOLLOWING TO BE TESTED -FOUND CONFLICT WHILE MERGING AND WAS COMMENTED
                                        predicateRule = ORKPredicateStepNavigationRule(resultPredicates: choicePredicate, destinationStepIdentifiers: destination!, defaultStepIdentifier: defaultStepIdentifier, validateArrays: true)
                                        
                                        (task as! ORKNavigableOrderedTask).setNavigationRule(predicateRule!, forTriggerStepIdentifier:step.identifier)
                                    }
                                    
                                }
                                else{
                                    //destination array is empty
                                }
                            }
                            else
                            {
                                //this is not question step
                            }
                            
                            i = i! + 1
                        }
                    }
                    if task != nil {
                        
                        if (self.activity?.branching)! {
                            return (task as! ORKNavigableOrderedTask)
                        }
                            
                        else{
                            return (task as! ORKOrderedTask)
                        }
                    }
                    else{
                        return nil
                    }
                }
                
            case .activeTask:
                
                /*
                 
                 var stepDict = activity?.steps!.last
                 
                 
                 
                 if Utilities.isValidObject(someObject: stepDict as AnyObject?) && Utilities.isValidValue(someObject: stepDict?[kActivityStepType] as AnyObject ) {
                 
                 
                 
                 let activeStep:ActivityActiveStep? = ActivityActiveStep()
                 
                 activeStep?.initWithDict(stepDict: stepDict!)
                 
                 task = activeStep?.getActiveTask()
                 
                 activityStepArray?.append(activeStep!)
                 
                 
                 
                 if (activityStepArray?.count)! > 0 {
                 
                 self.activity?.setActivityStepArray(stepArray: activityStepArray!)
                 
                 }
                 
                 
                 
                 return task!
                 
                 }
                 
                 else{
                 
                 Logger.sharedInstance.debug("Activity:stepDict is null:\(stepDict)")
                 
                 break;
                 
                 }
                 
                 */
                
                
                // case .questionnaireAndActiveTask:
                
                for var stepDict in (activity?.steps!)! {
                    
                    if Utilities.isValidObject(someObject: stepDict as AnyObject?) {
                        
                        if Utilities.isValidValue(someObject: stepDict[kActivityStepType] as AnyObject ){
                            
                            switch ActivityStepType(rawValue:stepDict[kActivityStepType] as! String)! as  ActivityStepType {
                                
                            case .instruction:
                                
                                let instructionStep:ActivityInstructionStep? = ActivityInstructionStep()
                                
                                instructionStep?.initWithDict(stepDict: stepDict)
                                
                                orkStepArray?.append((instructionStep?.getInstructionStep())!)
                                
                            case .question:
                                
                                let questionStep:ActivityQuestionStep? = ActivityQuestionStep()
                                
                                questionStep?.initWithDict(stepDict: stepDict)
                                
                                orkStepArray?.append((questionStep?.getQuestionStep())!)
                                
                            case   .active , .taskSpatialSpanMemory , .taskTowerOfHanoi :
                                
                                var localTask: ORKOrderedTask?
                                
                                let activeStep:ActivityActiveStep? = ActivityActiveStep()
                                
                                activeStep?.initWithDict(stepDict: stepDict)
                                
                                localTask = activeStep?.getActiveTask() as! ORKOrderedTask?
                                
                                activityStepArray?.append(activeStep!)
                                
                                if (localTask?.steps) != nil && ((localTask?.steps)?.count)! > 0 {
                                    
                                    for step  in (localTask?.steps)!{
                                        
                                        orkStepArray?.append(step)
                                        
                                    }
                                    
                                }
                                
                            default: break
                                
                            }
                        }
                    }
                    else{
                        Logger.sharedInstance.debug("Activity:stepDict is null:\(stepDict)")
                        break;
                    }
                }
                
                if (orkStepArray?.count)! > 0 {
                    
                    if (activityStepArray?.count)! > 0 {
                        
                        self.activity?.setActivityStepArray(stepArray: activityStepArray!)
                    }
                    
                    self.activity?.setORKSteps(orkStepArray: orkStepArray!)
                    
                    if (orkStepArray?.count)! > 0 {
                        task =  ORKOrderedTask(identifier: (activity?.actvityId!)!, steps: orkStepArray)
                    }
                    
                    return task!
                    
                }
                else{
                    return nil
                }
            }
        }
        else{
            Logger.sharedInstance.debug("activity is null:\(activity)")
        }
        return nil
        self.actvityResult?.setActivity(activity: self.activity!)
    }
    //MARK: Predicates For QuestionTypes
    
    /*
     getPredicateForNumeric generates predicate for the Numeric Question Type
     @resultSelector: instance of ORKResultSelector for specific QuestionStep
     @lhs:Boundary Value for predicate
     @OperatorType: repersents the operation type
     
     */
    
    func getPredicateForNumeric(resultSelector:ORKResultSelector, lhs:Double,minimumValue:Float, operatorType:OperatorType) ->NSPredicate{
        
        var predicate:NSPredicate = NSPredicate()
        
        switch(operatorType){
            
        case .equal: //Equal
            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, expectedAnswer: Int(lhs))
        case .notEqual : //NotEqual
            let equalPredicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, expectedAnswer: Int(lhs))
            predicate = NSCompoundPredicate.init(notPredicateWithSubpredicate: equalPredicate)
            
        case .greaterThan : //GreaterThan
            
           // predicate =  NSPredicate.init(format:"SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == \"CBQ0\" AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == \"CBQ0\" AND $z.answer >= 201 AND $z.answer < 401).@count > 0).@count > 0).@count > 0" , argumentArray: [])
            
           
            
             predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, minimumExpectedAnswerValue: lhs + 1  , maximumExpectedAnswerValue:Double.infinity )
        case .lessThan : //LessThan
            
            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, minimumExpectedAnswerValue:Double(minimumValue ), maximumExpectedAnswerValue: lhs - 1 )
            
           // predicate =  NSPredicate.init(format:"SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == \"CBQ0\" AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == \"CBQ0\" AND $z.answer >= 0 AND $z.answer < 200).@count > 0).@count > 0).@count > 0" , argumentArray: [])
            
           
        case .greaterThanOrEqual : //GreaterThanOrEqual
            
            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, minimumExpectedAnswerValue: lhs)
        case .lessThanOrEqual : //LessThanOrEqual
            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, maximumExpectedAnswerValue: lhs)                                                        case .range :break //Range
            
        default: break
            
        }
        return predicate
    }
    
    /*
     getPredicateForTimeInterval generates predicate for the Numeric Question Type
     @resultSelector: instance of ORKResultSelector for specific QuestionStep
     @lhs:Boundary Value for predicate
     @OperatorType: repersents the operation type
     
     */
    
    func getPredicateForTimeInterval(resultSelector:ORKResultSelector, lhs:Double,minimumValue:Float, operatorType:OperatorType) ->NSPredicate{
        
        var predicate:NSPredicate = NSPredicate()
        
        switch(operatorType){
            
        case .equal: //Equal
            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, expectedAnswer: Int(lhs))
        case .notEqual: //NotEqual
            let equalPredicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, expectedAnswer: Int(lhs))
            predicate = NSCompoundPredicate.init(notPredicateWithSubpredicate: equalPredicate)
        
        case .greaterThan : //GreaterThan
            predicate = ORKResultPredicate.predicateForTimeIntervalQuestionResult(with: resultSelector, minimumExpectedAnswerValue: lhs + 1, maximumExpectedAnswerValue: Double.infinity)
            
        case .lessThan : //LessThan
            predicate = ORKResultPredicate.predicateForTimeIntervalQuestionResult(with: resultSelector, minimumExpectedAnswerValue: 0.0, maximumExpectedAnswerValue:lhs - 1 )
            
        case .greaterThanOrEqual : //GreaterThanOrEqual
            predicate = ORKResultPredicate.predicateForTimeIntervalQuestionResult(with: resultSelector, minimumExpectedAnswerValue: lhs)
            
        case .lessThanOrEqual : //LessThanOrEqual
            predicate = ORKResultPredicate.predicateForTimeIntervalQuestionResult(with: resultSelector, maximumExpectedAnswerValue: lhs)
            
        case .range :break
            
        default: break
            
        }
        return predicate
    }
    
    /*
     getPredicateForScale generates predicate for the Numeric Question Type
     @resultSelector: instance of ORKResultSelector for specific QuestionStep
     @lhs:Boundary Value for predicate
     @OperatorType: repersents the operation type
     
     */
    
    func getPredicateForScale(resultSelector:ORKResultSelector, lhs:Double,minimumValue:Float, operatorType:OperatorType,rhs:Double,resultType:ORKAnswerFormat,activityStep:ActivityStep) ->NSPredicate{
        
        var predicate:NSPredicate = NSPredicate()
        
        switch(operatorType){
            
        case .equal: //Equal
            //
           
            if resultType is ORKScaleAnswerFormat{
                predicate = ORKResultPredicate.predicateForScaleQuestionResult(with: resultSelector, expectedAnswer: Int(lhs))
            }
            else{
                
                var offset:Double? = 0.0
                let maxFraction = (activityStep as! ActivityQuestionStep).formatDict![kStepQuestionContinuosScaleMaxFractionDigits] as? Int
                
                switch(maxFraction){
                case 0?:
                    offset = -0.25
                case 1?,2?,3?:
                    offset = 0.0
                case .none: break
                case .some(_): break
                }
                
                
                predicate =  NSPredicate.init(format:"SUBQUERY(SELF, $x, $x.identifier == $ORK_TASK_IDENTIFIER AND SUBQUERY($x.results, $y, $y.identifier == \"\(resultSelector.resultIdentifier)\" AND $y.isPreviousResult == 0 AND SUBQUERY($y.results, $z, $z.identifier == \"\(resultSelector.resultIdentifier)\" AND $z.answer >= \(lhs + offset!) AND $z.answer < \(lhs + 0.1)).@count > 0).@count > 0).@count > 0" , argumentArray: [])
            }
            
        case .notEqual: //Not Equal
            
            let equalPredicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, expectedAnswer: Int(lhs))
            predicate = NSCompoundPredicate.init(notPredicateWithSubpredicate: equalPredicate)
            
        case .greaterThan : //GreaterThan
            predicate = ORKResultPredicate.predicateForScaleQuestionResult(with: resultSelector, minimumExpectedAnswerValue: lhs + 1, maximumExpectedAnswerValue: Double.infinity)
            
        case .lessThan : //LessThan
            predicate = ORKResultPredicate.predicateForScaleQuestionResult(with: resultSelector, minimumExpectedAnswerValue: Double(minimumValue), maximumExpectedAnswerValue:lhs - 1 )
            
        case .greaterThanOrEqual : //GreaterThanOrEqual
            predicate = ORKResultPredicate.predicateForScaleQuestionResult(with: resultSelector, minimumExpectedAnswerValue: lhs)
            
        case .lessThanOrEqual : //LessThanOrEqual
            predicate = ORKResultPredicate.predicateForScaleQuestionResult(with: resultSelector, maximumExpectedAnswerValue: lhs)
            
        case .range :
             predicate = ORKResultPredicate.predicateForScaleQuestionResult(with: resultSelector, minimumExpectedAnswerValue: lhs, maximumExpectedAnswerValue:rhs  )
            
        default: break
            
        }
        return predicate
    }
    
}
