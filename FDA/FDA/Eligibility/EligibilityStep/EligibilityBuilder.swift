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

let kEligibilityVerifiedScreen = "VerifiedScreen"
let kEligibilityCompletionDescriptionText = "Your enrollment token has been successfully validated. You are eligible to join the Study.\nPlease click Continue to proceed to the Consent section."
let kEligibilityCompletionTitle = "You are Eligible!"



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
    
    
    init() {
        /* default Intalizer method */
        
        self.type = .token
        self.tokenTitle = ""
        self.testArray = Array()
    }
    
    func initEligibilityWithDict(eligibilityDict:Dictionary<String, Any>)  {
        
        if Utilities.isValidObject(someObject: eligibilityDict[kEligibilityTest] as AnyObject ){
            self.testArray = eligibilityDict[kEligibilityTest] as! Array<Dictionary<String, Any>>
        }
        if  Utilities.isValidValue(someObject: eligibilityDict[kEligibilityType] as AnyObject?){
            self.type = EligibilityStepType(rawValue: eligibilityDict[kEligibilityType] as! String)
        }
        if Utilities.isValidObject(someObject: eligibilityDict[kEligibilityCorrectAnswers] as AnyObject ){
            self.testArray = eligibilityDict[kEligibilityTest] as! Array<Dictionary<String, Any>>
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
            }
            else if self.type == EligibilityStepType.test {
                // for only test
                
                for stepDict in self.testArray!{
                    let questionStep:ActivityQuestionStep? = ActivityQuestionStep()
                    questionStep?.initWithDict(stepDict: stepDict as! Dictionary<String, Any>)
                    stepsArray?.append((questionStep?.getQuestionStep())!)
                }
                
                
            }
            else{
                // for both test + token
            for stepDict in self.testArray!{
        
            switch self.type! as EligibilityStepType{
            case .token:
                
                let eligibilityStep:EligibilityStep? = EligibilityStep(identifier: "EligibilityTokenStep")
                eligibilityStep?.type = "TOKEN"
                
                if self.tokenTitle != nil {
                    eligibilityStep?.text = self.tokenTitle!
                }
                stepsArray?.append(eligibilityStep!)
                
            case .test:
                
                let questionStep:ActivityQuestionStep? = ActivityQuestionStep()
                questionStep?.initWithDict(stepDict: stepDict as! Dictionary<String, Any>)
                stepsArray?.append((questionStep?.getQuestionStep())!)
                
            case .both:
                // need to check if it is of question type ?? or pass code type
                // business logic needed to arrage passcode and questionary
                break
            
            }
            
            }
            }
            if (stepsArray?.count)! > 0 {
                
                
                let eligibilityCompletionStep = customInstructionStep(identifier: kEligibilityVerifiedScreen)
                eligibilityCompletionStep.text = kEligibilityCompletionDescriptionText
                
                
                
                eligibilityCompletionStep.title = kEligibilityCompletionTitle
                eligibilityCompletionStep.image =  #imageLiteral(resourceName: "successBlueBig")
                stepsArray?.append(eligibilityCompletionStep)

            
                
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

