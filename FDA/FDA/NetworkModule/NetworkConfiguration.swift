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
    internal func shouldParseErrorMessage() -> Bool {
        return false
    }
    internal func parseError(errorResponse:Dictionary<String,Any>)->NSError{
        
//        let error = NSError(domain: NSURLErrorDomain, code:101,userInfo:[NSLocalizedDescriptionKey:"Handle your error here"])
//        return  error
      
      var errorCode = 0
      if let errResponse = errorResponse["error"] as? [String: Any] {
        if let errCD = errResponse["code"] as? Int {
          errorCode = errCD
          let errorDesc = errResponse["message"]
          
          let error = NSError(domain: NSURLErrorDomain, code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorDesc])
          return  error
        }
      }
      
      
      let error = NSError(domain: NSURLErrorDomain, code: 101, userInfo: [NSLocalizedDescriptionKey: "Your error localized description"])
      return  error
      
      
      
    }

    
}
class NetworkConfiguration: NetworkProtocols {


}
