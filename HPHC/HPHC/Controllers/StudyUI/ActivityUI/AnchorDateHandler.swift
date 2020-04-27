/*
 License Agreement for FDA My Studies
 Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
 hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
 limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 Software, and to permit persons to whom the Software is furnished to do so, subject to the following
 conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.
 Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
 Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
 THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
 OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit


class PropertyMetaData {
    
    lazy var propertyId: String = ""

    lazy var externalPropertyId: String = ""

    lazy var dateOfEntryId: String = ""
    
    var externalPropertyValue: String?

    var dateOfEntryValue: String?
    
    var propertyValue: String?
    
    /// To Init the IDs.
    init(ppMetaData: DBParticipantPropertyMetadata) {
        self.propertyId = ppMetaData.propertyID
        self.externalPropertyId = ppMetaData.externalPropertyID
        self.dateOfEntryId = ppMetaData.dateOfEntryID
    }
    
    init() {}
    
}

class AnchorDateQueryMetaData {
    
    enum FetchAnchorDateFor {
        case activity
        case resource
    }
    
    var activity: DBActivity?
    var resource: DBResources?
    var sourceKey: String!
    var sourceActivityId: String!
    var sourceFormKey: String?
    var anchorDate: Date?
    var sourceFormId: String!
    var participantPropertyMetaData: PropertyMetaData?
    var fetchAnchorDateFor: FetchAnchorDateFor = .activity
    
    init() {}
    
    /// Update PP data from LabKey response.
    func updateValue(with jsonDict: JSONDictionary) {
        guard let ppMetaData = self.participantPropertyMetaData
            else {return}
        // Anchor Date
        if let participantPropertyValue = jsonDict[ppMetaData.propertyId] as? JSONDictionary,
            let anchorDateString = participantPropertyValue["value"] as? String {
            let date = ResponseDataFetch.labkeyDateFormatter.date(from: anchorDateString)
            self.anchorDate = date
            self.participantPropertyMetaData?.propertyValue = anchorDateString
        }
        
        // Property external Id value
        if let externalPropertyData = jsonDict[ppMetaData.externalPropertyId] as? JSONDictionary,
            let externalPropertyValue = externalPropertyData["value"] as? String {
            self.participantPropertyMetaData?.externalPropertyValue = externalPropertyValue
        }
        
        // Date of entry
        if let dateOfEntryDict = jsonDict[ppMetaData.dateOfEntryId] as? JSONDictionary,
            let dateOfEntry = dateOfEntryDict["value"] as? String {
            //let date = ResponseDataFetch.labkeyDateFormatter.date(from: dateOfEntry)
            self.participantPropertyMetaData?.dateOfEntryValue = dateOfEntry //as? String
        }
    }
    
}

class AnchorDateHandler {
    
    lazy var anchorDateMetaDataList: [AnchorDateQueryMetaData] = []
    typealias AnchordDateFetchCompletionHandler = (_ success: Bool) -> Void
    var handler: AnchordDateFetchCompletionHandler!
    
    var study: Study
    
    init(study: Study){
        self.study = study
    }
    
    func queryAnchorDateForActivityResponseActivities(_ completionHandler: @escaping AnchordDateFetchCompletionHandler) {
        
        print("Log Started - \(Date().timeIntervalSince1970)")
        
        handler = completionHandler
        
        // Get activities from database for anchor date is not present
        let activities = DBHandler.activityResponseEmptyAnchorDateValueActivities(self.study.studyId)
        
        for activity in activities {
            
            let act = User.currentUser.participatedActivites.filter({$0.activityId == activity.sourceActivityId}).last
            
            if act != nil && (act?.status == UserActivityStatus.ActivityStatus.completed) {
                
                let emptyAnchorDateDetail = AnchorDateQueryMetaData()
                emptyAnchorDateDetail.activity = activity
                emptyAnchorDateDetail.sourceKey = activity.sourceKey
                emptyAnchorDateDetail.sourceActivityId = activity.sourceActivityId
                emptyAnchorDateDetail.sourceFormKey = activity.sourceFormKey
                anchorDateMetaDataList.append(emptyAnchorDateDetail)
            }
        }
    
        guard !anchorDateMetaDataList.isEmpty else {
            handler(false)
            return
        }
        
        let queryGroup = DispatchGroup()
        
        for anchorMetaData in anchorDateMetaDataList {
            queryGroup.enter()
            Logger.sharedInstance.info("AD Fetch start:")
            requestAnchorDateForActivityResponse(for: anchorMetaData) {
                Logger.sharedInstance.info("AD Fetch over:")
                queryGroup.leave()
            }
        }
        
        queryGroup.notify(queue: DispatchQueue.main) {
            self.saveAnchorDateInDatabase()
            self.handler(true)
        }
    }
    
    func queryAnchorDateForActivityResponseResources(_ completionHandler: @escaping AnchordDateFetchCompletionHandler){
        
        handler = completionHandler

        let resources = DBHandler.activityResponseEmptyAnchorDateResource(self.study.studyId)

        for resource in resources {
            
            let act = User.currentUser.participatedActivites.filter({$0.activityId == resource.sourceActivityId}).last
            
            if act != nil && (act?.status == UserActivityStatus.ActivityStatus.completed) {
                
                let emptyAnchorDateDetail = AnchorDateQueryMetaData()
                emptyAnchorDateDetail.fetchAnchorDateFor = .resource
                emptyAnchorDateDetail.resource = resource
                emptyAnchorDateDetail.sourceKey = resource.sourceKey
                emptyAnchorDateDetail.sourceActivityId = resource.sourceActivityId
                emptyAnchorDateDetail.sourceFormKey = resource.sourceFormKey
                anchorDateMetaDataList.append(emptyAnchorDateDetail)
            }
        }
        
        guard !anchorDateMetaDataList.isEmpty else {
            handler(false)
            return
        }
        
        let queryGroup = DispatchGroup()
        
        for anchorMetaData in anchorDateMetaDataList {
            queryGroup.enter()
            Logger.sharedInstance.info("AD Fetch start:")
            requestAnchorDateForActivityResponse(for: anchorMetaData) {
                Logger.sharedInstance.info("AD Fetch over:")
                queryGroup.leave()
            }
        }
        
        queryGroup.notify(queue: DispatchQueue.main) {
            self.saveAnchorDateInDatabase()
            self.handler(true)
        }
    }
    
    /// Participant Property values received from Response Server saved in Database.
    /// Saved value will be used to compare from the values Saved on UR Server.
    /// In case DB Saved values is most recent then liftime of that activity has to be calculated again.
    /// Newly calculated then saved UR Server.
    func queryParticipantPropertiesForActivities(_ completionHandler: @escaping AnchordDateFetchCompletionHandler) {
        
        handler = completionHandler
        
        // Get activities from database for anchor date is not present.
        let activities = DBHandler.participantPropertyActivities(self.study.studyId)
        
        for activity in activities {
            
            if activity.hasAnchorDate && !activity.shouldRefresh { // No need to update the anchor values again.
                continue
            }
            
            let emptyAnchorDateDetail = AnchorDateQueryMetaData()
            emptyAnchorDateDetail.fetchAnchorDateFor = .activity
            emptyAnchorDateDetail.activity = activity
            emptyAnchorDateDetail.participantPropertyMetaData = PropertyMetaData() // FIXME: Update type to match with resource
            emptyAnchorDateDetail.participantPropertyMetaData?.propertyId = activity.propertyId ?? ""
            emptyAnchorDateDetail.participantPropertyMetaData?.externalPropertyId = activity.externalPropertyId ?? ""
            emptyAnchorDateDetail.participantPropertyMetaData?.dateOfEntryId = activity.dateOfEntryId ?? ""
            anchorDateMetaDataList.append(emptyAnchorDateDetail)
            // }
            
        }
        
        guard !anchorDateMetaDataList.isEmpty else {
            handler(false)
            return
        }
        
        let queryGroup = DispatchGroup()
        
        for anchorMetaData in anchorDateMetaDataList {
            queryGroup.enter()
            Logger.sharedInstance.info("PP Fetch start:")
            requestAnchorDateForParticipantProperty(for: anchorMetaData) {
                Logger.sharedInstance.info("PP Fetch over:")
                queryGroup.leave()
            }
        }
        
        queryGroup.notify(queue: DispatchQueue.main) {
            self.saveParticipantPropertyAnchorDateInDB()
            self.handler(true)
        }

    }
    
    ///Participant Property values received from Response Server saved in Database.
    ///Saved value will be used to compare from the values Saved on UR Server.
    ///In case DB Saved values is most recent then liftime of that activity has to be calculated again.
    ///Newly calculated then saved UR Server.
    func queryParticipantPropertiesForResources(_ completionHandler: @escaping AnchordDateFetchCompletionHandler) {
        
        handler = completionHandler
        
        // Get resources from database for anchor date is not present & source is PP.
        let resources = DBHandler.participantPropertyResources(self.study.studyId)
        
        for resource in resources {
            if resource.startDate != nil
                && !(resource.participantMetaData?.shouldRefresh ?? false) {
                // No need to update the anchor values again.
                continue
            }
            
            let emptyAnchorDateDetail = AnchorDateQueryMetaData()
            emptyAnchorDateDetail.fetchAnchorDateFor = .resource
            emptyAnchorDateDetail.resource = resource
            if let ppMetaData = resource.participantMetaData {
                emptyAnchorDateDetail.participantPropertyMetaData = PropertyMetaData(ppMetaData: ppMetaData)
                anchorDateMetaDataList.append(emptyAnchorDateDetail)
            } else {
                continue // No need to query when pp data is not available.
            }
        }
        
        guard !anchorDateMetaDataList.isEmpty else {
            handler(false) // Nothing to query about.
            return
        }
        
        let queryGroup = DispatchGroup()
        
        for anchorMetaData in anchorDateMetaDataList {
            queryGroup.enter()
            requestAnchorDateForParticipantProperty(for: anchorMetaData) {
                queryGroup.leave()
            }
        }
        
        queryGroup.notify(queue: .main) {
            self.saveParticipantPropertyAnchorDateInDB()
            self.handler(true)
        }
        
    }
    
    
    func fakePPData() {
        
        for anchorDate in anchorDateMetaDataList {
            
            anchorDate.anchorDate = Date().addingTimeInterval(3600*24*10)
            anchorDate.participantPropertyMetaData?.externalPropertyValue = "x8"
            anchorDate.participantPropertyMetaData?.dateOfEntryValue = "17-11-2017 21:55:44"
        }
        
        self.saveParticipantPropertyAnchorDateInDB()
    }
    
    func requestAnchorDateForParticipantProperty(for emptyAnchorDateDetail: AnchorDateQueryMetaData,
                                               completion:  @escaping () -> Void) {
    
        guard let ppMetaData = emptyAnchorDateDetail.participantPropertyMetaData
            else {
            completion()
            return
        }
        
        let keys = ppMetaData.propertyId + "," + ppMetaData.externalPropertyId + "," + ppMetaData.dateOfEntryId
      
        let tableName = "ParticipantProperties"
        let method = ResponseMethods.executeSQL.method
        let query: String = "SELECT " + keys + " FROM " + tableName
        let participantId: String = (study.userParticipateState.participantId)! //"214b3c8b672c735988df8c139fed8abe"
        var urlString = ResponseServerURLConstants.DevelopmentURL + method.methodName + "?" + kParticipantId + "=" + participantId + "&sql=" + query
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        guard let requstUrl = URL(string: urlString) else {
            completion()
            return
        }
        var request = URLRequest(url: requstUrl, cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: NetworkConnectionConstants.ConnectionTimeoutInterval)
        request.httpMethod = method.methodType.methodTypeAsString
        //request.httpBody = data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                print(error as Any)
                completion()
            } else if let response = response, let data = data {
                
                let status = NetworkConstants.checkResponseHeaders(response)
                let statusCode = status.0
                if statusCode == 200 || statusCode == 0 {
                    
                    guard let responseDict = data.toJSONDictionary(),
                        let rows = responseDict["rows"] as? [JSONDictionary] ,
                        let rowDetail = rows.first,
                        let rowData = rowDetail["data"] as? JSONDictionary else {
                        completion()
                        return
                    }
                    emptyAnchorDateDetail.updateValue(with: rowData)
                    completion()
                } else {
                   completion()
                }
            } else {
                completion()
            }
        })
        dataTask.resume()
    }
    
    func requestAnchorDateForActivityResponse(for emptyAnchorDateDetail: AnchorDateQueryMetaData,
    completion:  @escaping () -> Void) {
        
        let keys = emptyAnchorDateDetail.sourceKey ?? ""
        let formKey: String = emptyAnchorDateDetail.sourceFormKey ?? ""
        let tableName = emptyAnchorDateDetail.sourceActivityId + formKey
        
        
        let method = ResponseMethods.executeSQL.method
        let query:String = "SELECT " + keys + ",Created" + " FROM " + tableName
        
        
        let participantId: String = (self.study.userParticipateState.participantId)! //"214b3c8b672c735988df8c139fed8abe"
        var urlString = ResponseServerURLConstants.DevelopmentURL + method.methodName + "?" + kParticipantId + "=" + participantId + "&sql=" + query
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        guard let requstUrl = URL(string: urlString) else {
            completion()
            return
        }
        
        var request = URLRequest(url: requstUrl, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: NetworkConnectionConstants.ConnectionTimeoutInterval)
        request.httpMethod = method.methodType.methodTypeAsString
        //request.httpBody = data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                print(error as Any)
                completion()
            } else if let response = response, let data = data {
                
                let status = NetworkConstants.checkResponseHeaders(response)
                let statusCode = status.0
                if statusCode == 200 || statusCode == 0 {
                    
                    guard let responseDict = data.toJSONDictionary(),
                        let rows = responseDict["rows"] as? [JSONDictionary] else {
                        completion()
                        return
                    }
                    for rowDetail in rows {
                        if let data =  rowDetail["data"] as? Dictionary<String,Any>{
                            
                            let anchorDateObject = data[emptyAnchorDateDetail.sourceKey] as? [String:String]
                            let anchorDateString = anchorDateObject?["value"]// as! String
                            let date = ResponseDataFetch.labkeyDateFormatter.date(from: anchorDateString!)
                            emptyAnchorDateDetail.anchorDate = date
                        }
                    }
                    completion()
                } else {
                   completion()
                }
            } else {
                completion()
            }
        })
        dataTask.resume()
    }
    
    func saveAnchorDateInDatabase() {
        
        print("Log DB Started - \(Date().timeIntervalSince1970)")
        let listItems = anchorDateMetaDataList.filter({$0.anchorDate != nil})
        for item in listItems {
            print("DB")
            if item.fetchAnchorDateFor == .activity,
                let dbActivity = item.activity,
                let anchorDate = item.anchorDate {
                DBHandler.updateActivityLifeTimeFor(dbActivity, anchorDate: anchorDate)
            } else if item.fetchAnchorDateFor == .resource, let dbResource = item.resource {
                
                var startDateStringEnrollment =  Utilities.formatterShort?.string(from: item.anchorDate!)
                let startTimeEnrollment =  "00:00:00"
                startDateStringEnrollment = (startDateStringEnrollment ?? "") + " " + startTimeEnrollment
                let anchorDate = Utilities.findDateFromString(dateString: startDateStringEnrollment ?? "")
                
                DBHandler.saveLifeTimeFor(resource: dbResource, anchorDate: anchorDate!)
            }
        }
        print("Log DB Finished - \(Date().timeIntervalSince1970)")
    }
    
    func saveParticipantPropertyAnchorDateInDB() {
        
        let listItems = anchorDateMetaDataList.filter({$0.anchorDate != nil})
        for item in listItems {
            if item.fetchAnchorDateFor == .activity, let dbActivity = item.activity {
                
                let oldEXPValue = dbActivity.externalPropertyValue
                let newEXPValue = item.participantPropertyMetaData?.externalPropertyValue
                
                let oldAnchorDate = dbActivity.anchorDateValue
                var newAnchorDate = item.anchorDate
             
                func updateActivity() {
                    guard let anchorDate = item.anchorDate else {return}
                    self.study.activitiesLocalNotificationUpdated = false
                    DBHandler.updateLocalNotificaitonUpdated(studyId: study.studyId, status: false)
                    DBHandler.updateActivityLifeTimeFor(dbActivity,
                    anchorDate: anchorDate,
                    externalIdValue: newEXPValue,
                    dateOfEntryValue: item.participantPropertyMetaData?.dateOfEntryValue)
                }
                
                // Check if any value exists otherwise treat it as new value OR values is updated.
                if oldEXPValue == nil {
                    updateActivity() // First time PP queried.
                } else if oldAnchorDate != newAnchorDate { // Anchor Date updated
                    updateActivity()
                } else if oldEXPValue != newEXPValue {
                    // Save the exp value to DB
                    // TODO: Need to handle this scenario
                }
                
            } else if item.fetchAnchorDateFor == .resource, let dbResource = item.resource {
                // Handle for resource
                print("Handle response here")
                var startDateStringEnrollment =  Utilities.formatterShort?.string(from: item.anchorDate!)
                let startTimeEnrollment =  "00:00:00"
                startDateStringEnrollment = (startDateStringEnrollment ?? "") + " " + startTimeEnrollment
                let anchorDate = Utilities.findDateFromString(dateString: startDateStringEnrollment ?? "")
                let propertyValuesMetaData = item.participantPropertyMetaData
                DBHandler.saveLifeTimeFor(resource: dbResource, anchorDate: anchorDate!, ppMetaData: propertyValuesMetaData)
            }
        }
    }
    
}


