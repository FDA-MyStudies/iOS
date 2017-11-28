//
//  ActivityQuestionStep.swift
//  ORKCatalog
//
//  Created by Arun Kumar on 2/8/17.
//  Copyright © 2017 researchkit.org. All rights reserved.
//

//
//  StepProvider.swift
//  FDA
//
//  Created by Arun Kumar on 2/7/17.
//  Copyright © 2017 BTC. All rights reserved.
//



import Foundation
import ResearchKit



//Step Constants
let kStepTitle = "title"
let kStepQuestionTypeValue = "QuestionType"


//Question Api Constants



let kStepQuestionPhi = "phi"
let kStepQuestionFormat = "format"
let kStepQuestionHealthDataKey = "healthDataKey"

// ScaleQuestion type Api Constants
let kStepQuestionScaleMaxValue = "maxValue"
let kStepQuestionScaleMinValue = "minValue"
let kStepQuestionScaleDefaultValue = "default"
let kStepQuestionScaleStep = "step"
let kStepQuestionScaleVertical = "vertical"
let kStepQuestionScaleMaxDesc = "maxDesc"
let kStepQuestionScaleMinDesc = "minDesc"
let kStepQuestionScaleMaxImage = "maxImage"
let kStepQuestionScaleMinImage = "minImage"


//ContinuosScaleQuestion Type Api Constants

let kStepQuestionContinuosScaleMaxValue = "maxValue"
let kStepQuestionContinuosScaleMinValue = "minValue"
let kStepQuestionContinuosScaleDefaultValue = "default"
let kStepQuestionContinuosScaleMaxFractionDigits = "maxFractionDigits"
let kStepQuestionContinuosScaleVertical = "vertical"
let kStepQuestionContinuosScaleMaxDesc = "maxDesc"
let kStepQuestionContinuosScaleMinDesc = "minDesc"
let kStepQuestionContinuosScaleMaxImage = "maxImage"
let kStepQuestionContinuosScaleMinImage = "minImage"

//TextScaleQuestion Type Api Constants
let kStepQuestionTextScaleTextChoices = "textChoices"
let kStepQuestionTextScaleDefault = "default"
let kStepQuestionTextScaleVertical = "vertical"

//ORKTextChoice Type Api Constants

let kORKTextChoiceText = "text"
let kORKTextChoiceValue = "value"
let kORKTextChoiceDetailText = "detail"
let kORKTextChoiceExclusive = "exclusive"


//StepQuestionImageChoice Type Api Constants

let kStepQuestionImageChoices = "imageChoices"

let kStepQuestionImageChoiceImage = "image"
let kStepQuestionImageChoiceSelectedImage = "selectedImage"
let kStepQuestionImageChoiceText = "text"
let kStepQuestionImageChoiceValue = "value"


//TextChoiceQuestion Type Api Constants

let kStepQuestionTextChoiceTextChoices = "textChoices"
let kStepQuestionTextChoiceSelectionStyle = "selectionStyle"

let kStepQuestionTextChoiceSelectionStyleSingle = "Single"
let kStepQuestionTextChoiceSelectionStyleMultiple = "Multiple"

//NumericQuestion Type Api Constants

let kStepQuestionNumericStyle = "style"
let kStepQuestionNumericUnit = "unit"
let kStepQuestionNumericMinValue = "minValue"
let kStepQuestionNumericMaxValue = "maxValue"
let kStepQuestionNumericPlaceholder = "placeholder"


//DateQuestion Type Api Constants

let kStepQuestionDateStyle = "style"
let kStepQuestionDateMinDate = "minDate"
let kStepQuestionDateMaxDate = "maxDate"
let kStepQuestionDateDefault = "default"
let kStepQuestionDateRange = "dateRange"
let kStepQuestionDateStyleDate = "Date"
let kStepQuestionDateStyleDateTime = "Date-Time"


//TextQuestion Type Api Constants

let kStepQuestionTextMaxLength = "maxLength"
let kStepQuestionTextValidationRegex = "validationRegex"
let kStepQuestionTextInvalidMessage = "invalidMessage"
let kStepQuestionTextMultipleLines = "multipleLines"
let kStepQuestionTextPlaceholder = "placeholder"

//EmailQuestion Type Api Constants

let kStepQuestionEmailPlaceholder = "placeholder"

//TimeIntervalQuestion Type Api Constants

let kStepQuestionTimeIntervalDefault = "default"
let kStepQuestionTimeIntervalStep = "step"

//height Type Api Constants

let kStepQuestionHeightMeasurementSystem = "measurementSystem"
let kStepQuestionHeightPlaceholder = "placeholder"

