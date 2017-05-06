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
    
    
//MARK:- ViewController Lifecycle
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

    
//MARK:- button Actions
    
    /**
     
     Next button clicked and navigate the screen to GateWay dashboard
     
     @param sender  accepts any object
     
     */
    @IBAction func nextButtonAction(_ sender: Any) {
        self.navigateToGatewayDashboard()
    }
    
    
//MARK:- Utility Methods
    
    /**
     
     Used to Navigate StudyList after completion
    
     */
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
    
    
    /**
     
     Method to Create Menu View after completion
    
     */
    func createMenuView() {
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
        
        let fda = storyboard.instantiateViewController(withIdentifier: "FDASlideMenuViewController") as! FDASlideMenuViewController
        fda.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.pushViewController(fda, animated: true)
    }
}


