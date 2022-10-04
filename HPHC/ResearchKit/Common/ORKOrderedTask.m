/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2016, Sage Bionetworks
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "ORKOrderedTask.h"

#import "ORKActiveStep_Internal.h"
#import "ORKStep_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
//#import "ResearchKit.Private.h"
#import <ResearchKit/ORKResult.h>
#import "ORKCollectionResult.h"

#import "ORKCollectionResult_Private.h"
#import "ORKPageStep.h"
#import "ORKQuestionResult_Private.h"
#import "ORKResult_Private.h"
#import "ORKStep.h"
#import "ORKTask.h"

#import "ORKHelpers_Internal.h"

//#import "ResearchKit-ImageClass.h"
//#import <UIImage+ResearchKit.h>

//#if __has_include("ActivityHelper-Swift.h")
//    #import "ActivityHelper-Swift.h"
//#endif

#import <ResearchKit/ResearchKit-Swift.h>
//#import <ResearchKit/ResearchKit-HelperUtilities.Swift.h>
//@class ActivityHelper;
//@class ImageClass;

@implementation ORKOrderedTask {
    NSString *_identifier;
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithIdentifier:(NSString *)identifier steps:(NSArray<ORKStep *> *)steps {
    self = [super init];
    if (self) {
        ORKThrowInvalidArgumentExceptionIfNil(identifier);
        
        _identifier = [identifier copy];
        _steps = steps;
      _stepsReplaced = steps.mutableCopy;
        _progressLabelColor = ORKColor(ORKProgressLabelColorKey);
        [self validateParameters];
    }
    return self;
}

- (instancetype)copyWithSteps:(NSArray <ORKStep *> *)steps {
    ORKOrderedTask *task = [self copyWithZone:nil];
    task->_steps = ORKArrayCopyObjects(steps);
    return task;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKOrderedTask *task = [[[self class] allocWithZone:zone] initWithIdentifier:[_identifier copy]
                                                                           steps:ORKArrayCopyObjects(_steps)];
    return task;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.identifier, castObject.identifier)
            && ORKEqualObjects(self.steps, castObject.steps));
}

- (NSUInteger)hash {
    return _identifier.hash ^ _steps.hash;
}

#pragma mark - ORKTask

- (void)validateParameters {
    NSArray *uniqueIdentifiers = [self.steps valueForKeyPath:@"@distinctUnionOfObjects.identifier"];
    BOOL itemsHaveNonUniqueIdentifiers = ( self.steps.count != uniqueIdentifiers.count );
    
    if (itemsHaveNonUniqueIdentifiers) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Each step should have a unique identifier" userInfo:nil];
    }
}

- (NSString *)identifier {
    return _identifier;
}

- (NSUInteger)indexOfStep:(ORKStep *)step {
    NSUInteger index = [_steps indexOfObject:step];
    if (index == NSNotFound) {
        NSArray *identifiers = [_steps valueForKey:@"identifier"];
        index = [identifiers indexOfObject:step.identifier];
    }
    return index;
}

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
  printf("resultresult---%@---", result);


  ORKStepResult *stepResult = [result stepResultForStepIdentifier:step.identifier];
//  ORKQuestionResult *result1 = (ORKQuestionResult *)(stepResult.results.count > 0 ? stepResult.results.firstObject : nil);
//  if (result1.answer != nil) {
//      if ([((NSArray *)result1.answer).firstObject isEqualToString:@"2"])
//      {
////          return self.step3a;
//      } else {
////          return self.step3b;
//      }
//  }
  
//  let val = self.setResultValue(stepResult: result, activityType: .Questionnaire )
//     print("1valval---\(val)")
  
//  NSString *val = [ActivityHelper setResultValue];
  
  
//  [health1KitBiological ]
//  [health ]
  
//  [health1KitBiologicalSex]
  
  ImageClass *imgObject = [[ImageClass alloc] init];
  [imgObject imageFromStringWithName:@"asd"];
  
  ActivityHelper *activityHelper1 = [[ActivityHelper alloc] init];