//LocationQuestion Type Api Constants

let kStepQuestionLocationUseCurrentLocation = "useCurrentLocation"


enum DateRange:String{
  case untilCurrent = "untilCurrent"
  case afterCurrent = "afterCurrent"
  case custom = "custom"
  case defaultValue = ""
}

enum DateStyle:String{
    case date = "Date"
    case dateAndTime = "Date-Time"
}

enum HeightMeasurementSystem:String{
    case local  = "Local"
    case metric  = "Metric"
    case us  = "US"
}

enum QuestionStepType:String{
    
    
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

enum PHIType:String{
    case notPHI = "NotPHI"
    case limited = "Limited"
    case phi = "PHI"
}

class ActivityQuestionStep: ActivityStep {
    
   
    var formatDict:Dictionary<String, Any>?
    
    var healthDataKey:String?
  
    //Following params exclusively used for texscale
    var textScaleDefaultIndex:Int? = -1
    var textScaleDefaultValue:String? = ""
  
    override init() {
        
        super.init()
       self.healthDataKey = ""
        self.formatDict? = Dictionary()
    }
    
    override func initWithDict(stepDict: Dictionary<String, Any>) {
        // Setter method with dictionary
        
        if Utilities.isValidObject(someObject: stepDict as AnyObject?){
            
            super.initWithDict(stepDict: stepDict)
            
          
            
            if Utilities.isValidObject(someObject: stepDict[kStepQuestionFormat] as AnyObject ){
                self.formatDict = (stepDict[kStepQuestionFormat] as? Dictionary)!
            }
            
            if Utilities.isValidValue(someObject: stepDict[kStepQuestionHealthDataKey] as AnyObject ){
                self.healthDataKey = stepDict[kStepQuestionHealthDataKey] as! String?
            }
            
        }
        else{
            Logger.sharedInstance.debug("Question Step Dictionary is null:\(stepDict)")
        }
        
    }
    
    
    //MARK:Question Step Creation
    
