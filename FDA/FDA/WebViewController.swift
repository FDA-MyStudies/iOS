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

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = "http://35.167.14.182:5080/live/viewer.jsp?host=35.167.14.182&stream=NoswMb" as AnyObject
        UIWebView.loadRequest(webView!)(NSURLRequest(url: NSURL(string: url as! String)! as URL) as URLRequest)
        
        //Used to add a loader
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY-100)
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @IBAction func cancelButtonClicked(_ sender : Any){
        self.dismiss(animated: true, completion: nil)
    }
}







