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
import PDFKit

class ConsentResult {
    
    var startTime: Date?
    var endTime: Date?
    
    var consentId: String?
    var consentDocument: ORKConsentDocument?
    var consentPdfData: Data?
    var result: Array<ActivityStepResult>?
    
    /// A boolean indicating user allows their data to be shared publically.
    var isShareDataWithPublic: Bool?
    
    var token: String?
    var consentPath: String?
    
    // MARK: Initializers
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
    func initWithORKTaskResult(taskResult: ORKTaskResult) {
        for stepResult in taskResult.results! {
            
            if   ((stepResult as? ORKStepResult)!.results?.count)! > 0 {
                
                if stepResult.identifier == kConsentSharing,
                    let stepResult = stepResult as? ORKStepResult,
                    let sharingChoiceResult = stepResult.results?.first as? ORKChoiceQuestionResult?,
                    let userResponse = sharingChoiceResult?.choiceAnswers?.first as? Bool {
                    self.isShareDataWithPublic = userResponse
                } else if let signatureStepResult = (stepResult as? ORKStepResult)!
                    .results?[0] as? ORKConsentSignatureResult? {
                    
                    signatureStepResult?.apply(to: self.consentDocument!)
                    
                    if self.consentPdfData?.count == 0 {
                        self.consentPath = "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + ".pdf"
                        
                        var secondFullPath = ""
                        var thirdFullPath = ""
                        var fullPath: String!
                        self.consentDocument?.makePDF(completionHandler: { data,error in
                            print("data: \(String(describing: data))    \n  error: \(String(describing: error))")
                            
                            
                            let path =  AKUtility.baseFilePath + "/study"
                            let fileName: String = "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + ".pdf"
                            
                            self.consentPath = fileName
                            
                            fullPath = path + "/" + fileName
                            
                            if !FileManager.default.fileExists(atPath: path) {
                                try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                            }
                            
                            self.consentPdfData = Data()
                            self.consentPdfData = data
                            self.consentPath = fileName
                            
                            let fileNameLAR: String = "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + "LAR" + ".pdf"
                            
                            secondFullPath = path + "/" + "second.pdf"
                            thirdFullPath = path + "/" + fileNameLAR
                            
                            do {
                                
                                if FileManager.default.fileExists(atPath: fullPath){
                                    try FileManager.default.removeItem(atPath: fullPath)
                                }
                                if FileManager.default.fileExists(atPath: secondFullPath){
                                    try FileManager.default.removeItem(atPath: secondFullPath)
                                }
                                if FileManager.default.fileExists(atPath: thirdFullPath){
                                    try FileManager.default.removeItem(atPath: thirdFullPath)
                                }
                                FileManager.default.createFile(atPath:fullPath , contents: data, attributes: [:])
                                
                                let defaultPath = fullPath
                                fullPath = "file://" + "\(fullPath!)"
                                try data?.write(to:  URL(string:fullPath!)!)
                                
                                if !consentHasLAR { //consentHasLAR {
                                    FileDownloadManager.encyptFile(pathURL: URL(string: defaultPath!)!)
                                    let notificationName = Notification.Name(kPDFCreationNotificationId)
                                    // Post notification
                                    NotificationCenter.default.post(name: notificationName, object: nil)
                                }
                                
                            } catch let error as NSError {
                                print(error.localizedDescription)
                            }
                            
                            
                            if consentHasLAR {
                                let participantFormStepResult = taskResult.stepResult(forStepIdentifier: kLARConsentParticipantStep)
                                let participantRelation = (participantFormStepResult?.result(forIdentifier: kLARConsentParticipantRelationItem) as! ORKTextQuestionResult).textAnswer ?? ""
                                let participantFirstName = (participantFormStepResult?.result(forIdentifier: kLARConsentParticipantFirstName) as! ORKTextQuestionResult).textAnswer ?? ""
                                let participantLastName = (participantFormStepResult?.result(forIdentifier: kLARConsentParticipantLastName) as! ORKTextQuestionResult).textAnswer ?? ""
                                
                                print("participantFirstName---\(participantFirstName)")
                                
                                let title = "Consent by a Legally Authorized Representative"
                                let body = "I am signing the consent document on behalf of the participant, as a legally-authorized representative of the participant."
                                let image = signatureStepResult?.signature?.signatureImage ?? UIImage() // UIImage()
                                let firstName = signatureStepResult?.signature?.givenName ?? ""
                                let lastName = signatureStepResult?.signature?.familyName ?? ""
                                var startDate = "\(self.startTime ?? Date())"
                                
                                let inputFormatter = DateFormatter()
                                inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                                let showDate = inputFormatter.date(from: startDate)
                                inputFormatter.dateFormat = "dd/MM/yyyy"
                                startDate = inputFormatter.string(from: showDate!)
                                
                                let pdfCreator = PDFCreator(title: title, body: body, image: image, relation: participantRelation, participantFirstName: participantFirstName, participantLastName: participantLastName, startTime: startDate, firstName: firstName, lastName: lastName)
                                let pdfData = pdfCreator.createFlyer()
                                
                                do {
                                    
                                    if FileManager.default.fileExists(atPath: secondFullPath){
                                        try FileManager.default.removeItem(atPath: secondFullPath)
                                    }
                                    FileManager.default.createFile(atPath:secondFullPath , contents: pdfData, attributes: [:])
                                    
                                    let defaultPath = secondFullPath
                                    secondFullPath = "file://" + "\(secondFullPath)"
                                    print("2fullPath---\(secondFullPath)")
                                    try pdfData.write(to:  URL(string:secondFullPath)!)
                                    //                                FileDownloadManager.encyptFile(pathURL: URL(string: thirdFullPath)!)
                                    
                                    
                                    let initialPDFReturned =  self.mergePdfFiles(sourcePdfFiles: [fullPath,secondFullPath], destPdfFile: thirdFullPath)
                                    
                                    if initialPDFReturned {
                                        do {
                                            if FileManager.default.fileExists(atPath: secondFullPath) {
                                                try FileManager.default.removeItem(atPath: secondFullPath)
                                            }
                                        } catch {
                                            
                                        }
                                        
                                        let data1 = try Data(contentsOf: URL(string: secondFullPath)!)
                                        
                                        //                                let pdfDoc = PDFDocument(url: URL(string: thirdFullPath)!)!
                                        self.consentPdfData = data1//pdfDoc.dataRepresentation()
                                        
                                        self.consentPath = fileNameLAR
                                        let notificationName = Notification.Name(kPDFCreationNotificationId)
                                        // Post notification
                                        NotificationCenter.default.post(name: notificationName, object: nil)
                                        
                                    }
                                }
                                catch let error as NSError {
                                    print(error.localizedDescription)
                                }
                            }
                            
                        })
                    } else {
                        
                        var fullPath: String!
                        let path =  AKUtility.baseFilePath + "/study"
                        let fileName: String = "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + ".pdf"
                        
                        self.consentPath = fileName
                        
                        fullPath = path + "/" + fileName
                        
                        if !FileManager.default.fileExists(atPath: path) {
                            try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                        }
                        
                        var data: Data? = Data.init()
                        data = self.consentPdfData
                        self.consentPath = fileName
                        
                        do {
                            
                            if FileManager.default.fileExists(atPath: fullPath) {
                                try FileManager.default.removeItem(atPath: fullPath)
                            }
                            FileManager.default.createFile(atPath:fullPath , contents: data, attributes: [:])
                            fullPath = "file://" + "\(fullPath!)"
                            
                            try data?.write(to:  URL(string: fullPath!)!)
                            FileDownloadManager.encyptFile(pathURL: URL(string: fullPath!)!)
                            
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }
                } else if let tokenStepResult: EligibilityTokenTaskResult? = (stepResult as? ORKStepResult)!.results?[0] as? EligibilityTokenTaskResult? {
                    self.token = tokenStepResult?.enrollmentToken
                }
            }
        }
    }
    
    func setConsentDocument(consentDocument: ORKConsentDocument)  {
        self.consentDocument = consentDocument;
    }
    
    func getConsentDocument() -> ORKConsentDocument {
        return self.consentDocument!
    }
    
    func initWithDict(activityDict: Dictionary<String, Any>){
        
        // setter method with Dictionary
        
        //Here the dictionary is assumed to have only type,startTime,endTime
        if Utilities.isValidObject(someObject: activityDict as AnyObject?){
            
            if Utilities.isValidValue(someObject: activityDict[kActivityStartTime] as AnyObject ) {
                
                if Utilities.isValidValue(someObject: Utilities.getDateFromString(dateString:(activityDict[kActivityStartTime] as? String)!) as AnyObject?) {
                    self.startTime =  Utilities.getDateFromString(dateString: (activityDict[kActivityStartTime] as? String)!)
                } else {
                    Logger.sharedInstance.debug("Date Conversion is null:\(activityDict)")
                }
            }
            if Utilities.isValidValue(someObject: activityDict[kActivityEndTime] as AnyObject ) {
                
                if Utilities.isValidValue(someObject: Utilities.getDateFromString(dateString:(activityDict[kActivityEndTime] as? String)!) as AnyObject?) {
                    self.endTime =  Utilities.getDateFromString(dateString: (activityDict[kActivityEndTime] as? String)!)
                } else {
                    Logger.sharedInstance.debug("Date Conversion is null:\(activityDict)")
                }
            }
        } else {
            Logger.sharedInstance.debug("activityDict Result Dictionary is null:\(activityDict)")
        }
    }
    
    
    // MARK: Setter & getter methods for ActivityResult
    func setActivityResult(activityStepResult: ActivityStepResult)  {
        self.result?.append(activityStepResult)
    }
    
    func getActivityResult() -> [ActivityStepResult] {
        return self.result!
    }
    
    func getResultDictionary() -> Dictionary<String,Any>? {
        
        // method to get the dictionary for Api
        var activityDict: Dictionary<String,Any>?
        
        if self.startTime != nil && (Utilities.getStringFromDate(date: self.startTime!) != nil){
            
            activityDict?[kActivityStartTime] = Utilities.getStringFromDate(date: self.startTime!)
        }
        if self.endTime != nil && (Utilities.getStringFromDate(date: self.endTime!) != nil){
            
            activityDict?[kActivityEndTime] = Utilities.getStringFromDate(date: self.endTime!)
        }
        
        if Utilities.isValidObject(someObject: result as AnyObject?) {
            
            var activityResultArray: Array<Dictionary<String,Any>> =  Array<Dictionary<String,Any>>()
            for stepResult  in result! {
                let activityStepResult = stepResult as ActivityStepResult
                activityResultArray.append( (activityStepResult.getActivityStepResultDict())! as Dictionary<String,Any>)
            }
            
            activityDict?[kActivityResult] = activityResultArray
        }
        
        return activityDict!
    }
    
    func mergePdfFiles(sourcePdfFiles:[String], destPdfFile:String) -> Bool {
        let pdfDoc3 = PDFDocument()
        let pdfDoc1 = PDFDocument(url: URL(string: sourcePdfFiles[0])!)!
        let page1 = pdfDoc1.page(at: 0)!
        
        let pdfDoc2 = PDFDocument(url: URL(string: sourcePdfFiles[1])!)!
        let page2 = pdfDoc2.page(at: 0)!
//        pdfDoc1.removePage(at: 1)
//        pdfDoc1.insert(page2, at: 1)
        
        pdfDoc3.insert(page1, at: 0)
        pdfDoc3.insert(page2, at: 1)
        
        
        
//        let valData = pdfDoc1.dataRepresentation()
        pdfDoc3.write(toFile: destPdfFile)
        let data = pdfDoc3.dataRepresentation()
        
        let cgDoc = pdfDoc3.documentRef
        
        
//        do {
//        try data?.write(to:  URL(string:destPdfFile)!)
//        }
//        catch {
//
//        }
        
        return true
    }
}
