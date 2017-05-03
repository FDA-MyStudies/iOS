    //
    //  AppDelegate.swift
    //  FDA
    //
    //  Created by Arun Kumar on 2/2/17.
    //  Copyright © 2017 BTC. All rights reserved.
    //
    
    import UIKit
    import Fabric
    import Crashlytics
    
    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
        var window: UIWindow?
        
        let healthStore = HKHealthStore()
        var containerViewController: ResearchContainerViewController? {
            return window?.rootViewController as? ResearchContainerViewController
        }
        
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            
            self.customizeNavigationBar()
            Fabric.with([Crashlytics.self])
            
            UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self]).tintColor = kUIColorForSubmitButtonBackground
            
           // self.checkForAppUpdate()
            
            return true
        }
        
        func applicationWillResignActive(_ application: UIApplication) {
            // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
            // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
            
            
        
              //  self.window?.isHidden = true;
        
            
        }
        
        func applicationDidEnterBackground(_ application: UIApplication) {
            // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
            // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
            
            
           
        }
        
        func applicationWillEnterForeground(_ application: UIApplication) {
            
            // self.window?.isHidden = true
            
             self.checkPasscode(viewController: (application.windows[0].rootViewController)!)
            
            // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        }
        
        func applicationDidBecomeActive(_ application: UIApplication) {
            // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
           // self.window?.isHidden = false
          
           
          
        }
        
        func applicationWillTerminate(_ application: UIApplication) {
            // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        }
        
        //MARK:Custom Navigation Bar
        func customizeNavigationBar(){
            UINavigationBar.appearance().titleTextAttributes = [
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 18)!
            ]
            // UINavigationBar.appearance().backgroundColor = UIColor.white
            // UINavigationBar.appearance().tintColor = UIColor.clear
        }
        
        func checkForAppUpdate(){
            WCPServices().checkForAppUpdates(delegate: self)
        }
        
         func checkPasscode(viewController:UIViewController) {
            if User.currentUser.userType == .FDAUser {
                //FDA user
                
                if  ORKPasscodeViewController.isPasscodeStoredInKeychain() == false{
                    let passcodeStep = ORKPasscodeStep(identifier: "PasscodeStep")
                    passcodeStep.passcodeType = .type4Digit
                    let task = ORKOrderedTask(identifier: "PassCodeTask", steps: [passcodeStep])
                    let taskViewController = ORKTaskViewController.init(task: task, taskRun: nil)
                    taskViewController.delegate = viewController as? ORKTaskViewControllerDelegate
                    viewController.present(taskViewController, animated: false, completion: nil)
                }
                else{
                    guard ORKPasscodeViewController.isPasscodeStoredInKeychain() && !(containerViewController?.presentedViewController is ORKPasscodeViewController) else { return }
                    window?.makeKeyAndVisible()
                    
                    let passcodeViewController = ORKPasscodeViewController.passcodeAuthenticationViewController(withText: "Enter Passcode to access app", delegate: self)
                    viewController.present(passcodeViewController, animated: false, completion: nil)
                }
                
            }
            else{
                //Anonomous user
                
                //ORKPasscodeViewController.removePasscodeFromKeychain()
            }

        }
        
    }
    //Handling for HTTPS
    extension AppDelegate : NMAuthChallengeDelegate{
        
        func networkCredential(_ manager : NetworkManager, challenge : URLAuthenticationChallenge) -> URLCredential{
            var urlCredential:URLCredential = URLCredential()
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                if challenge.protectionSpace.host == "hphci-fdama-te-ur-01.labkey.com" {
                    urlCredential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
                }
            }
            return urlCredential
        }
        
        func networkChallengeDisposition(_ manager : NetworkManager, challenge : URLAuthenticationChallenge) -> URLSession.AuthChallengeDisposition{
            return URLSession.AuthChallengeDisposition.useCredential
        }
    }
    extension AppDelegate:NMWebServiceDelegate {
        func startedRequest(_ manager: NetworkManager, requestName: NSString) {
            Logger.sharedInstance.info("requestname : \(requestName)")
            //self.addProgressIndicator()
        }
        func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
            Logger.sharedInstance.info("requestname : \(requestName) Response : \(response)")
            
            if requestName as String == WCPMethods.appUpdates.method.methodName {
                
                let appVersion = Utilities.getAppVersion()
                if appVersion != response?["currentVersion"] as! String {
                    
                    if response?["forceUpdate"] as! Bool {
                        
                        let appBlocker = AppUpdateBlocker.instanceFromNib(frame:(UIApplication.shared.keyWindow?.bounds)!, detail: response as! Dictionary<String, Any>);
                       // UIApplication.shared.keyWindow?.addSubview(appBlocker);
                    }
                    else {
                         UIUtilities.showAlertWithMessage(alertMessage: response?["message"] as! String);
                    }
                    
                    
                }
              
                
            }
            
            
            
        }
        func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
            Logger.sharedInstance.info("requestname : \(requestName)")
            
            
            
            
        }
    }

   
    extension AppDelegate:ORKTaskViewControllerDelegate{
        //MARK:ORKTaskViewController Delegate
        
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
    
    extension AppDelegate: ORKPasscodeDelegate {
        func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
            containerViewController?.contentHidden = false
          
            viewController.dismiss(animated: true, completion: nil)
        }
        
        func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
        }
    }
