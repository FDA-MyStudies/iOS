//
//  ActivityFormStep.swift
//  FDA
//
//  Created by Arun Kumar on 2/13/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit


let kStepFormSteps = "steps"

class ActivityFormStep: ActivityStep {
    
    var itemsArray:[Dictionary<String,Any>]
    
    override init() {
        self.itemsArray = Array()
        super.init()
        
        
    }
    override func initWithDict(stepDict: Dictionary<String, Any>) {
        if Utilities.isValidObject(someObject: stepDict as AnyObject?){
            
            super.initWithDict(stepDict: stepDict)
            
            
            if Utilities.isValidObject(someObject: stepDict[kStepFormSteps] as AnyObject ){
                self.itemsArray = (stepDict[kStepFormSteps] as? [Dictionary<String,Any>])!
            }
            
            
        }
        else{
            Logger.sharedInstance.debug("Instruction Step Dictionary is null:\(stepDict)")
        }
    }
    
    func getFormStep() -> ORKFormStep? {
        /*
         method creates the Form step based on the ActivityStep and using itemsArray
         returns the ORKFormStep
         NOTE: this method only return formStep of Questions, does not support ActiveTask as items
         */
        if   Utilities.isValidValue(someObject:title  as AnyObject?)
            && Utilities.isValidValue(someObject:key  as AnyObject?)
            && Utilities.isValidObject(someObject:self.itemsArray  as AnyObject?) {
            
            let step = ORKFormStep(identifier: key!, title: title, text: text)
            step.formItems = [ORKFormItem]()
            
            for dict in self.itemsArray {
                
                if  Utilities.isValidObject(someObject:dict  as AnyObject?){
                    
                    let questionStep:ActivityQuestionStep? = ActivityQuestionStep()
                    questionStep?.initWithDict(stepDict: dict)
                    
                    let orkQuestionStep:ORKQuestionStep = (questionStep?.getQuestionStep())!
                    
                    let formItem01 = ORKFormItem(identifier: orkQuestionStep.identifier, text: orkQuestionStep.title, answerFormat: orkQuestionStep.answerFormat)
                    formItem01.placeholder = orkQuestionStep.text
                    
                    step.formItems?.append(formItem01)
                    
                }
                else{
                    Logger.sharedInstance.debug("item Dictionary is null :\(dict)")
                }
            }
            return step
            
        }
        else{
            Logger.sharedInstance.debug("Form Data is null ")
            
            return nil
        }
        
        
    }
    
    
}
