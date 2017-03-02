//
//  User.swift
//  FDA
//
//  Created by Arun Kumar on 2/2/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation


enum UserType:Int{
    case AnonymousUser = 0
    case FDAUser
}

enum LogoutReason:String{
    case user_action
    case error
    case security_jailbroken
}





let kUserValueForOS = "ios"




//MARK: User
class User{
    
    var firstName : String?
    var lastName :String?
    var emailId : String?
    var settings : Settings?
    var userType : UserType?
    var userId : String!
    var password : String? = ""
    var confirmPassword : String? = ""
    var verified : Bool!
    var authToken: String!
    var participatedStudies:Array<UserStudyStatus>! = []
    var participatedActivites:Array<UserActivityStatus>! = []
    var logoutReason : LogoutReason = .user_action
    
    //sharedInstance
    static var currentUser = User()
    
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.emailId  = ""
        self.settings = Settings()
        self.userType = UserType.AnonymousUser
        self.userId = ""
        self.verified = false
    }
    
    init(firstName:String?,lastName:String?,emailId: String?,userType: UserType?,userId:String?){
        self.firstName = firstName
        self.lastName = lastName
        self.emailId = emailId
        self.userType = userType
        self.userId = userId
    }
    
    func setFirstName(firstName:String) {
        self.firstName = firstName
    }
    func setLastName(lastName:String) {
        self.lastName = lastName
    }
    func setEmailId(emailId:String) {
        self.emailId = emailId
    }
    func setUserType(userType:UserType) {
        self.userType = userType
    }
    func setUserId(userId:String) {
        self.userId = userId
    }
    func getFullName() -> String {
        return firstName! + " " + lastName!
    }
    
    func setUser(dict:NSDictionary)  {
        
        if Utilities.isValidObject(someObject: dict){
            
            if Utilities.isValidValue(someObject: dict[kUserFirstName] as AnyObject ){
                self.firstName = dict[kUserFirstName] as? String
            }
            if Utilities.isValidValue(someObject: dict[kUserLastName] as AnyObject ){
                self.lastName = dict[kUserLastName] as? String
            }
            if Utilities.isValidValue(someObject: dict[kUserEmailId] as AnyObject ){
                self.emailId = dict[kUserEmailId] as? String
            }
            if Utilities.isValidObject(someObject: dict[kUserSettings] as AnyObject ) {
                self.settings?.setSettings(dict: dict[kUserSettings] as! NSDictionary)
            }
            if Utilities.isValidValue(someObject: dict[kUserId] as AnyObject )  {
                self.userId = dict[kUserId] as? String
            }
        }
        else{
            Logger.sharedInstance.debug("User Dictionary is null:\(dict)")
        }
        
        
        
    }
    func getUserProfileDict() -> NSMutableDictionary {
        let dataDict = NSMutableDictionary()
        
        if self.userType == .FDAUser {
            
            if self.userId != nil{
                dataDict.setValue(self.userId, forKey:(kUserId as NSCopying) as! String)
            }
            let profileDict = NSMutableDictionary()
            
            
            if self.firstName != nil{
                profileDict.setValue(self.firstName, forKey:(kUserFirstName as NSCopying) as! String)
            }
            else{
                profileDict.setValue("", forKey:(kUserFirstName as NSCopying) as! String)
            }
            if self.lastName != nil{
                profileDict.setValue(self.lastName, forKey:(kUserLastName as NSCopying) as! String)
            }
            else{
                profileDict.setValue("", forKey:(kUserLastName as NSCopying) as! String)
            }
            
            let infoDict = NSMutableDictionary()
            
            infoDict.setValue(kUserValueForOS, forKey:kUserOS)
            
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                infoDict.setValue(version, forKey:kUserAppVersion)
            }
            
            dataDict.setObject(profileDict, forKey:kUserProfile as NSCopying)
            dataDict.setObject(profileDict, forKey:kUserInfo as NSCopying)
            
        }
        
        return dataDict
        
    }
    
    //MARK:Study Bookmark
    func isStudyBookmarked(studyId:String) -> Bool{
        
        let studies = self.participatedStudies as Array<UserStudyStatus>
        if let study =   studies.filter({$0.studyId == studyId}).first {
            return study.bookmarked
        }
        return false
        
    }
    
    
    func bookmarkStudy(studyId:String){
        
      
        let studies = self.participatedStudies as Array<UserStudyStatus>
        if let study =   studies.filter({$0.studyId == studyId}).first {
            study.bookmarked = true
            Logger.sharedInstance.info("Bookmark: study is bookmarked : \(studyId)")
        }
        else {
            Logger.sharedInstance.info("Bookmark: study not found : \(studyId)")
            
            let studyStatus = UserStudyStatus()
            studyStatus.bookmarked = true
            
            self.participatedStudies.append(studyStatus)
            
            Logger.sharedInstance.info("Bookmark: study is bookmarked : \(studyId)")
        }
      
    }
    
    func removeBookbarkStudy(studyId:String){
        
        let studies = self.participatedStudies as Array<UserStudyStatus>
        if let study =   studies.filter({$0.studyId == studyId}).first {
            study.bookmarked = false
            Logger.sharedInstance.info("Bookmark: study is removed from bookmark : \(studyId)")
        }
    }
    
    
    //MARK:Activity Bookmark
    func isActivityBookmarked(studyId:String,activityId:String) -> Bool{
        
        let activityes = self.participatedActivites as Array<UserActivityStatus>
        if let activity =   activityes.filter({$0.studyId == studyId && $0.activityId == activityId}).first {
            return activity.bookmarked
        }
        return false
        
    }
    
    
    func bookmarkActivity(studyId:String,activityId:String){
        
        
        let activityes = self.participatedActivites as Array<UserActivityStatus>
        if let activity =   activityes.filter({$0.studyId == studyId && $0.activityId == activityId}).first {
            activity.bookmarked = true
            Logger.sharedInstance.info("Bookmark: activity is bookmarked : \(studyId)")
        }
        else {
            Logger.sharedInstance.info("Bookmark: activity not found : \(studyId)")
            
            let activityStatus = UserActivityStatus()
            activityStatus.bookmarked = true
            
            self.participatedActivites.append(activityStatus)
            
            Logger.sharedInstance.info("Bookmark: activity is bookmarked : \(studyId)")
        }
        
    }
    
    func removeBookbarkActivity(studyId:String,activityId:String){
        
        let activityes = self.participatedActivites as Array<UserActivityStatus>
        if let activity =   activityes.filter({$0.studyId == studyId && $0.activityId == activityId}).first {
            activity.bookmarked = true
            Logger.sharedInstance.info("Bookmark: activity is removed from bookmarked : \(studyId)")
        }
    }
    
     //MARK:Study Status
    func updateStudyStatus(studyId:String,status:UserStudyStatus.StudyStatus){
        
        let studies = self.participatedStudies as Array<UserStudyStatus>
        if let study =   studies.filter({$0.studyId == studyId}).first {
            study.status = status
            Logger.sharedInstance.info("User Study Status: study is updated : \(studyId)")
        }
        else {
            Logger.sharedInstance.info("User Study Status: study not found : \(studyId)")
            
            let studyStatus = UserStudyStatus()
            studyStatus.status = status
            
            self.participatedStudies.append(studyStatus)
            
            Logger.sharedInstance.info("User Study Status: study is updated : \(studyId)")
        }
    }
    
    func getStudyStatus(studyId:String) -> UserStudyStatus.StudyStatus{
        
        let studies = self.participatedStudies as Array<UserStudyStatus>
        if let study =   studies.filter({$0.studyId == studyId}).first {
           return study.status
        }
        return .yetToJoin
    }
    
    //MARK:Activity Status
    func updateActivityStatus(studyId:String,activityId:String,status:UserActivityStatus.ActivityStatus){
        
        let activityes = self.participatedActivites as Array<UserActivityStatus>
        if let activity =   activityes.filter({$0.studyId == studyId && $0.activityId == activityId}).first {
            activity.status = status
            Logger.sharedInstance.info("User Activity Status: activity is updated : \(studyId)")
        }
        else {
            Logger.sharedInstance.info("User Activity Status: activity not found : \(studyId)")
            
            let activityStatus = UserActivityStatus()
            activityStatus.status = status
            self.participatedActivites.append(activityStatus)
            
            Logger.sharedInstance.info("User Activity Status: activity is updated : \(studyId)")
        }
    }
    
    func getActivityStatus(studyId:String,activityId:String) -> UserActivityStatus.ActivityStatus?{
        
        let activityes = self.participatedActivites as Array<UserActivityStatus>
        if let activity =   activityes.filter({$0.studyId == studyId && $0.activityId == activityId}).first {
            return activity.status
        }
        return .yetToJoin
    }

    
}

