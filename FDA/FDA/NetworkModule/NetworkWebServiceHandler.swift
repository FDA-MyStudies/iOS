//
//  NetworkWebServiceHandler.swift
//  NetworkM
//
//  Created by Ravishankar on 7/7/16.
//  Copyright © 2016 Boston Technology Corporation. All rights reserved.
//

import Foundation

enum RequestType: NSInteger {
    case requestTypeJSON
    case requestTypeHTTP
}

enum HTTPMethod : NSInteger {
    case httpMethodGet
    case httpMethodPUT
    case httpMethodPOST
    case httpMethodDELETE
}

struct DefaultHeaders {
    static let DefaultHeaderKey = NSDictionary.init(object: HTTPHeaderValues.ContentTypeJson, forKey: HTTPHeaderKeys.ContentType as NSCopying)
}

class NetworkWebServiceHandler: NSObject, URLSessionDelegate {
    
    var shouldRetryRequest = NetworkConnectionConstants.EnableRequestRetry
    var maxRequestRetryCount = NetworkConnectionConstants.NoOfRequestRetry
    var connectionTimeoutInterval : Double = NetworkConnectionConstants.ConnectionTimeoutInterval
   
    
    var delegate: NMWebServiceDelegate? = nil
    var challengeDelegate: NMAuthChallengeDelegate? = nil
    
    weak var networkManager: NetworkManager? = nil
    var configuration:NetworkConfiguration!
    
    init(delegate :  NMWebServiceDelegate, challengeDelegate:NMAuthChallengeDelegate?){
        self.delegate = delegate
        self.challengeDelegate = challengeDelegate
    }
    
    func getServerURLString() -> NSString {
        #if DEBUG
            return self.configuration.getDevelopmentURL() as NSString
        #else
            return self.configuration.getProductionURL()() as NSString
        #endif
    }
    
    fileprivate func getBaseURLString(_ requestName : NSString) -> NSString {
        return NSString.init(format: "%@%@", self .getServerURLString(),requestName)
    }
    
    fileprivate func getCombinedWithCommonParams(_ params : NSDictionary?) -> NSDictionary? {
        
        let commonParams  = self.configuration.getDefaultRequestParameters() as NSDictionary?
        var mParams : NSMutableDictionary? = nil
        if commonParams != nil{
            mParams = NSMutableDictionary.init(dictionary: commonParams!)
        }
        if  params != nil {
            if mParams != nil{
                mParams!.addEntries(from:params! as! [AnyHashable : Any])
            }else{
                mParams = NSMutableDictionary.init(dictionary: params!)
            }
        }
        return mParams!
    }
    
    fileprivate func getCombinedHeaders(_ userHeaders : NSDictionary?, defaultHeaders : NSDictionary?)-> NSDictionary? {
        
        let commonParams: NSDictionary? = self.configuration.getDefaultHeaders() as NSDictionary?
        
        var mParams : NSMutableDictionary? = nil
        if commonParams != nil{
            mParams = NSMutableDictionary.init(dictionary: commonParams!)
        }
        
        
        if  defaultHeaders != nil {
            if mParams != nil {
                mParams!.addEntries(from: defaultHeaders as! [AnyHashable: Any])
            }
            else {
                mParams = NSMutableDictionary.init(dictionary: defaultHeaders!)
            }
        }
        if userHeaders != nil && userHeaders!.count > 0  {
            if mParams != nil {
                mParams!.addEntries(from: userHeaders as! [AnyHashable: Any])
            }
            else {
                mParams = NSMutableDictionary.init(dictionary: userHeaders!)
            }
        }
        return mParams
    }
    
    func getRequestMethod(_ methods : HTTPMethod)-> NSString{
        switch methods {
        case .httpMethodGet:
            return "GET"
        case .httpMethodPOST:
            return "POST"
        case .httpMethodPUT:
            return "PUT"
        case .httpMethodDELETE:
            return "DELETE"
        }
    }
    
    fileprivate func getHttpRequest(_ requestName : NSString , parameters : NSDictionary?)-> NSString {
        let url : NSString = ""
        // get from uptiiq
        
        return url
    }
    
