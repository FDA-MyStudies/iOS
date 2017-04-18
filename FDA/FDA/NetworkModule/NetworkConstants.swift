//
//  NetworkConstants.swift
//  NetworkManager
//
//  Created by Vinay Raja on 08/07/16.
//  Copyright © 2016 Boston Technology Corporation. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



//Mark: WebRequestMethods
//let kSM




struct NetworkConnectionConstants {
    static let ConnectionTimeoutInterval = 30.0
    static let NoOfRequestRetry  = 3
    static let EnableRequestRetry = false
}

struct TrustedHosts {
    static let TrustedHost1 = ""
    static let TrustedHost2 = ""
    static let TrustedHost3 = ""
}

struct HTTPHeaderKeys {
    static let SetCookie = "Set-Cookie"
    static let ContentType = "Content-Type"
}

struct HTTPHeaderValues {
    static  let ContentTypeJson = "application/json"
}

struct NetworkURLConstants {
    //TODO: Set the server end points
    
    static let ProductionURL = ""
    static let DevelopmentURL = ""
    
}




class NetworkConstants: NSObject {
    //TODO: Configure common parameters for requests here.
    class func getCommonRequestParameters()-> NSDictionary? {
        return nil
    }
    
    class func getCommonHeaderParameters() -> NSDictionary? {
        let cookie = UserDefaults.standard.value(forKey: "cookies")
        var headers : NSDictionary? =  nil
        /*
        if (cookie != nil && (cookie as AnyObject).length > 0){
            headers = ["cookie" : cookie!]
        }
         */
        return headers
    }
    
    fileprivate func getTrustedHosts()-> NSArray{
        let array = [TrustedHosts.TrustedHost1,TrustedHosts.TrustedHost2,TrustedHosts.TrustedHost3]
        return array as NSArray
    }
    
    class func checkResponseHeaders(_ response : URLResponse)-> (NSInteger,String){
        let httpResponse = response as? HTTPURLResponse
       
        let headers = httpResponse!.allHeaderFields as NSDictionary
        let statusCode = httpResponse!.statusCode
        var statusMessage = ""
        
        if let message = headers["StatusMessage"] {
            // now val is not nil and the Optional has been unwrapped, so use it
            statusMessage = message as! String
        }
        
        return (statusCode,statusMessage)
    }
}

