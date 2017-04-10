//
//  Study.swift
//  FDA
//
//  Created by Surender Rathore on 2/14/17.
//  Copyright © 2017 BTC. All rights reserved.
//


import Foundation

let kConsentDocumentType = "type"
let kConsentDocumentVersion = "version"
let kConsentDocumentContent = "content"

enum StudyStatus:String{
    case active
    case upcoming
    case closed
    case paused
}

struct ConsentDocument {
    
    var htmlString:String?
    var mimeType:MimeType?
    var version:String?
    
    mutating func initialize(){
        self.mimeType = .html
        self.htmlString = ""
        self.version = ""
    }
    
    mutating func initData(consentDoucumentdict:Dictionary<String,Any>){
        if Utilities.isValidObject(someObject: consentDoucumentdict as AnyObject?){
            
            if Utilities.isValidValue(someObject: consentDoucumentdict[kConsentDocumentType] as AnyObject ){
                self.mimeType = MimeType(rawValue:consentDoucumentdict[kConsentDocumentType] as! String)
            }
            
            if Utilities.isValidValue(someObject: consentDoucumentdict[kConsentDocumentContent] as AnyObject ){
                self.htmlString = consentDoucumentdict[kConsentDocumentContent] as? String
            }
            
            if Utilities.isValidValue(someObject: consentDoucumentdict[kConsentDocumentVersion] as AnyObject ){
                self.version = consentDoucumentdict[kConsentDocumentVersion] as? String
            }
        }
        else{
            Logger.sharedInstance.debug("Study Dictionary is null:\(consentDoucumentdict)")
        }
    }
    
}

class Study {
    
    //MARK:Properties
    var studyId:String!
    var name:String?
    var version:String?
    var identifer:String?
    var category:String?
    var startDate:String?
    var endEnd:String?
    var status:StudyStatus = .active
    var sponserName:String?
    var description:String?
    var brandingConfiguration:String?
    var logoURL:String?
    var overview:Overview!
    var activities:Array<Activity>!
    var resources:Array<Resource>? = []
    var userParticipateState:UserStudyStatus! = nil
    
    var consentDocument:ConsentDocument?
    
    static var currentStudy:Study? = nil
    
    init() {
        
    }
    
    init(studyDetail:Dictionary<String,Any>) {
        
        if Utilities.isValidObject(someObject: studyDetail as AnyObject?){
            
            if Utilities.isValidValue(someObject: studyDetail[kStudyId] as AnyObject ){
                self.studyId = studyDetail[kStudyId] as? String
            }
            
            if Utilities.isValidValue(someObject: studyDetail[kStudyTitle] as AnyObject ){
                self.name = studyDetail[kStudyTitle] as? String
            }
            
            if Utilities.isValidValue(someObject: studyDetail[kStudyCategory] as AnyObject ){
                self.category = studyDetail[kStudyCategory] as? String
            }
            if Utilities.isValidValue(someObject: studyDetail[kStudySponserName] as AnyObject ){
                self.sponserName = studyDetail[kStudySponserName] as? String
            }
            if Utilities.isValidValue(someObject: studyDetail[kStudyTagLine] as AnyObject ){
                self.description = studyDetail[kStudyTagLine] as? String
            }
            if Utilities.isValidValue(someObject: studyDetail[kStudyLogoURL] as AnyObject ) {
                self.logoURL = studyDetail[kStudyLogoURL] as? String
            }
            if Utilities.isValidValue(someObject: studyDetail[kStudyStatus] as AnyObject )  {
                self.status = .active //StudyStatus.init(rawValue: studyDetail[kStudyStatus] as! String)!
            }
            
        }
        else{
            Logger.sharedInstance.debug("Study Dictionary is null:\(studyDetail)")
        }
        
    }
    
    
    
    
    class  func updateCurrentStudy(study:Study){
        Study.currentStudy = study
    }
    
    
    
}
