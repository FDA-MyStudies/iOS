//
//  EligibilityStepViewController.swift
//  FDA
//
//  Created by Arun Kumar on 3/21/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import ResearchKit

class EligibilityStep: ORKStep {
    var type:String?
}



class EligibilityStepViewController: ORKStepViewController {

    @IBOutlet weak var tokenTextField: UITextField!
    override init(step: ORKStep?) {
        super.init(step: step)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let step = step as? EligibilityStep {
            step.type = "token"
        }
    }
    
    
    
    override func hasNextStep() -> Bool {
        super.hasNextStep()
        return true
    }
    
    override func goForward(){
        
        super.goForward()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func buttonActionSubmit(sender: UIButton?) {
        
        self.view.endEditing(true)
        let token = tokenTextField.text
        
        if (token?.characters.count)! > 0 {
            // LabKeyServices().verifyEnrollmentToken(token: token!, delegate: self)
        }
        
        
        
        
       /*
        
        if username?.characters.count == 0 || password?.characters.count == 0{
            self.showAlert(title: "Error", message: "Please provide email id and password to sign in")
            return
        }
        
        self.toggleLoader(show: true)
        
        
        AppConnectHelper.sharedInstance.login(username: username!, password: password!) { (success, errorMessage) in
            self.toggleLoader(show: false)
            
            if  success {
                self.goForward()
            }
            else if  errorMessage != nil {
                self.showAlert(title: "Error", message: errorMessage!)
            }
        }
        
        */
        
    }
}

extension EligibilityStepViewController:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == " "{
            return false
        }
        else{
            return true
        }

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
}

extension EligibilityStepViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.addProgressIndicator()
        
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        self.goForward()
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString("Error", comment: "") as NSString, message: error.localizedDescription as NSString)
    }
}


