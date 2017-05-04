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
    case consentDocument
    case feedback
    case contactUs
    case studyUpdates
    case appUpdates
    
    var method:Method{
        switch self {
        case .feedback,.contactUs:
             return Method(methodName:self.rawValue, methodType: .httpMethodPOST, requestType: .requestTypeJSON)
        default:
            return Method(methodName:self.rawValue, methodType: .httpMethodGet, requestType: .requestTypeJSON)
    
            
        }
    }
    
}


struct WCPServerURLConstants {
    //TODO: Set the server end points
    
    //LabKey
    //static let ProductionURL =  "https://hphci-fdama-te-wcp-01.labkey.com/StudyMetaData/"
    //static let DevelopmentURL = "https://hphci-fdama-te-wcp-01.labkey.com/StudyMetaData/"
    
    
    //UAT
    static let ProductionURL = "http://23.89.199.27:8080/StudyMetaData/"
    static let DevelopmentURL = "http://23.89.199.27:8080/StudyMetaData/"

    
    //New SerVerForDevelopment
    //static let ProductionURL = "http://192.168.0.26:8080/StudyMetaData/"
    //static let DevelopmentURL = "http://192.168.0.26:8080/StudyMetaData/"
    

    
    //Production
    //static let ProductionURL = "http://192.168.0.50:8080/StudyMetaData/"
    //static let DevelopmentURL = "http://192.168.0.50:8080/StudyMetaData/"
    
    
    //Dev
    //static let ProductionURL = "http://192.168.0.50:8080/StudyMetaData-DEV/"
    //static let DevelopmentURL = "http://192.168.0.50:8080/StudyMetaData-DEV/"
    
    
    //local
   // static let ProductionURL = "http://192.168.0.32:8080/StudyMetaData/"
   // static let DevelopmentURL = "http://192.168.0.32:8080/StudyMetaData/"
    
    
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
    override func shouldParseErrorMessage() -> Bool {
        return false
    }

}
