//
//  ForgotPassword.swift
//  FDA
//
//  Created by Ravishankar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class ForgotPasswordViewController : UIViewController{
    
    @IBOutlet var buttonSubmit : UIButton?
    @IBOutlet var textFieldEmail : UITextField?
    
    //MARK:ViewController Delegates
    
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
    
    
    //MARK:Utility Methods
    
    /*
     Dismiss key board when clicked on Background
     */
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    /*
     Used to show the alert using Utility
    */
    func showAlertMessages(textMessage : String){
        UIUtilities.showAlertMessage("", errorMessage: NSLocalizedString(textMessage, comment: ""), errorAlertActionTitle: NSLocalizedString("OK", comment: ""), viewControllerUsed: self)
    }
    
    //MARK:Button Action
    @IBAction func submitButtonAction(_ sender: Any) {
        self.dismissKeyboard()
        if textFieldEmail?.text == "" {
            self.showAlertMessages(textMessage: kMessageEmailBlank)
            
        }else if !(Utilities.isValidEmail(testStr: (textFieldEmail?.text)!)) {
            self.showAlertMessages(textMessage: kMessageValidEmail)
            
        }else{
            print("Call the Webservice")
            User.currentUser.emailId = textFieldEmail?.text!
            UserServices().forgotPassword(email:(textFieldEmail?.text)!,delegate: self)
        }
    }
}

//MARK:Webservices Delegates
extension ForgotPasswordViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        UIUtilities.showAlertMessageWithActionHandler(NSLocalizedString(kTitleMessage, comment: ""), message: NSLocalizedString(kForgotPasswordResponseMessage, comment: "") , buttonTitle: NSLocalizedString(kTitleOk, comment: ""), viewControllerUsed: self) {
            
            _ = self.navigationController?.popViewController(animated: true)
            
        }
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        
        self.removeProgressIndicator()
        Logger.sharedInstance.info("requestname : \(requestName)")
        UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kTitleError, comment: "") as NSString, message: error.localizedDescription as NSString)
    }
}

//MARK:TextField Delegates
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

