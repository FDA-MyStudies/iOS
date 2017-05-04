//
//  WebViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/7/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class WebViewController : UIViewController{
    
    @IBOutlet var webView : UIWebView?
    @IBOutlet var barItemShare : UIBarButtonItem?
    
    var activityIndicator:UIActivityIndicatorView!
    var requestLink:String?
    
    var pdfData:Data?
    
    var isEmailAvailable:Bool? = false
    
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
        
        
        
        if self.isEmailAvailable == false{
            barItemShare = nil
        }
        
        
        if self.requestLink != nil && (self.requestLink?.characters.count)! > 0 {
            let url = URL.init(string:self.requestLink!)
            let urlRequest = URLRequest.init(url: url!)
            
            webView?.loadRequest(urlRequest)
            
        }
        else if self.htmlString != nil {
            
            webView?.loadHTMLString(self.htmlString!, baseURL: nil)
            
            
        }
        else if self.pdfData != nil {
            
            self.webView?.load(pdfData!, mimeType: "application/pdf", textEncodingName: "UTF-8", baseURL:URL.init(fileURLWithPath: "") )
            
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
    
    @IBAction func buttonActionShare(_ sender : UIBarButtonItem){
        
    }
    
   
    func sendConsentByMail() {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        
        mailComposerVC.setSubject("Consent")
       
         let data:Data?
       
        
        if self.requestLink != nil && (self.requestLink?.characters.count)! > 0 {
           
            do {
              data = try Data.init(contentsOf: URL.init(string:self.requestLink! )! )
                
                 mailComposerVC.addAttachmentData(data!, mimeType: "application/pdf", fileName:"UnsignedConset")
                
                 mailComposerVC.setMessageBody("", isHTML: false)
                
            } catch {
                print("Error: \(error)")
            }
        }
        else if self.htmlString != nil {
            mailComposerVC.setMessageBody(self.htmlString!, isHTML: true)
           
        }
        else{
        }
        
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposerVC, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title:NSLocalizedString(kTitleError, comment: ""),message:"",preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction.init(title:NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: nil)
                
            }))
        }
        
        
    }
    
}

extension WebViewController:MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
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







