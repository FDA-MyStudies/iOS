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
    
    func setActivityResultWithORKResult(taskResult:ORKTaskResult) {
        actvityResult?.initWithORKTaskResult(taskResult:taskResult)
    }
    
    func createTask()->ORKTask?{
        
        if  ((activity?.type) != nil){
            var orkStepArray:[ORKStep]?
            
            orkStepArray = Array<ORKStep>()
            
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
                                
                            case .question:
                                
                                let questionStep:ActivityQuestionStep? = ActivityQuestionStep()
                                questionStep?.initWithDict(stepDict: stepDict)
                                
                                orkStepArray?.append((questionStep?.getQuestionStep())!)
                                
                            case .form:
                                let formStep:ActivityFormStep? = ActivityFormStep()
                                formStep?.initWithDict(stepDict: stepDict)
                                
                                orkStepArray?.append((formStep?.getFormStep())!)
                                
                                
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
                
                var stepDict = activity?.steps![4]
                
                if Utilities.isValidObject(someObject: stepDict as AnyObject?) && Utilities.isValidValue(someObject: stepDict?[kActivityStepType] as AnyObject ) {
                    
                    let activeStep:ActivityActiveStep? = ActivityActiveStep()
                    activeStep?.initWithDict(stepDict: stepDict!)
                    task = activeStep?.getActiveTask()
                    return task!
                }
                else{
                    Logger.sharedInstance.debug("Activity:stepDict is null:\(stepDict)")
                    break;
                }
                
            default: break
                
            }
        }
        else{
            Logger.sharedInstance.debug("activity is null:\(activity)")
        }
        
        return nil
    }
    
    
    
    
    
    
    
}
