//
//  HelperUtilities.swift
//  ResearchKit
//
//  Created by MAC-MINI-GOVIND-PRASAD-C on 18/09/22.
//  Copyright © 2022 researchkit.org. All rights reserved.
//

import Foundation

@objc public class ActivityHelper: NSObject {
  
  @objc public func setResultValue(stepResult: ORKStepResult, activityType: String, resultType: String, allSteps: [ORKStep], currentStep: ORKStep) -> ORKStep? {// (ORKStep?, NSString?)  {
    var valAnswer = ""
    let valRes = stepResult.results?.count ?? 0
    if valRes > 0 {
        
        if  activityType == "questionnaire" {
            // for question Step
//            if stepResult.results?.count == 1 && self.type != .form {
          if stepResult.results?.count == 1 { // && activityType != .form {
            print("1questionstepResult---\(stepResult.results?.first as? ORKQuestionResult?)")
                if let questionstepResult: ORKQuestionResult? = stepResult.results?.first as? ORKQuestionResult? {
                  print("2questionstepResult---\(questionstepResult)")
                  let val = self.setValue(questionstepResult:questionstepResult!, resultType: resultType )
                  
                  let val1 = self.setValue(questionstepResult:questionstepResult!, resultType: resultType ) as NSString
                  
                  print("resulttt---\(currentStep.stepprevalue)")
                  if let operato = currentStep.steppreoperator, operato == "=" {
                    if val == currentStep.stepprevalue {
                      print("1resulttt---\(val)")
                      
                     let val90 = getReccurOverStepValue(stepResult: stepResult, activityType: activityType, resultType: resultType, allSteps: allSteps, currentStep: currentStep)
                      if val90 != nil {
                        return val90
                      }
                                            
                    }
                  }
                  else if let operato = currentStep.steppreoperator, operato == ">" {
                    if let intVal1 = Double(val), let intVal2 = Double(currentStep.stepprevalue ?? ""),
                       intVal1 > intVal2 {
                      print("2resulttt---\(val)")
                      let val90 = getReccurOverStepValue(stepResult: stepResult, activityType: activityType, resultType: resultType, allSteps: allSteps, currentStep: currentStep)
                       if val90 != nil {
                         return val90
                       }
                    }
                  }
                  else if let operato = currentStep.steppreoperator, operato == "<" {
                    if let intVal1 = Double(val), let intVal2 = Double(currentStep.stepprevalue ?? ""),
                       intVal1 < intVal2 {
                      print("2resulttt---\(val)")
                      let val90 = getReccurOverStepValue(stepResult: stepResult, activityType: activityType, resultType: resultType, allSteps: allSteps, currentStep: currentStep)
                       if val90 != nil {
                         return val90
                       }
                    }
                  }
                  
                  else if let operato = currentStep.steppreoperator, operato == ">=" {
                    if let intVal1 = Double(val), let intVal2 = Double(currentStep.stepprevalue ?? ""),
                       intVal1 >= intVal2 {
                      print("2resulttt---\(val)")
                      let val90 = getReccurOverStepValue(stepResult: stepResult, activityType: activityType, resultType: resultType, allSteps: allSteps, currentStep: currentStep)
                       if val90 != nil {
                         return val90
                       }
                    }
                  }
                  
                  else if let operato = currentStep.steppreoperator, operato == "<=" {
                    if let intVal1 = Double(val), let intVal2 = Double(currentStep.stepprevalue ?? ""),
                       intVal1 <= intVal2 {
                      print("2resulttt---\(val)")
                      let val90 = getReccurOverStepValue(stepResult: stepResult, activityType: activityType, resultType: resultType, allSteps: allSteps, currentStep: currentStep)
                       if val90 != nil {
                         return val90
                       }
                    }
                  }

                  else if let operato = currentStep.steppreoperator, operato.contains(":") {
                    
//                    ley va
                   let valCondition = meetTheCondition(operato: operato, actualResult: val, comparisionValues: currentStep.stepprevalue ?? "")
                    
                    if valCondition {
                      print("1colonresulttt---\(val)")
                      let val90 = getReccurOverStepValue(stepResult: stepResult, activityType: activityType, resultType: resultType, allSteps: allSteps, currentStep: currentStep)
                       if val90 != nil {
                         return val90
                       }
                    }
                  }
                  
                  print("5questionstepResult---\(val1)")
                  
                  
                  
                  
//                    return val1
                }
            }
            
        }
      
    }
    return nil
}
  
