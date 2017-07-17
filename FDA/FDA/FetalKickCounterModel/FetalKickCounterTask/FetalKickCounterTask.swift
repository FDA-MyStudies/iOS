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
    /*
     Default Initializer method
     */
    init() {
        self.steps =  [ORKStep]()
        self.identifier = kFetalKickCounterStepIdentifier
        self.duration = 0
        self.instructionText = ""
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
        }
        else{
            self.duration = 50
            Logger.sharedInstance.warn("Duration is null:\(duration)")
        }
        
        if Utilities.isValidValue(someObject: instructionText as AnyObject?){
             self.instructionText = instructionText
        }
        else{
             self.instructionText = ""
        }
    }
    
    /*
     Getter method to create fetalKickTask
     @returns OrkorderedTask    containing steps
     */
    
    func getTask() -> ORKOrderedTask {
        
        
        //create a Intro step
        
        let introStep = FetalKickIntroStep(identifier: kFetalKickIntroductionStepIdentifier)
        introStep.introTitle =  NSLocalizedString(kFetalKickInstructionStepTitle, comment: "")
        introStep.subTitle =  NSLocalizedString(kFetalKickInstructionStepText, comment: "")
        introStep.displayImage = #imageLiteral(resourceName: "task_img1")
        
       // let instructionStep = ORKInstructionStep(identifier: kFetalKickInstructionStepIdentifier)
       // instructionStep.title = NSLocalizedString(kFetalKickInstructionStepTitle, comment: "")
      // instructionStep.text = NSLocalizedString(kFetalKickInstructionStepText, comment: "")
        
       // instructionStep.auxiliaryImage = #imageLiteral(resourceName: "task_img1")
        
       // instructionStep.image = #imageLiteral(resourceName: "task_img1")
        
       // instructionStep.iconImage = #imageLiteral(resourceName: "task_img1")
        
        steps?.append(introStep)
        
        //create a Introduction step
        let introductionStep = ORKInstructionStep(identifier: kFetalKickInstructionStepIdentifier)
        introductionStep.title = NSLocalizedString(kFetalKickInstructionStepTitle, comment: "")
        
        
        if (self.instructionText?.characters.count)! > 0 {
            introductionStep.text = NSLocalizedString(self.instructionText!, comment: "")
            steps?.append(introductionStep)
        }
        
        
        
        //create a Fetal Kick Counter Step
        let kickStep = FetalKickCounterStep(identifier: self.identifier!)
        kickStep.counDownTimer = Int(self.duration! )
        
        
        kickStep.totalCounts = 0
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
        summaryStep.detailText = "Thank you for your time. Tap Done to submit responses. Responses cannot be modified after submission."
       
        
        
        steps?.append(summaryStep)
        
        return ORKOrderedTask(identifier: kFetalKickCounterTaskIdentifier, steps: steps)
    }
    
}
