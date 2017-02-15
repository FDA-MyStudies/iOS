//
//  ActivityActiveStep.swift
//  FDA
//
//  Created by Arun Kumar on 2/13/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit


let kActivityStepActiveOptions = "options"
let kActivityStepActiveFormat = "format"


//Active task Api constants

//FitnessCheckFormat

let kActiveFitnessCheckWalkDuration = "walkDuration"
let kActiveFitnessCheckRestDuration = "restDuration"



//ShortWalkFormat

let kActiveShortWalkNumberOfStepsPerLeg = "numberOfStepsPerLeg"
let kActiveShortWalkRestDuration = "restDuration"



//AudioFormat

let kActiveAudioSpeechInstruction = "speechInstruction"
let kActiveAudioShortSpeechInstruction = "shortSpeechInstruction"
let kActiveAudioDuration  = "duration"

//TwoFingerTappingIntervalFormat

let kActiveTwoFingerTappingIntervalDuration = "duration"
let kActiveTwoFingerTappingIntervalHandOptions = "handOptions"

//SpatialSpanMemoryFormat

let kActiveSpatialSpanMemoryInitialSpan = "initialSpan"
let kActiveSpatialSpanMemoryMinimumSpan = "minimumSpan"
let kActiveSpatialSpanMemoryMaximumSpan = "maximumSpan"
let kActiveSpatialSpanMemoryPlaySpeed = "playSpeed"
let kActiveSpatialSpanMemoryMaximumTests = "maximumTests"
let kActiveSpatialSpanMemoryMaximumConsecutiveFailures = "maximumConsecutiveFailures"
let kActiveSpatialSpanMemoryCustomTargetImage = "customTargetImage"
let kActiveSpatialSpanMemoryCustomTargetPluralName = "customTargetPluralName"
let kActiveSpatialSpanMemoryRequireReversal = "requireReversal"


//ToneAudiometryFormat
let kActiveToneAudiometrySpeechInstruction = "speechInstruction"
let kActiveToneAudiometryShortSpeechInstruction = "shortSpeechInstruction"
let kActiveToneAudiometryToneDuration = "toneDuration"

//TowerOfHanoiFormat
let kActiveTowerOfHanoiNumberOfDisks = "numberOfDisks"


//TimedWalkFormat

let kActiveTimedWalkTistanceInMeters = "distanceInMeters"
let kActiveTimedWalkTimeLimit = "timeLimit"
let kActiveTimedWalkTurnAroundTimeLimit = "turnAroundTimeLimit"

//PSATFormat

let kActivePSATPresentationMode = "presentationMode"
let kActivePSATInterStimulusInterval = "interStimulusInterval"
let kActivePSATStimulusDuration = "stimulusDuration"
let kActivePSATSeriesLength = "seriesLength"

//TremorTestFormat

let kActiveTremorTestActiveStepDuration = "activeStepDuration"
let kActiveTremorTestActiveTaskOptions = "activeTaskOptions"
let kActiveTremorTestHandOptions = "handOptions"


//HolePegTestFormat

let kActiveHolePegTestDominantHand = "dominantHand"
let kActiveHolePegTestNumberOfPegs = "numberOfPegs"
let kActiveHolePegTestThreshold = "threshold"
let kActiveHolePegTestRotated = "rotated"
let kActiveHolePegTestTimeLimit = "timeLimit"


//FetalKickCounterFormat
let kActiveFetalKickCounterDuration = "duration"



enum ActiveStepType:String{
    // Active Steps.
    case audioStep = "task-audio"
    case fitnessStep = "task-fitnessCheck"
    case holePegTestStep = "task-holePegTest"
    case psatStep = "task-psat"
    case reactionTime
    case shortWalkStep = "task-shortWalk"
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
    case fetalKickCounter = "task-fetalKickCounter"
}



class ActivityActiveStep: ActivityStep {
    
    var options:ORKPredefinedTaskOption?
    
    var formatDict:Dictionary<String, Any>?
    
    override init() {
        super.init()
        options = .excludeAudio
        formatDict = Dictionary()
    }
    