  @objc public func getReccurOverStepValue(stepResult: ORKStepResult, activityType: String, resultType: String, allSteps: [ORKStep], currentStep: ORKStep) -> ORKStep? {
    
    let destinStep = currentStep.steppredestinationTrueStepKey ?? ""
                     
    var identifierfound = false
    if destinStep == "" {
      identifierfound = true
      let val = allSteps.last
      val?.steppresourceQuestionKey = currentStep.identifier
      allSteps.last?.steppresourceQuestionKey = currentStep.identifier
      return val
    }
    for aSteps in allSteps {
      if aSteps.identifier == destinStep {
        identifierfound = true
        aSteps.steppreActiBack = currentStep.identifier
        return aSteps
      }
    }
    if !identifierfound {
      let destinActiId = currentStep.steppreactivityid ?? ""
      let destinStepId = currentStep.steppredestinationTrueStepKey ?? ""
      var valDummy = ORKStep(identifier: "valDummy")
      valDummy.steppreactivityid = destinActiId
      valDummy.steppredestinationTrueStepKey = destinStepId
      return valDummy
    }
    
  }
  
  @objc public func  getsecondActivityJumpStep(allSteps: [ORKStep], currentStep: ORKStep) -> ORKStep? {
    let destinStep = currentStep.steppreOtherActiStepId ?? ""
    
//                      if destinStep != "" {
//                        findTheIndex(allSteps: allSteps)
//                      }
    
    for aSteps in allSteps {
      
      if aSteps.identifier == destinStep {
        print("aSteps.identifier---\(aSteps.identifier)---\(destinStep)")
        return aSteps
      }
    }
    return nil
  }
  
  @objc public func  getNonHiddenStep(allSteps: [ORKStep], currentStep: ORKStep, indexVal: Int) -> ORKStep? {
    let destinStep = currentStep.steppreOtherActiStepId ?? ""
    
    var valindexVal = indexVal
    let valAllCount = allSteps.count - 1
    
    for acount in 0...valAllCount {
      if acount > indexVal {
//        if acount > indexVal && acount < valAllCount {
        let varStep = allSteps[acount]
        if ((varStep.steppreisHidden ?? "false") == "false") {
          return varStep
        }
      }
    }
    
//    for aSteps in allSteps {
//
//
//      if aSteps.identifier == destinStep {
//        print("aSteps.identifier---\(aSteps.identifier)---\(destinStep)")
//        return aSteps
//      }
//    }
    return nil
  }
  
  @objc public func getNonHiddenPreviousStep(allSteps: [ORKStep], currentStep: ORKStep, indexVal: Int, taskResult: ORKTaskResult) -> ORKStep? {
    let destinStep = currentStep.steppreOtherActiStepId ?? ""
    
    var valindexVal = allSteps.count - indexVal
    let valAllCount = allSteps.count - 1
    let allSteps2 = Array(allSteps.reversed())
    
    for acount in 0...valAllCount {
      if acount >= valindexVal {
//        if acount > indexVal && acount < valAllCount {
        let varStep = allSteps2[acount]
        if ((varStep.steppreisHidden ?? "false") == "false") {
          return varStep
        } else if ((varStep.steppreisHidden ?? "false") == "true") {
          let val = findPreviousHiddenResultStep(taskResult: taskResult, currentStepIdentifier: varStep.identifier)
          if val == "true" {
          return varStep
          }
        }
      }
    }
    
//    for aSteps in allSteps {
//
//
//      if aSteps.identifier == destinStep {
//        print("aSteps.identifier---\(aSteps.identifier)---\(destinStep)")
//        return aSteps
//      }
//    }
    return nil
  }
  
