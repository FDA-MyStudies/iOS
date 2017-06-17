//
//  SignUpCompleteViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/1/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

enum CompletionLoadFrom:Int{
    case signup
    case joinStudy
}
class SignUpCompleteViewController : UIViewController{
    
    @IBOutlet var buttonNext : UIButton?
    var shouldCreateMenu:Bool = true
    var viewLoadFrom:CompletionLoadFrom = .signup
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonNext?.layer.borderColor = kUicolorForButtonBackground
        self.title = NSLocalizedString("", comment: "")
        
        
        let settings:Settings? = Settings.init()
        
        settings?.remoteNotifications = false
        settings?.localNotifications = true
        settings?.touchId = true
        settings?.passcode = true
        
        User.currentUser.settings = settings
        
        UserServices().updateUserProfile(self as NMWebServiceDelegate)
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
        
        //Updating Key & Vector
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.updateKeyAndInitializationVector()
        
       
        if self.viewLoadFrom == .joinStudy{
            let leftController = slideMenuController()?.leftViewController as! LeftMenuViewController
            leftController.createLeftmenuItems()
            self.performSegue(withIdentifier: "unwindStudyHomeSegue", sender: self)
        }
        else {
            self.navigateToGatewayDashboard()
        }
        
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
        let storyboard = UIStoryboard(name: kStoryboardIdentifierGateway, bundle: nil)
        
        let fda = storyboard.instantiateViewController(withIdentifier: kStoryboardIdentifierSlideMenuVC) as! FDASlideMenuViewController
        fda.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.pushViewController(fda, animated: true)
    }
}



//MARK:- UserService Response handler
extension SignUpCompleteViewController:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        if requestName as String ==  RegistrationMethods.updateUserProfile.description {
            
            DBHandler.saveUserSettingsToDatabase()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.checkPasscode(viewController: self.navigationController!)

            let ud = UserDefaults.standard
            ud.set(false, forKey: kPasscodeIsPending)
            ud.set(false, forKey: kShowNotification)
            ud.synchronize()
            
            
        }
    }
    
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kErrorTitle, comment: "") as NSString, message: error.localizedDescription as NSString)
    }
}


