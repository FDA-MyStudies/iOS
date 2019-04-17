//
//  AnchorDateHandler.swift
//  HPHC
//
//  Created by Surender on 26/03/19.
//  Copyright © 2019 BTC. All rights reserved.
//

import UIKit

class EmptyAnchordDates {
    
    enum FetchAnchorDateFor {
        case activity
        case resource
    }
    
    var activity:DBActivity!
    var resource:DBResources!
    var sourceKey:String!
    var sourceActivityId:String!
    var sourceFormKey:String?
    var anchorDate:Date?
    var sourceFormId:String!
    var isFinishedFetching:Bool = false
    var fetchAnchorDateFor:FetchAnchorDateFor = .activity
    
    init() {
        
    }
    
}

class AnchorDateHandler {
    
    
    var emptyAnchorDatesList:[EmptyAnchordDates] = []
    typealias AnchordDateFetchCompletionHandler = (_ success:Bool)->Void
    var handler:AnchordDateFetchCompletionHandler!
    
    func fetchActivityAnchorDateResponseFromLabkey(_ completionHandler: @escaping AnchordDateFetchCompletionHandler) {
        
        print("Log Started - \(Date().timeIntervalSince1970)")
        
        handler = completionHandler
        //get activities from database for anchor date is not present
        let activities = DBHandler.getActivitiesWithEmptyAnchorDateValue((Study.currentStudy?.studyId)!)
               
        guard activities.count != 0 else {
            return handler(false)
        }
        
          for activity in activities {
            
            let act = User.currentUser.participatedActivites.filter({$0.activityId == activity.sourceActivityId}).last
            
            if act != nil && (act?.status == UserActivityStatus.ActivityStatus.completed) {
                
                let emptyAnchorDateDetail = EmptyAnchordDates()
                emptyAnchorDateDetail.activity = activity
                emptyAnchorDateDetail.sourceKey = activity.sourceKey
                emptyAnchorDateDetail.sourceActivityId = activity.sourceActivityId
                emptyAnchorDateDetail.sourceFormKey = activity.sourceFormKey
                emptyAnchorDatesList.append(emptyAnchorDateDetail)
            }
        
        }
        
        guard emptyAnchorDatesList.count != 0 else {
            return handler(false)
        }
        
        sendRequestToFetchResponse()
        
    }
    
    func fetchActivityAnchorDateForResourceFromLabkey(_ completionHandler: @escaping AnchordDateFetchCompletionHandler){
        
        let resources = DBHandler.getResourceWithEmptyAnchorDateValue((Study.currentStudy?.studyId)!)
        handler = completionHandler
        guard resources.count != 0 else {
            return handler(false)
        }
        
        for resource in resources {
            
            let act = User.currentUser.participatedActivites.filter({$0.activityId == resource.sourceActivityId}).last
            
            if act != nil && (act?.status == UserActivityStatus.ActivityStatus.completed) {
                
                let emptyAnchorDateDetail = EmptyAnchordDates()
                emptyAnchorDateDetail.fetchAnchorDateFor = .resource
                emptyAnchorDateDetail.resource = resource
                emptyAnchorDateDetail.sourceKey = resource.sourceKey
                emptyAnchorDateDetail.sourceActivityId = resource.sourceActivityId
                emptyAnchorDateDetail.sourceFormKey = resource.sourceFormKey
                emptyAnchorDatesList.append(emptyAnchorDateDetail)
            }
            
            
        }
        
        guard emptyAnchorDatesList.count != 0 else {
            return handler(false)
        }
        
        sendRequestToFetchResponse()
        
    }
    
    
    