  func meetTheCondition(operato: String, actualResult: String, comparisionValues: String) -> Bool {
    var conditonsatisfied = false
    if let intValactualResult = Double(actualResult) {
      let valArroperato = operato.components(separatedBy: ":")
      let valArrcomparisionValues = comparisionValues.components(separatedBy: ":")
      if valArroperato.count > 0 && valArrcomparisionValues.count > 0 {
        
        var valOperatorCount = 0
        var valcomparisionValuesCount = 0
        var conditonRequired = ""
        
        for valoperato in valArroperato {
          valOperatorCount += 1
         var valInternalconditonRequired = ""
          var valPreviousconditonsatisfied = conditonsatisfied
          if valoperato == ">" {
            if valArrcomparisionValues.count > valcomparisionValuesCount , let intVal2 = Double(valArrcomparisionValues[valcomparisionValuesCount] ?? ""),
               intValactualResult > intVal2 {
              print("1intValactualResult---\(intValactualResult)")
              
              conditonsatisfied = true
            } else {
              conditonsatisfied = false
            }
            valcomparisionValuesCount += 1
          }
          else if valoperato == "<" {
            if valArrcomparisionValues.count > valcomparisionValuesCount , let intVal2 = Double(valArrcomparisionValues[valcomparisionValuesCount] ?? ""),
               intValactualResult < intVal2 {
              print("2intValactualResult---\(intValactualResult)")
              
              conditonsatisfied = true
            } else {
              conditonsatisfied = false
            }
            valcomparisionValuesCount += 1
          }
          else if valoperato == "=" {
            if valArrcomparisionValues.count > valcomparisionValuesCount , let intVal2 = Double(valArrcomparisionValues[valcomparisionValuesCount] ?? ""),
               intValactualResult == intVal2 {
              print("3intValactualResult---\(intValactualResult)")
              
              conditonsatisfied = true
            } else {
              conditonsatisfied = false
            }
            
            valcomparisionValuesCount += 1
          }
          else if valoperato == ">=" {
            if valArrcomparisionValues.count > valcomparisionValuesCount , let intVal2 = Double(valArrcomparisionValues[valcomparisionValuesCount] ?? ""),
               intValactualResult >= intVal2 {
              print("2intValactualResult---\(intValactualResult)")
              
              conditonsatisfied = true
            } else {
              conditonsatisfied = false
            }
            valcomparisionValuesCount += 1
          }
          else if valoperato == "<=" {
            if valArrcomparisionValues.count > valcomparisionValuesCount , let intVal2 = Double(valArrcomparisionValues[valcomparisionValuesCount] ?? ""),
               intValactualResult <= intVal2 {
              print("2intValactualResult---\(intValactualResult)")
              
              conditonsatisfied = true
            } else {
              conditonsatisfied = false
            }
            valcomparisionValuesCount += 1
          }
          
          else if valoperato == "&&" {
            
            valInternalconditonRequired = "&&"
          }
          else if valoperato == "||" {
            
            valInternalconditonRequired = "||"
          }
          
          if conditonRequired == "&&", valInternalconditonRequired != "&&" {
            if (valPreviousconditonsatisfied && conditonsatisfied) {
              conditonsatisfied = true
            } else {
              conditonsatisfied = false
            }
          } else if conditonRequired == "||", valInternalconditonRequired != "||" {
            if valPreviousconditonsatisfied || conditonsatisfied {
              conditonsatisfied = true
            } else {
              conditonsatisfied = false
            }
          }
          
          conditonRequired = valInternalconditonRequired
        }
        valcomparisionValuesCount += 1
      }
      
      
    } else if actualResult != "" {
      let valArroperato = operato.components(separatedBy: ":")
      let valArrcomparisionValues = comparisionValues.components(separatedBy: ":")
      if valArroperato.count > 0 && valArrcomparisionValues.count > 0 {
        
        var valOperatorCount = 0
        var valcomparisionValuesCount = 0
        var conditonRequired = ""
        
        for valoperato in valArroperato {
          valOperatorCount += 1
         var valInternalconditonRequired = ""
          var valPreviousconditonsatisfied = conditonsatisfied

           if valoperato == "=" {
            if valArrcomparisionValues.count > valcomparisionValuesCount,
               actualResult == (valArrcomparisionValues[valcomparisionValuesCount] ) {
              print("3intValactualResult---\(actualResult)")
              
              conditonsatisfied = true
            } else {
              conditonsatisfied = false
            }
            
            valcomparisionValuesCount += 1
          }
          
          else if valoperato == "&&" {
            
            valInternalconditonRequired = "&&"
          }
          else if valoperato == "||" {
            
            valInternalconditonRequired = "||"
          }
          
          if conditonRequired == "&&", valInternalconditonRequired != "&&" {
            if (valPreviousconditonsatisfied && conditonsatisfied) {
              conditonsatisfied = true
            } else {
              conditonsatisfied = false
            }
          } else if conditonRequired == "||", valInternalconditonRequired != "||" {
            if valPreviousconditonsatisfied || conditonsatisfied {
              conditonsatisfied = true
            } else {
              conditonsatisfied = false
            }
          }
          
          conditonRequired = valInternalconditonRequired
        }
        valcomparisionValuesCount += 1
      }
      
    }
    print("conditonsatisfied---\(conditonsatisfied)")
    return conditonsatisfied
  }
  
//  func findTheIndex(allSteps: [ORKStep]) -> String {
//
//    return ""
//  }

func setValue(questionstepResult: ORKQuestionResult, resultType: String) -> String {
    switch questionstepResult.questionType.rawValue {

    case  ORKQuestionType.scale.rawValue : // scale and continuos scale

        if (questionstepResult as? ORKScaleQuestionResult) != nil {
            let stepTypeResult = (questionstepResult as? ORKScaleQuestionResult)!
          print("1res---\(stepTypeResult.answer)---\(stepTypeResult.scaleAnswer)")
          if stepTypeResult.scaleAnswer != nil {
          return "\(stepTypeResult.scaleAnswer!)"
          }
           } else {
            let stepTypeResult = (questionstepResult as? ORKChoiceQuestionResult)!
//               print("2res---\(stepTypeResult.answer)---\(stepTypeResult.choiceAnswers)")
             if (stepTypeResult.choiceAnswers?.count) ?? 0 > 0 {
//                   self.value = stepTypeResult.choiceAnswers?.first
               print("3res---\(stepTypeResult.choiceAnswers?.first)")
               
//                 getActualAnswer(choiceSelected: "\(stepTypeResult.choiceAnswers!.first!)", identifierOfRes: <#T##String#>)
               
               return "\(stepTypeResult.choiceAnswers!.first!)" //check
             }
             
        }

    case ORKQuestionType.singleChoice.rawValue: // textchoice + value picker + imageChoice

        let stepTypeResult = (questionstepResult as? ORKChoiceQuestionResult)!
//          var resultType: String? = (self.step?.resultType as? String)!
//      var resultType: String = getresultType(identifier: questionstepResult.identifier) //(self.step?.resultType as? String)!
      
      var resultType: String = resultType
      
      if ActivityHelper.isValidObject(someObject: stepTypeResult.choiceAnswers as AnyObject?) {
            if (stepTypeResult.choiceAnswers?.count)! > 0 {

                if resultType ==  QuestionStepType.imageChoice.rawValue ||  resultType == QuestionStepType.valuePicker.rawValue {

                    // for image choice and valuepicker

                    let resultValue: String! = "\(stepTypeResult.choiceAnswers!.first!)"

//                      self.value = (resultValue == nil ? "" : resultValue)
                  print("41res---\((resultValue == nil ? "" : resultValue))")
                  
                  return "\(resultValue == nil ? "" : resultValue ?? "")"
                } else {
                    // for text choice
                    var resultValue: [Any] = []
                    let selectedValue = stepTypeResult.choiceAnswers?.first

                    if let stringValue = selectedValue as? String {
                        resultValue.append(stringValue)
                    } else if let otherDict = selectedValue as? [String:Any] {
                        resultValue.append(otherDict)
                    } else {
                        resultValue.append(selectedValue as Any)
                    }
                  print("51res---\(resultValue)")
                  return "\(resultValue.first ?? "")" //check

//                      self.value = resultValue
                }

            }
        }
//      case ORKQuestionType.multipleChoice.rawValue: // textchoice + imageChoice
//
//          let stepTypeResult = (questionstepResult as? ORKChoiceQuestionResult)!
//
//          if let answers = stepTypeResult.choiceAnswers {
//
//              var resultArray: [Any] = []
//
//              for value in answers {
//
//                  if let stringValue = value as? String {
//                      resultArray.append(stringValue)
//                  } else if let otherDict = value as? [String:Any] {
//                      resultArray.append(otherDict)
//                  } else {
//                      resultArray.append(value)
//                  }
//
//              }
//              self.value = resultArray
//
//          } else {
//              // self.value = []
//              self.skipped = true
//          }
//
//          /*
//          if Utilities.isValidObject(someObject: stepTypeResult.choiceAnswers as AnyObject?) {
//              if (stepTypeResult.choiceAnswers?.count)! > 1 {
//
//
//
//              } else {
//
//                  let resultValue: String! = "\(stepTypeResult.choiceAnswers!.first!)"
//                  let resultArray: Array<String>? = ["\(resultValue == nil ? "" : resultValue!)"]
//                  self.value = resultArray
//              }
//
//          } else {
//              self.value = []
//          }
//           */
//
//      case ORKQuestionType.boolean.rawValue:
//
//          let stepTypeResult = (questionstepResult as? ORKBooleanQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.booleanAnswer as AnyObject?) {
//              self.value =  stepTypeResult.booleanAnswer! == 1 ? true : false
//
//          } else {
//              // self.value = false
//              self.skipped = true
//          }
//
//      case ORKQuestionType.integer.rawValue: // numeric type
//          let stepTypeResult = (questionstepResult as? ORKNumericQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.numericAnswer as AnyObject?) {
//              self.value =  Double(truncating:stepTypeResult.numericAnswer!)
//
//          } else {
//              // self.value = 0.0
//              self.skipped = true
//          }
//
//      case ORKQuestionType.decimal.rawValue: // numeric type
//          let stepTypeResult = (questionstepResult as? ORKNumericQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.numericAnswer as AnyObject?) {
//              self.value = Double(truncating:stepTypeResult.numericAnswer!)
//
//          } else {
//              // self.value = 0.0
//              self.skipped = true
//          }
//
//      case  ORKQuestionType.timeOfDay.rawValue:
//          let stepTypeResult = (questionstepResult as? ORKTimeOfDayQuestionResult)!
//
//          if stepTypeResult.dateComponentsAnswer != nil {
//
//              let hour: Int? = (stepTypeResult.dateComponentsAnswer?.hour == nil ? 0 : stepTypeResult.dateComponentsAnswer?.hour)
//              let minute: Int? = (stepTypeResult.dateComponentsAnswer?.minute == nil ? 0 : stepTypeResult.dateComponentsAnswer?.minute)
//              let seconds: Int? = (stepTypeResult.dateComponentsAnswer?.second == nil ? 0 : stepTypeResult.dateComponentsAnswer?.second)
//
//              self.value = (( hour! < 10 ? ("0" + "\(hour!)") : "\(hour!)") + ":" + ( minute! < 10 ? ("0" + "\(minute!)") : "\(minute!)") + ":" + ( seconds! < 10 ? ("0" + "\(seconds!)") : "\(seconds!)"))
//
//          } else {
//              // self.value = "00:00:00"
//              self.skipped = true
//          }
//
//      case ORKQuestionType.date.rawValue:
//          let stepTypeResult = (questionstepResult as? ORKDateQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.dateAnswer as AnyObject?) {
//              self.value =  Utilities.getStringFromDate(date: stepTypeResult.dateAnswer!)
//          } else {
//              // self.value = "0000-00-00'T'00:00:00"
//              self.skipped = true
//          }
//      case ORKQuestionType.dateAndTime.rawValue:
//          let stepTypeResult = (questionstepResult as? ORKDateQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.dateAnswer as AnyObject?) {
//              self.value =  Utilities.getStringFromDate(date: stepTypeResult.dateAnswer! )
//
//          } else {
//              // self.value = "0000-00-00'T'00:00:00"
//              self.skipped = true
//          }
//      case ORKQuestionType.text.rawValue: // text + email
//
//          let stepTypeResult = (questionstepResult as? ORKTextQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.answer as AnyObject?) {
//              self.value = (stepTypeResult.answer as? String)!
//
//          } else {
//              // self.value = ""
//              self.skipped = true
//          }
//
//      case ORKQuestionType.timeInterval.rawValue:
//
//          let stepTypeResult = (questionstepResult as? ORKTimeIntervalQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.intervalAnswer as AnyObject?) {
//              self.value = Double(truncating:stepTypeResult.intervalAnswer!)/3600
//
//          } else {
//              // self.value = 0.0
//              self.skipped = true
//          }
//
//      case ORKQuestionType.height.rawValue:
//
//          let stepTypeResult = (questionstepResult as? ORKNumericQuestionResult)!
//          if Utilities.isValidValue(someObject: stepTypeResult.numericAnswer as AnyObject?) {
//              self.value = Double(truncating:stepTypeResult.numericAnswer!)
//
//          } else {
//              // self.value = 0.0
//              self.skipped = true
//          }
//
//      case ORKQuestionType.location.rawValue:
//          let stepTypeResult = (questionstepResult as? ORKLocationQuestionResult)!
//          /*
//          if stepTypeResult.locationAnswer != nil && CLLocationCoordinate2DIsValid((stepTypeResult.locationAnswer?.coordinate)!) {
//
//              let lat = stepTypeResult.locationAnswer?.coordinate.latitude
//              let long = stepTypeResult.locationAnswer?.coordinate.longitude
//
//              self.value = "\(lat!)" + "," + "\(long!)"
//
//          } else {
//              self.value = "0.0,0.0"
//          }*/
//          if let locationAnswer = stepTypeResult.locationAnswer {
//              if CLLocationCoordinate2DIsValid(locationAnswer.coordinate) {
//                  let lat = locationAnswer.coordinate.latitude
//                  let long = locationAnswer.coordinate.longitude
//                  self.value = "\(lat)" + "," + "\(long)"
//              } else {
//                  self.value = "0.0,0.0"
//              }
//          } else {
//              self.skipped = true
//          }
    default:break
    }
  return ""
}
  
