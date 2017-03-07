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
        buttonNext?.layer.borderColor = kUicolorForButtonBackground
        self.title = NSLocalizedString("", comment: "")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //hide navigationbar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    
    
    //Next button Action
    @IBAction func nextButtonAction(_ sender: Any) {
        
            self.navigateToGatewayDashboard()
     
    }
    
    func navigateToGatewayDashboard(){
        
        let loginStoryboard = UIStoryboard.init(name: "Gateway", bundle:Bundle.main)
        let tabbarController = loginStoryboard.instantiateViewController(withIdentifier:"TabbarViewController")
        self.navigationController?.pushViewController(tabbarController, animated: true)
    }
    
}