//  NSString *val3 =  [activityHelper1 setResultValueWithStepResult:stepResult activityType:@"questionnaire" resultType:step.stepresultType];
  
  
  NSArray *steps = _steps;
  ORKStep *val3 =  [activityHelper1 setResultValueWithStepResult:stepResult activityType:@"questionnaire" resultType:step.stepresultType allSteps:steps currentStep:step];
  
  
  printf("val3---%@----", val3);
  
  if ([val3.identifier  isEqual: @"valDummy"]) {
    NSString *valueToSave = val3.steppreactivityid;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:valueToSave
                     forKey:@"jumpActivity"];
    
    NSString *valueToSave2 = val3.steppredestinationTrueStepKey;
    [userDefaults setObject:valueToSave2
                     forKey:@"OtherActiStepId"];
    [userDefaults synchronize];
    
    return nil;
  }
  
//  ActivityHelper* myScript = [[ActivityHelper alloc] init];
//
//  [ActivityHelper isValidObject]
  
//    NSArray *steps = _steps;
    
    if (steps.count <= 0) {
        return nil;
    }
    
    ORKStep *currentStep = step;
    ORKStep *nextStep = nil;
    
  printf("1therActiStepId---");
    if (currentStep == nil) {
      printf("2therActiStepId---");
        nextStep = steps[0];
      if (nextStep.steppreOtherActiStepId != nil && ![nextStep.steppreOtherActiStepId isEqual: @""]) {
        printf("3therActiStepId---");
        
        ORKStep *val5 =  [activityHelper1 getsecondActivityJumpStepWithAllSteps:steps currentStep:nextStep];
        if (val5 != nil) {
          printf("4therActiStepId---");
          nextStep = val5;
          return nextStep;
        }
        
      }
    } else {
        NSUInteger index = [self indexOfStep:step];
      
      if (val3 != nil) {
        index = [self indexOfStep:val3];
//        _stepsReplaced = self.steps.mutableCopy;
        [_stepsReplaced replaceObjectAtIndex:index withObject:val3];

//        steps[index] = val3;
        nextStep = steps[index];
        return nextStep;
      }
      
        
        if (NSNotFound != index && index != (steps.count - 1)) {
//          if ([step.steppredestinationTrueStepIndex  isEqual: @"6"]) {
//            nextStep = steps[6];
//          } else if ([step.steppredestinationTrueStepIndex  isEqual: @"8"]) {
//            nextStep = steps[13];
//          }
//          else {
//            nextStep = steps[index + 1];
//          }
          
          nextStep = steps[index + 1];
          if (![nextStep.steppreisHidden isEqual: @"false"] ) {
//            nextStep = steps[index + 2];
            
//            ORKStep *val7 =  [activityHelper1 getNonHiddenStep:steps currentStep:nextStep];
            
            ORKStep *val7 =  [activityHelper1 getNonHiddenStepWithAllSteps:steps currentStep:nextStep indexVal:index + 1];
            return val7;
          } else {
            return nextStep;
          }
          
        }
    }
    return nextStep;
}

- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    NSArray *steps = _steps;
  
  NSArray *arraystepsReplaced = [_stepsReplaced copy];
    
    if (steps.count <= 0) {
        return nil;
    }
  
  ORKStep *checkStep = steps[0];
    if (step.identifier == checkStep.steppreOtherActiStepId) {
      return nil;
    }
    
    ORKStep *currentStep = step;
    ORKStep *nextStep = nil;
  ActivityHelper *activityHelper1 = [[ActivityHelper alloc] init];
    
    if (currentStep == nil) {
        nextStep = nil;
        
    } else {
      
      if ([step.steppredefaultVisibility isEqual: @"false"] ) {
    //      nextStep = nil;
        if (![step.steppresourceQuestionKey  isEqual: @""]) {
        
    //      ActivityHelper *activityHelper1 = [[ActivityHelper alloc] init];
          
    //      ORKStep *val3 =  [activityHelper1 setResultValueWithStepResult:stepResult activityType:@"questionnaire" resultType:step.stepresultType allSteps:steps currentStep:step];
          NSArray *steps2 = _steps;
          ORKStep *val3 =  [activityHelper1 findPreviousStepWithTaskResult:result allSteps:steps2 currentStep:step];
          
          NSUInteger index1 = [self indexOfStep:step];
          if (val3 != nil) {
            index1 = [self indexOfStep:val3];
            nextStep = steps[index1];
            return nextStep;
          }
          
        }
      }
      
      
      
      
        NSUInteger index = [self indexOfStep:step];
        
        if (NSNotFound != index && index != 0) {
            nextStep = steps[index - 1];
          
          if (![nextStep.steppreisHidden isEqual: @"false"] ) {
//            nextStep = steps[index + 2];
            
//            ORKStep *val7 =  [activityHelper1 getNonHiddenStep:steps currentStep:nextStep];
            
//            ORKStep *val7 =  [activityHelper1 getNonHiddenPreviousStep:steps currentStep:nextStep indexVal:index - 1];
            
            
            ORKStep *currentStepReplaced = arraystepsReplaced[index - 1];
            
            ORKStep *val7 =  [activityHelper1 getNonHiddenPreviousStepWithAllSteps:steps currentStep:nextStep indexVal:index - 1];
            return val7;
          } else {
            return nextStep;
          }

        }
    }
