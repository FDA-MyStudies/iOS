//
//  ForgotPassword.swift
//  FDA
//
//  Created by Ravishankar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

let kVerifyViewControllerSegue = "VerifyViewControllerSegue"
let kVerficationMessageFromForgotPassword = "Your registered email(xyz@gmail.com) is pending verification. Enter the Verification Code received on this email to complete verification and try the Forgot Password action again."

class ForgotPasswordViewController : UIViewController{
    
    @IBOutlet var buttonSubmit : UIButton?
    @IBOutlet var textFieldEmail : UITextField?
    
//MARK:- ViewController Delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonSubmit?.layer.borderColor = kUicolorForButtonBackground
        self.title = NSLocalizedString(kForgotPasswordTitleText, comment: "")
        
        //Used for background tap dismiss keyboard
        let gestureRecognizwe : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(SignInViewController.dismissKeyboard))
        self.view?.addGestureRecognizer(gestureRecognizwe)
        
        self.addBackBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //unhide navigationbar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        UIApplication.shared.statusBarStyle = .default
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textFieldEmail?.becomeFirstResponder()
        
    }
    
//MARK:- Utility Methods
    
    /**
     
     Dismiss key board when clicked on Background
     
     */
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    /**
     
     Navigate the screen to VerifyViewController
     
     */
    func navigateToVerifyViewController()  {
        self.performSegue(withIdentifier: kVerifyViewControllerSegue, sender: self)
    }
    
    
    /**
    
     Used to show the alert using Utility
     
     @param textMessage     used to display in the alert message
    
     */
    func showAlertMessages(textMessage : String){
        UIUtilities.showAlertMessage("", errorMessage: NSLocalizedString(textMessage, comment: ""), errorAlertActionTitle: NSLocalizedString("OK", comment: ""), viewControllerUsed: self)
    }
    
    
//MARK:- Button Action
    
    /**
     
     Submit Button Clicked, it is used to check all the validations 
     before making a logout webservice call
     
     @param sender  Accepts any kind of object
     
     */
    @IBAction func submitButtonAction(_ sender: Any) {
        self.dismissKeyboard()
        if textFieldEmail?.text == "" {
            self.showAlertMessages(textMessage: kMessageEmailBlank)
            
        }else if !(Utilities.isValidEmail(testStr: (textFieldEmail?.text)!)) {
            self.showAlertMessages(textMessage: kMessageValidEmail)
            
        }else{
            print("Call the Webservice")
            //User.currentUser.emailId = textFieldEmail?.text!
            UserServices().forgotPassword(email:(textFieldEmail?.text)!,delegate: self)
        }
    }
    
    
//MARK:- Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let verifyController = segue.destination as? VerificationViewController {
            
            let message = kVerficationMessageFromForgotPassword
            let modifiedMessage = message.replacingOccurrences(of: kDefaultEmail, with:(textFieldEmail?.text)!)
            
            verifyController.labelMessage = modifiedMessage
            verifyController.viewLoadFrom = .forgotPassword
            verifyController.emailId = textFieldEmail?.text
        }
    }
}


//MARK:- Webservices Delegates
extension ForgotPasswordViewController:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        
        if requestName as String == RegistrationMethods.forgotPassword.description  {
            UIUtilities.showAlertMessageWithActionHandler(NSLocalizedString(kTitleMessage, comment: ""), message: NSLocalizedString(kForgotPasswordResponseMessage, comment: "") , buttonTitle: NSLocalizedString(kTitleOk, comment: ""), viewControllerUsed: self) {
                
                _ = self.navigationController?.popViewController(animated: true)
                
            }
        }
        else{
            // for resend email
            
              UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kAlertMessageText, comment: "") as NSString, message:NSLocalizedString(kAlertMessageResendEmail, comment: "") as NSString)
            
        }
    }
    
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        
        self.removeProgressIndicator()
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        if requestName as String == RegistrationMethods.forgotPassword.description && error.code == 403{
            
            self.navigateToVerifyViewController()
            
            /*
            UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString(kTitleMessage, comment: "") , errorMessage: error.localizedDescription, errorAlertActionTitle: NSLocalizedString("Ok", comment: ""),
                                                                 errorAlertActionTitle2: NSLocalizedString("Resend Email", comment: ""), viewControllerUsed: self,
                                                                 action1: {
            },
                                                                 action2: {
                                                                    
                                                                    UserServices().resendEmailConfirmation(emailId:(self.textFieldEmail?.text)!,delegate:self)
                                                                    
            })
 */

        }
        else{
            // if resend email fails
             UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kTitleError, comment: "") as NSString, message: error.localizedDescription as NSString)
        }
    }
}


//MARK:- TextField Delegates
extension ForgotPasswordViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let finalString = textField.text! + string
        
        if string == " " || finalString.characters.count > 255{
            return false
        }
        else{
            return true
        }
    }
}

