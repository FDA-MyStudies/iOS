//
//  WCPServices.swift
//  FDA
//
//  Created by Surender Rathore on 2/13/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

//Api constants
let kNotificationSkip = "skip"

let kActivity = "activity"

//study
let kStudyTitle = "title"
let kStudyCategory = "category"
let kStudySponserName = "sponsorName"
let kStudyDescription = "description"
let kStudyTagLine = "tagline"
let kStudyVersion = "studyVersion"

let kStudyStatus = "status"
let kStudyLogoURL = "logo"
let kStudySettings = "settings"
let kStudyEnrolling = "enrolling"
let kStudyPlatform = "platform"
let kStudyRejoin = "rejoin"

//resources
let kResources = "resources"


//overview
let kOverViewInfo = "info"
let kOverviewType = "type"
let kOverviewImageLink = "image"
let kOverviewTitle = "title"
let kOverviewText = "text"
let kOverviewMediaLink = "videoLink" // link
let kOverviewWebsiteLink = "website"

//notification
let kNotifications = "notifications"
let kNotificationId = "notificationId"
let kNotificationType = "type"
let kNotificationSubType = "subtype"
let kNotificationAudience = "audience"
let kNotificationTitle = "title"
let kNotificationMessage = "message"


//feedback
let kFeedbackSubject = "subject"
let kFeedbackBody = "body"

//contactus
let kContactusEmail = "email"
let kContactusFirstname = "firstName"

//studyupdates
let kStudyUpdates = "updates"
let kStudyCurrentVersion = "currentVersion"
let kStudyConsent = "consent"
let kStudyActivities = "activities"
let kStudyResources = "resources"
let kStudyInfo = "info"




class WCPServices: NSObject {
    let networkManager = NetworkManager.sharedInstance()
    var delegate:NMWebServiceDelegate! = nil
    
     //MARK:Requests
    func getStudyList(_ delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let method = WCPMethods.studyList.method
        let params = Dictionary<String, Any>()
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getConsentDocument(studyId:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        let header = [kStudyId:studyId]
        let method = WCPMethods.consentDocument.method
       
        self.sendRequestWith(method:method, params: nil, headers: header)
    }

    func getGatewayResources(delegate:NMWebServiceDelegate){
        self.delegate = delegate
        
        let method = WCPMethods.gatewayInfo.method
        let params = Dictionary<String, Any>()
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getEligibilityConsentMetadata(studyId:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        

        let method = WCPMethods.eligibilityConsent.method
        let headerParams = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: nil, headers: headerParams)
    }
    func getResourcesForStudy(studyId:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let method = WCPMethods.resources.method
        let headerParams = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: nil, headers: headerParams)
    }
    
