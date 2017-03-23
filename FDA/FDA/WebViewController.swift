//
//  WebViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/7/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class WebViewController : UIViewController{
    
    @IBOutlet var webView : UIWebView?
    var activityIndicator:UIActivityIndicatorView!
    var requestLink:String?

    var htmlString: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //let url = "http://35.167.14.182:5080/live/viewer.jsp?host=35.167.14.182&stream=NoswMb" as AnyObject
        //UIWebView.loadRequest(webView!)(NSURLRequest(url: NSURL(string: requestLink as String)! as URL) as URLRequest)
        
        //Used to add a loader
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY-100)
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        
        
        
        if self.htmlString != nil {
            //View Consent
            if Study.currentStudy?.consentDocument?.mimeType == MimeType.html {
                webView?.loadHTMLString((Study.currentStudy?.consentDocument?.htmlString)!, baseURL: nil)
            }
            else{
                // assumed to be link
                
                if Study.currentStudy?.consentDocument != nil {
                    let url = URL.init(string: (Study.currentStudy?.consentDocument?.htmlString)!)
                    let urlRequest = URLRequest.init(url: url!)
                    
                    webView?.loadRequest(urlRequest)
                    
                }
                
            }
 
        }
        else{
            //VisitWebsite
            
            if self.requestLink != nil {
                let url = URL.init(string:self.requestLink!)
                let urlRequest = URLRequest.init(url: url!)
                
                webView?.loadRequest(urlRequest)

            }
        }
    
        webView?.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @IBAction func cancelButtonClicked(_ sender : Any){
        self.dismiss(animated: true, completion: nil)
    }
}

extension WebViewController:UIWebViewDelegate{
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
        
        UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kTitleError, comment: "") as NSString, message: error.localizedDescription as NSString)
    }
}





