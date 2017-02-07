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


//MARK: ApiConstants
let kApiKeyFirstName = "firstName"
let kApiKeyLastName = "lastName"
let kApiKeyEmailId = "emailId"
let kApiKeySettings = "settings"
let kApiKeyUserId = "userId"
let kApiKeyProfile = "profile"
let kApiKeyInfo = "info"
let kApiKeyOS = "os"
let kApiKeyAppVersion = "appVersion"


let kValueForOS = "ios"


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
        if (dict["firstName"]) != nil{
            self.firstName = dict["firstName"] as? String
        }
        if (dict["lastName"]) != nil{
             self.lastName = dict["lastName"] as? String
        }
        if (dict["emailId"]) != nil{
            self.emailId = dict["emailId"] as? String
        }
        if (dict["settings"]) != nil {
            self.settings?.setSettings(dict: dict["settings"] as! NSDictionary)
        }
        if (dict["userId"]) != nil {
            self.userId = dict["userId"] as? String
        }
        
    }
    func getUserProfileDict() -> NSMutableDictionary {
        let dataDict = NSMutableDictionary()
        
        if self.userType == .FDAuser {
            
            if self.userId != nil{
                dataDict.setValue(self.userId, forKey:(kApiKeyUserId as NSCopying) as! String)
            }
            let profileDict = NSMutableDictionary()
            
           
            if self.firstName != nil{
                profileDict.setValue(self.firstName, forKey:(kApiKeyFirstName as NSCopying) as! String)
            }
            else{
                profileDict.setValue("", forKey:(kApiKeyFirstName as NSCopying) as! String)
            }
            if self.lastName != nil{
                profileDict.setValue(self.lastName, forKey:(kApiKeyLastName as NSCopying) as! String)
            }
            else{
                profileDict.setValue("", forKey:(kApiKeyLastName as NSCopying) as! String)
            }
            
            let infoDict = NSMutableDictionary()
            
            infoDict.setValue(kValueForOS, forKey:kApiKeyOS)
           
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                 infoDict.setValue(version, forKey:kApiKeyAppVersion)
            }
            
            dataDict.setObject(profileDict, forKey:kApiKeyProfile as NSCopying)
            dataDict.setObject(profileDict, forKey:kApiKeyInfo as NSCopying)
            
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
        if (dict["remoteNotifications"]) != nil{
            self.remoteNotifications = dict["remoteNotifications"] as? Bool
        }
        if (dict["localNotifications"]) != nil{
            self.localNotifications = dict["localNotifications"] as? Bool
        }
        if (dict["passCode"]) != nil{
            self.passcode = dict["passCode"] as? Bool
        }
        if (dict["touchId"]) != nil{
            self.touchId = dict["touchId"] as? Bool
        }
    }
}