  class func isValidObject(someObject: AnyObject?) -> Bool {
      
      guard let someObject = someObject else {
          // is null
          return false
      }
      
      if (someObject is NSNull) ==  false {
          if someObject as? Dictionary<String, Any> != nil  &&
              (someObject as? Dictionary<String, Any>)?.isEmpty == false &&
              ((someObject as? Dictionary<String, Any>)?.count)! > 0 {
              return true
              
          } else if someObject as? NSArray != nil && ((someObject as? NSArray)?.count)! > 0 {
              return true
              
          } else {
              return false
          }
          
      } else {
          return false
      }
  }
  
//  func getresultType(identifier: String, resultType: String) -> String {
//    let activity = Study.currentActivity
//    let activityStepArray = activity?.activitySteps?.filter({$0.key == identifier
//    })
//
//      if (activityStepArray?.count)! > 0 {
//          let step1 = activityStepArray?.first
//        print("step1?.resultType---\(step1?.resultType)")
//        let val1 = step1?.resultType as? String ?? ""
//
//       return val1
//      }
//    return ""
//  }
  
  
  @objc public func findPreviousStep(taskResult: ORKTaskResult, allSteps: [ORKStep], currentStep: ORKStep) -> ORKStep? {
    var valAnswer = ""
    let valRes = taskResult.results?.count ?? 0
    if valRes > 0 {
      if let valMainResult = taskResult.results, let valSourceKey = currentStep.steppresourceQuestionKey {
        for aSteps in valMainResult {
          if aSteps.identifier == valSourceKey {
            
            for aSteps1 in allSteps {
              if aSteps1.identifier == valSourceKey {
                return aSteps1
              }
            }
            
          }
        }
        
      }
    }
    return nil
  }
  
