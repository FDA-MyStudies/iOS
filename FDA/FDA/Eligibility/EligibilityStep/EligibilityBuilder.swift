//
//  EligibilityBuilder.swift
//  FDA
//
//  Created by Arun Kumar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit

let kEligibilityType = "type"
let kEligibilityTest = "test"
let kEligibilityCorrectAnswers = "correctAnswers"
let kEligibilityTokenTitle = "tokenTitle"

let kEligibilityInEligibleScreen = "InEligibleScreen"
let kEligibilityInEligibleDescriptionText = "Sorry, You are Ineligible"


let kEligibilityVerifiedScreen = "VerifiedScreen"
let kEligibilityCompletionDescriptionText = "Your enrollment token has been successfully validated. You are eligible to join the Study.\nPlease click Continue to proceed to the Consent section."
let kEligibilityCompletionTitle = "You are Eligible!"

let kEligibilityStep = "steps"

let kEligibilityValidateScreen = "ValidatedScreen"
let kEligibilityValidationDescriptionText = "Your ID has been validated. You are eligible to join the Study.Please click Continue to proceed to the Consent section."
let kEligibilityValidationTitle = "Validated!"



let kEligibilityTestInstructionStep = "EligibilityTestInstructionStep"
let kEligibilityTestInstructionTestTitle = "Eligibility Test"
let kEligibilityInstructionTestText = "Please answer some quick questions to confirm your eligibility for this study."



let kEligibilityCompletionTestDescriptionText = "Based on the answers you provided, you are eligible to participate in this study.\nPlease click Continue to proceed to the Consent section."


let kEligibilityCorrectAnswer = "answer"
let kEligibilityCorrectAnswerKey = "key"


enum EligibilityStepType:String {
    case token = "token"
    case test = "test"
    case both = "combined"
}


class EligibilityBuilder{
    
    var type:EligibilityStepType?
    var tokenTitle:String?
    
    var testArray:Array<Any>?
    static var currentEligibility:EligibilityBuilder? = nil
    var correctAnswers:Array<Dictionary<String,Any>>?
    
    
    init() {
        /* default Intalizer method */
        
        self.type = .token
        self.tokenTitle = ""
        self.testArray = Array()
        self.correctAnswers = Array<Dictionary<String,Any>>()
    }
    
    func initEligibilityWithDict(eligibilityDict:Dictionary<String, Any>)  {
        
        if Utilities.isValidObject(someObject: eligibilityDict[kEligibilityTest] as AnyObject ){
            self.testArray = eligibilityDict[kEligibilityTest] as! Array<Dictionary<String, Any>>
        }
        if  Utilities.isValidValue(someObject: eligibilityDict[kEligibilityType] as AnyObject?){
            self.type = EligibilityStepType(rawValue: eligibilityDict[kEligibilityType] as! String)
        }
        if Utilities.isValidObject(someObject: eligibilityDict[kEligibilityCorrectAnswers] as AnyObject ){
            self.correctAnswers = eligibilityDict[kEligibilityCorrectAnswers] as? Array<Dictionary<String, Any>>
        }
        if  Utilities.isValidValue(someObject: eligibilityDict[kEligibilityTokenTitle] as AnyObject?){
            self.tokenTitle =  eligibilityDict[kEligibilityTokenTitle] as? String
        }
        
        
    }
    
