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
let kConsentVisualScreens = "visualScreens"

let kConsentVersion = "version"
let kConsentPdfContent = "content"


// SharingConsent Api Constants

let kConsentSharingStepShortDesc = "shortDesc"
let kConsentSharingStepLongDesc = "longDesc"
let kConsentSharingSteplearnMore = "learnMore"
let kConsentSharingStepText = "text"
let kConsentSharingStepTitle = "title"



// ReviewConsent Api Constants

let kConsentReviewStepTitle = "title"
let kConsentReviewStepSignatureTitle = "signatureTitle"
let kConsentReviewStepSignatureContent = "reviewHTML"
let kConsentReviewStepReasonForConsent = "reasonForConsent"




//

let kConsentSharePdfCompletionStep = "ConsentShareCompletionStep"
let kConsentViewPdfCompletionStep = "ConsentViewPdfCompletionStep"
let kConsentCompletionStepIdentifier = "ConsentFinalCompletionStep"


//Completion Storyboard Segue

let kConsentSharePdfStoryboardId = "ConsentSharePdfStepViewControllerIdentifier"

let kConsentViewPdfStoryboardId = "ConsentPdfViewerStepViewControllerIdentifier"


enum ConsentStatus:String{
    case pending = "pending"
    case completed = "completed"
}




//MARK:ConsentBuilder Class

class ConsentBuilder{
    
    
    //var consentIdentifier:String? // this id will be used to add to signature
    
    var consentSectionArray:[ORKConsentSection]
    var consentStepArray:[ORKStep]
    
    var reviewConsent:ReviewConsent?
    var sharingConsent:SharingConsent?
    
    var consentDocument:ORKConsentDocument?
    var version:String?
    var consentStatus:ConsentStatus?
    var consentHasVisualStep:Bool?
    static var currentConsent: ConsentBuilder? = nil
    
    var consentResult:ConsentResult?
    
    init() {
        /* Default Initializer method
         by default sets all params to empty values
         */
        
        self.consentSectionArray = []
        
        self.consentStepArray = []
        self.reviewConsent = ReviewConsent()
        self.sharingConsent = SharingConsent()
        self.consentResult = ConsentResult()
        self.consentDocument = ORKConsentDocument()
        self.version = ""
        self.consentHasVisualStep = false
        
    }
    
