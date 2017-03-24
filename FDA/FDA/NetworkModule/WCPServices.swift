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


//study
let kStudyTitle = "title"
let kStudyCategory = "category"
let kStudySponserName = "sponsorName"
let kStudyDescription = "description"
let kStudyTagLine = "tagline"

let kStudyStatus = "status"
let kStudyLogoURL = "logo"

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

    
    
    func getEligibilityConsentMetadata(studyId:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        

        let method = WCPMethods.eligibilityConsent.method
        let params = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    func getResourcesForStudy(studyId:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let method = WCPMethods.resources.method
        let params = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: params, headers: nil)
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
        let params = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getStudyActivityMetadata(studyId:String, activityId:String,activityVersion:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        

        let method = WCPMethods.activity.method
        let params = [kStudyId:studyId,
                      kActivityId:activityId,
                      kActivityVersion:activityVersion]
        self.sendRequestWith(method:method, params: params, headers: nil)
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
    }
    
    func handleResourceListForGateway(response:Dictionary<String, Any>){
        
        let resources = response[kResources] as! Array<Dictionary<String,Any>>
        var listOfResources:Array<Resource>!
        for resource in resources{
            let resourceObj = Resource(detail: resource)
            listOfResources.append(resourceObj)
        }
        
        //assgin to Gateway
        Gateway.instance.resources = listOfResources
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
        
    }
    
    func handleStudyActivityList(response:Dictionary<String, Any>){
        
        let activities = response[kActivites] as! Array<Dictionary<String,Any>>
        
        
    }
    
    func handleGetStudyActivityMetadata(response:Dictionary<String, Any>){
        
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
        case .gatewayInfo:break
        case .studyList:
            self.handleStudyList(response: response as! Dictionary<String, Any>)
        case .eligibilityConsent:break
        case .resources:break
        case .consentDocument:
            self.handleConsentDocument(response: response as! Dictionary<String, Any>)
        case .studyInfo:
            self.handleStudyInfo(response: response as! Dictionary<String, Any>)
        case .activityList:break
        case .activity:break
        case .studyDashboard:break
        case .termsPolicy:
            self.handleTermsAndPolicy(response:response as! Dictionary<String, Any> )
        case .notifications:break
        
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
