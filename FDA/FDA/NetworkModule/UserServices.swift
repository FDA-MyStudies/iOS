//
//  UserServices.swift
//  FDA
//
//  Created by Surender Rathore on 2/9/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

//common keys
let kAppVersion = "appVersion"
let kOSType = "os"

//MARK: Registration Server API Constants
let kUserFirstName = "firstName"
let kUserLastName = "lastName"
let kUserEmailId = "emailId"
let kUserSettings = "settings"
let kUserId = "userId"
let kUserProfile = "profile"
let kUserInfo = "info"
let kUserOS = "os"
let kUserAppVersion = "appVersion"
let kUserPassword = "password"
let kUserLogoutReason = "reason"
let kBasicInfo = "info"
let kStudyId = "studyId"
let kDeleteData = "deleteData"
let kUserVerified = "verified"
let kUserAuthToken = "auth"
let kStudies = "studies"
let kActivites = "activities"
let kConsent = "consent"
let kUserEligibilityStatus = "eligbibilityStatus"
let kUserConsentStatus =  "consentStatus"

//MARK: Settings Api Constants
let kSettingsRemoteNotifications = "remoteNotifications"
let kSettingsLocalNotifications = "localNotifications"
let kSettingsPassCode = "passCode"
let kSettingsTouchId = "touchId"

let kBookmarked = "bookmarked"
let kStatus = "status"
let kActivityId = "activityId"
let kActivityVersion = "activityVersion"


class UserServices: NSObject {
    
    let networkManager = NetworkManager.sharedInstance()
    var delegate:NMWebServiceDelegate! = nil
    
