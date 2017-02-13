//
//  ActivityActiveStep.swift
//  FDA
//
//  Created by Arun Kumar on 2/13/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation

enum ActiveStepType:String{
    // Active Steps.
    case audioStep = "task-audio"
    case fitnessStep = "task-fitnessCheck"
    case holePegTestStep = "task-holePegTest"
    case psatStep = "task-psat"
    case reactionTime
    case shortWalkStep
    case spatialSpanMemoryStep = "task-spatialSpanMemory"
    case timedWalkStep = "task-timedWalk"
    case timedWalkWithTurnAroundStep
    case toneAudiometryStep = "task-toneAudiometry"
    case towerOfHanoi = "task-towerOfHanoi"
    case tremorTestStep = "task-tremorTest"
    case twoFingerTappingIntervalStep = "task-twoFingerTappingInterval"
    case walkBackAndForthStep
    case kneeRangeOfMotion
    case shoulderRangeOfMotion
}

enum ActiveTaskOptions:String{
    case excludeInstructions = "excludeInstructions"
    case excludeConclusion = "excludeConclusion"
    case excludeAccelerometer = "excludeAccelerometer"
    case excludeDeviceMotion = "excludeDeviceMotion"
    case excludePedometer = "excludePedometer"
    case excludeLocation = "excludeLocation"
    case excludeHeartRate = "excludeHeartRate"
    case excludeAudio = "excludeAudio"

}

class ActivityActiveStep: ActivityStep {
    
    var options:[ActiveTaskOptions]?
    
    
    
    
}
