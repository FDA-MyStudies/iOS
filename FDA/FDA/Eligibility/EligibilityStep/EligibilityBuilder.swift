//
//  EligibilityBuilder.swift
//  FDA
//
//  Created by Arun Kumar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit


enum EligibilityStepType:String {
    case token = "token"
    case test = "test"
    case both = "both"
}


class EligibilityBuilder{
    
    var type:EligibilityStepType?
    var tokenTitle:String?
    
    var testArray:Array<Any>?
    
    
    
    init() {
        /* default Intalizer method */
        
        self.type = .token
        self.tokenTitle = ""
        self.testArray = Array()
    }
    
    func initEligibilityWithDict(eligibilityDict:Dictionary<String, Any>)  {
        
    }
    
    func getEligibilitySteps() -> [ORKStep]?{
        
        
        if Utilities.isValidObject(someObject: self.testArray as AnyObject )
            && Utilities.isValidValue(someObject: self.tokenTitle as AnyObject )
            && Utilities.isValidValue(someObject: self.type as AnyObject ){
            
            var stepsArray:[ORKStep]? = [ORKStep]()
            
            
            for stepDict in self.testArray!{
            
            
            switch self.type! as EligibilityStepType{
            case .token:
                
                let passcodeStep = ORKPasscodeStep(identifier:tokenTitle! )
                stepsArray?.append(passcodeStep)
                
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
            if (stepsArray?.count)! > 0 {
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
