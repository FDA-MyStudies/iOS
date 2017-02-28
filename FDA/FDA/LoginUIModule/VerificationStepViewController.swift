//
//  VerificationStepViewController.swift
//  FDA
//
//  Created by Ravishankar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class VerificationStepViewController : UIViewController{
    
    @IBOutlet var buttonContinue : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonContinue?.layer.borderColor = UIColor.init(colorLiteralRed: 73/255.0, green: 182/255.0, blue: 229/255.0, alpha: 1.0).cgColor
        self.title = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
}
