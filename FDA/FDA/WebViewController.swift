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
        
       
        
        //Used to add a loader
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY-100)
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        
        
        if self.requestLink != nil {
            let url = URL.init(string:self.requestLink!)
            let urlRequest = URLRequest.init(url: url!)
            
            webView?.loadRequest(urlRequest)
            
        }
        else if self.htmlString != nil {
            
            webView?.loadHTMLString(self.htmlString!, baseURL: nil)
            
 
        }
        else{
            //VisitWebsite
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            
           
        }
    
        webView?.delegate = self
        
        UIApplication.shared.statusBarStyle = .default
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
        
        let buttonTitleOK = NSLocalizedString("OK", comment: "")
        let alert = UIAlertController(title:NSLocalizedString(kTitleError, comment: ""),message:error.localizedDescription,preferredStyle: UIAlertControllerStyle.alert)
      
        alert.addAction(UIAlertAction.init(title:buttonTitleOK, style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
      
        self.present(alert, animated: true, completion: nil)
        
       
    }
}





