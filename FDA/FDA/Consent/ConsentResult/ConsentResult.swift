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
    //MARK: Initializers
    init() {
       
        self.startTime = Date()
        self.endTime = Date()
        
        self.result = Array()
        
        self.consentDocument = ORKConsentDocument()
        self.consentPdfData = Data()
    }
    
    func initWithORKTaskResult(taskResult:ORKTaskResult) {
        for stepResult in taskResult.results!{
            
            if   ((stepResult as! ORKStepResult).results?.count)! > 0{
                
                if  let questionstepResult:ORKChoiceQuestionResult? = (stepResult as! ORKStepResult).results?[0] as? ORKChoiceQuestionResult?{
                  
                        if Utilities.isValidValue(someObject: questionstepResult?.choiceAnswers?[0] as AnyObject?){
                            /* sharing choice result either 1 selected or 2 seleceted
                            */

                            
                            
                        }
                        else{
                         
                        }
            }
                else if let signatureStepResult:ORKConsentSignatureResult? = (stepResult as! ORKStepResult).results?[0] as? ORKConsentSignatureResult?{
                    
                    signatureStepResult?.apply(to: self.consentDocument!)
                    
                    self.consentDocument?.makePDF(completionHandler: { data,error in
                        NSLog("data: \(data)    \n  error: \(error)")
                        
                        let dir = FileManager.getStorageDirectory(type: .study)
                        
                        let fullPath =  dir + "/" + "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + ".pdf"
                    
                        self.consentPdfData = Data()
                        self.consentPdfData = data?.base64EncodedData()
                        
                        
                        do {
                            
                            if FileManager.default.fileExists(atPath: fullPath){
                                
                               try FileManager.default.removeItem(atPath: fullPath)
                                
                            }
                            FileManager.default.createFile(atPath:fullPath , contents: data, attributes: [:])
                            
                            try data?.write(to: URL(string:fullPath)! , options: .noFileProtection)
                            
                            // writing to disk
                        
                            } catch let error as NSError {
                                print("error writing to url \(fullPath)")
                                print(error.localizedDescription)
                            }
                    })
                    
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
