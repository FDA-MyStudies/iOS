//
//  ResponseServerConfiguration.swift
//  FDA
//
//  Created by Surender Rathore on 2/9/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
enum ResponseMethods:String {
    //TODO : Write exact name for request method
    case enroll
    case validateEnrollmentToken
    case processResponse
    case withdrawFromStudy
    case getParticipantResponse
    case executeSQL
    
    
    var description:String{
        switch self {
            
        default:
            return self.rawValue+".api"
        }
    }
    
    var method:Method {
        
        switch self {
        case .getParticipantResponse,.validateEnrollmentToken,.executeSQL:
            return Method(methodName:(self.rawValue+".api"), methodType: .httpMethodGet, requestType: .requestTypeHTTP)
        case .withdrawFromStudy:
            return Method(methodName:(self.rawValue+".api"), methodType: .httpMethodPOST, requestType: .requestTypeHTTP)
        default:
            return Method(methodName:(self.rawValue+".api"), methodType: .httpMethodPOST, requestType: .requestTypeJSON)
        }
    }
    
}
struct ResponseServerURLConstants {
    //TODO: Set the server end points
    
    //static let ProductionURL = "https://hphci-fdama-te-ds-01.labkey.com/mobileappstudy-"
    //static let DevelopmentURL = "https://hphci-fdama-te-ds-01.labkey.com/mobileappstudy-"
    
    //Labkey UAT Server
    static let ProductionURL = "https://hphci-fdama-st-ds-01.labkey.com/mobileappstudy-"
    static let DevelopmentURL = "https://hphci-fdama-st-ds-01.labkey.com/mobileappstudy-"
    
    //Labkey Production Server
    //static let ProductionURL = "https://hphci-fdama-pr-ds-01.labkey.com/mobileappstudy-"
    //static let DevelopmentURL = "https://hphci-fdama-pr-ds-01.labkey.com/mobileappstudy-"
    
}
class ResponseServerConfiguration: NetworkConfiguration {
    static let configuration = ResponseServerConfiguration()
    
    
    //MARK:  Delegates
    override func getProductionURL() -> String {
        return ResponseServerURLConstants.ProductionURL
    }
    override func getDevelopmentURL() -> String {
        return ResponseServerURLConstants.DevelopmentURL
    }
    
    override func getDefaultHeaders() -> [String : String] {
        return Dictionary()
    }
    override func getDefaultRequestParameters() -> [String : Any] {
        return Dictionary()
    }
    override func shouldParseErrorMessage() -> Bool {
        return true
    }
    override func parseError(errorResponse:Dictionary<String,Any>)->NSError {
        
        var error = NSError(domain: NSURLErrorDomain, code:101,userInfo:[NSLocalizedDescriptionKey:"Could not connect to server"])
        
        if let errorMessage =  errorResponse["exception"] {
            
            error = NSError(domain: NSURLErrorDomain, code:101,userInfo:[NSLocalizedDescriptionKey:errorMessage])
        }
        
        return  error
    }
}
