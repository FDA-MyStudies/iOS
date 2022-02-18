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

import Foundation
import Realm

enum ResourceLevel: String{
    
    case gateway = "gateway"
    case study = "study"
}

enum ResourceAvailabilityType: String {
    case regular = "Regular"
    case anchorDate = "AnchorDate"
}

let kResourceLevel = "level"
let kResourceKey = "key"
let kResourceType = "type"
let kResourceFile = "file"
let kResourceConfigration = "availability"
let kResourceTitle = "title"
let kResourceId = "resourcesId"
let kResourceAudience = "audience"

// MARK: - PropertyMetadata
class ParticipantPropertyMetadata {

    let propertyType, propertyDataFormat: String!
    let shouldRefresh: Bool!
    let dataSource, status : String!
    let externalPropertyID, propertyID, dateOfEntryID: String!
    var externalPropertyValue, propertyValue, dateOfEntryValue: String?
    
    init(dict: JSONDictionary) {
        self.propertyType = dict[JSONKey.propertyType] as? String ?? ""
        self.propertyID = dict[JSONKey.propertyID] as? String ?? ""
        self.propertyDataFormat = dict[JSONKey.propertyDataFormat] as? String ?? ""
        self.shouldRefresh = dict[JSONKey.shouldRefresh] as? Bool ?? false
        self.dataSource = dict[JSONKey.dataSource] as? String ?? ""
        self.status = dict[JSONKey.status] as? String ?? ""
        self.externalPropertyID = dict[JSONKey.externalPropertyID] as? String ?? ""
        self.dateOfEntryID = dict[JSONKey.dateOfEntryID] as? String ?? ""
    }
    
    init(ppMetaData: DBParticipantPropertyMetadata) {
        self.propertyType = ppMetaData.propertyType
        self.propertyID = ppMetaData.propertyID
        self.propertyDataFormat = ppMetaData.propertyDataFormat
        self.shouldRefresh = ppMetaData.shouldRefresh
        self.dataSource = ppMetaData.dataSource
        self.status = ppMetaData.status
        self.externalPropertyID = ppMetaData.externalPropertyID
        self.dateOfEntryID = ppMetaData.dateOfEntryID
        self.externalPropertyValue = ppMetaData.externalPropertyValue
        self.dateOfEntryValue = ppMetaData.dateOfEntryValue
        self.propertyValue = ppMetaData.propertyValue
    }
    
    // MARK: - Enums and Structs
    private enum JSONKey {
        static let propertyType = "propertyType"
        static let propertyID = "propertyId"
        static let propertyDataFormat = "propertyDataFormat"
        static let shouldRefresh = "shouldRefresh"
        static let dataSource = "dataSource"
        static let status = "status"
        static let externalPropertyID = "externalPropertyId"
        static let dateOfEntryID = "dateOfEntryId"
    }
    
    
}

// MARK: - Resource model stores the resource of any Study or Gateway. Each resource has a unique id and have file and anchor data.
class Resource {
    var level: ResourceLevel?
    var key: String?
    var type: String?
    var notificationMessage: String?
    var file: File?
    var audience: Audience?
    var resourcesId: String?
    var configration: Dictionary<String, Any>?
    var startDate: Date?
    var endDate: Date?
    var anchorDateStartDays: Int?
    var anchorDateEndDays: Int?
    var title: String?
    var povAvailable: Bool = false
    
    //AnchorDate Values
    var availabilityType : ResourceAvailabilityType = .regular
    var sourceType : AnchorDateSourceType?
    var sourceActivityId : String?
    var sourceFormKey : String?
    var sourceKey : String?
    var startTime : String?
    var endTime : String?
    var availableToday = false
    
    var ppMetaData: ParticipantPropertyMetadata?
    