//MARK:User Settings
class Settings{

    var remoteNotifications : Bool?
    var localNotifications :Bool?
    var touchId :Bool?
    var passcode :Bool?
    
    init() {
        self.remoteNotifications = false
        self.localNotifications = false
        self.touchId  = false
        self.passcode = false
    }
    
    init(remoteNotifications:Bool?,localNotifications:Bool?,touchId: Bool?,passcode:Bool?){
        self.remoteNotifications = remoteNotifications
        self.localNotifications = localNotifications
        self.touchId = touchId
        self.passcode = passcode
    }
    
    func setRemoteNotification(value : Bool){
            self.remoteNotifications = value 
    }
    func setLocalNotification(value : Bool){
        self.localNotifications = value
    }
    func setTouchId(value : Bool){
        self.touchId = value
    }
    func setPasscode(value : Bool){
        self.passcode = value
    }
    
    
    func setSettings(dict:NSDictionary)  {
        
        if Utilities.isValidObject(someObject: dict){
            
            if  Utilities.isValidValue(someObject: dict[kSettingsRemoteNotifications] as AnyObject){
                self.remoteNotifications = dict[kSettingsRemoteNotifications] as? Bool
            }
            if Utilities.isValidValue(someObject: dict[kSettingsLocalNotifications] as AnyObject){
                self.localNotifications = dict[kSettingsLocalNotifications] as? Bool
            }
            if Utilities.isValidValue(someObject: dict[kSettingsPassCode] as AnyObject){
                self.passcode = dict[kSettingsPassCode] as? Bool
            }
            if Utilities.isValidValue(someObject: dict[kSettingsTouchId] as AnyObject){
                self.touchId = dict[kSettingsTouchId] as? Bool
            }
            
        }
        else{
            Logger.sharedInstance.debug("Settings Dictionary is null:\(dict)")
        }
        
        
    }
}

