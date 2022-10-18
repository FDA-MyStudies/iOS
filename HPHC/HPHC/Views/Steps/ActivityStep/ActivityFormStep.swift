/*
 License Agreement for FDA My Studies
Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.
Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import ResearchKit

let kStepFormSteps = "steps"

class ActivityFormStep: ActivityStep {
    
    var itemsArray: [Dictionary<String, Any>] // itemsArray stores the step details
    
    override init() {
        self.itemsArray = Array()
        super.init()
        
    }
    /**
     initializer with step dictiionary containing form items
     */
    override func initWithDict(stepDict: Dictionary<String, Any>, allSteps: Array<Dictionary<String, Any>>?) {
        if Utilities.isValidObject(someObject: stepDict as AnyObject?){
            
          super.initWithDict(stepDict: stepDict, allSteps: allSteps)
            if Utilities.isValidObject(someObject: stepDict[kStepFormSteps] as AnyObject ){
                self.itemsArray = (stepDict[kStepFormSteps] as? [Dictionary<String, Any>])!
            }
        } else {
            Logger.sharedInstance.debug("Instruction Step Dictionary is null:\(stepDict)")
        }
    }
    
    /*
     method creates the Form step based on the ActivityStep and using itemsArray
     returns the ORKFormStep
     NOTE: this method only return formStep of Questions, does not support ActiveTask as items
     */
    func getFormStep() -> ORKFormStep? {
        
        if Utilities.isValidValue(someObject: key  as AnyObject?)
            && Utilities.isValidObject(someObject: self.itemsArray  as AnyObject?) {
            
            let step: ORKFormStep?
            
            if self.repeatable == true {
                
                step  = RepeatableFormStep(identifier: key!, title:(self.title == nil ? "" : self.title!), text: text!)
                (step as? RepeatableFormStep)!.repeatable = true
                (step as? RepeatableFormStep)!.repeatableText = self.repeatableText
                
            } else {
                step = ORKFormStep(identifier: key!, title: (self.title == nil ? "" : self.title!), text: text!)
            }
            
            if  Utilities.isValidValue(someObject: title!  as AnyObject?) {
                step?.title = title!
            }
            if  Utilities.isValidValue(someObject: self.skippable!  as AnyObject?) {
                step?.isOptional = self.skippable!
            }
            
            var formItemsArray = [ORKFormItem]()
            
          for dict in self.itemsArray {
              
              if  Utilities.isValidObject(someObject: dict  as AnyObject?){
                  
                  let questionStep: ActivityQuestionStep? = ActivityQuestionStep()
                  questionStep?.initWithDict(stepDict: dict, allSteps: self.itemsArray)
                  
                  if let orkQuestionStep:ORKQuestionStep = (questionStep?.getQuestionStep()){
                      
                      let formItem01 = ORKFormItem(identifier: orkQuestionStep.identifier,
                                                   text: orkQuestionStep.question,
                                                   answerFormat: orkQuestionStep.answerFormat)
                      formItem01.placeholder = orkQuestionStep.placeholder == nil ? "" :  orkQuestionStep.placeholder
                      formItem01.isOptional = (questionStep?.skippable)!
                      formItemsArray.append(formItem01)
                  }else{
                      Logger.sharedInstance.debug("step is null :\(dict)")
                  }

                  
              } else {
                  Logger.sharedInstance.debug("item Dictionary is null :\(dict)")
              }
          }
          
          
          
          
          
          
          
////here
//          {
//            sourcePreLogicQuestionKey = formstepDict["sourceQuestionKey"] as? String
//            let val2 = formstepDict["preLoadLogic"] as? [String: String]
//            preactivityVersion = val2?["activityVersion"] ?? ""
//            preactivityid = val2?["activityId"] ?? ""
//            predestinationFalseStepKey = val2?["destinationFalseStepKey"] ?? ""
//            predestinationTrueStepKey = val2?["destinationStepKey"] ?? ""
//
//            if predestinationFalseStepKey != "" {
//            predestinationFalseStepIndex = getIndexByIdentifier(identifier1: predestinationFalseStepKey ?? "", allSteps: allSteps)
//            } else {
//              predestinationFalseStepIndex = ""
//            }
//            if predestinationTrueStepKey != "" {
//            predestinationTrueStepIndex = getIndexByIdentifier(identifier1: predestinationTrueStepKey ?? "", allSteps: allSteps)
//            } else {
//              predestinationTrueStepIndex = ""
//            }
//
//            preoperator = val2?["operator"] ?? ""
//            prevalue = val2?["value"] ?? ""
//    //          sourcePreLogicQuestionKey = stepDict["sourceQuestionKey"] as? String
//            presourceQuestionKey = stepDict["sourceQuestionKey"] as? String
//
//          }
//
//
//
//
//
          step?.steppredestinationTrueStepKey = predestinationTrueStepKey
          step?.steppreactivityid = preactivityid
          step?.steppredestinationFalseStepKey = predestinationFalseStepKey

         let valOtherActiStepId = UserDefaults.standard.value(forKey: "OtherActiStepId") as? String ?? "" //CHECK
          UserDefaults.standard.setValue("", forKey: "OtherActiStepId")
      UserDefaults.standard.synchronize()

          step?.steppreOtherActiStepId = valOtherActiStepId
          step?.steppredestinationTrueStepIndex = predestinationTrueStepIndex
          step?.steppredestinationFalseStepIndex = predestinationFalseStepIndex
          step?.stepresultType = resultType as? String ?? ""
          step?.steppreoperator = preoperator
          step?.stepprevalue = prevalue
          step?.steppresourceQuestionKey = presourceQuestionKey
          step?.steppredefaultVisibility = predefaultVisibility
          step?.steppreisHidden = preisHidden
//
//
//          //here
          
            
            if self.repeatable == true {
                (step as? RepeatableFormStep)!.initialItemCount = formItemsArray.count
            }
            
            step?.formItems = formItemsArray
            return step
            
        } else {
            Logger.sharedInstance.debug("Form Data is null ")
            return nil
        }
    }
}
