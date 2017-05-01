//
//  RegistrationConfiguration.swift
//  FDA
//
//  Created by Surender Rathore on 2/9/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
enum RegistrationMethods:String {
    //TODO : Write exact name for request method
    case login
    case register
    case confirmRegistration
    case userProfile
    case updateUserProfile
    case userPreferences
    case updatePreferences
    case updateEligibilityConsentStatus
    case consentPDF
    case updateActivityState
    case activityState
    case withdraw
    case forgotPassword
    case logout
    case deleteAccount
    case changePassword
    case resendConfirmation
    case deactivate
    case verify
    
    var description:String{
        switch self {
        
        default:
            return self.rawValue+".api"
        }
    }
    
    var method:Method{
        
        switch self {
       
        case .activityState,.consentPDF,.deleteAccount,.confirmRegistration,.userProfile,.userPreferences:
            //GET Methods
            return Method(methodName:(self.rawValue+".api"), methodType: .httpMethodGet, requestType: .requestTypeJSON)
        case .withdraw,.logout, .deactivate:
            //DELETE Methods
            return Method(methodName:(self.rawValue+".api"), methodType: .httpMethodDELETE, requestType: .requestTypeJSON)
        default:
            //POST Methods
            return Method(methodName:(self.rawValue+".api"), methodType: .httpMethodPOST, requestType: .requestTypeJSON)
            
            
        }
    }
   
}
struct RegistrationServerURLConstants {
    //TODO: Set the server end points
    
    
    //Testing server
   // static let ProductionURL = "http://192.168.0.6:8081/labkey/fdahpUserRegWS/"
   // static let DevelopmentURL = "http://192.168.0.6:8081/labkey/fdahpUserRegWS/"
    
    //LabKey Server
    static let ProductionURL = "https://hphci-fdama-te-ur-01.labkey.com/fdahpUserRegWS/"
    static let DevelopmentURL = "https://hphci-fdama-te-ur-01.labkey.com/fdahpUserRegWS/"
    
}
class RegistrationServerConfiguration: NetworkConfiguration {
    static let configuration = RegistrationServerConfiguration()
    
    
    //MARK:  Delegates
    override func getProductionURL() -> String {
        return RegistrationServerURLConstants.ProductionURL
    }
    override func getDevelopmentURL() -> String {
        return RegistrationServerURLConstants.DevelopmentURL
    }
    
    override func getDefaultHeaders() -> [String : String] {
        
        //let ud = UserDefaults.standard
        if User.currentUser.authToken != nil {
            return [kUserAuthToken:User.currentUser.authToken]
        }
        return Dictionary()
    }
    override func getDefaultRequestParameters() -> [String : Any] {
        return Dictionary()
    }
    override func shouldParseErrorMessage() -> Bool {
        return false
    }


}
