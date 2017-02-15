//
//  LabKeyServices.swift
//  FDA
//
//  Created by Surender Rathore on 2/15/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

//api keys
let kEnrollmentToken        = "enrollmentToken"
let kParticipantId          = "participantId"
let kEnrollmentTokenValid   = "valid"
let kDeleteResponses        = "deleteResponses"

class LabKeyServices: NSObject {
    
    let networkManager = NetworkManager.sharedInstance()
    var delegate:NMWebServiceDelegate! = nil
    
     //MARK:Requests
    func enrollForStudy(studyId:String, token:String , delegate:NMWebServiceDelegate){
        
        let method = ResponseMethods.enroll.method
        
        let params = [kEnrollmentToken:token,
                      kStudyId:studyId]
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func verifyEnrollmentToken(token:String, delegate:NMWebServiceDelegate){
        
        let method = ResponseMethods.verifyEnrollmentToken.method
        
        let params = [kEnrollmentToken:token,
                      ]
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func withdrawFromStudy(studyId:String,participantId:String,deleteResponses:Bool,delegate:NMWebServiceDelegate){
        
        let method = ResponseMethods.withdrawFromStudy.method
        
        let params = [kStudyId:studyId,
                      kParticipantId:participantId,
                      kDeleteResponses:deleteResponses
                      ] as [String : Any]
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func processResponse(_:NMWebServiceDelegate){
        
    }
    
    func getParticipantResponse(_:NMWebServiceDelegate){
        
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
    
    func handleGetParticipantResponse(response:Dictionary<String, Any>){
        
    }



    
    private func sendRequestWith(method:Method, params:Dictionary<String, Any>,headers:Dictionary<String, String>?){
        
        networkManager.composeRequest(RegistrationServerConfiguration.configuration,
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
            
        default:
            print("Request was not sent proper method name")
        }
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        
    }
}