//MARK: StudyStatus
class UserStudyStatus{
    
    enum StudyStatus:Int {
        
        case yetToJoin
        case notEligible
        case inProgress
        case completed
        case withdrawn
        
        var description:String {
            switch self {
            case .yetToJoin:
                return "Yet To Join"
            case .inProgress:
                return "In Progress"
            case.completed:
                return "Completed"
            case .notEligible:
                return "Not Eligible"
            case .withdrawn:
                return "Withdrawn"
           
            }
        }
    }
    
    var bookmarked:Bool = false
    var studyId:String! = ""
    var status:StudyStatus = .yetToJoin
    var consent:String! = ""
    
    init() {
        
    }
    
     init(detail:Dictionary<String, Any>){
        
        if Utilities.isValidObject(someObject: detail as AnyObject?){
            
            if  Utilities.isValidValue(someObject: detail[kStudyId] as AnyObject){
                self.studyId = detail[kStudyId] as! String
            }
            if Utilities.isValidValue(someObject: detail[kBookmarked] as AnyObject){
                self.bookmarked = detail[kBookmarked] as! Bool
            }
            if Utilities.isValidValue(someObject: detail[kStatus] as AnyObject){
                
                let statusValue = detail[kStatus] as! String
                
                if (StudyStatus.inProgress.description == statusValue) {
                    self.status = .inProgress
                }
                else if (StudyStatus.notEligible.description == statusValue) {
                    self.status = .notEligible
                }
                else if (StudyStatus.completed.description == statusValue) {
                    self.status = .completed
                }
                else if (StudyStatus.withdrawn.description == statusValue) {
                    self.status = .withdrawn
                }
            }
           
            
        }
        else{
            Logger.sharedInstance.debug("UserStudyStatus Dictionary is null:\(detail)")
        }
        
       

    }
    
}

//MARK: ActivityStatus
class UserActivityStatus{
    
    enum ActivityStatus {
        case yetToJoin
        case inProgress
        case completed
        case abandoned
        
        var description:String {
            switch self {
            case .yetToJoin:
                return "Yet To Join"
            case .inProgress:
                return "In Progress"
            case.completed:
                return "Completed"
            case .abandoned:
                return "Abandoned"
                
            }
        }
    }
    
    var bookmarked:Bool = false
    var activityId:String! = ""
    var studyId:String! = ""
    var activityVersion:String! = ""
    var status:ActivityStatus? = .yetToJoin
    init() {
        
    }
    init(detail:Dictionary<String, Any>){
        
        if Utilities.isValidObject(someObject: detail as AnyObject?){
            
            if  Utilities.isValidValue(someObject: detail[kStudyId] as AnyObject){
                self.studyId = detail[kStudyId] as! String
            }
            if  Utilities.isValidValue(someObject: detail[kActivityId] as AnyObject){
                self.activityId = detail[kActivityId] as! String
            }
            if  Utilities.isValidValue(someObject: detail[kActivityVersion] as AnyObject){
                self.activityVersion = detail[kActivityVersion] as! String
            }
            if Utilities.isValidValue(someObject: detail[kBookmarked] as AnyObject){
                self.bookmarked = detail[kBookmarked] as! Bool
            }
            
            
            if Utilities.isValidValue(someObject: detail[kStatus] as AnyObject){
                
                let statusValue = detail[kStatus] as! String
                
                if (ActivityStatus.inProgress.description == statusValue) {
                    self.status = .inProgress
                }
                else if (ActivityStatus.completed.description == statusValue) {
                    self.status = .completed
                }
                else if (ActivityStatus.abandoned.description == statusValue) {
                    self.status = .abandoned
                }
            }
            
            
        }
        else{
            Logger.sharedInstance.debug("UserStudyStatus Dictionary is null:\(detail)")
        }
        
      
        
    }
    
}