    func sendRequestToFetchResponse() {
        
        guard let emptyAnchorDateDetail = emptyAnchorDatesList.filter({$0.isFinishedFetching == false}).first else {
            
            print("Log API Finished - \(Date().timeIntervalSince1970)")
            saveAnchorDateInDatabase()
            //handler(true)
            return
        }
        
        //send request to get response"
        
        let keys = emptyAnchorDateDetail.sourceKey!
        let formKey:String = emptyAnchorDateDetail.sourceFormKey ?? ""
        let tableName = emptyAnchorDateDetail.sourceActivityId + formKey
        //let activityId = emptyAnchorDateDetail.activity.sourceActivityId
        
        let method = ResponseMethods.executeSQL.method
        let query:String = "SELECT " + keys + ",Created" + " FROM " + tableName
        //        let params = [
        //
        //            kParticipantId: "214b3c8b672c735988df8c139fed8abe",
        //            "sql": query
        //            ] as [String : Any]
        //
        //
        //        guard let data = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted) else {
        //            return
        //        }
        
        let participantId:String = (Study.currentStudy?.userParticipateState.participantId)! //"214b3c8b672c735988df8c139fed8abe"
        var urlString = ResponseServerURLConstants.DevelopmentURL + method.methodName + "?" + kParticipantId + "=" + participantId + "&sql=" + query
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let requstUrl = URL(string:urlString)
        var request = URLRequest.init(url: requstUrl!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: NetworkConnectionConstants.ConnectionTimeoutInterval)
        request.httpMethod = method.methodType.methodTypeAsString
        //request.httpBody = data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                print(error as Any)
                emptyAnchorDateDetail.isFinishedFetching = true
                self.sendRequestToFetchResponse()
            } else {
                
                let status = NetworkConstants.checkResponseHeaders(response!)
                let statusCode = status.0
                if statusCode == 200 || statusCode == 0 {
                    
                    DispatchQueue.main.async {
                        
                        guard let response = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any] else {
                            
                            emptyAnchorDateDetail.isFinishedFetching = true
                            self.sendRequestToFetchResponse()
                            
                            return
                        }
                        
                        guard let rows = response["rows"] as? Array<Dictionary<String,Any>> , rows.count > 0 else {
                            emptyAnchorDateDetail.isFinishedFetching = true
                            self.sendRequestToFetchResponse()
                            return
                        }
                        
                        for rowDetail in rows {
                            if let data =  rowDetail["data"] as? Dictionary<String,Any>{
                                
                                let anchorDateObject = data[emptyAnchorDateDetail.sourceKey] as? [String:String]
                                let anchorDateString = anchorDateObject?["value"]// as! String
                                let date = ResponseDataFetch.labkeyDateFormatter.date(from: anchorDateString!)
                                emptyAnchorDateDetail.anchorDate = date
                                emptyAnchorDateDetail.isFinishedFetching = true
                                self.sendRequestToFetchResponse()
                                
                            }
                        }
                    }
                }
                else {
                    emptyAnchorDateDetail.isFinishedFetching = true
                    self.sendRequestToFetchResponse()
                }
                
                
            }
        })
        
        dataTask.resume()
        
    }
    
    func saveAnchorDateInDatabase() {
        
        print("Log DB Started - \(Date().timeIntervalSince1970)")
        let listItems = emptyAnchorDatesList.filter({$0.anchorDate != nil && $0.isFinishedFetching == true})
        for item in listItems {
            print("DB")
            if item.fetchAnchorDateFor == .activity {
                DBHandler.updateActivityLifeTimeFor(item.activity, anchorDate: item.anchorDate!)
            }
            else if item.fetchAnchorDateFor == .resource {
                
                var startDateStringEnrollment =  Utilities.formatterShort?.string(from: item.anchorDate!)
                let startTimeEnrollment =  "00:00:00"
                startDateStringEnrollment = (startDateStringEnrollment ?? "") + " " + startTimeEnrollment
                let anchorDate = Utilities.findDateFromString(dateString: startDateStringEnrollment ?? "")
                
                DBHandler.saveLifeTimeFor(resource: item.resource, anchorDate: anchorDate!)
            }
        }
        print("Log DB Finished - \(Date().timeIntervalSince1970)")
        handler(true)
    }
    
}


