//
//  ConsentResult.swift
//  FDA
//
//  Created by Arun Kumar on 2/27/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit

class ConsentResult {
    
    var startTime:Date?
    var endTime:Date?
    
    var consentId:String?
    var consentDocument:ORKConsentDocument?
    var consentPdfData:Data?
    var result:Array<ActivityStepResult>?
    
    var token:String?
    var consentPath:String?
    
    //MARK: Initializers
    init() {
        
        self.startTime = Date()
        self.endTime = Date()
        
        self.result = Array()
        
        self.consentDocument = ORKConsentDocument()
        self.consentPdfData = Data()
        self.token = ""
    }
    /**
     initializer method creates consent result for genrating PDF and saving to server
     @param taskResult: is instance of ORKTaskResult and holds the step results
    */
    func initWithORKTaskResult(taskResult:ORKTaskResult) {
        for stepResult in taskResult.results! {
            
            if   ((stepResult as! ORKStepResult).results?.count)! > 0 {
                
                if  let questionstepResult:ORKChoiceQuestionResult? = (stepResult as! ORKStepResult).results?[0] as? ORKChoiceQuestionResult? {
                    
                    if Utilities.isValidValue(someObject: questionstepResult?.choiceAnswers?[0] as AnyObject?){
                        /* sharing choice result either 1 selected or 2 seleceted
                         */
                        
                    } else{
                        //Do Nothing
                    }
                } else if let signatureStepResult:ORKConsentSignatureResult? = (stepResult as! ORKStepResult).results?[0] as? ORKConsentSignatureResult? {
                    
                    signatureStepResult?.apply(to: self.consentDocument!)
                    
                    if self.consentPdfData?.count == 0 {
                    self.consentPath = "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + ".pdf"
        
                    self.consentDocument?.makePDF(completionHandler: { data,error in
                        print("data: \(String(describing: data))    \n  error: \(String(describing: error))")
                        
                        var fullPath:String!
                        let path =  AKUtility.baseFilePath + "/study"
                        let fileName:String = "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + ".pdf"
                        
                        self.consentPath = fileName
                        
                        fullPath = path + "/" + fileName
                        
                        if !FileManager.default.fileExists(atPath: path) {
                            try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                        }
                        
                        self.consentPdfData = Data()
                        self.consentPdfData = data
                        self.consentPath = fileName
                        
                        do {
                            
                            if FileManager.default.fileExists(atPath: fullPath){
                                try FileManager.default.removeItem(atPath: fullPath)
                            }
                            FileManager.default.createFile(atPath:fullPath , contents: data, attributes: [:])
                            
                            let defaultPath = fullPath
                            fullPath = "file://" + "\(fullPath!)"
                            
                            try data?.write(to:  URL(string:fullPath!)!)
                            FileDownloadManager.encyptFile(pathURL: URL(string:defaultPath!)!)
                            
                            let notificationName = Notification.Name(kPDFCreationNotificationId)
                            // Post notification
                            NotificationCenter.default.post(name: notificationName, object: nil)
                            
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    })
                    }
                    else{
                       
                        var fullPath:String!
                        let path =  AKUtility.baseFilePath + "/study"
                        let fileName:String = "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + ".pdf"
                        
                        self.consentPath = fileName
                        
                        fullPath = path + "/" + fileName
                        
                        if !FileManager.default.fileExists(atPath: path) {
                            try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                        }
                        
                        var data:Data? = Data.init()
                        data = self.consentPdfData
                        self.consentPath = fileName
                        
                        do {
                            
                            if FileManager.default.fileExists(atPath: fullPath) {
                                try FileManager.default.removeItem(atPath: fullPath)
                            }
                            FileManager.default.createFile(atPath:fullPath , contents: data, attributes: [:])
                            fullPath = "file://" + "\(fullPath!)"
                            
                            try data?.write(to:  URL(string:fullPath!)!)
                            FileDownloadManager.encyptFile(pathURL: URL(string:fullPath!)!)
                            
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }
                }
                else if let tokenStepResult:EligibilityTokenTaskResult? = (stepResult as! ORKStepResult).results?[0] as? EligibilityTokenTaskResult?{
                    self.token = tokenStepResult?.enrollmentToken
                }
            }
        }
    }
    
    func setConsentDocument(consentDocument:ORKConsentDocument)  {
        self.consentDocument = consentDocument;
    }
    
    func getConsentDocument() -> ORKConsentDocument {
        return self.consentDocument!
    }
    
    func initWithDict(activityDict:Dictionary<String, Any>){
        
        // setter method with Dictionary
        
        //Here the dictionary is assumed to have only type,startTime,endTime
        if Utilities.isValidObject(someObject: activityDict as AnyObject?){
            
            if Utilities.isValidValue(someObject: activityDict[kActivityStartTime] as AnyObject ) {
                
                if Utilities.isValidValue(someObject: Utilities.getDateFromString(dateString:(activityDict[kActivityStartTime] as? String)!) as AnyObject?) {
                    self.startTime =  Utilities.getDateFromString(dateString:(activityDict[kActivityStartTime] as? String)!)
                }
                else{
                    Logger.sharedInstance.debug("Date Conversion is null:\(activityDict)")
                }
            }
            if Utilities.isValidValue(someObject: activityDict[kActivityEndTime] as AnyObject ){
                
                if Utilities.isValidValue(someObject: Utilities.getDateFromString(dateString:(activityDict[kActivityEndTime] as? String)!) as AnyObject?) {
                    self.endTime =  Utilities.getDateFromString(dateString:(activityDict[kActivityEndTime] as? String)!)
                }
                else{
                    Logger.sharedInstance.debug("Date Conversion is null:\(activityDict)")
                }
            }
        }
        else{
            Logger.sharedInstance.debug("activityDict Result Dictionary is null:\(activityDict)")
        }
    }
    
    
    //MARK: Setter & getter methods for ActivityResult
    func setActivityResult(activityStepResult:ActivityStepResult)  {
        self.result?.append(activityStepResult)
    }
    
    func getActivityResult() -> [ActivityStepResult] {
        return self.result!
    }
    
    func getResultDictionary() -> Dictionary<String,Any>? {
        
        // method to get the dictionary for Api
        var activityDict:Dictionary<String,Any>?
        
        if self.startTime != nil && (Utilities.getStringFromDate(date: self.startTime!) != nil){
            
            activityDict?[kActivityStartTime] = Utilities.getStringFromDate(date: self.startTime!)
        }
        if self.endTime != nil && (Utilities.getStringFromDate(date: self.endTime!) != nil){
            
            activityDict?[kActivityEndTime] = Utilities.getStringFromDate(date: self.endTime!)
        }
        
        if Utilities.isValidObject(someObject: result as AnyObject?) {
            
            var activityResultArray :Array<Dictionary<String,Any>> =  Array<Dictionary<String,Any>>()
            for stepResult  in result! {
                let activityStepResult = stepResult as ActivityStepResult
                activityResultArray.append( (activityStepResult.getActivityStepResultDict())! as Dictionary<String,Any>)
            }
            
            activityDict?[kActivityResult] = activityResultArray
        }
        
        return activityDict!
    }
}
