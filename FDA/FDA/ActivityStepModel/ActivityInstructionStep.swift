//
//  ActivityInstructionStep.swift
//  FDA
//
//  Created by Arun Kumar on 2/13/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit
class ActivityInstructionStep: ActivityStep {
    
    var image:UIImage? //Used for custom image if exist
    var imageLocalPath:String? //Used for saving the custom image if exists any
    var imageServerURL:String?
    
    //Default Initializer
    override init() {
        super.init()
        self.imageLocalPath = ""
        self.imageServerURL = ""
        self.image = UIImage()
        
    }
    //Initializer with Dictionary
    override func initWithDict(stepDict: Dictionary<String, Any>) {
        
        if Utilities.isValidObject(someObject: stepDict as AnyObject?){
            super.initWithDict(stepDict: stepDict)
            
        }
        else{
            Logger.sharedInstance.debug("Instruction Step Dictionary is null:\(stepDict)")
        }
        
    }
    
    /* method creates ORKInstructionStep based on ActivityStep data
     returns ORKInstructionStep
     */
    func getInstructionStep() -> ORKInstructionStep? {
        
        if   Utilities.isValidValue(someObject:title  as AnyObject?) && Utilities.isValidValue(someObject:text  as AnyObject?) && Utilities.isValidValue(someObject:key  as AnyObject?)   {
            
            let instructionStep = ORKInstructionStep(identifier: key!)
            
            instructionStep.title = NSLocalizedString(title!, comment: "")
            instructionStep.text = text!
            return instructionStep
        }
        else{
            Logger.sharedInstance.debug("Instruction Step Data is null ")
            return nil
        }
    }
}
