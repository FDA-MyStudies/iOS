//
//  ConsentBuilder.swift
//  FDA
//
//  Created by Arun Kumar on 2/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit

//Consent Api Constants

let kConsentVisual = "consent"
let kConsentSharing = "sharing"
let kConsentReview = "review"


// SharingConsent Api Constants

let kConsentSharingStepShortDesc = "shortDesc"
let kConsentSharingStepLongDesc = "longDesc"
let kConsentSharingSteplearnMore = "learnMore"

// ReviewConsent Api Constants

let kConsentReviewStepTitle = "title"
let kConsentReviewStepSignatureTitle = "signatureTitle"
let kConsentReviewStepSignatureContent = "signatureContent"



//MARK:ConsentBuilder Class

class ConsentBuilder{
    

    var consentSectionArray:[ORKConsentSection]
    var consentStepArray:[ORKStep]
    
    var reviewConsent:ReviewConsent?
    var sharingConsent:SharingConsent?
    
    init() {
        /* Default Initializer method
         by default sets all params to empty values
         */

        self.consentSectionArray = []
       
        self.consentStepArray = []
         self.reviewConsent = ReviewConsent()
        self.sharingConsent = SharingConsent()
    }
    
    func initWithMetaData(metaDataDict:Dictionary<String, Any>)  {
        /* initializer method which initializes all params
         @metaDataDict:contains as Dictionaries for all the properties of Consent Step
         */
        
          if Utilities.isValidObject(someObject: metaDataDict as AnyObject?){
            
            let visualConsentArray = metaDataDict[kConsentVisual] as! Array<Dictionary<String,Any>>
            
            if  Utilities.isValidObject(someObject: visualConsentArray as AnyObject?){
                for sectionDict in visualConsentArray{
                    
                    let consentSection:ConsentSectionStep? = ConsentSectionStep()
                    consentSection?.initWithDict(stepDict: sectionDict)
                    consentSectionArray.append((consentSection?.createConsentSection())!)
                    
                }
                
            }
            
             let consentSharingDict = metaDataDict[kConsentSharing] as! Dictionary<String,Any>
            
            if  Utilities.isValidObject(someObject: consentSharingDict as AnyObject?){
                self.sharingConsent?.initWithSharingDict(dict: consentSharingDict)
                
            }
            let reviewConsentDict = metaDataDict[kConsentReview] as! Dictionary<String,Any>
            
            if  Utilities.isValidObject(someObject: reviewConsentDict as AnyObject?){
                self.reviewConsent?.initWithReviewDict(dict: reviewConsentDict)
                
            }
            
            
        }
    }
    
    func getVisualConsentStep() -> ORKVisualConsentStep {
        /* Method to get VisualConsentStep
         @returns an instance of ORKVisualConsentStep
         */

        
        let visualConsentStep = ORKVisualConsentStep(identifier: "visual", document: self.createConsentDocument())
        return visualConsentStep
    }
    
    
    