    func initWithMetaData(metaDataDict:Dictionary<String, Any>)  {
        /* initializer method which initializes all params
         @metaDataDict:contains as Dictionaries for all the properties of Consent Step
         */
        
        self.consentStatus = .pending
         self.consentHasVisualStep = false
        
        if Utilities.isValidObject(someObject: metaDataDict as AnyObject?){
            
            if Utilities.isValidValue(someObject: metaDataDict[kConsentVersion] as AnyObject?){
                
                self.version =  metaDataDict[kConsentVersion] as! String?
            }
            else{
                self.version = "No_Version"
            }
            let visualConsentArray = metaDataDict[kConsentVisualScreens] as! Array<Dictionary<String,Any>>
            
            if  Utilities.isValidObject(someObject: visualConsentArray as AnyObject?){
                for sectionDict in visualConsentArray{
                    
                    let consentSection:ConsentSectionStep? = ConsentSectionStep()
                    consentSection?.initWithDict(stepDict: sectionDict)
                         consentSectionArray.append((consentSection?.createConsentSection())!)
                    
                    if consentSection?.type != .custom{
                        self.consentHasVisualStep = true
                    }
                    
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
    
    func getVisualConsentStep() -> VisualConsentStep? {
        /* Method to get VisualConsentStep
         @returns an instance of ORKVisualConsentStep
         */
        
        if self.consentSectionArray.count > 0 {
        let visualConsentStep = VisualConsentStep(identifier: "visual", document: self.getConsentDocument())
        return visualConsentStep
        }
        else{
            return nil
        }
    }
    
    
    func getConsentDocument() -> ORKConsentDocument {
        
        if self.consentDocument != nil && Utilities.isValidObject(someObject: self.consentDocument?.sections as AnyObject?)   {
            return self.consentDocument!
        }
        else{
            //self.consentDocument = ORKConsentDocument()
            self.consentDocument = self.createConsentDocument()
            return self.consentDocument!
        }
        
        
    }
    
    
    func createConsentDocument() -> ORKConsentDocument? {
        /* Method to create ConsentDocument
         @returns a ORKConsentDocument for VisualConsentStep and Review Step
         */
        
        
        let consentDocument = ORKConsentDocument()
        
        if Utilities.isValidValue(someObject: "title" as AnyObject )
            && Utilities.isValidValue(someObject: "signaturePageTitle" as AnyObject )
            && Utilities.isValidValue(someObject: "signaturePageContent" as AnyObject ){
            
            
            
            consentDocument.title = Study.currentStudy?.name
            consentDocument.signaturePageTitle = "Participant"
            consentDocument.signaturePageContent = "signaturePageContent"
            
            consentDocument.sections = [ORKConsentSection]()
            
            if self.consentSectionArray.count > 0 {
               consentDocument.sections?.append(contentsOf: self.consentSectionArray)
            }
            
            // consentDocument.sections? = self.consentSectionArray
            
//            let user = User.currentUser
//            let signatureImage = UIImage(named: "Bomb.png")!
//            
//            let investigatorSignatureTitle = NSLocalizedString(user.getFullName(), comment: "")
//            let investigatorSignatureGivenName = NSLocalizedString(user.firstName!, comment: "")
//            let investigatorSignatureFamilyName = NSLocalizedString(user.lastName!, comment: "")
//            let investigatorSignatureDateString = Utilities.getStringFromDate(date: Date.init(timeIntervalSinceNow: 0))
            
//            let investigatorSignature = ORKConsentSignature(forPersonWithTitle: investigatorSignatureTitle, dateFormatString: nil, identifier:"Signature", givenName: investigatorSignatureGivenName, familyName: investigatorSignatureFamilyName, signatureImage: signatureImage, dateString: investigatorSignatureDateString)
            
            let investigatorSignature = ORKConsentSignature(forPersonWithTitle:"Participant", dateFormatString: "MM/dd/YYYY", identifier: "Signature")
            
            consentDocument.addSignature(investigatorSignature)
            
            return consentDocument
            
        }
        else{
            
            Logger.sharedInstance.debug("consent Step has null values:")
            return nil
        }
        
    }
    
    
    func getReviewConsentStep() -> ConsentReviewStep? {
        /* Method to get ReviewConsentStep
         @returns an instance of ORKConsentReviewStep
         */
        
        let reviewConsentStep:ConsentReviewStep?

        if  Utilities.isValidValue(someObject: self.reviewConsent?.signatureContent as AnyObject ){
            
            // identifier missing
            
            let consentDocument:ORKConsentDocument? = (self.getConsentDocument() as ORKConsentDocument)
            consentDocument?.htmlReviewContent = self.reviewConsent?.signatureContent
            
            consentDocument?.signaturePageContent = NSLocalizedString("I agree to participate in this research study.", comment: "")
            
            
             reviewConsentStep = ConsentReviewStep(identifier: "Review", signature: (self.getConsentDocument() as ORKConsentDocument).signatures?[0], in: self.getConsentDocument())
            
          
            
        }
        else{
            
            let consentDocument:ORKConsentDocument? = (self.getConsentDocument() as ORKConsentDocument)
            
            consentDocument?.signaturePageContent = NSLocalizedString("I agree to participate in this research study.", comment: "") 

            
            
             reviewConsentStep = ConsentReviewStep(identifier: "Review", signature: consentDocument?.signatures?[0], in: consentDocument!)
            
        }
        
        if Utilities.isValidValue(someObject: self.reviewConsent?.signatureTitle as AnyObject ) {
            reviewConsentStep?.text = self.reviewConsent?.title
        } else {
            reviewConsentStep?.text = ""
        }
        
        if Utilities.isValidValue(someObject: self.reviewConsent?.reasonForConsent as AnyObject ) {
            reviewConsentStep?.reasonForConsent = self.reviewConsent?.reasonForConsent
        } else {
            reviewConsentStep?.reasonForConsent = ""
        }
        
        return reviewConsentStep
        
    }
    
    
    func getConsentSharingStep() -> ConsentSharingStep? {
        /* Method to get ConsentSharingStep
         @returns an instance of ORKConsentSharingStep
         */
        
        if Utilities.isValidValue(someObject: self.sharingConsent?.shortDesc as AnyObject )
            && Utilities.isValidValue(someObject: self.sharingConsent?.longDesc as AnyObject )
            && Utilities.isValidValue(someObject: self.sharingConsent?.learnMore as AnyObject ){
            
            
            // identifier missing
            
            let sharingConsentStep = ConsentSharingStep(identifier: "Sharing", investigatorShortDescription: (self.sharingConsent?.shortDesc)!, investigatorLongDescription: (self.sharingConsent?.longDesc)!, localizedLearnMoreHTMLContent: (self.sharingConsent?.learnMore)!)
            
            return sharingConsentStep
            
        }
        else{
            
            Logger.sharedInstance.debug("consent Step has null values:")
            return nil
        }
        
    }
    
    
    func createConsentTask() -> ORKTask? {
        /* Method to get ORKTask i.e ConsentTask
         @returns an instance of ORKTask
         */
        let visualConsentStep:VisualConsentStep? = self.getVisualConsentStep()
        let sharingConsentStep:ConsentSharingStep? = self.getConsentSharingStep()
        let reviewConsentStep:ConsentReviewStep? = self.getReviewConsentStep()
                
        var stepArray:Array<ORKStep>? = Array()
        
        if visualConsentStep != nil{
            
            if  self.consentHasVisualStep! {
                stepArray?.append(visualConsentStep!)
            }
            else{
                // it means all steps are custom only included in documents
            }
            
        }
        if sharingConsentStep != nil{
            stepArray?.append(sharingConsentStep!)
        }
        if reviewConsentStep != nil{
            stepArray?.append(reviewConsentStep!)
        }
        
        
        
       // kConsentViewPdfCompletionStep
        
        let consentCompletionStep = ConsentCompletionStep(identifier: kConsentSharePdfCompletionStep)
        
       
        
        consentCompletionStep.mainTitle = "Thanks for providing consent for this Study"
        consentCompletionStep.subTitle =  "You can now start participating in the Study"
        
        let consentViewPdfStep = ConsentPdfViewerStep(identifier:kConsentViewPdfCompletionStep )
        

        let completionStep = CustomCompletionStep(identifier:kConsentCompletionStepIdentifier)
        completionStep.title = NSLocalizedString("Thanks for providing consent for this Study", comment: "")
        
        
        if (stepArray?.count)! > 0 {
            
             stepArray?.append(consentCompletionStep)
             stepArray?.append(consentViewPdfStep)
            
            stepArray?.append(completionStep)
            
            
            let task = ORKNavigableOrderedTask(identifier: "ConsentTask", steps: stepArray)
            
            return task
            
            //return ORKOrderedTask(identifier: "ConsentTask", steps: stepArray)
        }
        else{
            return nil
        }
        
    }
    
    
}


//MARK:SharingConsent Struct

struct SharingConsent {
    
    var shortDesc:String?
    var longDesc:String?
    var learnMore:String?
    var allowWithoutSharing:Bool?
    var text:String?
    var title:String?
    
    init() {
        self.shortDesc = ""
        self.longDesc =  ""
        self.learnMore =  ""
        self.allowWithoutSharing =  false
        self.text = ""
        self.title = ""
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
            
            if Utilities.isValidValue(someObject: dict[kConsentSharingStepText] as AnyObject ){
                self.text = dict[kConsentSharingStepText] as? String
            }
            if Utilities.isValidValue(someObject: dict[kConsentSharingStepTitle] as AnyObject ){
                self.title = dict[kConsentSharingStepTitle] as? String
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
    var reasonForConsent:String?
    
    init() {
        self.title = ""
        self.signatureTitle =  ""
        self.signatureContent =  ""
        self.reasonForConsent = ""
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
            if Utilities.isValidValue(someObject: dict[kConsentReviewStepReasonForConsent] as AnyObject ){
                self.reasonForConsent = dict[kConsentReviewStepReasonForConsent] as? String
            }
        }
        else{
            Logger.sharedInstance.debug("ConsentDocument Step Dictionary is null:\(dict)")
        }
        
    }
}

class ConsentReviewStep:ORKConsentReviewStep {
    
   /* func showsProgress() -> Bool {
        return true
    }
    */
}

class VisualConsentStep:ORKVisualConsentStep {
    
   /* func showsProgress() -> Bool {
        return true
    }
    */
}

class ConsentSharingStep:ORKConsentSharingStep {
    
   /* func showsProgress() -> Bool {
        return true
    }
   */
}

class CustomCompletionStep:ORKCompletionStep {
    
    func showsProgress() -> Bool {
     return true
     }
    
}