    override func initWithDict(stepDict: Dictionary<String, Any>) {
        //Setter method to set Activity Active Steps
        if Utilities.isValidObject(someObject: stepDict as AnyObject?){
            
            super.initWithDict(stepDict: stepDict)
            
            if Utilities.isValidObject(someObject: stepDict[kActivityStepActiveOptions] as AnyObject ){
                
                for  option:Int in stepDict[kActivityStepActiveOptions] as! [Int] {
                    self.options?.formUnion(ORKPredefinedTaskOption(rawValue: UInt(option)))
                    //?.append( ORKPredefinedTaskOption(rawValue: UInt(option)))
                }
            }
            
            if Utilities.isValidObject(someObject: stepDict[kActivityStepActiveFormat] as AnyObject ){
                self.formatDict = (stepDict[kActivityStepActiveFormat] as? Dictionary)!
            }
        }
        else{
            Logger.sharedInstance.debug("Question Step Dictionary is null:\(stepDict)")
        }
        
    }
    
    
    func getActiveTask() -> ORKTask? {
        //Method to get Active Tasks
        
        if Utilities.isValidObject(someObject: self.formatDict as AnyObject?) && Utilities.isValidValue(someObject:resultType  as AnyObject?) && Utilities.isValidObject(someObject: self.options as AnyObject?)  {
            
            switch resultType as! ActiveStepType {
                
            case .audioStep :
                
                if  Utilities.isValidValue(someObject:formatDict?[kActiveAudioSpeechInstruction] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveAudioShortSpeechInstruction] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveAudioDuration] as AnyObject?)
                {
                    
                    return ORKOrderedTask.audioTask(withIdentifier: key!,
                                                    intendedUseDescription: title!,
                                                    speechInstruction: formatDict?[kActiveAudioSpeechInstruction] as! String?,
                                                    shortSpeechInstruction: formatDict?[kActiveAudioShortSpeechInstruction] as! String?,
                                                    duration: formatDict?[kActiveAudioDuration] as! TimeInterval,
                                                    recordingSettings: nil,
                                                    checkAudioLevel: true, options:self.options!)
                    
                    
                }
                else{
                    Logger.sharedInstance.debug("audioStep:formatDict has null values:\(formatDict)")
                    return nil
                }
                
            case .fitnessStep :
                
                if  Utilities.isValidValue(someObject:formatDict?[kActiveFitnessCheckWalkDuration] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveFitnessCheckRestDuration] as AnyObject?)
                {
                    
                    return ORKOrderedTask.fitnessCheck(withIdentifier: key!,
                                                       intendedUseDescription: title!,
                                                       walkDuration: formatDict?[kActiveFitnessCheckWalkDuration] as! TimeInterval,
                                                       restDuration: formatDict?[kActiveFitnessCheckRestDuration] as! TimeInterval,
                                                       options: self.options!)
                    
                    
                    
                }
                else{
                    Logger.sharedInstance.debug("fitnessStep:formatDict has null values:\(formatDict)")
                    return nil
                }
            case .holePegTestStep :
                if  Utilities.isValidValue(someObject:formatDict?[kActiveHolePegTestDominantHand] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveHolePegTestNumberOfPegs] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveHolePegTestThreshold] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveHolePegTestRotated] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveHolePegTestTimeLimit] as AnyObject?)
                {
                    
                    
                    return ORKNavigableOrderedTask.holePegTest(withIdentifier:key!, intendedUseDescription: title!,
                                                               dominantHand: ORKBodySagittal(rawValue: formatDict?[kActiveHolePegTestDominantHand] as! Int)!,
                                                               numberOfPegs:formatDict?[kActiveHolePegTestNumberOfPegs] as! Int32,
                                                               threshold: formatDict?[kActiveHolePegTestThreshold] as! Double,
                                                               rotated: ((formatDict?[kActiveHolePegTestRotated]) != nil),
                                                               timeLimit: formatDict?[kActiveHolePegTestTimeLimit] as! TimeInterval,
                                                               options: self.options!)
                    
                    
                }
                else{
                    Logger.sharedInstance.debug("holePegTestStep:formatDict has null values:\(formatDict)")
                    return nil
                }
            case .psatStep :
                
                if  Utilities.isValidValue(someObject:formatDict?[kActivePSATPresentationMode] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActivePSATInterStimulusInterval] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kActivePSATStimulusDuration] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kActivePSATSeriesLength] as AnyObject?)
                {
                    
                    return ORKOrderedTask.psatTask(withIdentifier: key!,
                                                   intendedUseDescription: title!,
                                                   presentationMode: ORKPSATPresentationMode(rawValue:formatDict?[kActivePSATPresentationMode] as! Int),
                                                   interStimulusInterval: formatDict?[kActivePSATInterStimulusInterval] as! TimeInterval,
                                                   stimulusDuration: formatDict?[kActivePSATStimulusDuration] as! TimeInterval,
                                                   seriesLength: formatDict?[kActivePSATSeriesLength]  as! Int,
                                                   options: self.options!)
                    
                    
                }
                else{
                    Logger.sharedInstance.debug("psatStep:formatDict has null values:\(formatDict)")
                    return nil
                }
                
                
            case .shortWalkStep:
                
                if  Utilities.isValidValue(someObject:formatDict?[kActiveShortWalkNumberOfStepsPerLeg] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveShortWalkRestDuration] as AnyObject?)
                {
                    
                    return ORKOrderedTask.shortWalk(withIdentifier: key!, intendedUseDescription: title!, numberOfStepsPerLeg: formatDict?[kActiveShortWalkNumberOfStepsPerLeg] as! Int, restDuration: formatDict?[kActiveShortWalkRestDuration] as! TimeInterval , options: self.options!)
                    
                }
                else{
                    Logger.sharedInstance.debug("shortWalkStep:formatDict has null values:\(formatDict)")
                    return nil
                }
                
                
            case .spatialSpanMemoryStep :
                
                if  Utilities.isValidValue(someObject:formatDict?[kActiveSpatialSpanMemoryInitialSpan] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveSpatialSpanMemoryMinimumSpan] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveSpatialSpanMemoryMaximumSpan] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveSpatialSpanMemoryPlaySpeed] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveSpatialSpanMemoryMaximumTests] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveSpatialSpanMemoryMaximumConsecutiveFailures] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveSpatialSpanMemoryCustomTargetImage] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveSpatialSpanMemoryCustomTargetPluralName] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveSpatialSpanMemoryRequireReversal] as AnyObject?)
                {
                    
                    //Image data downloading pending ->  kActiveSpatialSpanMemoryCustomTargetImage
                    
                    return ORKOrderedTask.spatialSpanMemoryTask(withIdentifier:  key!, intendedUseDescription:
                        title!,
                                                                initialSpan: formatDict?[kActiveSpatialSpanMemoryInitialSpan] as! Int,
                                                                minimumSpan: formatDict?[kActiveSpatialSpanMemoryMinimumSpan] as! Int,
                                                                maximumSpan: formatDict?[kActiveSpatialSpanMemoryMaximumSpan] as! Int,
                                                                playSpeed: formatDict?[kActiveSpatialSpanMemoryPlaySpeed] as! TimeInterval,
                                                                maximumTests: formatDict?[kActiveSpatialSpanMemoryMaximumTests] as! Int,
                                                                maximumConsecutiveFailures: formatDict?[kActiveSpatialSpanMemoryMaximumConsecutiveFailures] as! Int,
                                                                customTargetImage: formatDict?[kActiveSpatialSpanMemoryCustomTargetImage] as! UIImage?,
                                                                customTargetPluralName: formatDict?[kActiveSpatialSpanMemoryCustomTargetPluralName] as! String?,
                                                                requireReversal: ((formatDict?[kActiveSpatialSpanMemoryRequireReversal]) != nil),
                                                                options: self.options!)
                }
                else{
                    Logger.sharedInstance.debug("spatialSpanMemoryStep:formatDict has null values:\(formatDict)")
                    return nil
                }
            case .timedWalkStep :
                
                if  Utilities.isValidValue(someObject:formatDict?[kActiveTimedWalkTistanceInMeters] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveTimedWalkTimeLimit] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kActiveTimedWalkTurnAroundTimeLimit] as AnyObject?)
                {
                    // includeAssistiveDeviceForm set to false by default
                    
                    return ORKOrderedTask.timedWalk(withIdentifier: key!,
                                                    intendedUseDescription: title!,
                                                    distanceInMeters: formatDict?[kActiveTimedWalkTistanceInMeters] as! Double,
                                                    timeLimit: formatDict?[kActiveTimedWalkTimeLimit] as! TimeInterval,
                                                    turnAroundTimeLimit: formatDict?[kActiveTimedWalkTurnAroundTimeLimit] as! TimeInterval,
                                                    includeAssistiveDeviceForm: false,
                                                    options: self.options!)
                    
                }
                else{
                    Logger.sharedInstance.debug("timedWalkStep:formatDict has null values:\(formatDict)")
                    return nil
                }
            case .toneAudiometryStep :
                
                if  Utilities.isValidValue(someObject:formatDict?[kActiveToneAudiometrySpeechInstruction] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kActiveToneAudiometryShortSpeechInstruction] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kActiveToneAudiometryToneDuration] as AnyObject?)
                {
                    
                    return ORKOrderedTask.toneAudiometryTask(withIdentifier:  key!,
                                                             intendedUseDescription: title!,
                                                             speechInstruction: formatDict?[kActiveToneAudiometrySpeechInstruction] as! String? ,
                                                             shortSpeechInstruction: formatDict?[kActiveToneAudiometryShortSpeechInstruction] as! String?,
                                                             toneDuration: formatDict?[kActiveToneAudiometryToneDuration] as! TimeInterval,
                                                             options: self.options!)
                    
                }
                else{
                    Logger.sharedInstance.debug("toneAudiometryStep:formatDict has null values:\(formatDict)")
                    return nil
                }
            case .towerOfHanoi :
                
                if  Utilities.isValidValue(someObject:formatDict?[kActiveTowerOfHanoiNumberOfDisks] as AnyObject?)
                {
                    return ORKOrderedTask.towerOfHanoiTask(withIdentifier: key!,
                                                           intendedUseDescription: title!,
                                                           numberOfDisks: formatDict?[kActiveTowerOfHanoiNumberOfDisks] as! UInt ,
                                                           options:self.options!)
                }
                else{
                    Logger.sharedInstance.debug("towerOfHanoi:formatDict has null values:\(formatDict)")
                    return nil
                }
            case .twoFingerTappingIntervalStep :
                
                if  Utilities.isValidValue(someObject:formatDict?[kActiveTwoFingerTappingIntervalDuration] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kActiveTwoFingerTappingIntervalHandOptions] as AnyObject?)
                {
                    return ORKOrderedTask.twoFingerTappingIntervalTask(withIdentifier: key!,
                                                                       intendedUseDescription: title!,
                                                                       duration: formatDict?[kActiveTwoFingerTappingIntervalDuration] as! TimeInterval,
                                                                       handOptions: ORKPredefinedTaskHandOption(rawValue:formatDict?[kActiveTwoFingerTappingIntervalHandOptions] as! UInt),
                                                                       options: self.options!)
                    
                }
                else{
                    Logger.sharedInstance.debug("twoFingerTappingIntervalStep:formatDict has null values:\(formatDict)")
                    return nil
                }
                
            case .fetalKickCounter :
                
                if  Utilities.isValidValue(someObject:formatDict?[kActiveFetalKickCounterDuration] as AnyObject?)
                    
                {
                    // need to create new  one
                    return nil
                    
                }
                else{
                    Logger.sharedInstance.debug("fetalKickCounter:formatDict has null values:\(formatDict)")
                    return nil
                    
                }
                
                
                
                
                
            default:
                
                Logger.sharedInstance.debug("Case Mismatch:Default Executed null values:\(formatDict)")
                
                return nil
                
            }
            
        }
        else{
            Logger.sharedInstance.debug("Format Dict have null values:\(formatDict)")
            return nil
        }
        
        
    }
    
    
    
}
