//
//  SplashViewController.swift
//  FDA
//
//  Created by Surender Rathore on 3/7/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
var isAppOpenedForFirstTime:Bool? = false
    
//MARK:- Viewcontroller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         DBHandler().initilizeCurrentUser()
        //TEMP : Need to get form Realm
        //let ud = UserDefaults.standard
        
        
        self.checkIfAppLaunchedForFirstTime()
        
        /*Used to Check AuthKey, If exists navigate to HomeController else GatewayDashboard*/
        if User.currentUser.authToken != nil {
           
//            DBHandler().initilizeCurrentUser()
//            User.currentUser.authToken = ud.object(forKey: kUserAuthToken) as! String!
//            User.currentUser.userId = ud.object(forKey:kUserId) as! String!
//            User.currentUser.userType = UserType.FDAUser
            
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.checkPasscode(viewController: self)
            
            self.navigateToGatewayDashboard()
        }
        else {
            self.navigateToHomeController()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
     
     Navigating to Home Screen and load HomeViewController from Login Storyboard
     
     */
    func navigateToHomeController(){
        
        let loginStoryboard = UIStoryboard.init(name: "Login", bundle:Bundle.main)
        let homeViewController = loginStoryboard.instantiateViewController(withIdentifier:"HomeViewController")
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    
    /** 
     
     Navigate to gateway Dashboard 
     
     */
    func navigateToGatewayDashboard(){
        self.createMenuView()
    }
    
    
    /**
     
     Navigating to Study list and Load FDASlideMenuViewController from Gateway Storyboard
     
     */
    func createMenuView() {
        
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
        
        let fda = storyboard.instantiateViewController(withIdentifier: "FDASlideMenuViewController") as! FDASlideMenuViewController
        fda.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.pushViewController(fda, animated: true)
    }
    
    func checkIfAppLaunchedForFirstTime(){
        
        if isAppOpenedForFirstTime == false{
            
            
            let currentDate = "\(Date(timeIntervalSinceNow: 0))"
            
            let currentIndex = currentDate.index(currentDate.endIndex
                , offsetBy: -13)
            let subStringFromDate = currentDate.substring(to: currentIndex)
            
            let ud = UserDefaults.standard
            
           
            
            if User.currentUser.userType == .FDAUser{
                
                let index =  User.currentUser.userId.index(User.currentUser.userId.endIndex
                    , offsetBy: -16)
                
                let subKey = User.currentUser.userId.substring(to:index )
                
                ud.set("\(subKey + subStringFromDate)", forKey: "EncryptionKey")
            }
            else{
                ud.set(currentDate + "Password123", forKey: "EncryptionKey")
            }
            
            
            if UIDevice.current.model == "iPhone Simulator" {
                // simulator
                
                ud.set("drowssapdrowssap", forKey: "EncryptionIV")
                
            }
            else{
                // not a simulator
                var udid = UIDevice.current.identifierForVendor?.uuidString
                
                let index =  udid?.index((udid?.endIndex)!
                    , offsetBy: -20)
                
                udid = udid?.substring(to: index!)
                
                ud.set(udid, forKey: "EncryptionIV")
            }
            
            ud.synchronize()
            
        }
        
    }

}


//MARK:- ORKTaskViewController Delegate
extension SplashViewController:ORKTaskViewControllerDelegate{
    
    func taskViewControllerSupportsSaveAndRestore(_ taskViewController: ORKTaskViewController) -> Bool {
        return true
    }
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        var taskResult:Any?
        
        switch reason {
            
        case ORKTaskViewControllerFinishReason.completed:
            print("completed")
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.failed:
            print("failed")
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.discarded:
            print("discarded")
            
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.saved:
            print("saved")
            taskResult = taskViewController.restorationData
            
        }
        taskViewController.dismiss(animated: true, completion: nil)
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        
    }
}