    func composeRequestFor(_ requestName: NSString, requestType : RequestType , method : HTTPMethod , params : NSDictionary?, headers : NSDictionary?){
        
        if ((delegate?.startedRequest) != nil) {
            delegate?.startedRequest(networkManager!, requestName: requestName)
        }
        
        var requestParams:NSDictionary? = nil
        if params != nil{
            requestParams = self.getCombinedWithCommonParams(params)
        }
        switch requestType {
        case .requestTypeHTTP:
            self.generateHTTPRequest(requestName, method: method, params: requestParams, headers: headers!)
            break
        case .requestTypeJSON:
            self.generateJSONRequest(requestName, method: method, params: requestParams, headers: headers)
            break
        }
    }
    
    func composeRequest(_ configuration:NetworkConfiguration, method: Method, params : NSDictionary?, headers : NSDictionary?){
        
        
        self.configuration = configuration
        
        if ((delegate?.startedRequest) != nil) {
            delegate?.startedRequest(networkManager!, requestName: method.methodName as NSString)
        }
        
        
        
        var requestParams:NSDictionary? = nil
        if params != nil{
            requestParams = self.getCombinedWithCommonParams(params)
        }
        switch method.requestType {
        case .requestTypeHTTP:
            self.generateHTTPRequest(method.methodName as NSString, method: method.methodType, params: requestParams, headers: headers!)
            break
        case .requestTypeJSON:
            self.generateJSONRequest(method.methodName as NSString, method: method.methodType, params: requestParams, headers: headers)
            break
        }
    }
    
