//
//  SecondViewController.swift
//  FDA
//
//  Created by Ravishankar on 2/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class SecondViewController : UIViewController{
    
    @IBOutlet var buttonGetStarted : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonGetStarted?.layer.borderColor = UIColor.init(colorLiteralRed: 0/255.0, green: 124/255.0, blue: 186/255.0, alpha: 1.0).cgColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
}