    func createConsentDocument() -> ORKConsentDocument? {
        /* Method to create ConsentDocument
         @returns a ORKConsentDocument for VisualConsentStep and Review Step
         */
        
        let consentDocument = ORKConsentDocument()
        
        if Utilities.isValidValue(someObject: "title" as AnyObject )
            && Utilities.isValidValue(someObject: "signaturePageTitle" as AnyObject )
            && Utilities.isValidValue(someObject: "signaturePageContent" as AnyObject ){
            
            consentDocument.title = "title"
            consentDocument.signaturePageTitle = "signaturePageTitle"
            consentDocument.signaturePageContent = "signaturePageContent"
            

            consentDocument.sections? = self.consentSectionArray
            
            
            let signatureImage = UIImage(named: "Bomb.png")!
            
            let investigatorSignatureTitle = NSLocalizedString(user.getFullName(), comment: "")
            let investigatorSignatureGivenName = NSLocalizedString(user.firstName!, comment: "")
            let investigatorSignatureFamilyName = NSLocalizedString(user.lastName!, comment: "")
            let investigatorSignatureDateString = Utilities.getStringFromDate(date: Date.init(timeIntervalSinceNow: 0))
            
            let investigatorSignature = ORKConsentSignature(forPersonWithTitle: investigatorSignatureTitle, dateFormatString: nil, identifier:"Signature", givenName: investigatorSignatureGivenName, familyName: investigatorSignatureFamilyName, signatureImage: signatureImage, dateString: investigatorSignatureDateString)

             consentDocument.addSignature(investigatorSignature)
            return consentDocument
            
        }
        else{
            
            Logger.sharedInstance.debug("consent Step has null values:")
            return nil
        }
        
        
    }
    
    
    func getReviewConsentStep() -> ORKConsentReviewStep? {
        /* Method to get ReviewConsentStep
         @returns an instance of ORKConsentReviewStep
         */
        
        if Utilities.isValidValue(someObject: self.reviewConsent?.title as AnyObject )
            && Utilities.isValidValue(someObject: self.reviewConsent?.signatureTitle as AnyObject )
            && Utilities.isValidValue(someObject: self.reviewConsent?.signatureContent as AnyObject ){
            
            
            // identifier missing
            
            
            let reviewConsentStep = ORKConsentReviewStep(identifier: "Review", signature: (self.createConsentDocument()! as ORKConsentDocument).signatures?[0], in: self.createConsentDocument()!)
            
            // In a real application, you would supply your own localized text.
            reviewConsentStep.text = self.reviewConsent?.title
            reviewConsentStep.reasonForConsent = self.reviewConsent?.signatureContent
            return reviewConsentStep
        }
        else{
            
            Logger.sharedInstance.debug("consent Step has null values:")
            return nil
        }
        
    }
    
    
    func getConsentSharingStep() -> ORKConsentSharingStep? {
        /* Method to get ConsentSharingStep
         @returns an instance of ORKConsentSharingStep
         */
        
        if Utilities.isValidValue(someObject: self.sharingConsent?.shortDesc as AnyObject )
            && Utilities.isValidValue(someObject: self.sharingConsent?.longDesc as AnyObject )
            && Utilities.isValidValue(someObject: self.sharingConsent?.learnMore as AnyObject ){
            
            
            // identifier missing
            
            let sharingConsentStep = ORKConsentSharingStep(identifier: "Sharing", investigatorShortDescription: (self.sharingConsent?.shortDesc)!, investigatorLongDescription: (self.sharingConsent?.longDesc)!, localizedLearnMoreHTMLContent: (self.sharingConsent?.learnMore)!)
            
            return sharingConsentStep
            
        }
        else{
            
            Logger.sharedInstance.debug("consent Step has null values:")
            return nil
        }
        
    }
    
    
    func createConsentTask() -> ORKTask {
        /* Method to get ORKTask i.e ConsentTask
         @returns an instance of ORKTask
         */
        let visualConsentStep:ORKVisualConsentStep? = self.getVisualConsentStep()
        let sharingConsentStep:ORKConsentSharingStep? = self.getConsentSharingStep()
        let reviewConsentStep:ORKConsentReviewStep? = self.getReviewConsentStep()
        
        return ORKOrderedTask(identifier: "ConsentTask", steps: [
            visualConsentStep!,
            sharingConsentStep!,
            reviewConsentStep!
            ])
    }
    
    
}


//MARK:SharingConsent Struct

struct SharingConsent {
    
    var shortDesc:String?
    var longDesc:String?
    var learnMore:String?
    init() {
        self.shortDesc = ""
        self.longDesc =  ""
        self.learnMore =  ""
    }
    
    public mutating func initWithSharingDict(dict:Dictionary<String, Any>)
    {
        /* initializer method which initializes all params
         @dict:contains as key:Value pair for all the properties of SharingConsent Step
         */
        
        if Utilities.isValidObject(someObject: dict as AnyObject?){
            
            if Utilities.isValidValue(someObject: dict[kConsentSharingStepShortDesc] as AnyObject ){
                self.shortDesc =  (dict[kConsentSharingStepShortDesc] as? String)!
            }
            
            if Utilities.isValidValue(someObject: dict[kConsentSharingStepLongDesc] as AnyObject ){
                self.longDesc = dict[kConsentSharingStepLongDesc] as? String
            }
            if Utilities.isValidValue(someObject: dict[kConsentSharingSteplearnMore] as AnyObject ){
                self.learnMore = dict[kConsentSharingSteplearnMore] as? String
            }
        }
        else{
            Logger.sharedInstance.debug("ConsentDocument Step Dictionary is null:\(dict)")
        }
        
    }
    
}


//MARK:ReviewConsent Struct

struct ReviewConsent{
    
    var title:String?
    var signatureTitle:String?
    var signatureContent:String?
    
    init() {
        self.title = ""
        self.signatureTitle =  ""
        self.signatureContent =  ""
    }
    mutating func initWithReviewDict(dict:Dictionary<String, Any>) {
        /* initializer method which initializes all params
         @dict:contains as key:Value pair for all the properties of ReviewConsent Step
         */
        
        if Utilities.isValidObject(someObject: dict as AnyObject?){
            
            if Utilities.isValidValue(someObject: dict[kConsentReviewStepTitle] as AnyObject ){
                self.title =  (dict[kConsentReviewStepTitle] as? String)!
            }
            
            if Utilities.isValidValue(someObject: dict[kConsentReviewStepSignatureTitle] as AnyObject ){
                self.signatureTitle = dict[kConsentReviewStepSignatureTitle] as? String
            }
            if Utilities.isValidValue(someObject: dict[kConsentReviewStepSignatureContent] as AnyObject ){
                self.signatureContent = dict[kConsentReviewStepSignatureContent] as? String
            }
        }
        else{
            Logger.sharedInstance.debug("ConsentDocument Step Dictionary is null:\(dict)")
        }
        
    }
}
