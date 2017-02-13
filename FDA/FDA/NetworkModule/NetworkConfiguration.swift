//
//  NetworkConfiguration.swift
//  FDA
//
//  Created by Surender Rathore on 2/8/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation

protocol NetworkConfigurationProtocol {
    func getDevelopmentURL()->String
    func getProductionURL()->String
    func getDefaultHeaders()->Dictionary<String, String>
    func getDefaultRequestParameters()->Dictionary<String, Any>
}
class  Method {
    
    let methodName:String
    let methodType:HTTPMethod
    let requestType:RequestType
    init(methodName:String,methodType:HTTPMethod,requestType:RequestType){
        self.methodName = methodName
        self.methodType = methodType
        self.requestType = requestType
    }
}
class NetworkProtocols:NetworkConfigurationProtocol{
    
    internal func getDefaultRequestParameters() -> Dictionary<String, Any> {
        return Dictionary()
    }

    internal func getDefaultHeaders() -> Dictionary<String, String> {
        return Dictionary()
    }

    internal func getProductionURL() -> String {
        return ""
    }

    internal func getDevelopmentURL() -> String {
        return ""
    }

    
}
class NetworkConfiguration: NetworkProtocols {


}