     //MARK: Requests
    func loginUser(_:NMWebServiceDelegate){
        
        let user = User.currentUser
        let params = [kUserEmailId : user.emailId,
                      kUserPassword: user.password]
        
        let method = RegistrationMethods.login.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    func registerUser(_:NMWebServiceDelegate){
        
        let user = User.currentUser
        let params = [kUserEmailId : user.emailId,
                      kUserFirstName : user.firstName,
                      kUserLastName : user.lastName,
                      kUserPassword: user.password]
        let method = RegistrationMethods.register.method
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    func confirmUserRegistration(_:NMWebServiceDelegate){
        
        let user = User.currentUser
        let params = [kUserId : user.userId]
        let method = RegistrationMethods.confirmRegistration.method
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    func logoutUser(_:NMWebServiceDelegate){
        
        let user = User.currentUser
        let params = [kUserId : user.userId,
                      kUserLogoutReason: user.logoutReason.rawValue]
        let method = RegistrationMethods.logout.method
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    func forgotPassword(_:NMWebServiceDelegate){
        
        let user = User.currentUser
        let params = [kUserEmailId : user.emailId]
        
        let method = RegistrationMethods.forgotPassword.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getUserProfile(_:NMWebServiceDelegate){
        
        let user = User.currentUser
        let params = [kUserId : user.userId]
        
        let method = RegistrationMethods.userProfile.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }

    func updateUserProfile(_:NMWebServiceDelegate){
        
        let user = User.currentUser
        
        let profile = [kUserFirstName : user.firstName,
                       kUserLastName : user.lastName]
        
        let version = Utilities.getAppVersion()
        let info = [kAppVersion : version,
                    kOSType :"ios"]
        
        let params = [kUserId : user.userId! as String,
                      kUserProfile:profile,
                      kBasicInfo:info] as [String : Any]
        
        let method = RegistrationMethods.updateUserProfile.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getUserPreference(_:NMWebServiceDelegate){
        
        let user = User.currentUser
        let params = [kUserId : user.userId]
        
        let method = RegistrationMethods.userPreferences.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func updateUserPreference(_:NMWebServiceDelegate){
        
        //INCOMPLETE
        let user = User.currentUser
        let params = [kUserId : user.userId]
        let method = RegistrationMethods.updatePreferences.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func updateUserEligibilityConsentStatus(_:NMWebServiceDelegate){
        
        //INCOMPLETE
        let user = User.currentUser
        let params = [kUserId : user.userId]
        let method = RegistrationMethods.updateEligibilityConsentStatus.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getConsentPDFForStudy(studyId:String , delegate:NMWebServiceDelegate) {
        
        let user = User.currentUser
        let params = [kUserId : user.userId,
                      kStudyId: studyId]
        
        let method = RegistrationMethods.consentPDF.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func updateUserActivityState(){
        
        //INCOMPLETE
         let method = RegistrationMethods.updateActivityState.method
    }
    
    func getUserActivityState(studyId:String , delegate:NMWebServiceDelegate) {
        
        let user = User.currentUser
        let params = [kUserId : user.userId,
                      kStudyId: studyId]
        
        let method = RegistrationMethods.activityState.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func withdrawFromStudy(studyId:String ,shouldDeleteData:Bool, delegate:NMWebServiceDelegate){
        
        let user = User.currentUser
        let params = [kUserId : user.userId! as String,
                      kStudyId: studyId,
                      kDeleteData: shouldDeleteData] as [String : Any]
        
        let method = RegistrationMethods.withdraw.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    
     //MARK:Parsers
    func handleUserLoginResponse(response:Dictionary<String, Any>){
        
        let user = User.currentUser
        user.userId     = response[kUserId] as! String
        user.verified   = response[kUserVerified] as! Bool
        user.authToken  = response[kUserAuthToken] as! String
    }
    
    func handleUserRegistrationResponse(response:Dictionary<String, Any>){
        
        let user = User.currentUser
        user.userId     = response[kUserId] as! String
        user.verified   = response[kUserVerified] as! Bool
        user.authToken  = response[kUserAuthToken] as! String

    }
    
    func handleConfirmRegistrationResponse(response:Dictionary<String, Any>){
        
        let user = User.currentUser
        user.verified   = response[kUserVerified] as! Bool
    }
    
    func handleUpdateUserProfileResponse(response:Dictionary<String, Any>){
        //INCOMPLETE
        

    }
    
    func handleGetPreferenceResponse(response:Dictionary<String, Any>){
        
        let user = User.currentUser
        
        //settings
        let settings = response[kUserSettings] as! Dictionary<String, Any>
        let userSettings = Settings()
        userSettings.setSettings(dict: settings as NSDictionary)
        user.settings = userSettings
        
        //studies
        let studies = response[kStudies] as! Array<Dictionary<String, Any>>
        
        for study in studies {
            let participatedStudy = UserStudyStatus(detail: study)
            user.participatedStudies.append(participatedStudy)
        }
        
        //activities
        let activites = response[kActivites]  as! Array<Dictionary<String, Any>>
        for activity in activites {
            let participatedActivity = UserActivityStatus(detail: activity)
            user.participatedActivites.append(participatedActivity)
        }
    }
    
    func handleUpdateEligibilityConsentStatusResponse(response:Dictionary<String, Any>){
        
       
        
    }
    
    func handleGetConsentPDFResponse(response:Dictionary<String, Any>){
        
        let user = User.currentUser
        if Utilities.isValidValue(someObject: response[kConsent] as AnyObject?) {
           // user.consent = response[kConsent] as! String
        }
    }
    
    func handleUpdateActivityStateResponse(response:Dictionary<String, Any>){
        
    }
    
    func handleGetActivityStateResponse(response:Dictionary<String, Any>){
        
        let user = User.currentUser
        
        //activities
        let activites = response[kActivites]  as! Array<Dictionary<String, Any>>
        for activity in activites {
            let participatedActivity = UserActivityStatus(detail: activity)
            user.participatedActivites.append(participatedActivity)
        }
    }
    
    func handleWithdrawFromStudyResponse(response:Dictionary<String, Any>){
        
    }

    
    
    private func sendRequestWith(method:Method, params:Dictionary<String, Any>,headers:Dictionary<String, String>?){
        
        networkManager.composeRequest(RegistrationServerConfiguration.configuration,
                                      method: method,
                                      params: params as NSDictionary?,
                                      headers: headers as NSDictionary?,
                                      delegate: self)
    }
    
}
extension UserServices:NMWebServiceDelegate{
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        if delegate != nil {
            delegate.startedRequest(manager, requestName: requestName)
        }
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        
       switch requestName {
            case RegistrationMethods.login.rawValue as String:
                
                self.handleUserLoginResponse(response: response as! Dictionary<String, Any>)
        
            case RegistrationMethods.register.rawValue as String: break
            case RegistrationMethods.confirmRegistration.rawValue as String: break
            case RegistrationMethods.userProfile.rawValue as String: break
            case RegistrationMethods.updateUserProfile.rawValue as String: break
            case RegistrationMethods.userPreferences.rawValue as String: break
            case RegistrationMethods.updatePreferences.rawValue as String: break
            case RegistrationMethods.updateEligibilityConsentStatus.rawValue as String: break
            case RegistrationMethods.consentPDF.rawValue as String: break
            case RegistrationMethods.updateActivityState.rawValue as String: break
            case RegistrationMethods.activityState.rawValue as String: break
            case RegistrationMethods.withdraw.rawValue as String: break
            case RegistrationMethods.forgotPassword.rawValue as String: break
            case RegistrationMethods.logout.rawValue as String: break
        default:
            print("Request was not sent proper method name")
        }
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        
    }
}
