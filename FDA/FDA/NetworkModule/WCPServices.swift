//
//  WCPServices.swift
//  FDA
//
//  Created by Surender Rathore on 2/13/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit


let kNotificationSkip = "skip"


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
