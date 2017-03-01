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
let kOverviewMediaLink = "link"

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
    func getStudyList(_:NMWebServiceDelegate){
        
        let method = WCPMethods.studyList.method
        let params = Dictionary<String, Any>()
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getEligibilityConsentMetadata(studyId:String, delegate:NMWebServiceDelegate){
        
        let method = WCPMethods.eligibilityConsent.method
        let params = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    func getResourcesForStudy(studyId:String, delegate:NMWebServiceDelegate){
        
        let method = WCPMethods.resources.method
        let params = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getStudyInformation(studyId:String, delegate:NMWebServiceDelegate){
        
        let method = WCPMethods.studyInfo.method
        let params = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getStudyActivityList(studyId:String, delegate:NMWebServiceDelegate){
        let method = WCPMethods.activityList.method
        let params = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getStudyActivityMetadata(studyId:String, activityId:String,activityVersion:String, delegate:NMWebServiceDelegate){
        
        let method = WCPMethods.activity.method
        let params = [kStudyId:studyId,
                      kActivityId:activityId,
                      kActivityVersion:activityVersion]
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getStudyDashboardInfo(studyId:String, delegate:NMWebServiceDelegate){
        
        let method = WCPMethods.studyDashboard.method
        let params = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getTermsPolicy(studyId:String, delegate:NMWebServiceDelegate){
        
        let method = WCPMethods.termsPolicy.method
        let params = [kStudyId:studyId]
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getNotification(skip:Int, delegate:NMWebServiceDelegate){
        
        let method = WCPMethods.notifications.method
        let params = [kNotificationSkip:skip]
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    //MARK:Parsers
    func handleStudyList(response:Dictionary<String, Any>){
        
        let studies = response[kStudies] as! Array<Dictionary<String,Any>>
        var listOfStudies:Array<Study>!
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
    
    func handleStudyInfo(response:Dictionary<String, Any>){
        
        let overviewList = response[kOverViewInfo] as! Array<Dictionary<String,Any>>
        var listOfOverviews:Array<OverviewSection>!
        for overview in overviewList{
            let overviewObj = OverviewSection(detail: overview)
            listOfOverviews.append(overviewObj)
        }
        
        //create new Overview object
        let overview = Overview()
        overview.type = .study
        overview.sections = listOfOverviews
        
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

    
    private func sendRequestWith(method:Method, params:Dictionary<String, Any>,headers:Dictionary<String, String>?){
        
        networkManager.composeRequest(RegistrationServerConfiguration.configuration,
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
        
        switch requestName {
        
        default:
            print("Request was not sent proper method name")
        }
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        
    }
}
