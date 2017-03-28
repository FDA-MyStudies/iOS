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

let kAlertMessageResendEmail = "An email verification code has been sent to your registered email."




class VerificationViewController : UIViewController{
    
    @IBOutlet var buttonContinue : UIButton?
    @IBOutlet var buttonResendEmail : UIButton?
    @IBOutlet var labelVerificationMessage : UILabel?
    @IBOutlet var textFieldEmail :UITextField?
    @IBOutlet var textFieldVerificationCode : UITextField?
    var labelMessage : String?
    var isFromForgotPassword :Bool =  false
    var emailId:String?
    var shouldCreateMenu:Bool = true
    
 //MARK:View Controllere delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonContinue?.layer.borderColor = kUicolorForButtonBackground
        self.title = NSLocalizedString("", comment: "")
        
        //let message = labelVerificationMessage?.text
        //let modifiedMessage = message?.replacingOccurrences(of: kDefaultEmail, with: User.currentUser.emailId!)
        //labelVerificationMessage?.text = modifiedMessage
        
        
        if labelMessage != nil {
            labelVerificationMessage?.text = labelMessage
        }
        
        textFieldEmail?.text = self.emailId!
        
        
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
 
    
    @IBAction func buttonActionBack(_ sender : UIButton){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueTwoButtonAction( _ sender : UIButton){
        
        self.view.endEditing(true)
        if ((textFieldEmail?.text)!.isEmpty) && (self.textFieldVerificationCode?.text == "") {
            self.showAlertMessages(textMessage: kMessageAllFieldsAreEmpty)
        }else if (textFieldEmail?.text)! == "" {
            self.showAlertMessages(textMessage: kMessageEmailBlank)
            
        }else if !(Utilities.isValidEmail(testStr: (textFieldEmail?.text)!)) {
            self.showAlertMessages(textMessage: kMessageValidEmail)
            
        }else if self.textFieldVerificationCode?.text == ""{
            self.showAlertMessages(textMessage: kMessageVerificationCodeEmpty)
            
        }else{
            print("Call the webservice")
            
            UserServices().verifyEmail(emailId:(textFieldEmail?.text)!,  verificationCode:(self.textFieldVerificationCode?.text)! , delegate: self)
            
            
        }
    }
    
    
    @IBAction func continueButtonAction(_ sender: Any) {
        
        if (textFieldVerificationCode?.text?.characters.count)! > 0 {
             UserServices().verifyEmail(emailId:User.currentUser.emailId!,  verificationCode:(self.textFieldVerificationCode?.text)! , delegate: self)
        }
        else{
             self.showAlertMessages(textMessage: kMessageVerificationCodeEmpty)
        }
    }
    
    @IBAction func resendEmailButtonAction(_ sender: UIButton){
        
        var finalEmail:String = User.currentUser.emailId!
        
        if isFromForgotPassword {
            finalEmail = (textFieldEmail?.text)!
        }
       
        
        if (finalEmail.isEmpty) || !(Utilities.isValidEmail(testStr: finalEmail)) {
             self.showAlertMessages(textMessage: kMessageValidEmail)
        }
        else{
             UserServices().resendEmailConfirmation(emailId: finalEmail, delegate: self)
        }
       
        
        
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let singupCompletion = segue.destination as? SignUpCompleteViewController {
           
            singupCompletion.shouldCreateMenu = self.shouldCreateMenu
        }
    }
//MARK:Utility Methods
    
    
    /*
     Used to show the alert using Utility
     */
    func showAlertMessages(textMessage : String){
        UIUtilities.showAlertMessage("", errorMessage: NSLocalizedString(textMessage, comment: ""), errorAlertActionTitle: NSLocalizedString("OK", comment: ""), viewControllerUsed: self)
    }
    
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

//MARK:TextField Delegates
extension VerificationViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let finalString = textField.text! + string
        
        if string == " " || finalString.characters.count > 255{
            return false
        }
        else{
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text!)
       
        if textField == textFieldEmail {
             User.currentUser.emailId = textField.text
            
        } else {
            
        }
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
            
            if self.isFromForgotPassword{
                
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