    fileprivate func generateHTTPRequest(_ requestName : NSString ,method : HTTPMethod , params : NSDictionary?, headers : NSDictionary?){
        
        let httpHeaders : NSDictionary? = self.getCombinedHeaders(headers, defaultHeaders: nil)
        let baseURLString  : NSString = self.getBaseURLString(requestName)
        let httpRequestString  : NSString? = self.getHttpRequest(requestName, parameters: params)
        var requestString  : NSString!
        
        if (httpRequestString?.length == 0) {
            requestString = baseURLString
        }else{
            requestString = String(format:"%@?%@",baseURLString,httpRequestString!) as NSString!
        }
        
        if #available(iOS 9, *) {
            requestString = requestString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) as NSString!
        }else{
            requestString = requestString.addingPercentEscapes(using: String.Encoding.utf8.rawValue) as NSString!
        }
        
        let requestUrl = URL(string: requestString as String)!
      
         var request = URLRequest.init(url: requestUrl, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: self.connectionTimeoutInterval)
        request.httpMethod = self.getRequestMethod(method) as String
        if httpHeaders != nil {
            request.allHTTPHeaderFields = httpHeaders as? [String : String]
        }
        self.fireRequest(request, requestName: requestName)
    }
    
    fileprivate func generateJSONRequest(_ requestName : NSString , method : HTTPMethod , params : NSDictionary? , headers : NSDictionary?) {
        var defaultheaders : NSDictionary? = DefaultHeaders.DefaultHeaderKey
        if params == nil || params?.count == 0 {
            defaultheaders = nil
        }
        let httpHeaders : NSDictionary? = self.getCombinedHeaders(headers, defaultHeaders: defaultheaders)
        let baseURLString : NSString = self.getBaseURLString(requestName)
        let requestUrl = URL(string: baseURLString as String)
        do{
            
            
            var request = URLRequest.init(url: requestUrl!, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: self.connectionTimeoutInterval)
          
            
            if params != nil{
                let data = try JSONSerialization.data(withJSONObject: params!, options: JSONSerialization.WritingOptions.prettyPrinted)
                request.httpBody = data
            }
            
            
            
            request.httpMethod=self.getRequestMethod(method) as String
            if httpHeaders != nil {
                request.allHTTPHeaderFields = httpHeaders! as! [String : String]
            }
            self.fireRequest(request, requestName: requestName)
            
        }catch{
            print("Serilization error")
        }
    }
    
    fileprivate func fireRequest (_ request : URLRequest? , requestName : NSString?){
        
        if NetworkManager.isNetworkAvailable(){
           // mURLRequest = request!
            let config = URLSessionConfiguration.default
            let session = Foundation.URLSession.init(configuration: config, delegate: self , delegateQueue: nil)
            
            //var request = URLRequest(url:myUrl!)
            
            session.dataTask(with: request!) {(data, response, error) -> Void in
                if let data = data {
                    DispatchQueue.main.async {
                        self.handleResponse(data, response: response, requestName: requestName, error: error as NSError?)
                    }
                    
                }
                }.resume()
            

        }else{
            if ((delegate?.failedRequest) != nil) {
                //let error1 = NSError(domain: "Network not available", code:0,userInfo: nil)
                let error1 = NSError(domain: NSURLErrorDomain, code:101,userInfo:[NSLocalizedDescriptionKey:"Network not available"])
                delegate?.failedRequest(networkManager!, requestName: requestName!,error: error1)
            }
        }
    }
    
     func handleResponse(_ data : Data? , response : URLResponse?, requestName : NSString?,error : NSError?){
       
        
        if (error != nil) {
            if shouldRetryRequest && maxRequestRetryCount > 0  {
                maxRequestRetryCount -= 1
               // self.fireRequest(mURLRequest, requestName: requestName!)
            }else{
                
                if error?.code == -1001 { //Could not connect to the server.
                   
                }
                if ((delegate?.failedRequest) != nil) {
                    delegate?.failedRequest(networkManager!, requestName: requestName!,error: error!)
                }

//                
//                if error?.localizedDescription == "Could not connect to the server."{
//                    let error1 = NSError(domain: "Could not connect to the server.", code: 0,userInfo: nil)
//                    delegate?.failedRequest(networkManager!, requestName: requestName!,error: error1)
//                }else{
//                    if ((delegate?.failedRequest) != nil) {
//                        delegate?.failedRequest(networkManager!, requestName: requestName!,error: error!)
//                    }
//                }
            }
        }else{
            let status = NetworkConstants.checkResponseHeaders(response!)
            let statusCode = status.0
            var error1 : NSError?
            if statusCode == 200 || statusCode == 0 {
                var responseDict: NSDictionary? = nil
                
                do{
                    //NSJSONReadingOptions.MutableContainers
                    responseDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                
                    
                }catch{
                    print("Serilization error")
                }
                
                if ((delegate?.finishedRequest) != nil) {
                    
                    if (responseDict != nil) {
                        delegate?.finishedRequest(networkManager!, requestName: requestName!,response: responseDict!)
                        
                    }else{
                        var dictionary = NSDictionary()
                        print("response Dictionary Nil")
                        
                        
                        if let httpResponse = response as? HTTPURLResponse {
                            if let contentType = httpResponse.allHeaderFields["Status Message"] as? String {
                                // use contentType here
                                dictionary = ["Status Message": contentType]
                                
                            }
                        }
                        
                        
                        error1 = NSError(domain: NSURLErrorDomain, code: statusCode,userInfo: dictionary as? [AnyHashable: Any])
                        
                        
                        if ((delegate?.failedRequest) != nil) {
                            delegate?.failedRequest(networkManager!, requestName: requestName!,error:error1!)
                        }
                    }
                    
                    
                    
                }
            }else{
                error1 = NSError(domain: NSURLErrorDomain, code:statusCode,userInfo:[NSLocalizedDescriptionKey: status.1])
              
                if ((delegate?.failedRequest) != nil) {
                    delegate?.failedRequest(networkManager!, requestName: requestName!,error:error1!)
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        var credential : URLCredential!
        
        if (challengeDelegate?.networkCredential) != nil {
            credential = challengeDelegate?.networkCredential(networkManager!, challenge: challenge)
        }
        
        if (credential != nil) {
            var challengeDisposition : Foundation.URLSession.AuthChallengeDisposition!
            if (challengeDelegate?.networkChallengeDisposition) != nil {
                challengeDisposition = challengeDelegate?.networkChallengeDisposition(networkManager!, challenge: challenge)
            }
            completionHandler(challengeDisposition,credential)
        }
        
    }
}
