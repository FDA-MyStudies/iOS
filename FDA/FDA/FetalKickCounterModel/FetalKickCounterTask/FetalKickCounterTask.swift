//
//  FetalKickCounterTask.swift
//  FDA
//
//  Created by Arun Kumar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit

class FetalKickCounterTask {
    
    
    var steps:[ORKStep]? = [ORKStep]()
    init() {
        
    }
    
    func getTask() -> ORKOrderedTask {
        let instructionStep = ORKInstructionStep(identifier: "1234")
        instructionStep.title = NSLocalizedString("KickTitle", comment: "")
        
        instructionStep.text = "InstructionStep"
        
        steps?.append(instructionStep)
        
        
        let kickStep = FetalKickCounterStep(identifier: "FetalKickCounter")
        
        kickStep.counDownTimer = 30
        kickStep.totalCounts = 0
        
        
        
        
        kickStep.stepDuration = 20
        kickStep.shouldShowDefaultTimer = false
        kickStep.shouldStartTimerAutomatically = true
        kickStep.shouldContinueOnFinish = true
        kickStep.title = "Please listen for 30 seconds."
        
        steps?.append(kickStep)
        
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        steps?.append(summaryStep)
        
        return ORKOrderedTask(identifier: "FetalKickCounterTask", steps: steps)
    }
    
    
   
}
