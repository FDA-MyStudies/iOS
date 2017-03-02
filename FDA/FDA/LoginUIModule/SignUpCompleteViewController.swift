//
//  SignUpCompleteViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/1/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit


class SignUpCompleteViewController : UIViewController{
    
    @IBOutlet var buttonNext : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonNext?.layer.borderColor = UIColor.init(colorLiteralRed: 0/255.0, green: 124/255.0, blue: 186/255.0, alpha: 1.0).cgColor
        self.title = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    
    //MARK: Submit Button Action and validation checks
    @IBAction func nextButtonAction(_ sender: Any) {
        
        
        
        
        
    }
    
}
