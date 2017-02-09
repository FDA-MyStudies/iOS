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
    case login
    
    var method:Method{
        switch self {
        default:
            return Method(methodName:self.rawValue, methodType: .httpMethodGet, requestType: .requestTypeJSON)
    
            
        }
    }
    
}


struct WCPServerURLConstants {
    //TODO: Set the server end points
    
    static let ProductionURL = "production url not set"
    static let DevelopmentURL = "development url not set"
    
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
        return Dictionary()
    }
    override func getDefaultRequestParameters() -> [String : Any] {
        return Dictionary()
    }

}
