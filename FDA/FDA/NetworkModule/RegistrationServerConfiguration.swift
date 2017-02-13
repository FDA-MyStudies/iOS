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
    
    
    
    var method:Method{
        switch self {
       
        case .activityState,.consentPDF,.userPreferences,.userProfile,.forgotPassword,.confirmRegistration :
            //GET Methods
            return Method(methodName:self.rawValue, methodType: .httpMethodGet, requestType: .requestTypeJSON)
        case .withdraw,.logout:
            //DELETE Methods
            return Method(methodName:self.rawValue, methodType: .httpMethodDELETE, requestType: .requestTypeJSON)
        default:
            //POST Methods
            return Method(methodName:self.rawValue, methodType: .httpMethodPOST, requestType: .requestTypeJSON)
            
            
        }
    }
   
}
struct RegistrationServerURLConstants {
    //TODO: Set the server end points
    
    static let ProductionURL = "production url not set"
    static let DevelopmentURL = "development url not set"
    
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
        return Dictionary()
    }
    override func getDefaultRequestParameters() -> [String : Any] {
        return Dictionary()
    }

}
