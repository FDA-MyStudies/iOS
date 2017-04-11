//
//  ActivityBuilder.swift
//  FDA
//
//  Created by Arun Kumar on 2/16/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit

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
                                
                                orkStepArray?.append((questionStep?.getQuestionStep())!)
                                activityStepArray?.append(questionStep!)
                                
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
                        
                        task =  ORKOrderedTask(identifier: (activity?.actvityId!)!, steps: orkStepArray)
                        return task!
                        
                    }
                    
                }
                
            case .activeTask:
                
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
           // case .questionnaireAndActiveTask:
                
            /*
                
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
                    task =  ORKOrderedTask(identifier: (activity?.actvityId!)!, steps: orkStepArray)
                    return task!
                }
                else{
                    return nil
                }

             */
              
            }
            
           
            
        }
        else{
            Logger.sharedInstance.debug("activity is null:\(activity)")
        }
        
        return nil
        
        
         self.actvityResult?.setActivity(activity: self.activity!)
        
    }
    
    
    
    
    
    
    
}
