//
//  VerificationStepViewController.swift
//  FDA
//
//  Created by Ravishankar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class VerificationViewController : UIViewController{
    
    @IBOutlet var buttonContinue : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonContinue?.layer.borderColor = kUicolorForButtonBackground
        self.title = NSLocalizedString("", comment: "")
        
        //hide navigationbar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    //Continue Button Action and validation checks
    @IBAction func continueButtonAction(_ sender: Any) {
        
        UserServices().confirmUserRegistration(self)
    }
    
    func navigateToSignUpCompletionStep(){
        
        self.performSegue(withIdentifier: "signupCompletionSegue", sender: nil)
    }
}

extension VerificationViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        if User.currentUser.verified == true{
            self.navigateToSignUpCompletionStep()
        }
        else {
            
            UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString("Message", comment: "") as NSString, message:NSLocalizedString("Please verify your email adderss.", comment: "") as NSString)
        }
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString("Error", comment: "") as NSString, message: error.localizedDescription as NSString)
    }
}
