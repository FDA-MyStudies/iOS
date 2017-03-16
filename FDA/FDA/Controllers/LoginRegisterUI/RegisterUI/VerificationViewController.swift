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
    @IBOutlet var buttonResendEmail : UIButton?
    @IBOutlet var labelVerificationMessage : UILabel?
    var shouldCreateMenu:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonContinue?.layer.borderColor = kUicolorForButtonBackground
        self.title = NSLocalizedString("", comment: "")
        
        let message = labelVerificationMessage?.text
        let modifiedMessage = message?.replacingOccurrences(of: "xyz@gmail.com", with: User.currentUser.emailId!)
        labelVerificationMessage?.text = modifiedMessage
        
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
    
    @IBAction func resendEmailButtonAction(_ sender: Any){
        UserServices().resendEmailConfirmation(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let singupCompletion = segue.destination as? SignUpCompleteViewController {
           
            singupCompletion.shouldCreateMenu = self.shouldCreateMenu
        }
    }
    func navigateToSignUpCompletionStep(){
        
        self.performSegue(withIdentifier: "signupCompletionSegue", sender: nil)
    }
}

extension VerificationViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        
        self.addProgressIndicator()
        Logger.sharedInstance.info("requestname : \(requestName)")
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        
        if User.currentUser.verified == true{
            
            self.navigateToSignUpCompletionStep()
        }
        else {
            
            UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString("Message", comment: "") as NSString, message:NSLocalizedString("Please verify your email adderss.", comment: "") as NSString)
        }

    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        if error.code == 401 { //unauthorized
            UIUtilities.showAlertMessageWithActionHandler(kErrorTitle, message: error.localizedDescription, buttonTitle: kTitleOk, viewControllerUsed: self, action: {
                _ = self.navigationController?.popToRootViewController(animated: true)
            })
        }
        else {
            
            UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kErrorTitle, comment: "") as NSString, message: error.localizedDescription as NSString)
        }
    }
}