    /**
     Default Initializer
     */
    init() {
        self.level = ResourceLevel.gateway
        self.key = ""
        self.type  = ""
        self.file = File()
        self.configration = Dictionary()
        self.title = ""
    }
    /**
     initializer method with ditionary of properties
     */
    init(detail: Dictionary<String, Any>) {
        
        if Utilities.isValidObject(someObject: detail as AnyObject?){
            
            if (Utilities.isValidValue(someObject: (detail[kResourceId]) as AnyObject)) {
                self.resourcesId = detail[kResourceId] as? String
            }
            if (Utilities.isValidValue(someObject: (detail[kResourceAudience]) as AnyObject)) {
                self.audience = Audience(rawValue:detail[kResourceAudience] as! String)
            }
            if (Utilities.isValidValue(someObject: (detail[kResourceLevel]) as AnyObject)) {
                self.level = detail[kResourceLevel] as? ResourceLevel
            }
            if (Utilities.isValidValue(someObject: (detail[kResourceKey]) as AnyObject)){
                self.key = detail[kResourceKey] as? String
            }
            if (Utilities.isValidValue(someObject: (detail[kResourceType]) as AnyObject)) {
                self.type = detail[kResourceType] as? String
            }
            if (Utilities.isValidValue(someObject: (detail[kResourceFile]) as AnyObject)) {
                self.file?.setFile(dict: detail[kResourceFile] as? JSONDictionary ?? [:])
            }
            if (Utilities.isValidValue(someObject: (detail["notificationText"]) as AnyObject)){
                self.notificationMessage = detail["notificationText"] as? String
            }
            
            //Setting the configuration if any
            if (Utilities.isValidObject(someObject: detail[kResourceConfigration] as AnyObject)) {
                let configuration = detail[kResourceConfigration] as! Dictionary<String,Any>
                self.povAvailable = true
                
                if (Utilities.isValidValue(someObject: (configuration["availableDate"]) as AnyObject)) {
                    self.startDate = Utilities.getDateFromStringWithFormat("YYYY-MM-dd", resultDate: configuration["availableDate"] as! String)
                }
                if (Utilities.isValidValue(someObject: (configuration["expiryDate"]) as AnyObject)) {
                    self.endDate = Utilities.getDateFromStringWithFormat("YYYY-MM-dd", resultDate: configuration["expiryDate"] as! String)
                }
                
                self.anchorDateStartDays = configuration["startDays"] as? Int
                self.anchorDateEndDays = configuration["endDays"] as? Int
                
                if (Utilities.isValidValue(someObject: (configuration["availabilityType"]) as AnyObject)){
                    self.availabilityType =  ResourceAvailabilityType(rawValue: configuration["availabilityType"] as? String ?? "Regular")!
                }
                
                if (Utilities.isValidValue(someObject: (configuration["sourceType"]) as AnyObject)){
                    self.sourceType =  AnchorDateSourceType(rawValue: configuration["sourceType"] as? String ?? "EnrollmentDate")!
                }
                
                if (Utilities.isValidValue(someObject: (configuration["sourceActivityId"]) as AnyObject)){
                    self.sourceActivityId = configuration["sourceActivityId"] as? String
                }
                
                if (Utilities.isValidValue(someObject: (configuration["sourceKey"]) as AnyObject)){
                    self.sourceKey = configuration["sourceKey"] as? String
                }
                
                if (Utilities.isValidValue(someObject: (configuration["startTime"]) as AnyObject)){
                    self.startTime = configuration["startTime"] as? String
                }
                if (Utilities.isValidValue(someObject: (configuration["endTime"]) as AnyObject)){
                    self.endTime = configuration["endTime"] as? String
                }

            } else {
                self.povAvailable = false
            }
            
            if (Utilities.isValidValue(someObject: (detail[kResourceTitle]) as AnyObject)) {
                print("Krishna resource Title: \(detail[kResourceTitle])")
                print("Krishna resource localised Title: \(NSLocalizedStrings(detail[kResourceTitle] as! String, comment: ""))")
                self.title = detail[kResourceTitle] as? String
            }
            self.file = File()
            self.file?.setFileForStudy(dict: detail)
        } else {
            Logger.sharedInstance.debug("Resource Dictionary is null:\(detail)")
        }
    }
    
