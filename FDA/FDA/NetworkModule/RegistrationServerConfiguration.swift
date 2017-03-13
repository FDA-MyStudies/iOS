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
    
    var description:String{
        switch self {
        
        default:
            return self.rawValue+".api"
        }
    }
    
    var method:Method{
        
        switch self {
       
        case .activityState,.consentPDF,.forgotPassword ,.deleteAccount:
            //GET Methods
            return Method(methodName:(self.rawValue+".api"), methodType: .httpMethodGet, requestType: .requestTypeJSON)
        case .withdraw,.logout:
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
    
    static let ProductionURL = "http://192.168.0.6:8081/labkey/fdahpUserRegWS/home/"
    static let DevelopmentURL = "http://192.168.0.6:8081/labkey/fdahpUserRegWS/home/"
    
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
        
        let ud = UserDefaults.standard
        if (ud.object(forKey: kUserAuthToken) != nil) {
            return [kUserAuthToken:ud.object(forKey: kUserAuthToken) as! String]
        }
        return Dictionary()
    }
    override func getDefaultRequestParameters() -> [String : Any] {
        return Dictionary()
    }

}
