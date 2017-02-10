//
//  StepProvider.swift
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


/*
import Foundation
import ResearchKit



//Step Constants
let kStepTitle = "title"
let kStepQuestionTypeValue = "QuestionType"



//Question Api Constants

let kStepQuestionType = "type"
let kStepQuestionResultType = "resultType"
let kStepQuestionKey = "key"
let kStepQuestionTitle = "title"
let kStepQuestionText = "text"
let kStepQuestionSkippable = "skippable"
let kStepQuestionGroupName = "groupName"
let kStepQuestionRepeatable = "repeatable"
let kStepQuestionRepeatableText = "repeatableText"
let kStepQuestionDestinations = "destinations"
let kStepQuestionPhi = "phi"
let kStepQuestionFormat = "format"


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
let kORKTextChoiceDetailText = "detail text"
let kORKTextChoiceExclusive = "exclusive"


//StepQuestionImageChoice Type Api Constants

let kStepQuestionImageChoices = "imageChoices"

let kStepQuestionImageChoiceImage = "image"
let kStepQuestionImageChoiceSelectedImage = "selected image"
let kStepQuestionImageChoiceText = "text"
let kStepQuestionImageChoiceValue = "value"


//TextChoiceQuestion Type Api Constants

let kStepQuestionTextChoiceTextChoices = "textChoices"
let kStepQuestionTextChoiceSelectionStyle = "selectionStyle"

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

//HeightQuestion Type Api Constants

let kStepQuestionHeightMeasurementSystem = "measurementSystem"
let kStepQuestionHeightPlaceholder = "placeholder"

//LocationQuestion Type Api Constants

let kStepQuestionLocationUseCurrentLocation = "useCurrentLocation"



class Step: ORKStep {
    
    enum StepType:String{
        
        case formStep
        
        // Survey Step specific identifiers.
        case introStep
        case questionStep
        case summaryStep
        
        // Step for  Boolean question.
        case booleanQuestionStep = "boolean"
        
        // Step for  example of date entry.
        case dateQuestionStep = "date"
        
        // Step for  example of date and time entry.
        case dateTimeQuestionStep
        
        // Step for  example of height entry.
        case heightQuestion = "height"
        
        // Step for  image choice question.
        case imageChoiceQuestionStep = "imageChoice"
        
        // Step for  location entry.
        case locationQuestionStep = "location"
        
        // Step with examples of numeric questions.
        case numericQuestionStep = "numeric"
        case numericNoUnitQuestionStep
        
        // Step with examples of questions with sliding scales.
        case scaleQuestionStep = "scale"
        case continuousScaleQuestionStep = "continuousScale"
        case discreteVerticalScaleQuestionStep
        case continuousVerticalScaleQuestionStep
        case textScaleQuestionStep = "textScale"
        case textVerticalScaleQuestionStep
        
        // Step for  example of free text entry.
        case textQuestionStep = "text"
        
        // Step for  example of a multiple choice question.
        case textChoiceQuestionStep = "textChoice"
        
        // Step for  example of time of day entry.
        case timeOfDayQuestionStep = "timeOfDay"
        
        // Step for  example of time interval entry.
        case timeIntervalQuestionStep = "timeInterval"
        
        // Step for  value picker.
        case valuePickerChoiceQuestionStep = "valuePicker"
        
        // Step for  example of validated text entry.
        case validatedTextQuestionStepEmail = "email"
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
    
    func getQuestionStep(dataDict:NSDictionary) -> ORKQuestionStep {
        
        if Utilities.isValidObject(someObject: dataDict){
            
            
            let formatDict:NSDictionary?
            formatDict = dataDict[kStepQuestionFormat] as? NSDictionary
            
            
            if Utilities.isValidObject(someObject: formatDict) && Utilities.isValidValue(someObject:formatDict?[kStepQuestionType]  as AnyObject?)   {
                
                var questionStepAnswerFormat:ORKAnswerFormat?
                
                var questionStep:ORKQuestionStep?
                
                switch dataDict[kStepQuestionType] as! StepType {
                case .scaleQuestionStep:
                    
                   
                    
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleMaxValue] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleMinValue] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleDefaultValue] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleStep] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleVertical] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleMaxDesc] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleMinDesc] as AnyObject?){
                        
                        questionStepAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: (formatDict![kStepQuestionScaleMaxValue] as? Int)!, minimumValue: (formatDict?[kStepQuestionScaleMinValue] as? Int)!, defaultValue: (formatDict?[kStepQuestionScaleDefaultValue] as? Int)!, step: (formatDict?[kStepQuestionScaleStep] as? Int)!, vertical: (formatDict?[kStepQuestionScaleVertical] as? Bool)!, maximumValueDescription: (formatDict?[kStepQuestionScaleMaxDesc] as? String)!, minimumValueDescription: (formatDict?[kStepQuestionScaleMinDesc] as? String)!)
                        
                        //questionStep?.placeholder =???
                        
                    }
                    else{
                        //debug lines
                    }
                case .continuousScaleQuestionStep:
                    
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionContinuosScaleMaxValue] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionContinuosScaleMinValue] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionContinuosScaleDefaultValue] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionContinuosScaleMaxFractionDigits] as AnyObject?) && formatDict?[kStepQuestionContinuosScaleVertical] != nil && formatDict?[kStepQuestionContinuosScaleMaxDesc] != nil &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionScaleMinDesc] as AnyObject?){
                        
                        questionStepAnswerFormat = ORKAnswerFormat.continuousScale(withMaximumValue: (formatDict?[kStepQuestionContinuosScaleMaxValue] as? Double)!, minimumValue: (formatDict?[kStepQuestionContinuosScaleMinValue] as? Double)!, defaultValue: (formatDict?[kStepQuestionContinuosScaleDefaultValue] as? Double)!, maximumFractionDigits: (formatDict?[kStepQuestionContinuosScaleMaxFractionDigits] as? Int)!, vertical: (formatDict?[kStepQuestionContinuosScaleVertical] as? Bool)!, maximumValueDescription: (formatDict?[kStepQuestionContinuosScaleMaxDesc] as? String)!
                            , minimumValueDescription: (formatDict?[kStepQuestionScaleMinDesc] as? String)!)
                        
                        
                        
                        
                    }
                    else{
                        //debug lines
                    }
                case .textScaleQuestionStep:
                    
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextScaleTextChoices] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextScaleDefault] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextScaleVertical] as AnyObject?) {
                        
                        let textChoiceArray:[ORKTextChoice]?
                        
                        textChoiceArray = self.getTextChoices(dataArray: formatDict?[kStepQuestionScaleMaxValue] as! NSArray)
                        
                        questionStepAnswerFormat = ORKAnswerFormat.textScale(with: textChoiceArray!, defaultIndex: formatDict?[kStepQuestionTextScaleDefault] as! Int, vertical: formatDict?[kStepQuestionTextScaleVertical] as! Bool)
                        
                        
                        
                    }
                    else{
                        //debug lines
                    }
                case .valuePickerChoiceQuestionStep:
                    
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextScaleTextChoices] as AnyObject?)  {
                        
                        let textChoiceArray:[ORKTextChoice]?
                        
                        textChoiceArray = self.getTextChoices(dataArray: formatDict?[kStepQuestionTextScaleTextChoices] as! NSArray)
                        
                        
                        questionStepAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with:textChoiceArray!)
                        
                        
                    }
                    else{
                        //debug lines
                    }
                case .imageChoiceQuestionStep:
                    
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionImageChoices] as AnyObject?)  {
                        
                        let imageChoiceArray:[ORKImageChoice]?
                        
                        imageChoiceArray = self.getImageChoices(dataArray: formatDict?[kStepQuestionImageChoices] as! NSArray)
                        
                        questionStepAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: imageChoiceArray!)
                        
                        
                    }
                    else{
                        //debug lines
                    }
                case .textChoiceQuestionStep:
                    // array(text choices) + int(selection Type)
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextChoiceTextChoices] as AnyObject?)  &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextChoiceSelectionStyle] as AnyObject?){
                        
                        let textChoiceArray:[ORKTextChoice]?
                        
                        textChoiceArray = self.getTextChoices(dataArray: (formatDict?[kStepQuestionTextChoiceTextChoices] as? NSArray)! )
                        
                        
                        if (formatDict?[kStepQuestionTextChoiceSelectionStyle] as! ORKChoiceAnswerStyle) == ORKChoiceAnswerStyle.singleChoice{
                            // single choice
                            questionStepAnswerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: textChoiceArray!)
                        }
                        else  if(formatDict?[kStepQuestionTextChoiceSelectionStyle] as! ORKChoiceAnswerStyle) == ORKChoiceAnswerStyle.multipleChoice{
                            // multiple choice
                            questionStepAnswerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.multipleChoice, textChoices: textChoiceArray!)
                        }
                        else{
                            // debug line for invalid selection type
                        }
                    }
                    else{
                        //debug lines
                    }
                case .numericQuestionStep:
                    
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericStyle] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericUnit] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericMinValue] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericMaxValue] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionNumericPlaceholder] as AnyObject?){
                        
                        
                        let localizedQuestionStepAnswerFormatUnit = NSLocalizedString(formatDict?[kStepQuestionNumericUnit] as! String , comment: "")
                        
                        switch formatDict?[kStepQuestionNumericStyle] as! ORKNumericAnswerStyle {
                        case .integer:
                            questionStepAnswerFormat = ORKAnswerFormat.integerAnswerFormat(withUnit:localizedQuestionStepAnswerFormatUnit)
                            
                        case .decimal:
                            questionStepAnswerFormat = ORKAnswerFormat.decimalAnswerFormat(withUnit: localizedQuestionStepAnswerFormatUnit)
                        default:
                            // debug lines
                            break
                        }
                        
                        
                    }
                    else{
                        //debug lines
                    }
                case .dateQuestionStep:
                    
                    
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionDateStyle] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionDateMinDate] as AnyObject?)
                        &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionDateMaxDate] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionDateDefault] as AnyObject?) {
                        
                        // need to
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM-dd-yyyy"
                        
                        
                        
                        let defaultDate:NSDate? = dateFormatter.date(from: formatDict?[kStepQuestionDateDefault] as! String) as NSDate?
                        let minimumDate:NSDate? = dateFormatter.date(from: formatDict?[kStepQuestionDateDefault] as! String) as NSDate?
                        let maximumDate:NSDate? = dateFormatter.date(from: formatDict?[kStepQuestionDateDefault] as! String) as NSDate?
                        
                        
                        switch formatDict?[kStepQuestionDateStyle] as! ORKDateAnswerStyle {
                            
                        case .date:
                            
                            questionStepAnswerFormat = ORKAnswerFormat.dateAnswerFormat(withDefaultDate: defaultDate as Date?, minimumDate: minimumDate as Date?, maximumDate: maximumDate as Date?, calendar: NSCalendar.current)
                            
                        case .dateAndTime:
                            
                            questionStepAnswerFormat = ORKAnswerFormat.dateTime(withDefaultDate: defaultDate as Date?, minimumDate: minimumDate as Date?, maximumDate: maximumDate as Date?, calendar: NSCalendar.current)
                            
                        default: break
                            // debug lines
                            
                        }
                        
                    }else{
                        // debug lines
                        
                    }
                case .textQuestionStep:
                    
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextMaxLength] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextValidationRegex] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextInvalidMessage] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextMultipleLines] as AnyObject?) &&  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTextPlaceholder] as AnyObject?) {
                        let answerFormat = ORKAnswerFormat.textAnswerFormat()
                        
                        answerFormat.maximumLength = formatDict?[kStepQuestionTextMaxLength] as! Int
                        answerFormat.validationRegex = formatDict?[kStepQuestionTextMaxLength] as? String
                        answerFormat.invalidMessage = formatDict?[kStepQuestionTextInvalidMessage] as? String
                        answerFormat.multipleLines = formatDict?[kStepQuestionTextMultipleLines] as! Bool
                        
                        // placeholder  usage???
                        
                        questionStepAnswerFormat = answerFormat
                        
                        
                    }
                    else{
                        //debug lines
                    }
                case .validatedTextQuestionStepEmail:
                    
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionEmailPlaceholder] as AnyObject?)
                    {
                        
                        questionStepAnswerFormat = ORKAnswerFormat.emailAnswerFormat()
                        // Place holder???
                        
                    }
                    else{
                        //debug lines
                    }
                case .timeIntervalQuestionStep:
                    
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionTimeIntervalDefault] as AnyObject?) &&   Utilities.isValidValue(someObject:formatDict?[kStepQuestionTimeIntervalStep] as AnyObject?)
                    {
                        
                        questionStepAnswerFormat = ORKAnswerFormat.timeIntervalAnswerFormat(withDefaultInterval: formatDict?[kStepQuestionTimeIntervalDefault] as! Double, step: formatDict?[kStepQuestionTimeIntervalStep] as! Int)
                        
                        
                    }
                    else{
                        //debug lines
                    }
                case .heightQuestion:
                    
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionHeightPlaceholder] as AnyObject?) &&   Utilities.isValidValue(someObject:formatDict?[kStepQuestionHeightMeasurementSystem] as AnyObject?)
                    {
                        questionStepAnswerFormat = ORKAnswerFormat.heightAnswerFormat(with:formatDict?[kStepQuestionHeightMeasurementSystem] as! ORKMeasurementSystem)
                        
                        // Place holder
                        
                    }
                    else{
                        //debug lines
                    }
                case .locationQuestionStep:
                    if  Utilities.isValidValue(someObject:formatDict?[kStepQuestionLocationUseCurrentLocation] as AnyObject?)
                    {
                        let answerFormat = ORKAnswerFormat.locationAnswerFormat()
                        answerFormat.useCurrentLocation = formatDict?[kStepQuestionLocationUseCurrentLocation] as! Bool
                        
                        questionStepAnswerFormat = answerFormat
                        
                        
                    }
                    else{
                        //debug lines
                    }
                default:break
                    
                }
                
                questionStep = ORKQuestionStep(identifier:(dataDict[kStepQuestionKey] as? String)! , title: dataDict[kStepQuestionTitle] as? String, answer: questionStepAnswerFormat)
                
                
                questionStep?.text = dataDict[kStepQuestionText] as? String
                
                
                return questionStep!
                
                
                
                
                
            }
            else{
                //Debug lines QuestionFormat dict is empty
                
                return (formatDict as? ORKQuestionStep)!
            }
        }
        else
        {
            //complete Dict is empty
            
            return (dataDict as? ORKQuestionStep)!
            
        }
        
    }
    
    
    /*
     func getFormStep(dict:NSDictionary) -> ORKFormStep {
     
     //let step = ORKFormStep(identifier: dict["key"] as! String, title: exampleQuestionText, text: exampleDetailText)
     
     
     
     }
     */
    
    func getTextChoices(dataArray:NSArray) -> [ORKTextChoice] {
        
        let textChoiceArray:[ORKTextChoice]?
        
        textChoiceArray = [ORKTextChoice]()
        
        if dataArray != nil {
            
            for i  in 0 ..< dataArray.count {
                
                if ((dataArray[i] as? [Dictionary<String, Any>]) != nil)  {
                    // if it is array of dictionary used TextScale
                    let dict:NSDictionary = dataArray[i] as! NSDictionary
                    
                    if dict != nil{
                        
                        if dict[kORKTextChoiceText] != nil && dict[kORKTextChoiceValue] != nil && dict[kORKTextChoiceDetailText] != nil && dict[kORKTextChoiceExclusive] != nil {
                            
                            let  choice = ORKTextChoice(text: dict[kORKTextChoiceText] as! String, detailText: dict[kORKTextChoiceDetailText] as? String, value: dict[kORKTextChoiceValue] as? Int as! NSCoding & NSCopying & NSObjectProtocol, exclusive: (dict[kORKTextChoiceValue] as? Bool)!)
                            textChoiceArray?.append(choice)
                            
                        }
                        
                    }
                }
                else if dataArray[i] as? String != nil{
                    // if it is array of string used for Value Picker & TextChoice
                    let key:String = dataArray[i] as! String
                    
                    if key != nil {
                        
                        let choice = ORKTextChoice(text: key, value: i as NSCoding & NSCopying & NSObjectProtocol )
                        
                        textChoiceArray?.append(choice)
                    }
                }
                else{
                    // Debug Lines
                }
                
            }
        }
        return textChoiceArray!
    }
    
    
    
    
    func getImageChoices(dataArray:NSArray) -> [ORKImageChoice] {
        
        ///PENDING
        
        let imageChoiceArray:[ORKImageChoice]?
        
        imageChoiceArray = [ORKImageChoice]()
        if dataArray != nil {
            
            for i  in 0 ..< dataArray.count {
                
                if ((dataArray[i] as? [Dictionary<String, Any>]) != nil)  {
                    // if it is array of dictionary
                    let dict:NSDictionary = dataArray[i] as! NSDictionary
                    
                    if dict != nil{
                        
                        if dict[kStepQuestionImageChoiceImage] != nil && dict[kStepQuestionImageChoiceSelectedImage] != nil && dict[kStepQuestionImageChoiceText] != nil && dict[kStepQuestionImageChoiceValue] != nil {
                            
                            // check if file exist at local path
                            
                            let normalImage:UIImage = UIImage(contentsOfFile:"localPath" )!
                            let selectedImage:UIImage = UIImage(contentsOfFile:"localPath")!
                            
                            //else  download image from url
                            
                            
                            //let normalImage:UIImage = UIImage(data: )
                            //let selectedImage:UIImage = UIImage(data: )
                            
                            
                            let  choice = ORKImageChoice( normalImage: normalImage ,  selectedImage: selectedImage , text: dict[kStepQuestionImageChoiceText] as? String, value: dict[kStepQuestionImageChoiceValue] as! Int as NSCoding & NSCopying & NSObjectProtocol )
                            
                            imageChoiceArray?.append(choice)
                            
                        }
                        
                    }
                    else{
                        // debug lines : dictionary is nil
                    }
                }
                
            }
        }
        return imageChoiceArray!
    }
    
    
    
    
}
*/
