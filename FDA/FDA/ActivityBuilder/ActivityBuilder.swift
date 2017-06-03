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
                    
                    
                    /*
                     
                     // checking if navigable or randomized or ordered
                     if (activity?.branching)! {
                     
                     //TODO:Next Phase
                     
                     /*
                     task =  ORKNavigableOrderedTask(identifier:(activity?.actvityId)!, steps: orkStepArray)
                     for step in orkStepArray! {
                     
                     if step.isKind(of: ORKQuestionStep.self){
                     let questionStep = step as! ORKQuestionStep
                     
                     switch questionStep.answerFormat {
                     case is ORKScaleAnswerFormat:
                     
                     default:
                     
                     }
                     
                     }
                     
                     
                     }
                     */
                     
                     task =  ORKOrderedTask(identifier: (activity?.actvityId!)!, steps: orkStepArray)
                     return task!
                     }
                     else if (activity?.randomization)! {
                     // randomization
                     //TODO:Next Phase
                     }
                     else{
                     // ordered
                     */
                    
                    
                    let completionStep = ORKCompletionStep(identifier: "CompletionStep")
                    completionStep.title = "Task Completed"
                    completionStep.image = #imageLiteral(resourceName: "successBlueBig")
                    
                    orkStepArray?.append(completionStep)
                    
                    if (orkStepArray?.count)! > 0 {
                        task =  ORKOrderedTask(identifier: (activity?.actvityId!)!, steps: orkStepArray)
                        
                       // self.activity?.branching = true
                        
                        if self.activity?.branching == true{
                        
                           task =  ORKNavigableOrderedTask(identifier:(activity?.actvityId)!, steps: orkStepArray)
                        } // comment the else part
                        else{
                            task =  ORKOrderedTask(identifier:(activity?.actvityId)!, steps: orkStepArray)
                        }
                        
                        
                    }
                    
                    var i:Int? = 0
                    
                    //self.activity?.branching = true
                    
                    if self.activity?.branching == true{
                    
                    for step in orkStepArray!
                    {
                        print("stepid \(step.identifier)")
                        if step.isKind(of: ORKQuestionStep.self){
                            
                            let activityStep:ActivityQuestionStep? = activityStepArray?[(i!)] as?  ActivityQuestionStep
                            
                            
                            if (activityStep?.destinations?.count)! > 0{
                                
                                var defaultStepIdentifier:String = ""
                                
                                if i! + 1 < (activityStepArray?.count)!{
                                    defaultStepIdentifier = (activityStepArray?[(i!+1)].key)!
                                }
                                else{
                                    defaultStepIdentifier = "CompletionStep"
                                }
                                
                                var defaultStepExist:Bool? = false
                                let resultSelector: ORKResultSelector?
                                var predicateRule: ORKPredicateStepNavigationRule?
                                
                                resultSelector =  ORKResultSelector(stepIdentifier: step.identifier, resultIdentifier: step.identifier)
                                
                                let questionStep = step as! ORKQuestionStep
                                
                                var choicePredicate:[NSPredicate] = [NSPredicate]()
                                
                                var destination:Array<String>? = Array<String>()
                                
                                for dict in (activityStep?.destinations)!{
                                    var predicateQuestionChoiceA:NSPredicate = NSPredicate()
                                    
                                    if Utilities.isValidValue(someObject: dict[kCondtion] as AnyObject) {
                                        
                                        switch questionStep.answerFormat {
                                            
                                        case is ORKTextChoiceAnswerFormat, is ORKTextScaleAnswerFormat, is ORKImageChoiceAnswerFormat:
                                            
                                            predicateQuestionChoiceA = ORKResultPredicate.predicateForChoiceQuestionResult(with:resultSelector! , expectedAnswerValue: dict[kCondtion] as! NSCoding & NSCopying & NSObjectProtocol)
                                            
                                            choicePredicate.append(predicateQuestionChoiceA)
                                            
                                            if dict[kCondtion] != nil && dict[kDestination] != nil && (dict[kDestination] as! String) == "" {
                                                // this means c = value & d = ""
                                                
                                                 destination?.append( "CompletionStep" )
                                            }
                                            else{
                                                // this means c = value && d =  value
                                                
                                                destination?.append( dict[kDestination]! as! String)
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
                                                
                                                destination?.append( "CompletionStep" )
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
                                                
                                                 defaultStepIdentifier = "CompletionStep"
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
                                            directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: "CompletionStep")
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
                                    predicateRule = ORKPredicateStepNavigationRule(resultPredicates: choicePredicate, destinationStepIdentifiers: destination!, defaultStepIdentifier: defaultStepIdentifier, validateArrays: true)
                                    
                                    
                                    (task as! ORKNavigableOrderedTask).setNavigationRule(predicateRule!, forTriggerStepIdentifier:step.identifier)
                                }
                                
                                
                                // case is ORKBooleanAnswerFormat:
                                
                                // case is ORKImageChoiceAnswerFormat:
                                // case is ORKTextChoiceAnswerFormat:
                                
                                // task =  ORKNavigableOrderedTask(identifier:(activity?.actvityId)!, steps: orkStepArray)
                                
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
                 
                 
                 for step  in (localTask?.steps)!{
                 orkStepArray?.append(step)
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
    
    
    
    
    
    
    
}
