//
//  WCPConfiguration.swift
//  FDA
//
//  Created by Surender Rathore on 2/8/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit


enum WCPMethods:String {
    
    //TODO : Write exact name for request method
    case gatewayInfo
    case studyList
    case eligibilityConsent
    case resources
    case studyInfo
    case activityList
    case activity
    case studyDashboard
    case termsPolicy
    case notifications
    
    var method:Method{
        switch self {
        default:
            return Method(methodName:self.rawValue, methodType: .httpMethodGet, requestType: .requestTypeJSON)
    
            
        }
    }
    
}


struct WCPServerURLConstants {
    //TODO: Set the server end points
    
    static let ProductionURL = "http://192.168.0.50:8080/StudyMetaData/"
    static let DevelopmentURL = "http://192.168.0.50:8080/StudyMetaData/"
    
}

class WCPConfiguration: NetworkConfiguration {
    
    static let configuration = WCPConfiguration()
    
    
    //MARK:  Delegates
    override func getProductionURL() -> String {
        return WCPServerURLConstants.ProductionURL
    }
    override func getDevelopmentURL() -> String {
        return WCPServerURLConstants.DevelopmentURL
    }
    
    override func getDefaultHeaders() -> [String : String] {
        
        let token = Utilities.getBundleIdentifier() + ":" + "ee91a4f6-d9c4-4ee9-a0e2-5682c5b1c916"
        let base64token = "Basic " + token.toBase64()
        
        let headers = ["Authorization":base64token]
        return headers
    }
    override func getDefaultRequestParameters() -> [String : Any] {
        return Dictionary()
    }

}
