/*
 License Agreement for FDA My Studies
Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.
Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import UIKit


protocol NMWebServiceDelegate: class{
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
    var networkAvailability : Bool = false
    var reachability : Reachability? = nil
    
    
    class func isNetworkAvailable() -> Bool{
        return self.sharedInstance().networkAvailability
    }
    
    init() {
    
        reachability =  try? Reachability()
        print("network available init() and reachability \(reachability)")
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)),
                                               name: Notification.Name.reachabilityChanged, object: nil)
        try? reachability?.startNotifier()
    }
    
    class func sharedInstance() -> NetworkManager {
        self.instance = self.instance ?? NetworkManager()
        return self.instance!
    }
    
    @objc func reachabilityChanged(_ notification: Notification) {
            
            let oldLocale = getLanguageLocale()
            print("Krishna oldLocale in rechabilityChanged \(oldLocale)")
          
            if self.reachability!.connection == .wifi
                || self.reachability!.connection == .cellular {
                networkAvailability = true
                // change local if needed on network connection change
                setLanguageLocale()
                if oldLocale != getLanguageLocale() {
                    resetLanguage()
                }
                
            } else {
                networkAvailability = false
                // change local if needed on network connection change
                setLanguageLocale()
            }
            
            print("Krishna reachabilityChanged networkAvailability set to \(networkAvailability) \n\n")
            SyncUpdate.currentSyncUpdate.updateData(isReachable: networkAvailability)
        }

    func resetLanguage() {
                    
            localeBundle = AppDelegate.selectedLocale()
            
            // if let name = UIApplication.shared.topMostViewController()?.storyboard?.value(forKey: "name") {
            if let name = UIApplication.shared.topMostViewController()?.visibViewController?.storyboard?.value(forKey: "name") {
                
                print("storyboard in view is \(name)")
                
                // Bundle(path: Bundle.main.path(forResource: "es", ofType: "lproj") ?? "en")
                let sb = UIStoryboard(name: name as! String, bundle:nil)
                let vc = sb.instantiateInitialViewController()
                
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                appdelegate.window?.rootViewController = vc
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