    func getQuestionStep() -> ORKQuestionStep? {
        
        /* method creates QuestionStep using ActivityStep data
         return ORKQuestionStep
         */
        
        
        //Utilities.isValidObject(someObject: self.formatDict as AnyObject?)
        
        if  Utilities.isValidValue(someObject:resultType  as AnyObject?)   {
            
            var questionStepAnswerFormat:ORKAnswerFormat?
            
            var questionStep:ORKQuestionStep?
            
            var placeholderText:String? = ""
            
            switch   QuestionStepType(rawValue:resultType as! String)! as QuestionStepType {
            case .scale:
                
                if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleMaxValue] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleMinValue] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleDefaultValue] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleStep] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleVertical] as AnyObject?)
                   {
                    
                    
                    let maxDesc = formatDict?[kStepQuestionScaleMaxDesc] as? String
                    let minDesc = formatDict?[kStepQuestionScaleMinDesc] as? String
                    
                    
                    let difference = (formatDict?[kStepQuestionScaleMaxValue] as? Int)! - (formatDict?[kStepQuestionScaleMinValue] as? Int)!
                    
                    let divisibleValue = difference % (formatDict?[kStepQuestionScaleStep] as? Int)!
                    
                    let stepsValue = difference / (formatDict?[kStepQuestionScaleStep] as? Int)!
                    
                    let defaultPosition = formatDict?[kStepQuestionScaleDefaultValue] as! Int
                    
                    
                    var defaultValue = defaultPosition * stepsValue
                    
                    if defaultValue > (formatDict?[kStepQuestionScaleMaxValue] as! Int){
                        defaultValue = formatDict?[kStepQuestionScaleMaxValue] as! Int
                    }
                    
                    
                    if ((formatDict?[kStepQuestionScaleMaxValue] as? Int)! != (formatDict?[kStepQuestionScaleMinValue] as? Int)!) && divisibleValue == 0 && (stepsValue >= 1 && stepsValue <= 13){
                    
                    questionStepAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: (formatDict?[kStepQuestionScaleMaxValue] as? Int)!,
                                                                     minimumValue: (formatDict?[kStepQuestionScaleMinValue] as? Int)!,
                                                                     defaultValue: (formatDict?[kStepQuestionScaleDefaultValue] as? Int)!,
                                                                     step: (formatDict?[kStepQuestionScaleStep] as? Int)!,
                                                                     vertical: (formatDict?[kStepQuestionScaleVertical] as? Bool)!,
                                                                     maximumValueDescription: maxDesc,
                                                                     minimumValueDescription: minDesc)
                      
                      if Utilities.isValidValue(someObject: (formatDict?[kStepQuestionScaleMaxImage] as? String as AnyObject)) && Utilities.isValidValue(someObject: (formatDict?[kStepQuestionScaleMinImage] as? String as AnyObject)){
                        
                        let minImageBase64String =  formatDict![kStepQuestionScaleMinImage] as! String
                        let minNormalImageData = NSData(base64Encoded: minImageBase64String, options: .ignoreUnknownCharacters)
                        let minNormalImage:UIImage = UIImage(data:minNormalImageData! as Data)!
                        
                        let maxImageBase64String =  formatDict![kStepQuestionScaleMaxImage] as! String
                        let maxNormalImageData = NSData(base64Encoded: maxImageBase64String, options: .ignoreUnknownCharacters)
                        let maxNormalImage:UIImage = UIImage(data:maxNormalImageData! as Data)!
                        
                        (questionStepAnswerFormat as! ORKScaleAnswerFormat).minimumImage = minNormalImage
                        (questionStepAnswerFormat as! ORKScaleAnswerFormat).maximumImage = maxNormalImage
                      }
                      
                      
                      
                    }
                    else{
                        return nil
                    }
                    //questionStep?.placeholder =???
                    
                }
                else{
                    Logger.sharedInstance.debug("Scale Question Step has null values:\(formatDict)")
                    return nil
                    
                }
            case .continuousScale:
                
                if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionContinuosScaleMaxValue] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionContinuosScaleMinValue] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionContinuosScaleDefaultValue] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionContinuosScaleMaxFractionDigits] as AnyObject?)
                    && formatDict?[kStepQuestionContinuosScaleVertical] != nil
                    //&& formatDict?[kStepQuestionContinuosScaleMaxDesc] != nil
                    //&&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleMinDesc] as AnyObject?)
                {
                    
                    let maxDesc =   formatDict?[kStepQuestionContinuosScaleMaxDesc] as? String
                    let minDesc =   formatDict?[kStepQuestionContinuosScaleMinDesc] as? String
                    
                    
                    if (formatDict?[kStepQuestionContinuosScaleMinValue] as? Double)! != (formatDict?[kStepQuestionContinuosScaleMaxValue] as? Double)!{
                    
                    
                    questionStepAnswerFormat = ORKAnswerFormat.continuousScale(withMaximumValue: (formatDict?[kStepQuestionContinuosScaleMaxValue] as? Double)!,
                                                                               minimumValue: (formatDict?[kStepQuestionContinuosScaleMinValue] as? Double)!, defaultValue: (formatDict?[kStepQuestionContinuosScaleDefaultValue] as? Double)!, maximumFractionDigits: (formatDict?[kStepQuestionContinuosScaleMaxFractionDigits] as? Int)!,
                                                                               vertical: (formatDict?[kStepQuestionContinuosScaleVertical] as? Bool)!,
                                                                               maximumValueDescription:maxDesc,
                                                                               minimumValueDescription: minDesc)
                      
                      
                      if Utilities.isValidValue(someObject: (formatDict?[kStepQuestionContinuosScaleMaxImage] as? String as AnyObject)) && Utilities.isValidValue(someObject: (formatDict?[kStepQuestionContinuosScaleMinImage] as? String as AnyObject)){
                        
                        let minImageBase64String =  formatDict![kStepQuestionContinuosScaleMinImage] as! String
                        let minNormalImageData = NSData(base64Encoded: minImageBase64String, options: .ignoreUnknownCharacters)
                        let minNormalImage:UIImage = UIImage(data:minNormalImageData! as Data)!
                        
                        let maxImageBase64String =  formatDict![kStepQuestionContinuosScaleMaxImage] as! String
                        let maxNormalImageData = NSData(base64Encoded: maxImageBase64String, options: .ignoreUnknownCharacters)
                        let maxNormalImage:UIImage = UIImage(data:maxNormalImageData! as Data)!
                        
                        (questionStepAnswerFormat as! ORKContinuousScaleAnswerFormat).minimumImage = minNormalImage
                        (questionStepAnswerFormat as! ORKContinuousScaleAnswerFormat).maximumImage = maxNormalImage
                      }
                    
                      
                    
                    }
                    else{
                        return nil
                    }
                    
                }
                else{
                    Logger.sharedInstance.debug("Continuous Scale Question Step has null values:\(formatDict)")
                    return nil
                    
                }
            case .textscale:
                
                if  Utilities.isValidObject(someObject:formatDict?[kStepQuestionTextScaleTextChoices] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextScaleDefault] as AnyObject?)
                    &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextScaleVertical] as AnyObject?) {
                    
                    let textChoiceArray:[ORKTextChoice]?
                  
                  var defaultValue = formatDict?[kStepQuestionTextScaleDefault] as! Int
                  self.textScaleDefaultValue = "\(defaultValue)"
                 
                  
                    textChoiceArray = self.getTextChoices(dataArray: formatDict?[kStepQuestionTextScaleTextChoices] as! NSArray)
                  
                  defaultValue = self.textScaleDefaultIndex!
                 
                    questionStepAnswerFormat = ORKAnswerFormat.textScale(with: textChoiceArray!,
                                                                         defaultIndex: defaultValue,
                                                                         vertical: formatDict?[kStepQuestionTextScaleVertical] as! Bool)
                    
                    
                    
                }
                else{
                    Logger.sharedInstance.debug("Text Scale Question Step has null values:\(formatDict)")
                    return nil
                    
                }
            case .valuePicker:
                
                if  Utilities.isValidObject(someObject:formatDict?[kStepQuestionTextScaleTextChoices] as AnyObject?)  {
                    
                    let textChoiceArray:[ORKTextChoice]?
                    
                    textChoiceArray = self.getTextChoices(dataArray: formatDict?[kStepQuestionTextScaleTextChoices] as! NSArray)
                    
                    questionStepAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with:textChoiceArray!)
                }
                else{
                    Logger.sharedInstance.debug("valuePickerChoice Question Step has null values:\(formatDict)")
                    return nil
                    
                }
            case .imageChoice:
                
                if  Utilities.isValidObject(someObject:formatDict?[kStepQuestionImageChoices] as AnyObject?)  {
                    
                    let imageChoiceArray:[ORKImageChoice]?
                    
                    imageChoiceArray = self.getImageChoices(dataArray: formatDict?[kStepQuestionImageChoices] as! NSArray)
                    if imageChoiceArray == nil {
                        return nil
                    }
                    
                    questionStepAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: imageChoiceArray!)
                    
                    
                }
                else{
                    Logger.sharedInstance.debug("imageChoice Question Step has null values:\(formatDict)")
                    return nil
                    
                }
            case .textChoice:
                // array(text choices) + int(selection Type)
                if  Utilities.isValidObject(someObject:formatDict?[kStepQuestionTextChoiceTextChoices] as AnyObject?)
                    && Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextChoiceSelectionStyle] as AnyObject?){
                    
                    let textChoiceArray:[ORKTextChoice]?
                    
                    textChoiceArray = self.getTextChoices(dataArray: (formatDict?[kStepQuestionTextChoiceTextChoices] as? NSArray)! )
                    
                    
                   // if (textChoiceArray?.count)! >= 2 &&  (textChoiceArray?.count)! <= 8 {
                    
                    
                    if (formatDict?[kStepQuestionTextChoiceSelectionStyle] as! String) == kStepQuestionTextChoiceSelectionStyleSingle{
                        // single choice
                        questionStepAnswerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: textChoiceArray!)
                    }
                    else  if (formatDict?[kStepQuestionTextChoiceSelectionStyle] as! String) == kStepQuestionTextChoiceSelectionStyleMultiple{
                        // multiple choice
                        questionStepAnswerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.multipleChoice, textChoices: textChoiceArray!)
                    }
                    else{
                        Logger.sharedInstance.debug("kStepQuestionTextChoiceSelectionStyle has null value:\(formatDict)")
                        return nil
                        
                    }
                   // }
                   // else{
                   //     return nil
                   // }
                }
                else{
                    Logger.sharedInstance.debug("textChoice Question Step has null values:\(formatDict)")
                    return nil
                    
                }
                
            case .boolean:
                
                questionStepAnswerFormat = ORKBooleanAnswerFormat()
                
            case .numeric:
                
                if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericStyle] as AnyObject?)
                   
                   {
                     //&&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericUnit] as AnyObject?)
                    
                    // &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericMinValue] as AnyObject?)
                   // &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericMaxValue] as AnyObject?)
                    
                    // &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericPlaceholder] as AnyObject?)
                    
                    //ORKStep dont need placeholder
                    
                    var maxValue = formatDict?[kStepQuestionNumericMaxValue] as? NSNumber
                    
                    var minValue = formatDict?[kStepQuestionNumericMinValue] as? NSNumber
                    
                    if maxValue != nil && maxValue == 0 {
                        maxValue = nil
                    }
                    if minValue != nil && minValue == 0  {
                        minValue = nil
                    }
                  
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericPlaceholder] as AnyObject?){
                        placeholderText = formatDict?[kStepQuestionNumericPlaceholder] as? String
                    }
                    
                    
                    let localizedQuestionStepAnswerFormatUnit = NSLocalizedString((formatDict?[kStepQuestionNumericUnit] as? String)! , comment: "")
                    
                    let style = (formatDict?[kStepQuestionNumericStyle] as! String == "Decimal") ? 0 : 1
                    
                    switch ORKNumericAnswerStyle(rawValue:style)! as ORKNumericAnswerStyle {
                    case .integer:
                        
                        
                        if  Utilities.isValidValue(someObject:self.healthDataKey as AnyObject?){
                            
                            
                            let quantityTypeId:HKQuantityTypeIdentifier = HKQuantityTypeIdentifier.init(rawValue:self.healthDataKey! )
                          
                            
                            let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeId)
                            //let unit =  HKUnit.init(from: "kgi")
                          var unit:HKUnit? = nil
                          
                          if self.isUnitValid(unit: localizedQuestionStepAnswerFormatUnit){
                            unit = HKUnit.init(from: localizedQuestionStepAnswerFormatUnit)
                          }
                          
                           // unit =  HKUnit.init(from: localizedQuestionStepAnswerFormatUnit)
                            //let healthKitStore = HKHealthStore()
                            //healthKitStore.is
                         questionStepAnswerFormat = ORKHealthKitQuantityTypeAnswerFormat.init(quantityType: quantityType!, unit: unit, style: ORKNumericAnswerStyle.integer)
                        
                        }
                        else{
                        if minValue != nil || maxValue != nil {
                            questionStepAnswerFormat = ORKNumericAnswerFormat.init(style: ORKNumericAnswerStyle.integer, unit: localizedQuestionStepAnswerFormatUnit, minimum: minValue , maximum: maxValue)
                        }
                        else{
                            questionStepAnswerFormat = ORKAnswerFormat.integerAnswerFormat(withUnit:localizedQuestionStepAnswerFormatUnit)
                        }
                        }
                    case .decimal:
                        if  Utilities.isValidValue(someObject:self.healthDataKey as AnyObject?){
                            
                            let quantityTypeId = HKQuantityTypeIdentifier.init(rawValue:self.healthDataKey!)
                            //self.healthDataKey!
                            //let unit =  HKUnit.init(from: localizedQuestionStepAnswerFormatUnit)
                            
                          var unit:HKUnit? = nil
                          
                          if localizedQuestionStepAnswerFormatUnit != "" && self.isUnitValid(unit: localizedQuestionStepAnswerFormatUnit){
                            unit = HKUnit.init(from: localizedQuestionStepAnswerFormatUnit)
                          }
                             questionStepAnswerFormat = ORKHealthKitQuantityTypeAnswerFormat.init(quantityType: HKQuantityType.quantityType(forIdentifier: quantityTypeId)!, unit: unit, style: ORKNumericAnswerStyle.decimal)
                        }
                        else{
                        
                        if minValue != nil || maxValue != nil {
                            questionStepAnswerFormat = ORKNumericAnswerFormat.init(style: ORKNumericAnswerStyle.decimal, unit: localizedQuestionStepAnswerFormatUnit, minimum: minValue , maximum: maxValue)
                        }
                        else{
                             questionStepAnswerFormat = ORKAnswerFormat.decimalAnswerFormat(withUnit: localizedQuestionStepAnswerFormatUnit)
                        }
                        }
                    }
                    
                    
                }
                else{
                    Logger.sharedInstance.debug("numeric has null values:\(formatDict)")
                    return nil
                    
                }
                
            case .timeOfDay:
                
                questionStepAnswerFormat = ORKAnswerFormat.timeOfDayAnswerFormat()
                
                
            case .date:
              
                if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionDateStyle] as AnyObject?)
                    //&&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionDateMinDate] as AnyObject?)
                    //&&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionDateMaxDate] as AnyObject?)
                    //&&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionDateDefault] as AnyObject?)
                {
                    
                    // need to
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                  
                  var dateRange:DateRange? = DateRange.defaultValue
                  
                  if Utilities.isValidValue(someObject:formatDict?[kStepQuestionDateRange] as AnyObject?) {
                    
                    dateRange = DateRange.init(rawValue: formatDict?[kStepQuestionDateRange] as! String)
                  }
                  
                    let defaultDate:NSDate? = dateFormatter.date(from: formatDict?[kStepQuestionDateDefault] as! String) as NSDate?
                    var minimumDate:NSDate? = dateFormatter.date(from: formatDict?[kStepQuestionDateMinDate] as! String) as NSDate?
                    var maximumDate:NSDate? = dateFormatter.date(from: formatDict?[kStepQuestionDateMaxDate] as! String) as NSDate?
                  
                  switch dateRange! {
                  case .untilCurrent:
                    maximumDate = Date.init(timeIntervalSinceNow: 0) as NSDate
                  case .afterCurrent:
                    minimumDate = Date.init(timeIntervalSinceNow: 86400) as NSDate
                  case .defaultValue: break
                  case .custom: break
                  }
                  
                    
                    switch  DateStyle(rawValue:formatDict?[kStepQuestionDateStyle] as! String)! as DateStyle{
                        
                    case .date:
                        
                        questionStepAnswerFormat = ORKAnswerFormat.dateAnswerFormat(withDefaultDate: defaultDate as Date?, minimumDate: minimumDate as Date?, maximumDate: maximumDate as Date?, calendar: NSCalendar.current)
                        
                    case .dateAndTime:
                        
                        questionStepAnswerFormat = ORKAnswerFormat.dateTime(withDefaultDate: defaultDate as Date?, minimumDate: minimumDate as Date?, maximumDate: maximumDate as Date?, calendar: NSCalendar.current)
                        
                    default:
                        break
                    }
                    
                }else{
                    Logger.sharedInstance.debug("date has null values:\(formatDict)")
                    return nil
                    
                    
                }
            case .text:
                
                //Question
                
                // Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextMaxLength] as AnyObject?)
                   // &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextValidationRegex] as AnyObject?)
                   // &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextInvalidMessage] as AnyObject?)
                   // &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextPlaceholder] as AnyObject?)
                    if Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextMultipleLines] as AnyObject?){
                    
                        
                        if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericPlaceholder] as AnyObject?){
                            placeholderText = formatDict?[kStepQuestionNumericPlaceholder] as? String
                        }
                      
                      var answerFormat = ORKAnswerFormat.textAnswerFormat()
                    
                    if Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextMaxLength] as AnyObject?){
                         answerFormat.maximumLength = formatDict?[kStepQuestionTextMaxLength] as! Int
                    }
                    else{
                         answerFormat.maximumLength = 0
                    }
                    
                    if Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextValidationRegex] as AnyObject?) && Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextInvalidMessage] as AnyObject?){
                      
                      var regex:NSRegularExpression? = nil
                      do
                      {
                        regex = try NSRegularExpression.init(pattern:(formatDict?[kStepQuestionTextValidationRegex] as? String)! , options: [])
                      }
                      catch{
                        
                      }
                      if regex != nil{
                        answerFormat = ORKAnswerFormat.textAnswerFormat(withValidationRegularExpression: regex!, invalidMessage: (formatDict?[kStepQuestionTextInvalidMessage] as? String)!)
                      }
                      
                        //answerFormat.validationRegex = formatDict?[kStepQuestionTextValidationRegex] as? String
                        // answerFormat.invalidMessage = formatDict?[kStepQuestionTextInvalidMessage] as? String
                    }
                    else{
                        //answerFormat.validationRegex = nil
                        answerFormat.invalidMessage = nil
                    }
                    
                    answerFormat.multipleLines = formatDict?[kStepQuestionTextMultipleLines] as! Bool
                    
                    // placeholder  usage???
                    
                    questionStepAnswerFormat = answerFormat
                }
                else{
                    Logger.sharedInstance.debug("text has null values:\(formatDict)")
                    return nil
                    
                }
            case .email:
                
                    questionStepAnswerFormat = ORKAnswerFormat.emailAnswerFormat()
                
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericPlaceholder] as AnyObject?){
                        placeholderText = formatDict?[kStepQuestionNumericPlaceholder] as? String
                }
                    // Place holder???

            case .timeInterval:
                
                if Utilities.isValidValue(someObject:formatDict?[kStepQuestionTimeIntervalStep] as AnyObject?)
                {
                    let defaultTimeInterval:Double?
                    
                    if Utilities.isValidValue(someObject:formatDict?[kStepQuestionTimeIntervalDefault] as AnyObject?){
                        defaultTimeInterval = Double((formatDict?[kStepQuestionTimeIntervalDefault] as? Int)!  )
                    }
                    else{
                        defaultTimeInterval = Double(0.0)
                    }
                    
                    
                    if (formatDict?[kStepQuestionTimeIntervalStep] as? Int)! >= 1 && (formatDict?[kStepQuestionTimeIntervalStep] as? Int)! <= 30 {
                    
                    questionStepAnswerFormat = ORKAnswerFormat.timeIntervalAnswerFormat(withDefaultInterval:defaultTimeInterval!, step: formatDict?[kStepQuestionTimeIntervalStep] as! Int)
                    }
                    else{
                        return nil
                    }
                    
                }
                else{
                    Logger.sharedInstance.debug("timeInterval has null values:\(formatDict)")
                    return nil
                    
                }
            case .height:
                
                if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionHeightMeasurementSystem] as AnyObject?)
                {
                    
                    let measurementSystem:ORKMeasurementSystem?
                    
                    switch HeightMeasurementSystem(rawValue: formatDict?[kStepQuestionHeightMeasurementSystem] as! String)! {
                    case .local:
                        measurementSystem = .local
                        
                    case .metric:
                        measurementSystem = .metric
                    case .us:
                        measurementSystem = .USC
                    default:break
                        
                    }
                    questionStepAnswerFormat = ORKAnswerFormat.heightAnswerFormat(with:measurementSystem! )
                    // Place holder
                    
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericPlaceholder] as AnyObject?){
                        placeholderText = formatDict?[kStepQuestionNumericPlaceholder] as? String
                    }
                    
                }
                else{
                    Logger.sharedInstance.debug("height has null values:\(formatDict)")
                    return nil
                    
                    
                }
            case .location:
                if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionLocationUseCurrentLocation] as AnyObject?)
                {
                    let answerFormat = ORKAnswerFormat.locationAnswerFormat()
                    answerFormat.useCurrentLocation = formatDict?[kStepQuestionLocationUseCurrentLocation] as! Bool
                    
                    questionStepAnswerFormat = answerFormat
                }
                else{
                    Logger.sharedInstance.debug("location has null values:\(formatDict)")
                    return nil
                    
                }
            default:break
                
            }
            
            
            questionStep = ORKQuestionStep(identifier:key! , title: title!, answer: questionStepAnswerFormat)
            // By default a step is skippable
            if (skippable == false) {
                questionStep?.isOptional = false
            }
            
            if  Utilities.isValidValue(someObject:placeholderText as AnyObject?){
                questionStep?.placeholder = placeholderText
            }
            questionStep?.text = text
          
            return questionStep!
          
        }
        else{
            Logger.sharedInstance.debug("FormatDict has null values:\(formatDict)")
            
            return nil
        }
    }
    
    
    
    
    func getTextChoices(dataArray:NSArray) -> [ORKTextChoice] {
        
        /* Method  creates ORKTextChoice Array
         @param dataArray: is either array of Dictionary or array of String
         returns array of ORKTextChoice
         */
        
        var textChoiceArray:[ORKTextChoice]? = []
      
        if  Utilities.isValidObject(someObject:dataArray )  {
            
            for i  in 0 ..< dataArray.count {
                
                if (Utilities.isValidObject(someObject:dataArray[i] as AnyObject?) && (((dataArray[i] as? NSDictionary) != nil)))  {
                    // if it is array of dictionary used TextScale
                    let dict:NSDictionary = dataArray[i] as! NSDictionary
                    
                    if Utilities.isValidObject(someObject: dict){
                        
                        if  Utilities.isValidValue(someObject:dict[kORKTextChoiceText] as AnyObject?) &&  Utilities.isValidValue(someObject:dict[kORKTextChoiceValue] as AnyObject?) &&  Utilities.isValidValue(someObject:dict[kORKTextChoiceExclusive] as AnyObject?) {
                            
                            let detailText:String?
                            
                            if Utilities.isValidValue(someObject: (dict[kORKTextChoiceDetailText] as? String as AnyObject?)){
                                detailText = dict[kORKTextChoiceDetailText] as? String
                            }
                            else{
                                detailText = " "
                            }
                          
                          if self.textScaleDefaultValue?.isEmpty == false && self.textScaleDefaultValue != ""{
                            if (dict[kORKTextChoiceValue] as! String)  == self.textScaleDefaultValue {
                              self.textScaleDefaultIndex = i
                            }
                          }
                          
                            
                            let  choice = ORKTextChoice(text: (dict[kORKTextChoiceText] as? String)!, detailText: detailText, value: (dict[kORKTextChoiceValue] as? NSCoding & NSCopying & NSObjectProtocol)! , exclusive: (dict[kORKTextChoiceExclusive] as? Bool)!)
                            textChoiceArray?.append(choice)
                            
                        }
                        
                    }
                }
                else if dataArray[i] as? String != nil && Utilities.isValidValue(someObject:dataArray[i] as AnyObject? ){
                    // if it is array of string used for Value Picker & TextChoice
                    let key:String = dataArray[i] as! String
                    
                    if Utilities.isValidValue(someObject: key as AnyObject?) {
                        
                        let choice = ORKTextChoice(text: key, value: i as NSCoding & NSCopying & NSObjectProtocol )

                      if self.textScaleDefaultValue?.isEmpty == false && self.textScaleDefaultValue != ""{
                        if key == self.textScaleDefaultValue{
                          self.textScaleDefaultIndex = i
                        }
                      }
                        textChoiceArray?.append(choice)
                    }
                }
                else{
                    Logger.sharedInstance.debug("dataArray has Invalid data: null ")
                }
                
            }
        }
        return textChoiceArray!
    }
    
    
    
    
    func getImageChoices(dataArray:NSArray) -> [ORKImageChoice]? {
        
        /* Method  creates ORKImageChoice Array
         @dataArray: is array of Dictionary
         returns array of ORKImageChoice
         */
        
        
        ///PENDING
        
        let imageChoiceArray:[ORKImageChoice]?
        
        imageChoiceArray = [ORKImageChoice]()
        if Utilities.isValidObject(someObject: dataArray){
            
            for i  in 0 ..< dataArray.count {
                
                if Utilities.isValidObject(someObject: dataArray[i] as AnyObject ) {
                    // if it is array of dictionary
                    let dict:NSDictionary = dataArray[i] as! NSDictionary
                    
                     var value:String!
                    
                    if Utilities.isValidValue(someObject: dict[kStepQuestionImageChoiceValue] as AnyObject){
                         value = dict[kStepQuestionImageChoiceValue] as! String
                    }
                    
                    if  Utilities.isValidValue(someObject: dict[kStepQuestionImageChoiceImage] as AnyObject? )
                        &&  Utilities.isValidValue(someObject:dict[kStepQuestionImageChoiceSelectedImage] as AnyObject?)
                        &&  Utilities.isValidValue(someObject:dict[kStepQuestionImageChoiceText] as AnyObject?)
                        {
                        
                        // check if file exist at local path
                        
                            
                        let base64String =  dict[kStepQuestionImageChoiceImage] as! String
                            
                        let normalImageData = NSData(base64Encoded: base64String, options: .ignoreUnknownCharacters)
                        let selectedImageData  = NSData(base64Encoded: (dict[kStepQuestionImageChoiceSelectedImage] as! String), options: .ignoreUnknownCharacters)
                            
                        let normalImage:UIImage = UIImage(data:normalImageData as! Data)!
                        let selectedImage:UIImage =  UIImage(data:selectedImageData as! Data)!
                        
                        //else  download image from url
                        
                        
                        //let normalImage:UIImage = UIImage(data: )
                        //let selectedImage:UIImage = UIImage(data: )
                        
                        
                        let  choice = ORKImageChoice( normalImage: normalImage ,  selectedImage: selectedImage , text: dict[kStepQuestionImageChoiceText] as? String, value: value  as NSCoding & NSCopying & NSObjectProtocol )
                        
                        imageChoiceArray?.append(choice)
                        
                    }
                    else {
                        //To be removed
                        /*
                        
                        let normalImage:UIImage = UIImage(named:"Bomb.png")!
                        let selectedImage:UIImage = UIImage(named:"container.png")!
                        let  choice = ORKImageChoice( normalImage: normalImage ,  selectedImage: selectedImage , text: dict[kStepQuestionImageChoiceText] as? String, value: value as Int as NSCoding & NSCopying & NSObjectProtocol )
                        
                        imageChoiceArray?.append(choice)
                        */
                        
                        return nil
                    }
                }
                else{
                    return nil
                    Logger.sharedInstance.debug("ORKImageChoice Dictionary is null :\(dataArray[i])")
                    
                }
                
            }
        }
        else{
            Logger.sharedInstance.debug("ORKImageChoice Array is null :\(dataArray)")
            return nil
        }
        return imageChoiceArray!
    }
    
  
  
  func isUnitValid(unit:String) -> Bool {
    
    let filePath = Bundle.main.path(forResource: "Units", ofType: ".json", inDirectory:nil)
    var resultDict:Dictionary<String,Any>?
    let data = NSData(contentsOfFile: filePath!)
    do {
       resultDict = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
    }
    catch let error as NSError{
      print("\(error)")
    }
    
    let categoryDict = resultDict!["Category"] as! Dictionary<String,String>
    if let category =  categoryDict[self.healthDataKey!]{
      let unitDict = resultDict!["Unit"] as! Dictionary<String,Any>
      if let unitsArray = unitDict[category] as? Array<String> {
        if unitsArray.contains(unit){
          return true
        }
        else{
          return false
        }
      }
      return false
    }
    return false
  }
  
  
    
    
}




