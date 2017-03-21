//
//  EligibilityViewController.swift
//  FDA
//
//  Created by Arun Kumar on 3/21/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import ResearchKit

class EligibilityViewController: ORKStepViewController {

    @IBOutlet weak var tokenTextField: UITextField!
    override init(step: ORKStep?) {
        super.init(step: step)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func buttonActionSubmit(sender: UIButton?) {
        
        self.view.endEditing(true)
        let token = tokenTextField.text
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

extension EligibilityViewController:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
}


