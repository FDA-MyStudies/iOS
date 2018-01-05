//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by Ravishankar on 7/12/16.
//  Copyright © 2016 Boston Technology Corporation. All rights reserved.
//

import Foundation
import UIKit


protocol NMWebServiceDelegate{
    /**
     *  Called when request is fired.Use this to show any activity indicator
     *
     *  @param manager       NetworkManager instance
     *  @param requestName Web request@objc  name
     */
    func startedRequest(_ manager: NetworkManager, requestName:NSString)
    
    /**
     *  Called when request if finished. Handle your response or error in this delegate
     *
     *  @param manager       NetworkManager instance
     *  @param requestName Web request name
     *  @param response    Web response of NSDictionary format
     */
    func finishedRequest(_ manager: NetworkManager, requestName:NSString, response: AnyObject?)
    
    /**
     *  Called when request failed, Handle errors in this delegate
     *
     *  @param manager       NetworkManager instance
     *  @param requestName Web request name
     *  @param error       Request error
     */
    func failedRequest(_ manager: NetworkManager, requestName:NSString, error: NSError)
    
}


protocol NMAuthChallengeDelegate{
    /**
     *  Called when server throws for authentacation challenge
     *
     *  @param manager     NetworkManager instance
     *  @param challenge NSURLAuthenticationChallenge
     *
     *  @return NSURLCredential
     */
    func networkCredential(_ manager : NetworkManager, challenge : URLAuthenticationChallenge) -> URLCredential
    
    /**
     *  Called when request ask for authentication
     *
     *  @param manager     NetworkManager instance
     *  @param challange NSURLAuthenticationChallenge
     *
     *  @return NSURLSessionAuthChallengeDisposition
     */
    func networkChallengeDisposition(_ manager : NetworkManager, challenge : URLAuthenticationChallenge) -> URLSession.AuthChallengeDisposition
}

class NetworkManager {
    
    static var instance : NetworkManager? = nil
    var networkAvailability : Bool = true
    var reachability : Reachability? = nil
    
    
    class func isNetworkAvailable()-> Bool{
        return self.sharedInstance().networkAvailability
    }
    
    init() {

        reachability =  Reachability.init()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name:ReachabilityChangedNotification, object: nil)
    
        do{
            try reachability?.startNotifier()
        }catch {
            print("could not start reachability notifier")
        }
    }
    
    class func sharedInstance()-> NetworkManager {
        self.instance = self.instance ?? NetworkManager()
        return self.instance!
    }
    
    @objc func reachabilityChanged(_ notification: Notification) {
        
        if self.reachability!.isReachable {
            networkAvailability = true
        } else {
            networkAvailability = false
        }
    }
    
    func composeRequest(_ requestName: NSString, requestType : RequestType , method : HTTPMethod , params : NSDictionary?, headers : NSDictionary?, delegate : NMWebServiceDelegate){
        
        let networkWSHandler = NetworkWebServiceHandler(delegate: delegate, challengeDelegate: UIApplication.shared.delegate as? NMAuthChallengeDelegate)
        networkWSHandler.networkManager = self
        networkWSHandler.composeRequestFor(requestName, requestType: requestType, method: method, params: params, headers: headers)
        
    }
    
    func composeRequest(_ configuration:NetworkConfiguration, method: Method, params : NSDictionary?, headers : NSDictionary?, delegate : NMWebServiceDelegate){
        
        let networkWSHandler = NetworkWebServiceHandler(delegate: delegate, challengeDelegate: UIApplication.shared.delegate as? NMAuthChallengeDelegate)
        networkWSHandler.networkManager = self
        networkWSHandler.composeRequest(configuration, method: method, params: params, headers: headers)
        
    }
    
    
    
}