  @objc public func findPreviousHiddenResultStep(taskResult: ORKTaskResult,  currentStepIdentifier: String) -> String {
    var valAnswer = ""
    let valRes = taskResult.results?.count ?? 0
    if valRes > 0 {
      if let valMainResult = taskResult.results {
        for aSteps in valMainResult {
          if aSteps.identifier == currentStepIdentifier {
            return "true"
//            for aSteps1 in allSteps {
//              if aSteps1.identifier == valSourceKey {
//                return aSteps1
//              }
//            }
            
          }
        }
        
      }
    }
    return "false"
  }
  
  @objc public func findPreviousStepForCompletionStep(taskResult: ORKTaskResult, allSteps: [ORKStep], currentStep: ORKStep) -> ORKStep? {
    var valAnswer = ""
    let valRes = taskResult.results?.count ?? 0
    if valRes > 0 {
      if let valMainResult = taskResult.results, let valSourceKey = currentStep.steppresourceQuestionKey {
        for aSteps in valMainResult {
          if aSteps.identifier == valSourceKey {
            
            for aSteps1 in allSteps {
              if aSteps1.identifier == valSourceKey {
//                let val = allSteps.last
//                allSteps.last?.steppresourceQuestionKey = ""
                return aSteps1
              }
            }
            
          }
        }
        
      }
    }
    return nil
  }
  
}