    func getStudyInformation(studyId:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let method = WCPMethods.studyInfo.method
        let params = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: nil, headers: params)
    }
    
    func getStudyActivityList(studyId:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        

        let method = WCPMethods.activityList.method
        let headerParams = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: nil, headers: headerParams)
    }
    
    func getStudyActivityMetadata(studyId:String, activityId:String,activityVersion:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        

        let method = WCPMethods.activity.method
        let headerParams = [kStudyId:studyId,
                      kActivityId:activityId,
                      kActivityVersion:activityVersion]
        self.sendRequestWith(method:method, params: nil, headers: headerParams)
    }
    
    func getStudyDashboardInfo(studyId:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        

        let method = WCPMethods.studyDashboard.method
        let params = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getTermsPolicy(studyId:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        

        let method = WCPMethods.termsPolicy.method
        let params = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getTermsPolicy(delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        
        let method = WCPMethods.termsPolicy.method
       
        self.sendRequestWith(method:method, params: nil, headers: nil)
    }
    
    func getNotification(skip:Int, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        

        let method = WCPMethods.notifications.method
        let params = [kNotificationSkip:skip]
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    func sendUserFeedback(delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
      
        let method = WCPMethods.feedback.method
        let params = [kFeedbackBody:FeedbackDetail.feedback,
                      kFeedbackSubject:FeedbackDetail.subject]
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    func sendUserContactUsRequest(delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let method = WCPMethods.contactUs.method
        let params = [kFeedbackBody:ContactUsFeilds.message,
                      kFeedbackSubject:ContactUsFeilds.subject,
                      kContactusEmail:ContactUsFeilds.email,
                      kContactusFirstname:ContactUsFeilds.firstName]
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    func getStudyUpdates(study:Study,delegate:NMWebServiceDelegate){
        self.delegate = delegate
        
        let method = WCPMethods.studyUpdates.method
        let headerParams = [kStudyId:study.studyId!,
                            kStudyVersion:study.version!]
        self.sendRequestWith(method:method, params: nil, headers: headerParams)
        
    }
    func checkForAppUpdates(delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        let method = WCPMethods.appUpdates.method
        let headerParams = [kAppVersion:Utilities.getAppVersion(),
                            kOSType:"ios"]
        self.sendRequestWith(method:method, params: nil, headers: headerParams)
    }
    
    //MARK:Parsers
    func handleStudyList(response:Dictionary<String, Any>){
        
        let studies = response[kStudies] as! Array<Dictionary<String,Any>>
        var listOfStudies:Array<Study> = []
        for study in studies{
            let studyModelObj = Study(studyDetail: study)
            listOfStudies.append(studyModelObj)
        }
        
        //assgin to Gateway
        Gateway.instance.studies = listOfStudies
        
        //save in database
        DBHandler().saveStudies(studies: listOfStudies)
    }
    
    func handleEligibilityConsentMetaData(response:Dictionary<String, Any>){
        let consent = response[kConsent] as! Dictionary<String, Any>
        let eligibility = response[kEligibility] as! Dictionary<String, Any>
        
        if Utilities.isValidObject(someObject: consent as AnyObject?){
            ConsentBuilder.currentConsent = ConsentBuilder()
            ConsentBuilder.currentConsent?.initWithMetaData(metaDataDict: consent)
        }
        
        if Utilities.isValidObject(someObject: eligibility as AnyObject?){
            EligibilityBuilder.currentEligibility = EligibilityBuilder()
            EligibilityBuilder.currentEligibility?.initEligibilityWithDict(eligibilityDict:eligibility )
        }
        
    }
    
    
    
    func handleResourceListForGateway(response:Dictionary<String, Any>){
        
        let resources = response[kResources] as! Array<Dictionary<String,Any>>
        var listOfResources:Array<Resource>! = []
        for resource in resources{
            let resourceObj = Resource(detail: resource)
            listOfResources.append(resourceObj)
        }
        
        //assgin to Gateway
        Gateway.instance.resources = listOfResources
    }
    
    func handleResourceForStudy(response:Dictionary<String, Any>){
        let resources = response[kResources] as! Array<Dictionary<String,Any>>
        var listOfResources:Array<Resource>! = []
        for resource in resources{
            let resourceObj = Resource()
            resourceObj.level = ResourceLevel.study
            resourceObj.setResource(dict: resource as NSDictionary)
            
            listOfResources.append(resourceObj)
        }
        
        //assgin to Gateway
       Study.currentStudy?.resources = listOfResources

    }
    
    func handleStudyDashboard(response:Dictionary<String, Any>){
        
    }
    
    func handleConsentDocument(response:Dictionary<String, Any>){
        
        let consentDict = response[kConsent] as! Dictionary<String, Any>
        
        if Utilities.isValidObject(someObject: consentDict as AnyObject?) {
            
            Study.currentStudy?.consentDocument = ConsentDocument()
            
            Study.currentStudy?.consentDocument?.initData(consentDoucumentdict: consentDict)
        }

    }
    
    
    func handleTermsAndPolicy(response:Dictionary<String, Any>){
        
       TermsAndPolicy.currentTermsAndPolicy =  TermsAndPolicy()
       TermsAndPolicy.currentTermsAndPolicy?.initWithDict(dict: response)
        
    }
    
    
    func handleStudyInfo(response:Dictionary<String, Any>){
        
        let overviewList = response[kOverViewInfo] as! Array<Dictionary<String,Any>>
        var listOfOverviews:Array<OverviewSection> = []
        for overview in overviewList{
            let overviewObj = OverviewSection(detail: overview)
            listOfOverviews.append(overviewObj)
        }
        
        //create new Overview object
        let overview = Overview()
        overview.type = .study
        overview.sections = listOfOverviews
        overview.websiteLink = response[kOverViewWebsiteLink] as? String
        
        
        //update overview object to current study
        Study.currentStudy?.overview = overview
        
        //save in database
        DBHandler.saveStudyOverview(overview: overview, studyId: (Study.currentStudy?.studyId)!)
        
    }
    
    func handleStudyActivityList(response:Dictionary<String, Any>){
        
        let activities = response[kActivites] as! Array<Dictionary<String,Any>>
        
        if Utilities.isValidObject(someObject: activities as AnyObject? ) {
            
            var activityList:Array<Activity> = []
           // Study.currentStudy?.activities = Array<Activity>()
            for activityDict in activities{
                
                //let activity:Activity? = Activity.init()
                //activity?.initWithStudyActivityList(infoDict: activityDict)
                let activity = Activity.init(studyId: (Study.currentStudy?.studyId)!, infoDict: activityDict)
                
                activityList.append(activity)
                
               
            }
            
            //save to current study object
            Study.currentStudy?.activities = activityList
            //save in database
            DBHandler.saveActivities(activityies: (Study.currentStudy?.activities)!)
        }
        else{
            Logger.sharedInstance.debug("activities is null:\(activities)")
        }
        
        
    }
    
    func handleGetStudyActivityMetadata(response:Dictionary<String, Any>){
        
        Study.currentActivity?.setActivityMetaData(activityDict:response[kActivity] as! Dictionary<String, Any>)
        
         if Utilities.isValidObject(someObject: Study.currentActivity?.steps as AnyObject?){
            
            ActivityBuilder.currentActivityBuilder = ActivityBuilder()
            ActivityBuilder.currentActivityBuilder.initWithActivity(activity:Study.currentActivity! )
        }
        
        
    }
    
    func handleGetNotification(response:Dictionary<String, Any>){
        
        let notifications = response[kNotifications] as! Array<Dictionary<String,Any>>
        var listOfNotifications:Array<AppNotification>!
        for notification in notifications{
             let overviewObj = AppNotification(detail: notification)
             listOfNotifications.append(overviewObj)
        }
        
        Gateway.instance.notification = listOfNotifications
    }

    func handleContactUsAndFeedback(response:Dictionary<String, Any>){
    }
    func handleStudyUpdates(response:Dictionary<String, Any>){
        
        if Utilities.isValidObject(someObject: response as AnyObject?){
            _ = StudyUpdates(detail: response as! Dictionary<String, Any>)
        }
    }

    
    private func sendRequestWith(method:Method, params:Dictionary<String, Any>?,headers:Dictionary<String, String>?){
        
        networkManager.composeRequest(WCPConfiguration.configuration,
                                      method: method,
                                      params: params as NSDictionary?,
                                      headers: headers as NSDictionary?,
                                      delegate: self)
    }
    
    
}
extension WCPServices:NMWebServiceDelegate{
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        if delegate != nil {
            delegate.startedRequest(manager, requestName: requestName)
        }
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        
        let methodName = WCPMethods(rawValue: requestName as String)!
        
        switch methodName {
        case .gatewayInfo:
            self.handleResourceListForGateway(response: response as! Dictionary<String, Any>)
        case .studyList:
            self.handleStudyList(response: response as! Dictionary<String, Any>)
        case .eligibilityConsent:
            self.handleEligibilityConsentMetaData(response: response as! Dictionary<String, Any>)
        case .resources:
             self.handleResourceForStudy(response: response as! Dictionary<String, Any>)
        case .consentDocument:
            self.handleConsentDocument(response: response as! Dictionary<String, Any>)
        case .studyInfo:
            self.handleStudyInfo(response: response as! Dictionary<String, Any>)
        case .activityList:
            self.handleStudyActivityList(response: response as! Dictionary<String, Any>)
        case .activity:
            self.handleGetStudyActivityMetadata(response: response as! Dictionary<String, Any>)
        case .studyDashboard:
            self.handleStudyDashboard(response: response as! Dictionary<String, Any>)
        case .termsPolicy:
            self.handleTermsAndPolicy(response:response as! Dictionary<String, Any> )
        case .notifications:break
        case .contactUs,.feedback:
            self.handleContactUsAndFeedback(response:response as! Dictionary<String, Any> )
        case .studyUpdates:
            self.handleStudyUpdates(response: response as! Dictionary<String, Any>)
        case .appUpdates: break
        default:
            print("Request was not sent proper method name")
        }
        
        if delegate != nil {
            delegate.finishedRequest(manager, requestName: requestName, response: response)
        }
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        if delegate != nil {
            delegate.failedRequest(manager, requestName: requestName, error: error)
        }
    }
}
