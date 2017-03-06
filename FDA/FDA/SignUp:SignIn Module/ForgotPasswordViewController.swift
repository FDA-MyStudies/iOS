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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonSubmit?.layer.borderColor = kUicolorForButtonBackground
        self.title = NSLocalizedString("Forgot Password", comment: "")
        
        //Used for background tap dismiss keyboard
        let gestureRecognizwe : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(SignInViewController.dismissKeyboard))
        self.view?.addGestureRecognizer(gestureRecognizwe)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textFieldEmail?.becomeFirstResponder()
        
    }
    
    //Dismiss key board when clicked on Background
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    //Used to show the alert using Utility
    func showAlertMessages(textMessage : String){
        UIUtilities.showAlertMessage("", errorMessage: NSLocalizedString(textMessage, comment: ""), errorAlertActionTitle: NSLocalizedString("OK", comment: ""), viewControllerUsed: self)
    }
    
    //MARK: Submit Button Action and validation checks
    @IBAction func submitButtonAction(_ sender: Any) {
        self.dismissKeyboard()
        if textFieldEmail?.text == "" {
            self.showAlertMessages(textMessage: "Please enter your email address.")
            
        }else if !(Utilities.isValidEmail(testStr: (textFieldEmail?.text)!)) {
            self.showAlertMessages(textMessage: "Please enter valid email address.")
            
        }else{
            print("Call the Webservice")
            
            
            
        
        }
    }
}