enum ActivityType: String {
    case Questionnaire = "questionnaire"
    case activeTask = "task"
}


enum QuestionStepType: String {
    
    // Step for  Boolean question.
    case boolean = "boolean"
    
    // Step for  example of date entry.
    case date = "date"
    
    // Step for  example of date and time entry.
    case dateTimeQuestionStep
    
    // Step for  example of height entry.
    case height = "height"
    
    // Step for  image choice question.
    case imageChoice = "imageChoice"
    
    // Step for  location entry.
    case location = "location"
    
    // Step with examples of numeric questions.
    case numeric = "numeric"
    case numericNoUnitQuestionStep
    
    // Step with examples of questions with sliding scales.
    case scale = "scale"
    case continuousScale = "continuousScale"
    case discreteVerticalscale
    case continuousVerticalscale
    case textscale = "textScale"
    case textVerticalscale
    
    // Step for  example of free text entry.
    case text = "text"
    
    // Step for  example of a multiple choice question.
    case textChoice = "textChoice"
    
    // Step for  example of time of day entry.
    case timeOfDay = "timeOfDay"
    
    // Step for  example of time interval entry.
    case timeInterval = "timeInterval"
    
    // Step for  value picker.
    case valuePicker = "valuePicker"
    
    // Step for  example of validated text entry.
    case email = "email"
    case validatedtextDomain
    
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
    
    // Video instruction Steps.
    case videoInstructionStep
    
}

@objc extension ORKOrderedTask {
  @objc public func health1KitBiologicalSex() {
      
  }
}

@objc public class ImageClass: NSObject {
  @objc public func imageFromString(name: String?) {
  //code to make the image
//  return image
  }
}
