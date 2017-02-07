//
//  StepProvider.swift
//  FDA
//
//  Created by Arun Kumar on 2/7/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation

enum StepType {
    
    case formStep
    
    // Survey Step specific identifiers.
    case introStep
    case questionStep
    case summaryStep
    
    // Step for  Boolean question.
    case booleanQuestionStep
    
    // Step for  example of date entry.
    case dateQuestionStep
    
    // Step for  example of date and time entry.
    case dateTimeQuestionStep
    
    // Step for  example of height entry.
    case heightQuestion
    
    // Step for  image choice question.
    case imageChoiceQuestionStep
    
    // Step for  location entry.
    case locationQuestionStep
    
    // Step with examples of numeric questions.
    case numericQuestionStep
    case numericNoUnitQuestionStep
    
    // Step with examples of questions with sliding scales.
    case discreteScaleQuestionStep
    case continuousScaleQuestionStep
    case discreteVerticalScaleQuestionStep
    case continuousVerticalScaleQuestionStep
    case textScaleQuestionStep
    case textVerticalScaleQuestionStep
    
    // Step for  example of free text entry.
    case textQuestionStep
    
    // Step for  example of a multiple choice question.
    case textChoiceQuestionStep
    
    // Step for  example of time of day entry.
    case timeOfDayQuestionStep
    
    // Step for  example of time interval entry.
    case timeIntervalQuestionStep
    
    // Step for  value picker.
    case valuePickerChoiceQuestionStep
    
    // Step for  example of validated text entry.
    case validatedTextQuestionStepEmail
    case validatedTextQuestionStepDomain
    
    // Image capture Step specific identifiers.
    case imageCaptureStep
    
    // Video capture Step specific identifiers.
    case VideoCaptureStep
    
    // Step for  example of waiting.
    case waitStepDeterminate
    case waitStepIndeterminate
    
    // Consent Step specific identifiers.
    case visualConsentStep
    case consentSharingStep
    case consentReviewStep
    case consentDocumentParticipantSignature
    case consentDocumentInvestigatorSignature
    
    // Account creation Step specific identifiers.
  
    case registrationStep
    case waitStep
    case verificationStep
    
    // Login Step specific identifiers.
    case loginStep
    
    // Passcode Step specific identifiers.
    case passcodeStep
    
    // Active Steps.
    case audioStep
    case fitnessStep
    case holePegTestStep
    case psatStep
    case reactionTime
    case shortWalkStep
    case spatialSpanMemoryStep
    case timedWalkStep
    case timedWalkWithTurnAroundStep
    case toneAudiometryStep
    case towerOfHanoi
    case tremorTestStep
    case twoFingerTappingIntervalStep
    case walkBackAndForthStep
    case kneeRangeOfMotion
    case shoulderRangeOfMotion
    
    // Video instruction Steps.
    case videoInstructionStep
}

//MARK: Step Creation

/*
func getFormStep(dict:NSDictionary) -> ORKFormStep {
    
}
*/
