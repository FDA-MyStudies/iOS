//
//  FetalKickCounterTask.swift
//  FDA
//
//  Created by Arun Kumar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit


let kFetalKickInstructionStepIdentifier = "Instruction"
let kFetalKickInstructionStepTitle = "Fetal Kick Counter"
let kFetalKickInstructionStepText = "This task needs you to record the number of times you experience fetal kicks in a given duration of time.Also called as the Fetal Kick Counter task, this will help assess the activity of the baby within."


let kFetalKickIntroductionStepIdentifier = "FetalKickIntroduction"
let kFetalKickIntroductionStepTitle = ""
let kFetalKickIntroductionStepText = "This task needs you to record the number of times you experience fetal kicks in a given duration of time.Also called as the Fetal Kick Counter task, this will help assess the activity of the baby within."


let kFetalKickCounterStepIdentifier = "FetalKickCounterStep"

let kFetalKickCounterStepCompletionTitle = "CompletionStep"
let kFetalKickCounterStepCompletionText = "Thank you for your time!"

let kFetalKickCounterTaskIdentifier = "FetalKickCounterTask"


class FetalKickCounterTask {
    
    var duration:Float?       // task run time
    var identifier:String?
    var steps:[ORKStep]?    // steps involved in fetal kick
    var instructionText:String?
    var maxKickCounts:Int?
    /*
     Default Initializer method
     */
    init() {
        self.steps =  [ORKStep]()
        self.identifier = kFetalKickCounterStepIdentifier
        self.duration = 0
        self.instructionText = ""
        self.maxKickCounts = 0
    }
    
    
    /*
     Initalizer method to create instance
     @param duration    is task run time in hours
     */
    func initWithFormat(duration:Float,identifier:String,instructionText:String?)  {
        
        self.identifier = identifier
        self.steps =  [ORKStep]()
        if duration > 0.0{
            self.duration =  duration
            
        }else{
            self.duration = 50
            Logger.sharedInstance.warn("Duration is null:\(duration)")
        }
        
        if Utilities.isValidValue(someObject: instructionText as AnyObject?){
             self.instructionText = instructionText
            
        }else{
             self.instructionText = ""
        }
        self.maxKickCounts = 0
    }
    
    /* setter method to set totalKickCounts
    */
    func setMaxKicks(maxKicks:Int) {
        self.maxKickCounts = maxKicks
    }
    
    
    /*
     Getter method to create fetalKickTask
     @returns OrkorderedTask    containing steps
     */
    func getTask() -> ORKOrderedTask {
        
        //create a Intro step
        let introStep = FetalKickIntroStep(identifier: kFetalKickIntroductionStepIdentifier)
        introStep.introTitle =  NSLocalizedString(kFetalKickInstructionStepTitle, comment: "")
      
      if (self.instructionText?.characters.count)! > 0 {
        introStep.subTitle = NSLocalizedString(self.instructionText!, comment: "")
       
      }else {
         introStep.subTitle = NSLocalizedString(kFetalKickInstructionStepText, comment: "")
      }
      
        introStep.displayImage = #imageLiteral(resourceName: "task_img1")
        
        steps?.append(introStep)
      
        //create a Fetal Kick Counter Step
        let kickStep = FetalKickCounterStep(identifier: self.identifier!)
        kickStep.counDownTimer = Int(self.duration! )
        
        kickStep.totalCounts = self.maxKickCounts
        kickStep.stepDuration = 30
        kickStep.shouldShowDefaultTimer = false
        kickStep.shouldStartTimerAutomatically = true
        kickStep.shouldContinueOnFinish = true
        kickStep.shouldUseNextAsSkipButton = false
        
        steps?.append(kickStep)
        
        //create a Completion Step
        let summaryStep = ORKCompletionStep(identifier: kFetalKickCounterStepCompletionTitle)
        summaryStep.title = "Activity Completed"
        summaryStep.image = #imageLiteral(resourceName: "successBlueBig")
        summaryStep.detailText = "Thank you for your time!\n\nTap Done to submit responses. Responses cannot be modified after submission."
       
        steps?.append(summaryStep)
        
        return ORKOrderedTask(identifier: kFetalKickCounterTaskIdentifier, steps: steps)
    }
    
}
