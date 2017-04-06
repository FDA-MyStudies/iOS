//
//  ResourcesDetailViewController.swift
//  FDA
//
//  Created by Arun Kumar on 4/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import MessageUI

class ResourcesDetailViewController: UIViewController {
    
    
    @IBOutlet var webView : UIWebView?
    var activityIndicator:UIActivityIndicatorView!
    var requestLink:String?
    
    var htmlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        
        if self.requestLink != nil {
            
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY-100)
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            let url:URL? = URL.init(string:self.requestLink!)!
            let urlRequest = URLRequest(url: url!)
            
            webView?.loadRequest(urlRequest)
            
        }
        else{
            
        }
        
        webView?.delegate = self
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // self.tabBar.isHidden = false
    }
    
    //MARK:Button Actions
    
    @IBAction func cancelButtonClicked(_ sender : Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonActionForward(_ sender : UIBarButtonItem){
        
       self.sendEmail()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ResourcesDetailViewController:UIWebViewDelegate{
    
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

extension ResourcesDetailViewController:MFMailComposeViewControllerDelegate{
    
    func sendEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        
        composeVC.setSubject("Resources")
        
        if self.requestLink != nil{
            composeVC.setMessageBody(self.requestLink!, isHTML: false)
        }
        else{
            composeVC.setMessageBody(self.requestLink!, isHTML: true)
        }
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
       
        controller.dismiss(animated: true, completion: nil)
    }

}