//  if ([step.steppreisHidden isEqual: @"false"] ) {//check
  if ([step.steppredefaultVisibility isEqual: @"false"] ) {
//      nextStep = nil;
    if (![step.steppresourceQuestionKey  isEqual: @""]) {
    
//      ActivityHelper *activityHelper1 = [[ActivityHelper alloc] init];
      
//      ORKStep *val3 =  [activityHelper1 setResultValueWithStepResult:stepResult activityType:@"questionnaire" resultType:step.stepresultType allSteps:steps currentStep:step];
      NSArray *steps2 = _steps;
      ORKStep *val3 =  [activityHelper1 findPreviousStepWithTaskResult:result allSteps:steps2 currentStep:step];
      
      NSUInteger index1 = [self indexOfStep:step];
      if (val3 != nil) {
        index1 = [self indexOfStep:val3];
        nextStep = steps[index1];
        return nextStep;
      }
      
    }
  }
  
  
    return nextStep;
}

- (ORKStep *)stepWithIdentifier:(NSString *)identifier {
    __block ORKStep *step = nil;
    [_steps enumerateObjectsUsingBlock:^(ORKStep *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:identifier]) {
            step = obj;
            *stop = YES;
        }
    }];
    return step;
}

- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResult:(ORKTaskResult *)taskResult {
    ORKTaskProgress progress;
    progress.current = [self indexOfStep:step];
    progress.total = _steps.count;
    
    if (![step showsProgress]) {
        progress.total = 0;
    }
    return progress;
}

- (NSSet *)requestedHealthKitTypesForReading {
    NSMutableSet *healthTypes = [NSMutableSet set];
    for (ORKStep *step in self.steps) {
        NSSet *stepSet = [step requestedHealthKitTypesForReading];
        if (stepSet) {
            [healthTypes unionSet:stepSet];
        }
    }
    return healthTypes.count ? healthTypes : nil;
}

- (NSSet *)requestedHealthKitTypesForWriting {
    return nil;
}

- (ORKPermissionMask)requestedPermissions {
    ORKPermissionMask mask = ORKPermissionNone;
    for (ORKStep *step in self.steps) {
        mask |= [step requestedPermissions];
    }
    return mask;
}

- (BOOL)providesBackgroundAudioPrompts {
    BOOL providesAudioPrompts = NO;
    for (ORKStep *step in self.steps) {
        if ([step isKindOfClass:[ORKActiveStep class]]) {
            ORKActiveStep *activeStep = (ORKActiveStep *)step;
            if ([activeStep hasVoice] || [activeStep hasCountDown]) {
                providesAudioPrompts = YES;
                break;
            }
        }
    }
    return providesAudioPrompts;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
    ORK_ENCODE_OBJ(aCoder, steps);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        ORK_DECODE_OBJ_ARRAY(aDecoder, steps, ORKStep);
        
        for (ORKStep *step in _steps) {
            if ([step isKindOfClass:[ORKStep class]]) {
                [step setTask:self];
            }
        }
    }
    return self;
}

@end
