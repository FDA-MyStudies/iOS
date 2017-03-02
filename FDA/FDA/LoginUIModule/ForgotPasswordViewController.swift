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
        buttonSubmit?.layer.borderColor = UIColor.init(colorLiteralRed: 0/255.0, green: 124/255.0, blue: 186/255.0, alpha: 1.0).cgColor
        self.title = "Forgot Password"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    //MARK: Submit Button Action and validation checks
    @IBAction func submitButtonAction(_ sender: Any) {
        
        
        
        
        
    }
    
}
