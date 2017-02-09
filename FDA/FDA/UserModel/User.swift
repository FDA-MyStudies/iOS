//
//  User.swift
//  FDA
//
//  Created by Arun Kumar on 2/2/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation


enum UserType:Int{
    case ananomous = 0
    case FDAuser
}


//MARK: UserApiConstants
let kUserFirstName = "firstName"
let kUserLastName = "lastName"
let kUserEmailId = "emailId"
let kUserSettings = "settings"
let kUserUserId = "userId"
let kUserProfile = "profile"
let kUserInfo = "info"
let kUserOS = "os"
let kUserAppVersion = "appVersion"


let kUserValueForOS = "ios"

//MARK: Settings Api Constants

let kSettingsRemoteNotifications = "remoteNotifications"
let kSettingsLocalNotifications = "localNotifications"
let kSettingsPassCode = "passCode"
let kSettingsTouchId = "touchId"


//MARK: User
class User{
    var firstName : String?
    var lastName :String?
    var emailId : String?
    var settings : Settings?
    var userType : UserType?
    var userId : String?
    
    
    init() {
         self.firstName = ""
        self.lastName = ""
         self.emailId  = ""
        self.settings = Settings()
        self.userType = UserType.ananomous
        self.userId = ""
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
            if Utilities.isValidValue(someObject: dict[kUserUserId] as AnyObject )  {
                self.userId = dict[kUserUserId] as? String
            }
        }
        else{
            Logger.sharedInstance.debug("User Dictionary is null:\(dict)")
        }
        
        
        
    }
    func getUserProfileDict() -> NSMutableDictionary {
        let dataDict = NSMutableDictionary()
        
        if self.userType == .FDAuser {
            
            if self.userId != nil{
                dataDict.setValue(self.userId, forKey:(kUserUserId as NSCopying) as! String)
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
