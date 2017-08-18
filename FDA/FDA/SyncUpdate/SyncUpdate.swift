//
//  SyncUpdate.swift
//  FDA
//
//  Created by Arun Kumar on 19/05/17.
//  Copyright © 2017 BTC. All rights reserved.
//


//let studyId =  Study.currentStudy?.studyId!
//let activiyId =  Study.currentActivity?.actvityId!
//let activityName =  Study.currentActivity?.shortName!
//let activityVersion = Study.currentActivity?.version!
//let currentRunId = Study.currentActivity?.currentRunId

import Foundation
import RealmSwift

class SyncUpdate{
    
    var isReachabilityChanged:Bool
    static var currentSyncUpdate:SyncUpdate? = nil
    var selectedRun:DBActivityRun?
   
    init() {
        self.isReachabilityChanged = false
    }
    
    @objc func updateData(){
       
        
        if (NetworkManager.sharedInstance().reachability?.isReachable)!{
            print("*******************update Data***************")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                // your code here
                //self.updateRunInformationToServer()
                self.syncDataToServer()
            }
            
            
        }
        else {
             print("not available")
        }
    }
    
    func syncDataToServer() {
        
        let realm = try! Realm()
        let toBeSyncedData = realm.objects(DBDataOfflineSync.self).sorted(byKeyPath: "date", ascending: true).first
        if toBeSyncedData != nil {
            
            //request params
            var params:Dictionary<String, Any>? = nil
            if toBeSyncedData?.requestParams != nil {
                
                do {
                    params = try JSONSerialization.jsonObject(with: (toBeSyncedData?.requestParams)!, options: []) as? Dictionary<String, Any>
                    
                }
                catch{
                    
                }
            }
            
            //header params
            var headers:Dictionary<String, String>? = nil
            if toBeSyncedData?.headerParams != nil {
                
                do {
                    headers = try JSONSerialization.jsonObject(with: (toBeSyncedData?.headerParams)!, options: []) as? Dictionary<String, String>
                    
                }
                catch{
                    
                }
            }
            
            
            let methodString = toBeSyncedData?.method!
            let server = toBeSyncedData?.server!
            
            if server == "registration" {
                
                let methodName = methodString?.components(separatedBy: ".").first
                let registrationMethod = RegistrationMethods(rawValue:methodName!)
                let method = registrationMethod?.method
                UserServices().syncOfflineSavedData(method: method!, params: params, headers: headers ,delegate: self)
                
                
            }
            else if server == "wcp" {
                
            }
            else if server == "response" {
                
                let methodName = methodString?.components(separatedBy: ".").first
                let registrationMethod = ResponseMethods(rawValue:methodName!)
                let method = registrationMethod?.method
                LabKeyServices().syncOfflineSavedData(method: method!, params: params, headers: headers ,delegate: self)
            }
            
            //delete current database object
            try! realm.write {
               realm.delete(toBeSyncedData!)
            }
            
        }
    }
    
    func updateRunInformationToServer(){
        
        
        let realm = try! Realm()
        let dbRuns = realm.objects(DBActivityRun.self).filter({$0.toBeSynced == true})
        
        if dbRuns.count > 0 {
            
            //get last run
            let run = dbRuns.last
            self.selectedRun = run
            
            let activity = realm.object(ofType: DBActivity.self, forPrimaryKey: run?.activityId!)
            
            if activity == nil{
                self.findNextRunToSync()
            }
            else if activity != nil && activity?.shortName == nil{
                self.findNextRunToSync()
            }
            else {
                
                let currentUser = User.currentUser
                if let userStudyStatus = currentUser.participatedStudies.filter({$0.studyId == run?.studyId}).first {
                    
                    
                    
                    
                    let studyId =  run?.studyId
                    let activiyId =  run?.activityId
                    let activityName =  activity?.shortName
                    let activityVersion = activity?.version!
                    let currentRunId = run?.runId
                    
                    
                    
                    let info =  [kStudyId:studyId! ,
                                 kActivityId:activiyId! ,
                                 kActivityName:activityName! ,
                                 "version" :activityVersion! ,
                                 kActivityRunId:"\(currentRunId!)"
                        ] as [String : String]
                    
                    let ActivityType = activity?.type
                    
                    let participationid = userStudyStatus.participantId
                    
                    var data:Dictionary<String, Any> = [:]
                    do {
                        let responseData = try JSONSerialization.jsonObject(with: (run?.responseData)!, options: []) as! [String:Any]
                        data = (responseData["data"] as! Dictionary<String, Any>?)!
                    }
                    catch{
                        
                    }
                    
                    LabKeyServices().processResponse(metaData: info, activityType: ActivityType!, responseData: data, participantId: participationid!, delegate: self)
                    
                }
            }
         
            
        }
        else{
            self.selectedRun = nil
        }
    }
    
    func findNextRunToSync(){
        if selectedRun != nil {
            
            let realm = try! Realm()
            try! realm.write {
                self.selectedRun?.toBeSynced = false
                self.selectedRun?.responseData = nil
            }
            
            self.updateRunInformationToServer()
        }
    }
    
    
}

//MARK:- Webservices Delegates
extension SyncUpdate:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) : \(response)")
        
       //self.findNextRunToSync()
        self.syncDataToServer()
       
    }
    
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
    }
}
