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
let kUserOldPassword = "currentPassword"
let kUserNewPassword = "newPassword"
let kUserIsTempPassword = "resetPassword"

//MARK: Settings Api Constants
let kSettingsRemoteNotifications = "remoteNotifications"
let kSettingsLocalNotifications = "localNotifications"
let kSettingsPassCode = "passcode"
let kSettingsTouchId = "touchId"
let kSettingsLeadTime = "remindersTime"




let kBookmarked = "bookmarked"
let kStatus = "status"
let kActivityId = "activityId"
let kActivityVersion = "activityVersion"

//MARK: Logout Api constants
let kLogoutReason = "reason"
let kLogoutReasonValue = "Logout"

class UserServices: NSObject {
    
    let networkManager = NetworkManager.sharedInstance()
    var delegate:NMWebServiceDelegate! = nil
    
    //MARK: Requests
    func loginUser(_ delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let user = User.currentUser
        let params = [kUserEmailId : user.emailId!,
                      kUserPassword: user.password!]
        
        let method = RegistrationMethods.login.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    func registerUser(_ delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let user = User.currentUser
        //let userSettings = user.settings
        
        /*
        let params = [kUserEmailId : user.emailId!,
                      kUserFirstName : user.firstName!,
                      kUserLastName : user.lastName!,
                      kUserPassword: user.password!,
                      ]
        */
        let params = [kUserEmailId : user.emailId!,
                      kUserPassword: user.password!,
                      ]

        
        
        let method = RegistrationMethods.register.method
        self.sendRequestWith(method:method, params: params, headers: nil)
        
    }
    
    func confirmUserRegistration(_ delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let user = User.currentUser
        let headerParams = [kUserId : user.userId!]
        let method = RegistrationMethods.confirmRegistration.method
        self.sendRequestWith(method:method, params: nil, headers:headerParams)
        
    }
    
    func resendEmailConfirmation(_ delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let user = User.currentUser
        let headerParams = [kUserId : user.userId!]
        
         let params = [kUserEmailId: user.emailId]
        
        let method = RegistrationMethods.resendEmailConfirmation.method
        self.sendRequestWith(method:method, params: params, headers:headerParams)
        
    }
    
    
    func logoutUser(_ delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let user = User.currentUser
        let headerParams = [kUserId : user.userId!]
        let params = [kUserLogoutReason: user.logoutReason.rawValue]
        
        let method = RegistrationMethods.logout.method
        self.sendRequestWith(method:method, params: params, headers: headerParams)
        
    }
    
    func deleteAccount(_ delegate:NMWebServiceDelegate)  {
        
        self.delegate = delegate
        
        let user = User.currentUser
        let headerParams = [kUserAuthToken: user.authToken] as Dictionary<String,String>
        let method = RegistrationMethods.deleteAccount.method
        self.sendRequestWith(method:method, params: nil, headers: headerParams)
    }
    
    func forgotPassword(email:String, delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let user = User.currentUser
        let params = [kUserEmailId : email]
        
        let method = RegistrationMethods.forgotPassword.method
        
        self.sendRequestWith(method:method, params: params, headers:nil )
    }
    
    func changePassword(oldPassword:String,newPassword:String,delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let user = User.currentUser
        
        let headerParams = [kUserId : user.userId!]
        
        let params = [kUserOldPassword:oldPassword,
                      kUserNewPassword:newPassword]
        
        let method = RegistrationMethods.changePassword.method
        self.sendRequestWith(method:method, params: params, headers: headerParams)
    }
    
    func getUserProfile(_ delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let user = User.currentUser
        
        let headerParams = [kUserId : user.userId!]
        
        let method = RegistrationMethods.userProfile.method
        
        self.sendRequestWith(method:method, params: nil, headers: headerParams)
    }
    
    func updateUserProfile(_ delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let user = User.currentUser
        
        let headerParams = [kUserId : user.userId!]

        /*
        let profile = [kUserFirstName : user.firstName!,
                       kUserLastName : user.lastName!]
        */
        
        let settings = [kSettingsRemoteNotifications: (user.settings?.remoteNotifications)! as Bool,
                        kSettingsTouchId : (user.settings?.touchId)! as Bool,
                        kSettingsPassCode : (user.settings?.passcode)! as Bool,
                        kSettingsLocalNotifications : (user.settings?.localNotifications)! as Bool,
                        kSettingsLeadTime : (user.settings?.leadTime)! as String
        ] as [String : Any]
        
        let version = Utilities.getAppVersion()
        let info = [kAppVersion : version,
                    kOSType :"ios"]
        /*
        let params = [kUserProfile:profile,
                      kUserSettings:settings,
                      kBasicInfo:info] as [String : Any]
        */
        
        let params = [
                      kUserSettings:settings,
                      kBasicInfo:info] as [String : Any]
        
        let method = RegistrationMethods.updateUserProfile.method
        
        self.sendRequestWith(method:method, params: params, headers: headerParams)
    }
    
    func getUserPreference(_ delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        let user = User.currentUser
        let headerParams = [kUserId : user.userId!,
                            kUserAuthToken: user.authToken] as Dictionary<String, String>
        
        let method = RegistrationMethods.userPreferences.method
        
        self.sendRequestWith(method:method, params: nil, headers: headerParams)
    }
    
    func updateStudyBookmarkStatus(studyStauts:UserStudyStatus , delegate:NMWebServiceDelegate){
        self.delegate = delegate
        
        let user = User.currentUser
        let params = [kUserId : user.userId,
                      kStudies:[studyStauts.getBookmarkUserStudyStatus()]] as [String : Any]
        let method = RegistrationMethods.updatePreferences.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func updateUserPreference(_ delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        //INCOMPLETE
        let user = User.currentUser
        let params = [kUserId : user.userId]
        let method = RegistrationMethods.updatePreferences.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func updateUserEligibilityConsentStatus(_ delegate:NMWebServiceDelegate){
        
        
        self.delegate = delegate
        
        //INCOMPLETE
        let user = User.currentUser
        let params = [kUserId : user.userId]
        let method = RegistrationMethods.updateEligibilityConsentStatus.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func getConsentPDFForStudy(studyId:String , delegate:NMWebServiceDelegate) {
        
        self.delegate = delegate
        
        let user = User.currentUser
        let params = [kUserId : user.userId,
                      kStudyId: studyId]
        
        let method = RegistrationMethods.consentPDF.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func updateUserActivityState(_ delegate:NMWebServiceDelegate){
        
        self.delegate = delegate
        
        //INCOMPLETE
        let method = RegistrationMethods.updateActivityState.method
    }
    
    func getUserActivityState(studyId:String , delegate:NMWebServiceDelegate) {
        
        self.delegate = delegate
        
        let user = User.currentUser
        let params = [kUserId : user.userId,
                      kStudyId: studyId]
        
        let method = RegistrationMethods.activityState.method
        
        self.sendRequestWith(method:method, params: params, headers: nil)
    }
    
    func withdrawFromStudy(studyId:String ,shouldDeleteData:Bool, delegate:NMWebServiceDelegate){
        
        
        self.delegate = delegate
        
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
        
        if let isTempPassword = response[kUserIsTempPassword] as? Bool {
            user.isLoginWithTempPassword = isTempPassword
        }
        
       
        
       
        if user.verified! && !user.isLoginWithTempPassword {
            
            user.userType = UserType.FDAUser
            
            //TEMP : Need to save these values in Realm
            let ud = UserDefaults.standard
            ud.set(user.authToken, forKey:kUserAuthToken)
            ud.set(user.userId!, forKey: kUserId)
            ud.synchronize()
        }
        
    }
    
    func handleUserRegistrationResponse(response:Dictionary<String, Any>){
        
        let user = User.currentUser
        user.userId     = response[kUserId] as! String
        user.verified   = response[kUserVerified] as! Bool
        user.authToken  = response[kUserAuthToken] as! String
        
    }
    
    func handleConfirmRegistrationResponse(response:Dictionary<String, Any>){
        
        let user = User.currentUser
        if let varified = response[kUserVerified] as? Bool {
            
            user.verified = varified
            if user.verified! {
                
                user.userType = UserType.FDAUser
                
                //TEMP : Need to save these values in Realm
                let ud = UserDefaults.standard
                ud.set(user.authToken, forKey:kUserAuthToken)
                ud.set(user.userId!, forKey: kUserId)
                ud.synchronize()
            }
        }
       
        
       
        
    }
    
    func handleGetUserProfileResponse(response:Dictionary<String, Any>){
        
        let user = User.currentUser
        
        //settings
        let settings = response[kUserSettings] as! Dictionary<String, Any>
        let userSettings = Settings()
        userSettings.setSettings(dict: settings as NSDictionary)
        user.settings = userSettings
        
        //profile
        let profile = response[kUserProfile] as! Dictionary<String, Any>
        user.emailId = profile[kUserEmailId] as? String
        user.firstName = profile[kUserFirstName] as? String
        user.lastName = profile[kUserLastName] as? String
    }
    
    func handleUpdateUserProfileResponse(response:Dictionary<String, Any>){
        //INCOMPLETE
        
        
    }
    
    func handleResendEmailConfirmationResponse(response:Dictionary<String, Any>){
        
        
        
    }
    
    
    func handleChangePasswordResponse(response:Dictionary<String, Any>){
        //INCOMPLETE
        
        let user = User.currentUser
        if user.verified! {
            
            user.userType = UserType.FDAUser
            
            //TEMP : Need to save these values in Realm
            let ud = UserDefaults.standard
            ud.set(user.authToken, forKey:kUserAuthToken)
            ud.set(user.userId!, forKey: kUserId)
            ud.synchronize()
        }
        
    }
    
    
    func handleGetPreferenceResponse(response:Dictionary<String, Any>){
        
        let user = User.currentUser
        
        //        //settings
        //        let settings = response[kUserSettings] as! Dictionary<String, Any>
        //        let userSettings = Settings()
        //        userSettings.setSettings(dict: settings as NSDictionary)
        //        user.settings = userSettings
        
        
        
        //studies
        if let studies = response[kStudies] as? Array<Dictionary<String, Any>> {
            
            for study in studies {
                let participatedStudy = UserStudyStatus(detail: study)
                user.participatedStudies.append(participatedStudy)
            }
        }
        
        
        
        //activities
        if let activites = response[kActivites]  as? Array<Dictionary<String, Any>> {
            for activity in activites {
                let participatedActivity = UserActivityStatus(detail: activity)
                user.participatedActivites.append(participatedActivity)
            }
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
    
    func handleLogoutResponse(response:Dictionary<String, Any>)  {
        
        let ud = UserDefaults.standard
        ud.removeObject(forKey: kUserAuthToken)
        ud.removeObject(forKey: kUserId)
        ud.synchronize()
        
        //reset user object
        User.resetCurrentUser()
        
    }
    
    func handleDeleteAccountResponse(response:Dictionary<String, Any>) {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: kUserAuthToken)
        ud.removeObject(forKey: kUserId)
        ud.synchronize()
        
        //reset user object
        User.resetCurrentUser()
    }
    
    
    
    
    private func sendRequestWith(method:Method, params:Dictionary<String, Any>?,headers:Dictionary<String, String>?){
        
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
        case RegistrationMethods.login.description as String:
            
            self.handleUserLoginResponse(response: response as! Dictionary<String, Any>)
            
        case RegistrationMethods.register.description as String:
            
            self.handleUserRegistrationResponse(response: response as! Dictionary<String, Any>)
            
        case RegistrationMethods.confirmRegistration.description as String:
            
            self.handleConfirmRegistrationResponse(response: response as! Dictionary<String, Any>)
            
        case RegistrationMethods.userProfile.description as String:
            
            self.handleGetUserProfileResponse(response: response as! Dictionary<String, Any>)
            
        case RegistrationMethods.updateUserProfile.description as String:
            
            self.handleUpdateUserProfileResponse(response: response as! Dictionary<String, Any>)
            
        case RegistrationMethods.userPreferences.description as String:
            
            self.handleGetPreferenceResponse(response: response as! Dictionary<String, Any>)
        case RegistrationMethods.changePassword.description as String:
            
            self.handleChangePasswordResponse(response: response as! Dictionary<String, Any>)
            
        case RegistrationMethods.updatePreferences.description as String: break //did not handled response
        case RegistrationMethods.updateEligibilityConsentStatus.description as String: break
        case RegistrationMethods.consentPDF.description as String: break
        case RegistrationMethods.updateActivityState.description as String: break
        case RegistrationMethods.activityState.description as String: break
        case RegistrationMethods.withdraw.description as String: break
        case RegistrationMethods.forgotPassword.description as String: break
        case RegistrationMethods.logout.description as String:
            self.handleLogoutResponse(response: response as! Dictionary<String, Any>)
        case RegistrationMethods.deleteAccount.description as String:
            self.handleDeleteAccountResponse(response: response as! Dictionary<String, Any>)
        default : break
        }
        
        if delegate != nil {
            delegate.finishedRequest(manager, requestName: requestName, response: response)
        }
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        if delegate != nil {
            delegate.failedRequest(manager, requestName: requestName, error: error)
        }
    }
    
}
