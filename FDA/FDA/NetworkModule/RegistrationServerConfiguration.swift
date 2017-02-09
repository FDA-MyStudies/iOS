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
    case register
    
    var method:Method{
        switch self {
        default:
            return Method(methodName:self.rawValue, methodType: .httpMethodGet, requestType: .requestTypeJSON)
            
            
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
