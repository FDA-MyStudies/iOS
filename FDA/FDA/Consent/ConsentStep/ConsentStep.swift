//
//  ConsentStep.swift
//  FDA
//
//  Created by Arun Kumar on 2/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit

let kConsentStepType = "type"

let kConsentStepTitle = "title"
let kConsentStepText = "text"
let kConsentStepDescription = "description"
let kConsentStepHTML = "html"
let kConsentStepURL = "url"
let kConsentStepVisualStep = "visualStep"


enum ConsentStepSectionType:String{
    case overview = "overview"
    case dataGathering = "dataGathering"
    case privacy = "privacy"
    case dataUse = "dataUse"
    case timeCommitment = "timeCommitment"
    case studySurvey = "studySurvey"
    case studyTasks = "studyTasks"
    case withdrawing = "withdrawing"
    case custom = "custom"
    
    
    /*
     method to get IntegerValue for the Enum
     returns Integer specific to ORKconsent
     
    */
    
    
    func getIntValue()-> Int!{
        switch self {
        case .overview:
            return 0;
        case .dataGathering:
            return 1;
        case .privacy:
            return 2;
        case .dataUse :
            return 3;
        case .timeCommitment:
            return 4;
        case .studySurvey:
            return 5;
        case .studyTasks:
            return 6;
        case .withdrawing:
            return 7;
        case .custom:
            return 8;
        default:
            return -1
        }
    }

    
}

class ConsentSectionStep{
    
    var type:ConsentStepSectionType?
    var title:String?
    
    var text:String?
    var description:String? // Identifier
   
    var html:String?
    var url:String?
    
    var visualStep:Bool?
    
    
    init() {
        /* default Intalizer method */
        
        self.type = .overview
        self.title = ""
        self.text = ""
       
        self.description = ""
        self.html = ""
  
        self.url = ""
        self.visualStep = false

    }
    func initWithDict(stepDict:Dictionary<String, Any>){
        
        /* setter method which initializes all params
         @stepDict:contains as key:Value pair for all the properties of ConsentSectionStep
         */
        
        if Utilities.isValidObject(someObject: stepDict as AnyObject?){
            
            if Utilities.isValidValue(someObject: stepDict[kConsentStepType] as AnyObject ){
                self.type =  ConsentStepSectionType(rawValue:(stepDict[kConsentStepType] as? String)!)
            }
            
            if Utilities.isValidValue(someObject: stepDict[kConsentStepTitle] as AnyObject ){
                self.title = stepDict[kConsentStepTitle] as? String
            }
            if Utilities.isValidValue(someObject: stepDict[kConsentStepText] as AnyObject ){
                self.text = stepDict[kConsentStepText] as? String
            }
            if Utilities.isValidValue(someObject: stepDict[kConsentStepDescription] as AnyObject ){
                self.description = stepDict[kConsentStepDescription] as? String
            }
            if Utilities.isValidValue(someObject: stepDict[kConsentStepHTML] as AnyObject ) {
                self.html = stepDict[kConsentStepHTML] as? String
            }
            if Utilities.isValidValue(someObject: stepDict[kConsentStepURL] as AnyObject )  {
                self.url = stepDict[kConsentStepURL] as? String
            }
            if Utilities.isValidValue(someObject: stepDict[kConsentStepVisualStep] as AnyObject )  {
                self.visualStep = stepDict[kConsentStepVisualStep] as? Bool
            }
            
        }
        else{
            Logger.sharedInstance.debug("ConsentDocument Step Dictionary is null:\(stepDict)")
        }
        
    }
    

    func createConsentSection() ->ORKConsentSection {
        
        let consentType:Int? = (self.type?.getIntValue())! >= 0 ? (self.type?.getIntValue()) : -1
        
        let consentSection:ORKConsentSection!
        
        if self.visualStep == true{
            
            consentSection = ORKConsentSection(type: ORKConsentSectionType(rawValue: consentType! )!)
        }
        else{
            consentSection = ORKConsentSection(type: ORKConsentSectionType.onlyInDocument)
        }
        consentSection.title = self.title!
        consentSection.summary = self.text!
        
        if self.description?.isEmpty == false{
            consentSection.content = self.description!
        }
        else if self.html!.isEmpty == false{
           consentSection.htmlContent =  self.html!
        }
        else if self.url!.isEmpty == false{
             consentSection.contentURL = URL(string:self.url!)
        }
        
        return consentSection
    }
    
    
    
   
    
}
