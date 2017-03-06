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


let kFetalKickIntroductionStepIdentifier = "Introduction"
let kFetalKickIntroductionStepTitle = ""
let kFetalKickIntroductionStepText = "This task needs you to record the number of times you experience fetal kicks in a given duration of time.Also called as the Fetal Kick Counter task, this will help assess the activity of the baby within."


let kFetalKickCounterStepIdentifier = "FetalKickCounterStep"

let kFetalKickCounterStepCompletionTitle = "Task Completed"
let kFetalKickCounterStepCompletionText = "Thank you for your time!"

let kFetalKickCounterTaskIdentifier = "FetalKickCounterTask"


class FetalKickCounterTask {
    
    var duration:Int?       // task run time
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
    func initWithFormatDuration(duration:Int)  {
        
        self.steps =  [ORKStep]()
        if Utilities.isValidValue(someObject: duration as AnyObject? ){
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
        
        
        //create a Instruction step
        let instructionStep = ORKInstructionStep(identifier: kFetalKickInstructionStepIdentifier)
        instructionStep.title = NSLocalizedString(kFetalKickInstructionStepTitle, comment: "")
        instructionStep.text = NSLocalizedString(kFetalKickInstructionStepText, comment: "")
        
        steps?.append(instructionStep)
        
        //create a Introduction step
        let introductionStep = ORKInstructionStep(identifier: kFetalKickInstructionStepIdentifier)
        introductionStep.title = NSLocalizedString(kFetalKickInstructionStepTitle, comment: "")
        introductionStep.text = NSLocalizedString(kFetalKickInstructionStepText, comment: "")
        
        //create a Fetal Kick Counter Step
        let kickStep = FetalKickCounterStep(identifier: kFetalKickCounterStepIdentifier)
        kickStep.counDownTimer = self.duration
        
        
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