    func getEligibilitySteps() -> [ORKStep]?{
        
        
        
        if  self.type != nil{
            
            // Utilities.isValidObject(someObject: self.testArray as AnyObject )
            //  && Utilities.isValidValue(someObject: self.tokenTitle as AnyObject )
            
           
            var stepsArray:[ORKStep]? = [ORKStep]()
            
            
            if self.type == EligibilityStepType.token {
                
                //let passcodeStep = ORKPasscodeStep(identifier:tokenTitle! )
                //stepsArray?.append(passcodeStep)
                
                let eligibilityStep:EligibilityStep? = EligibilityStep(identifier: kEligibilityTokenStep)
                eligibilityStep?.type = "TOKEN"
                
                if self.tokenTitle != nil {
                    eligibilityStep?.text = self.tokenTitle!
                }
                
                stepsArray?.append(eligibilityStep!)
                
                // creating Token Validated Step
                let eligibilityValidationStep = customInstructionStep(identifier: kEligibilityValidateScreen)
                eligibilityValidationStep.text = kEligibilityValidationDescriptionText
                
                eligibilityValidationStep.title = kEligibilityValidationTitle
                eligibilityValidationStep.image =  #imageLiteral(resourceName: "successBlueBig")
                stepsArray?.append(eligibilityValidationStep)
                
                
                
                
            }
            else if self.type == EligibilityStepType.test {
                // for only test
                
                // add the Instruction step for eligibility Test
                
                let eligibilityTestInstructionStep = customInstructionStep(identifier: kEligibilityTestInstructionStep)
                eligibilityTestInstructionStep.text = kEligibilityInstructionTestText
                
                eligibilityTestInstructionStep.title = kEligibilityTestInstructionTestTitle
                stepsArray?.append(eligibilityTestInstructionStep)
                
                
                //test array will hold the questions, correct answers will hold the answers
                
                for stepDict in self.testArray!{
                    let questionStep:ActivityQuestionStep? = ActivityQuestionStep()
                    questionStep?.initWithDict(stepDict: stepDict as! Dictionary<String, Any>)
                    stepsArray?.append((questionStep?.getQuestionStep())!)
                }
                
                // creating InEligibility Completion Step
                
                let eligibilityCompletionStep:InEligibilityStep? = InEligibilityStep(identifier: kInEligibilityStep)
                
                stepsArray?.append(eligibilityCompletionStep!)
                
                
            }
            else{
                // for both test + token
                
                // creating Token Step
                let eligibilityStep:EligibilityStep? = EligibilityStep(identifier: kEligibilityTokenStep)
                eligibilityStep?.type = "TOKEN"
                
                if self.tokenTitle != nil {
                    eligibilityStep?.text = self.tokenTitle!
                }
                
                stepsArray?.append(eligibilityStep!)
                
                
                
                // add the Instruction step for eligibility Test
                
                let eligibilityTestInstructionStep = customInstructionStep(identifier: kEligibilityTestInstructionStep)
                eligibilityTestInstructionStep.text = kEligibilityInstructionTestText
                
                eligibilityTestInstructionStep.title = kEligibilityTestInstructionTestTitle
                stepsArray?.append(eligibilityTestInstructionStep)
                
                
                // creating Test Questions
                
                for stepDict in self.testArray!{
                    
                    let questionStep:ActivityQuestionStep? = ActivityQuestionStep()
                    questionStep?.initWithDict(stepDict: stepDict as! Dictionary<String, Any>)
                    // Questions are mandatory not skippable
                    questionStep?.skippable = false
                    stepsArray?.append((questionStep?.getQuestionStep())!)
                    
                }
                
                // creating InEligibility Completion Step
                
                let eligibilityCompletionStep:InEligibilityStep? = InEligibilityStep(identifier: kInEligibilityStep)
                
                stepsArray?.append(eligibilityCompletionStep!)
                
                
            }
            
            
            if (stepsArray?.count)! > 0 {
                
                
                if self.type == EligibilityStepType.test || self.type == .both {
                    
                    // creating Eligibility Completion Step
                    let eligibilityCompletionStep = customInstructionStep(identifier: kEligibilityVerifiedScreen)
                    eligibilityCompletionStep.text = kEligibilityCompletionTestDescriptionText
                    
                    eligibilityCompletionStep.title = kEligibilityCompletionTitle
                    eligibilityCompletionStep.image =  #imageLiteral(resourceName: "successBlueBig")
                    stepsArray?.append(eligibilityCompletionStep)
                }
                
                return stepsArray!
            }
            else{
                return nil
            }
        }
        else{
            
            Logger.sharedInstance.debug("consent Step has null values:")
            return nil
        }
        
        
    }
    
}

class customInstructionStep:ORKInstructionStep{
    func showsProgress() -> Bool {
        return false
    }
}

