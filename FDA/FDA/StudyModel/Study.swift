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
    case Active
    case Upcoming
    case Closed
    case Paused
    
    var sortIndex : Int {
        switch self {
        case .Active:
            return 0
        case .Upcoming:
            return 1
        case .Paused:
            return 2
        case .Closed:
            return 3
        
        }
    }
}

struct ConsentDocument {
    
    var htmlString:String?
    var mimeType:MimeType?
    var version:String?
    
    mutating func initialize(){
        self.mimeType = .html
        self.htmlString = ""
        self.version = "No_Version"
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
    var newVersion:String?
    var identifer:String?
    var category:String?
    var startDate:String?
    var endEnd:String?
    var status:StudyStatus = .Active
    var sponserName:String?
    var description:String?
    var brandingConfiguration:String?
    var logoURL:String?
    var overview:Overview!
    var activities:Array<Activity>! = []
    var resources:Array<Resource>? = []
    var userParticipateState:UserStudyStatus! = nil
    var studySettings:StudySettings!
    var consentDocument:ConsentDocument?
    var signedConsentVersion:String?
    var signedConsentFilePath:String?
    
    static var currentStudy:Study? = nil
    static var currentActivity:Activity? = nil
    
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
            if Utilities.isValidValue(someObject: studyDetail[kStudyVersion] as AnyObject ){
                self.version = studyDetail[kStudyVersion] as? String
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
                self.status = StudyStatus.init(rawValue: studyDetail[kStudyStatus] as! String)!
            }
            if Utilities.isValidObject(someObject: studyDetail[kStudySettings] as AnyObject )  {
                self.studySettings = StudySettings(settings: studyDetail[kStudySettings] as! Dictionary<String, Any>)
            }
            let currentUser = User.currentUser
            if let userStudyStatus = currentUser.participatedStudies.filter({$0.studyId == self.studyId}).last{
                self.userParticipateState = userStudyStatus
            }
            else {
                self.userParticipateState = UserStudyStatus()
            }
        }
        else{
            Logger.sharedInstance.debug("Study Dictionary is null:\(studyDetail)")
        }
        
    }
    
    
    class func updateCurrentActivity(activity:Activity){
        Study.currentActivity = activity
    }
    
    class  func updateCurrentStudy(study:Study){
        Study.currentStudy = study
    }
    
    
    
}

class StudySettings{
    
    var enrollingAllowed = true
    var rejoinStudyAfterWithdrawn = false
    var platform = "ios"
    
    init() {
        
    }
    
    init(settings:Dictionary<String,Any>) {
        
        if Utilities.isValidObject(someObject: settings as AnyObject?){
            
            if Utilities.isValidValue(someObject: settings[kStudyEnrolling] as AnyObject ){
                self.enrollingAllowed = (settings[kStudyEnrolling] as? Bool)!
            }
            
            if Utilities.isValidValue(someObject: settings[kStudyRejoin] as AnyObject ){
                self.rejoinStudyAfterWithdrawn = (settings[kStudyRejoin] as? Bool)!
            }
            
            if Utilities.isValidValue(someObject: settings[kStudyPlatform] as AnyObject ){
                self.platform = (settings[kStudyPlatform] as? String)!
            }
        }
    }
}

struct StudyUpdates{
    
   static  var studyInfoUpdated = false
   static  var studyConsentUpdated = false
   static  var studyActivitiesUpdated = false
   static  var studyResourcesUpdated = false
    static  var studyVersion:String = ""
    
    init(detail:Dictionary<String,Any>){
        
        if Utilities.isValidObject(someObject: detail[kStudyUpdates] as AnyObject?){
            
            let updates =  detail[kStudyUpdates] as! Dictionary<String,Any>
            
            if Utilities.isValidValue(someObject: updates[kStudyResources] as AnyObject ){
                StudyUpdates.studyResourcesUpdated = (updates[kStudyResources] as? Bool)!
            }
            if Utilities.isValidValue(someObject: updates[kStudyInfo] as AnyObject ){
                StudyUpdates.studyInfoUpdated = (updates[kStudyInfo] as? Bool)!
            }
            if Utilities.isValidValue(someObject: updates[kStudyConsent] as AnyObject ){
                StudyUpdates.studyConsentUpdated = (updates[kStudyConsent] as? Bool)!
            }
            if Utilities.isValidValue(someObject: updates[kStudyActivities] as AnyObject ){
                StudyUpdates.studyActivitiesUpdated = (updates[kStudyActivities] as? Bool)!
            }
            
        }
        
        StudyUpdates.studyVersion = detail[kStudyCurrentVersion] as! String
       
    }
    
}
