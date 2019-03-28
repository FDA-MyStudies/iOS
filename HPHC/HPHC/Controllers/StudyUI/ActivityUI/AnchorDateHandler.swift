//
//  AnchorDateHandler.swift
//  HPHC
//
//  Created by Surender on 26/03/19.
//  Copyright © 2019 BTC. All rights reserved.
//

import UIKit

class EmptyAnchordDates {
    
    var activity:DBActivity!
    var sourceKeysSet:Set<String> = []
    var sourceKeys:String {
        return Array(self.sourceKeysSet).joined(separator: ",")
    }
    var sourceKey:String!
    var sourceActivityId:String!
    var anchorDate:Date?
    var sourceFormId:String!
    var isFinishedFetching:Bool = false
    
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
            
            let emptyAnchorDateDetail = EmptyAnchordDates()
            emptyAnchorDateDetail.activity = activity
            emptyAnchorDateDetail.sourceKey = activity.sourceKey
            emptyAnchorDateDetail.sourceActivityId = activity.sourceActivityId
            emptyAnchorDatesList.append(emptyAnchorDateDetail)
            
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
        
        //send request to get response
        
        let keys = emptyAnchorDateDetail.sourceKey!
        let tableName = emptyAnchorDateDetail.activity.sourceActivityId
        //let activityId = emptyAnchorDateDetail.activity.sourceActivityId
        
        let method = ResponseMethods.executeSQL.method
        let query:String = "SELECT " + keys + ",Created" + " FROM " + tableName!
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
            } else {
                
                DispatchQueue.main.async {
                    guard let response = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any] else {
                        return
                    }
                    
                    if let rows = response["rows"] as? Array<Dictionary<String,Any>> {
                        for rowDetail in rows {
                            if let data =  rowDetail["data"] as? Dictionary<String,Any>{
                                
                                let anchorDateObject = data[emptyAnchorDateDetail.sourceKey] as? [String:String]
                                let anchorDateString = anchorDateObject?["value"]// as! String
                                let date = ResponseDataFetch.localDateFormatter.date(from: anchorDateString!)
                                emptyAnchorDateDetail.anchorDate = date
                                emptyAnchorDateDetail.isFinishedFetching = true
                                self.sendRequestToFetchResponse()
                                
                            }
                        }
                    }
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
            DBHandler.updateActivityLifeTimeFor(item.activity, anchorDate: item.anchorDate!)
        }
        print("Log DB Finished - \(Date().timeIntervalSince1970)")
        handler(true)
    }
    
}


