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
    case verifyEnrollmentToken
    case processResponse
    case withdrawFromStudy
    case getParticipantResponse
    
    var method:Method{
        switch self {
        case .getParticipantResponse,.verifyEnrollmentToken:
            return Method(methodName:self.rawValue, methodType: .httpMethodGet, requestType: .requestTypeJSON)
        default:
            return Method(methodName:self.rawValue, methodType: .httpMethodPOST, requestType: .requestTypeJSON)
            
            
        }
    }
    
}
struct ResponseServerURLConstants {
    //TODO: Set the server end points
    
    static let ProductionURL = "production url not set"
    static let DevelopmentURL = "development url not set"
    
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
}
