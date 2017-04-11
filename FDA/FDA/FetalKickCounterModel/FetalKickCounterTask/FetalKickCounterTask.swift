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

let kFetalKickCounterStepCompletionTitle = "Task Completed"
let kFetalKickCounterStepCompletionText = "Thank you for your time!"

let kFetalKickCounterTaskIdentifier = "FetalKickCounterTask"


class FetalKickCounterTask {
    
    var duration:Float?       // task run time
    var steps:[ORKStep]?    // steps involved in fetal kick
    
    /*
     Default Initializer method
     */
    init() {
        self.steps =  [ORKStep]()
        self.duration = 0
    }
    
    
    /*
     Initalizer method to create instance
     @param duration    is task run time in hours
     */
    func initWithFormatDuration(duration:Float)  {
        
        self.steps =  [ORKStep]()
        if duration > 0.0{
            self.duration = duration
        }
        else{
            
            Logger.sharedInstance.warn("Duration is null:\(duration)")
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
        introductionStep.text = NSLocalizedString(kFetalKickInstructionStepText, comment: "")
        
        //create a Fetal Kick Counter Step
        let kickStep = FetalKickCounterStep(identifier: kFetalKickCounterStepIdentifier)
        kickStep.counDownTimer = Int(self.duration! * 60)
        
        
        kickStep.totalCounts = 0
        kickStep.stepDuration = 30
        kickStep.shouldShowDefaultTimer = false
        kickStep.shouldStartTimerAutomatically = true
        kickStep.shouldContinueOnFinish = true
        kickStep.shouldUseNextAsSkipButton = false
        
        steps?.append(kickStep)
        
        //create a Completion Step
        let summaryStep = ORKCompletionStep(identifier: kFetalKickCounterStepCompletionTitle)
        
        steps?.append(summaryStep)
        
        return ORKOrderedTask(identifier: kFetalKickCounterTaskIdentifier, steps: steps)
    }
    
}
