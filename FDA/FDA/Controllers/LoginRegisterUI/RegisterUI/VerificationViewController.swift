//
//  VerificationStepViewController.swift
//  FDA
//
//  Created by Ravishankar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

let kDefaultEmail = "xyz@gmail.com"
let kSignupCompletionSegue = "signupCompletionSegue"
let kAlertMessageText = "Message"
let kAlertMessageVerifyEmail = "Please verify your email address."

let kAlertMessageResendEmail = "An email verification link has been sent to your registered email."

class VerificationViewController : UIViewController{
    
    @IBOutlet var buttonContinue : UIButton?
    @IBOutlet var buttonResendEmail : UIButton?
    @IBOutlet var labelVerificationMessage : UILabel?
    var shouldCreateMenu:Bool = true
    
 //MARK:View Controllere delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonContinue?.layer.borderColor = kUicolorForButtonBackground
        self.title = NSLocalizedString("", comment: "")
        
        let message = labelVerificationMessage?.text
        let modifiedMessage = message?.replacingOccurrences(of: kDefaultEmail, with: User.currentUser.emailId!)
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
    
    
//MARK:Button Actions
 
    @IBAction func continueButtonAction(_ sender: Any) {
        
        UserServices().confirmUserRegistration(self)
    }
    
    @IBAction func resendEmailButtonAction(_ sender: UIButton){
        UserServices().resendEmailConfirmation(emailId: User.currentUser.emailId!, delegate: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let singupCompletion = segue.destination as? SignUpCompleteViewController {
           
            singupCompletion.shouldCreateMenu = self.shouldCreateMenu
        }
    }
//MARK:Utility Methods
    func navigateToSignUpCompletionStep(){
        
        self.performSegue(withIdentifier: kSignupCompletionSegue, sender: nil)
    }
    func navigateToChangePasswordViewController(){
        
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
        
        let fda = storyboard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        
        if shouldCreateMenu {
            fda.viewLoadFrom = .login
        }
        else{
            fda.viewLoadFrom = .menu_login
        }
        
        self.navigationController?.pushViewController(fda, animated: true)
    }
}

//MARK:Webservice Delegates

extension VerificationViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        
        self.addProgressIndicator()
        Logger.sharedInstance.info("requestname : \(requestName)")
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        
        if User.currentUser.verified == true{
            
            if User.currentUser.isLoginWithTempPassword {
                self.navigateToChangePasswordViewController()
            }
            else{
                self.navigateToSignUpCompletionStep()
            }
            
        }
        else {
            
            
            if requestName as String == RegistrationMethods.resendConfirmation.description {
                UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kAlertMessageText, comment: "") as NSString, message:NSLocalizedString(kAlertMessageResendEmail, comment: "") as NSString)
            }
            else{
                UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kAlertMessageText, comment: "") as NSString, message:NSLocalizedString(kAlertMessageVerifyEmail, comment: "") as NSString)
            }
            
            
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
