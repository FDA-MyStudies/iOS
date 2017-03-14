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
    var shouldCreateMenu:Bool = true
    
    
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
        
        if shouldCreateMenu {
            
            self.createMenuView()
        }
        else {
            let leftController = slideMenuController()?.leftViewController as! LeftMenuViewController
            leftController.createLeftmenuItems()
            leftController.changeViewController(.studyList)
        }
        
    }
    func createMenuView() {
        
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
        
        let fda = storyboard.instantiateViewController(withIdentifier: "FDASlideMenuViewController") as! FDASlideMenuViewController
        fda.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.pushViewController(fda, animated: true)
    }
    
}