    /**
     Setter method for resource
     @param dict, dictionary of properties of resource
     */
    func setResourceForStudy(dict: JSONDictionary) {
        
        self.title = dict[kResourceTitle] as? String ?? ""
        self.resourcesId = dict[kResourceId] as? String
        self.audience = Audience(rawValue:dict[kResourceAudience] as? String ?? "")
        self.level = ResourceLevel.study
        self.key = dict[kResourceKey] as? String
        self.type = dict[kResourceType] as? String
        self.notificationMessage = dict["notificationText"] as? String
        
        if self.level != nil {
            if self.level == ResourceLevel.study {
                // Study Level
                self.file?.setFileForStudy(dict: dict)
            } else if self.level == ResourceLevel.gateway {
                // Gateway Level
                self.file?.setFile(dict: dict[kResourceFile] as? JSONDictionary ?? [:])
            }
        }
        
        if let availability = dict[kResourceConfigration] as? JSONDictionary, !availability.isEmpty {
            
            self.povAvailable = true
            
            if let availableDate = availability["availableDate"] as? String {
                self.startDate = Utilities.getDateFromStringWithFormat("YYYY-MM-dd", resultDate: availableDate)
            }
            if let expiryDate = availability["expiryDate"] as? String {
                 self.endDate = Utilities.getDateFromStringWithFormat("YYYY-MM-dd", resultDate: expiryDate)
            }
           
            self.anchorDateStartDays = availability["startDays"] as? Int
            self.anchorDateEndDays = availability["endDays"] as? Int
            self.availabilityType =  ResourceAvailabilityType(rawValue: availability["availabilityType"] as? String ?? "Regular")!
            self.sourceType =  AnchorDateSourceType(rawValue: availability["sourceType"] as? String ?? "EnrollmentDate")!
            self.sourceActivityId = availability["sourceActivityId"] as? String
            self.sourceKey = availability["sourceKey"] as? String
            self.sourceFormKey = availability["sourceFormKey"] as? String
            self.startTime = availability["startTime"] as? String
            self.endTime = availability["endTime"] as? String
            
            if let propertyMetaDataDict = availability["propertyMetadata"] as? JSONDictionary {
                self.ppMetaData = ParticipantPropertyMetadata(dict: propertyMetaDataDict)
            }
        }
        
        self.calculateAvailability() // When source type is enrollmentDate
    }
    
    
    func calculateAvailability() {
        
        if self.sourceType == AnchorDateSourceType.enrollmentDate {
            var enrollmentDate = Study.currentStudy?.userParticipateState.joiningDate
            
            //update start date
            var startDateStringEnrollment =  Utilities.formatterShort?.string(from: enrollmentDate!)
            let startTimeEnrollment =  "00:00:00"
            startDateStringEnrollment = (startDateStringEnrollment ?? "") + " " + startTimeEnrollment
            enrollmentDate = Utilities.findDateFromString(dateString: startDateStringEnrollment ?? "")
            
           
            let lifeTime = self.updateLifeTime(enrollmentDate!)
            
            //update start date
            var startDateString =  Utilities.formatterShort?.string(from: lifeTime.0!)
            let startTime =  (self.startTime == nil) ? "00:00:00" : (self.startTime)!
            startDateString = (startDateString ?? "") + " " + startTime
            let startdate = Utilities.findDateFromString(dateString: startDateString ?? "")
            
            //update end date
            var endDateString =  Utilities.formatterShort?.string(from: lifeTime.1!)
            let endTime =  (self.endTime == nil) ? "23:59:59" : (self.endTime)!
            endDateString = (endDateString ?? "") + " " + endTime
            let endDate = Utilities.findDateFromString(dateString: endDateString ?? "")
            
            self.startDate = startdate
            self.endDate = endDate
        }
    }
    
    func updateLifeTime(_ date:Date) -> (Date?,Date?) {
        
        var startDate:Date!
        var endDate:Date!
        
        let startDateInterval = TimeInterval(60*60*24*(self.anchorDateStartDays)!)
        let endDateInterval = TimeInterval(60*60*24*(self.anchorDateEndDays)!)
        
        startDate = date.addingTimeInterval(startDateInterval)
        endDate = date.addingTimeInterval(endDateInterval)
        return (startDate,endDate)
          
    }
}
