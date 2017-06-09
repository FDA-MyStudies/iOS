//
//  LabKeyServices.swift
//  FDA
//
//  Created by Surender Rathore on 2/15/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

//api keys
let kEnrollmentToken        = "token"
let kParticipantId          = "participantId"
let kEnrollmentTokenValid   = "valid"
let kDeleteResponses        = "deleteResponses"

class LabKeyServices: NSObject {
    
    let networkManager = NetworkManager.sharedInstance()
    var delegate:NMWebServiceDelegate! = nil
    
    //MARK:Requests
    func enrollForStudy(studyId:String, token:String , delegate:NMWebServiceDelegate){
        self.delegate = delegate
        let method = ResponseMethods.enroll.method
        
        let params = [kEnrollmentToken:token,
                      kStudyId:studyId]
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func verifyEnrollmentToken(studyId:String,token:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let method = ResponseMethods.validateEnrollmentToken.method
        
        let params = [kEnrollmentToken:token,
                      kStudyId:studyId
        ]
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func withdrawFromStudy(studyId:String,participantId:String,deleteResponses:Bool,delegate:NMWebServiceDelegate){
        self.delegate = delegate
        let method = ResponseMethods.withdrawFromStudy.method
        
        let params = [
                      kParticipantId:participantId,
                      kDeleteResponses:deleteResponses
            ] as [String : Any]
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func processResponse(metaData:Dictionary<String,Any>,activityType:String,responseData:Dictionary<String,Any>,participantId:String,delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        let method = ResponseMethods.processResponse.method
        
        let params = [kActivityType:activityType ,
                      kActivityInfoMetaData:metaData,
                      kParticipantId: participantId,
                      kActivityResponseData :responseData
            ] as [String : Any]
        
        print("processresponse \(params)")
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    func processResponse(responseData:Dictionary<String,Any>, delegate:NMWebServiceDelegate){
        self.delegate = delegate
        
        let method = ResponseMethods.processResponse.method
       /*
        let studyId =  "CAFDA12" // Study.currentStudy?.studyId!
        let activiyId = "QR-4" // Study.currentActivity?.actvityId!
        let activityName =  "QR4" //Study.currentActivity?.shortName!
        let activityVersion = "1.0" //Study.currentActivity?.version!
        let currentRunId = Study.currentActivity?.currentRunId
        
        */
        
        
        let currentUser = User.currentUser
        if let userStudyStatus = currentUser.participatedStudies.filter({$0.studyId == Study.currentStudy?.studyId!}).first {
            
            
            let studyId =  Study.currentStudy?.studyId!
            let activiyId =  Study.currentActivity?.actvityId!
            let activityName =  Study.currentActivity?.shortName!
            let activityVersion = Study.currentActivity?.version!
            let currentRunId = Study.currentActivity?.currentRunId
            
            
            
            let info =  [kStudyId:studyId! ,
                         kActivityId:activiyId! ,
                         kActivityName:activityName! ,
                         "version" :activityVersion! ,
                         kActivityRunId:"\(currentRunId!)"
                ] as [String : String]
            
            let ActivityType = Study.currentActivity?.type?.rawValue
            
            let params = [kActivityType:ActivityType! ,
                          kActivityInfoMetaData:info,
                          kParticipantId: userStudyStatus.participantId! as String,  //"43decbe8662d1f3c198b19d79c6df7d6",
                          kActivityResponseData :responseData
                ] as [String : Any]
            
            print("processresponse \(params)")
            self.sendRequestWith(method:method, params: params, headers: nil)
            
            
        }
        
        
   
        
        
    }
    
    func getParticipantResponse(activityId:String,participantId:String,delegate:NMWebServiceDelegate){
        self.delegate = delegate
        
        let method = ResponseMethods.executeSQL.method
        let query = "SELECT * FROM " + activityId
        let params = [
            
                      kParticipantId: participantId,
                      "sql" :query
            ] as [String : Any]
        
       
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    //MARK:Parsers
    func handleEnrollForStudy(response:Dictionary<String, Any>){
        
    }
    
    func handleVerifyEnrollmentToken(response:Dictionary<String, Any>){
        
    }
    
    func handleWithdrawFromStudy(response:Dictionary<String, Any>){
        
    }
    
    func handleProcessResponse(response:Dictionary<String, Any>){
        
    }
    
    class DashboardResponse{
        var key:String?
        var type:String?
        var value:Float = 0.0
        var date:String?
        var isPHI:String?
        
        init() {
            
        }
    }
    func handleGetParticipantResponse(response:Dictionary<String, Any>){
        
        
        
       
        
        
        var dashBoardResponse:Array<DashboardResponse> = []
        if let feilds = response["fields"] as? Array<Dictionary<String,Any>>{
            
           
            
            print("rows \(feilds)")
            for feildDetail in feilds {
                
                if let fieldKeys = feildDetail["fieldKey"] as? Array<String> {
                    
                    let fieldKeyValue = fieldKeys.first
                    
                    let responseData = DashboardResponse()
                    //check for key which don't need to be parsed
                    if (fieldKeyValue != "container"
                        || fieldKeyValue != "CreatedBy"
                        || fieldKeyValue != "ModifiedBy"
                        || fieldKeyValue != "lastIndexed"
                        || fieldKeyValue != "Modified"
                        || fieldKeyValue != "Key"
                        || fieldKeyValue != "ParticipantId" ){
                        
                        responseData.key = fieldKeyValue
                        responseData.type = feildDetail["type"] as! String?
                        responseData.isPHI = feildDetail["phi"] as! String?
                        
                        dashBoardResponse.append(responseData)
                    }
                }
                
                
            }
            
        }
        
        if let rows = response["rows"] as? Array<Dictionary<String,Any>>{
            print("rows \(rows)")
            
            
            
        }
    
    
    
    
    private func sendRequestWith(method:Method, params:Dictionary<String, Any>,headers:Dictionary<String, String>?){
        
        networkManager.composeRequest(ResponseServerConfiguration.configuration,
                                      method: method,
                                      params: params as NSDictionary?,
                                      headers: headers as NSDictionary?,
                                      delegate: self)
    }
}
extension LabKeyServices:NMWebServiceDelegate{
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        if delegate != nil {
            delegate.startedRequest(manager, requestName: requestName)
        }
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        
        switch requestName {
        case ResponseMethods.validateEnrollmentToken.description as String: break
        case ResponseMethods.enroll.description as String:
            self.handleEnrollForStudy(response: response as! Dictionary<String, Any>)
        case ResponseMethods.getParticipantResponse.description as String: break
        case ResponseMethods.executeSQL.description as String:
            self.handleGetParticipantResponse(response: response as! Dictionary<String, Any>)
        case ResponseMethods.processResponse.description as String: break
        case ResponseMethods.withdrawFromStudy.description as String: break
        default:
            print("Request was not sent with proper method name")
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
