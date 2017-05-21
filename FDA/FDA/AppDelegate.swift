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
    import UserNotifications
    
    import CallKit
    
    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
        var window: UIWindow?
        
        var appIsResignedButDidNotEnteredBackground:Bool? = false
        
        let healthStore = HKHealthStore()
        var containerViewController: ResearchContainerViewController? {
            return window?.rootViewController as? ResearchContainerViewController
        }
        
        func askForNotification(){
            
//            let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
//            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            
            if #available(iOS 10.0, *) {
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: {_, _ in })
                
                // For iOS 10 display notification (sent via APNS)
                UNUserNotificationCenter.current().delegate = self
                
                
            } else {
                let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
            }
            UIApplication.shared.registerForRemoteNotifications()
            
        }
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            
            
            
            self.customizeNavigationBar()
            Fabric.with([Crashlytics.self])
            
            UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self]).tintColor = kUIColorForSubmitButtonBackground
            
            // self.checkForAppUpdate()
            
           
           // self.checkForAppUpdate()
            
            
            
            
            SyncUpdate.currentSyncUpdate = SyncUpdate()
            
              NotificationCenter.default.addObserver(SyncUpdate.currentSyncUpdate as Any , selector: #selector(SyncUpdate.currentSyncUpdate?.updateData), name:ReachabilityChangedNotification, object: nil)
            
            
            return true
           
    }
        
        func applicationWillResignActive(_ application: UIApplication) {
            // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
            // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
            
            
            
            self.appIsResignedButDidNotEnteredBackground = true
            
            //  self.window?.isHidden = true;
            
            
        }
        
        func applicationDidEnterBackground(_ application: UIApplication) {
            // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
            // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
            
            self.appIsResignedButDidNotEnteredBackground = false
            
            
        }
        
        
        func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            
            /*
            if let tabBarController = window?.rootViewController as? UITabBarController,
                let viewControllers = tabBarController.viewControllers
            {
                for viewController in viewControllers {
                    if let fetchViewController = viewController as? FetalKickCounterStepViewController {
                        fetchViewController.fetch {
                            fetchViewController.updateUI()
                            completionHandler(.newData)
                        }
                    }
                }
            }
     
     */
        }
        
        
        func applicationWillEnterForeground(_ application: UIApplication) {
            
            // self.window?.isHidden = true
            
            
           
                  self.checkPasscode(viewController: (application.windows[0].rootViewController)!)
            
            
            
            
          
            
            // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        }
        
        func applicationDidBecomeActive(_ application: UIApplication) {
            // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
            // self.window?.isHidden = false
            
            /*
             
             let navController = application.windows[0].rootViewController
             
             if (navController as? UINavigationController) != nil &&  (navController as? UINavigationController)?.visibleViewController?.isKind(of: ORKTaskViewController.self) == false {
             
             
             self.checkPasscode(viewController: navController!)
             }
             
             */
            
            if self.appIsResignedButDidNotEnteredBackground! {
                
                let navController = application.windows[0].rootViewController
                
                if (navController as? UINavigationController) != nil &&  (navController as? UINavigationController)?.visibleViewController?.isKind(of: ORKTaskViewController.self) == false {
                    
                    
                    self.checkPasscode(viewController: navController!)
                }
            }
            
            if AppDelegate.jailbroken(application: application) {
                
                let navigationController =  (self.window?.rootViewController as! UINavigationController)
                
                let appBlocker = JailbrokeBlocker.instanceFromNib(frame: navigationController.view.frame, detail: nil);
                
                UIApplication.shared.keyWindow?.addSubview(appBlocker);
                
                UIApplication.shared.keyWindow?.bringSubview(toFront: appBlocker)
                
            }
            
            
            
        }
        
        
        func applicationWillTerminate(_ application: UIApplication) {
            // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        }
        
       //MARK:- NOTIFICATION
        
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            
            let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
            print(deviceTokenString)
            //UserDetails.deviceToken = deviceTokenString
            
            UserServices().updateUserProfile(deviceToken: deviceTokenString , delegate: self)
            
            
            print("APNs token retrieved: \(deviceToken)")
           
            
        }
        func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            
            print("i am not available in simulator \(error)")
            
        }
        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
            print(userInfo)
            
            //For iOS 8 & 9
            if (UIApplication.shared.applicationState == UIApplicationState.background)||(UIApplication.shared.applicationState == UIApplicationState.inactive){
               
            }
        }
        func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
            print("Notificatio received\(notification.userInfo)")
        }
        
        
        public static func jailbroken(application: UIApplication) -> Bool {
            guard let cydiaUrlScheme = NSURL(string: "cydia://package/com.example.package") else { return isJailbroken() }
            return application.canOpenURL(cydiaUrlScheme as URL) || isJailbroken()
        }
        
        
        static func isJailbroken() -> Bool {
            
            if UIDevice.current.model != "iPhone Simulator" {
               return false
            }
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
                fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
                fileManager.fileExists(atPath: "/bin/bash") ||
                fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
                fileManager.fileExists(atPath: "/etc/apt") ||
                fileManager.fileExists(atPath: "/usr/bin/ssh") {
                return true
            }
            
            if canOpen(path: "/Applications/Cydia.app") ||
                canOpen(path: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
                canOpen(path: "/bin/bash") ||
                canOpen(path: "/usr/sbin/sshd") ||
                canOpen(path: "/etc/apt") ||
          
                canOpen(path: "/usr/bin/ssh") {
                return true
            }
            
            let path = "/private/" + NSUUID().uuidString
            do {
                try "anyString".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                try fileManager.removeItem(atPath: path)
                return true
            } catch {
                return false
            }
        }
        
        static func canOpen(path: String) -> Bool {
            let file = fopen(path, "r")
            guard file != nil else { return false }
            fclose(file)
            return true
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
        
        func sendRequestToSignOut() {
            
            self.addAndRemoveProgress(add: true)
            
            UserServices().logoutUser(self as NMWebServiceDelegate)
            
        }
        
        func checkConsentStatus() {
            
           
            if(StudyUpdates.studyConsentUpdated){
                print("Study consent is updated: Please Present Consent UI")
                
                
                
                let navigationController =  (self.window?.rootViewController as! UINavigationController)
                
                var topController:UIViewController = navigationController
                if navigationController.viewControllers.count > 0 {
                     topController = navigationController.viewControllers.first!
                }
                
                
                
                            UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString("Consent Updated", comment: ""), errorMessage: NSLocalizedString("The Consent Document for this study has been updated. Please review the revised Consent terms and provide your Informed Consent, to continue participating in the study.", comment: ""), errorAlertActionTitle: NSLocalizedString("Review", comment: ""),
                                                                                 errorAlertActionTitle2:nil, viewControllerUsed: topController,
                                                                                 action1: {
                                                                                     WCPServices().getEligibilityConsentMetadata(studyId:(Study.currentStudy?.studyId)!, delegate: self as NMWebServiceDelegate)
                                                                                    self.addAndRemoveProgress(add: true)
                            },
                                                                                 action2: {
                
                            })
                
            }
            else {
                print("Study consent not updated")
            }
        }
        
        
        /**
         
         Used to Create Eligibility Consent Task
         
         */
        func createEligibilityConsentTask() {
            
            let taskViewController:ORKTaskViewController?
            
            let consentTask:ORKOrderedTask? = ConsentBuilder.currentConsent?.createConsentTask() as! ORKOrderedTask?
            
            taskViewController = ORKTaskViewController(task:consentTask, taskRun: nil)
            
            taskViewController?.delegate = self
            taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            taskViewController?.navigationItem.title = nil
            
            UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self]).tintColor = kUIColorForSubmitButtonBackground
            
            UIApplication.shared.statusBarStyle = .default
            
            
            var topVC = UIApplication.shared.keyWindow?.rootViewController
            
            
            while topVC?.presentedViewController != nil {
                topVC = topVC?.presentedViewController
            }
            
            topVC?.present(taskViewController!, animated: true, completion: nil)
        }
        
        
        
        func checkPasscode(viewController:UIViewController) {
            
            
            
            if User.currentUser.userType == .FDAUser {
                //FDA user
                
                
                if User.currentUser.settings?.passcode! == true {
                    
                    if  ORKPasscodeViewController.isPasscodeStoredInKeychain() == false{
                        
                        let passcodeStep = ORKPasscodeStep(identifier: "PasscodeStep")
                        passcodeStep.passcodeType = .type4Digit
                        
                        let task = ORKOrderedTask(identifier: "PassCodeTask", steps: [passcodeStep])
                        
                        
                        let taskViewController = ORKTaskViewController.init(task: task, taskRun: nil)
                        
                        if viewController.isKind(of: UINavigationController.self){
                            taskViewController.delegate = self
                        }
                        else{
                            taskViewController.delegate = viewController as? ORKTaskViewControllerDelegate
                        }
                        taskViewController.isNavigationBarHidden = true
                        viewController.present(taskViewController, animated: false, completion: nil)
                    }
                    else{
                        guard ORKPasscodeViewController.isPasscodeStoredInKeychain() && !(containerViewController?.presentedViewController is ORKPasscodeViewController) else { return }
                        window?.makeKeyAndVisible()
                        
                        let passcodeViewController = ORKPasscodeViewController.passcodeAuthenticationViewController(withText: "Enter Passcode to access app", delegate: self)
                        
                        
                        
                        var topVC = UIApplication.shared.keyWindow?.rootViewController
                        
                        
                        while topVC?.presentedViewController != nil {
                            topVC = topVC?.presentedViewController
                        }
                        
                        if (topVC?.presentedViewController?.isKind(of: ORKPasscodeViewController.self) == false && (topVC?.presentedViewController?.isKind(of: ORKTaskViewController.self))!) || ( topVC != nil && topVC?.isKind(of: ORKPasscodeViewController.self) == false) {
                             topVC!.present(passcodeViewController, animated: false, completion: nil)
                        }
                        
                       
                             //UIApplication.shared.keyWindow?.rootViewController?.present(passcodeViewController, animated: false, completion: nil)
                    
                        
                    
                       // viewController.present(passcodeViewController, animated: false, completion: nil)
                    }
                }
                else{
                    //Passcode is not set by user
                }
            }
            else{
                //Anonomous user
                
                // ORKPasscodeViewController.removePasscodeFromKeychain()
            }
            
        }
        
        func addAndRemoveProgress(add:Bool){
            
            let navigationController =  (self.window?.rootViewController as! UINavigationController)
            
            if navigationController.viewControllers.count > 0 {
                let studyListController = navigationController.viewControllers.first
                
                if add == true{
                    
                    studyListController?.addProgressIndicator()
                }
                else{
                    
                    studyListController?.removeProgressIndicator()
                }
            }
            
        }
        
        
        func popToStudyListViewController(){
            
            let navigationController =  (self.window?.rootViewController as! UINavigationController)
            
            var topController:UIViewController = navigationController
            if navigationController.viewControllers.count > 0 {
                topController = navigationController.viewControllers.first!
            }
            _ = topController.navigationController?.popViewController(animated: true)
        }
        
        
        func handleSignoutResponse(){
            
            
            if ORKPasscodeViewController.isPasscodeStoredInKeychain(){
                ORKPasscodeViewController.removePasscodeFromKeychain()
            }
            
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: kPasscodeIsPending)
            ud.synchronize()
            
            
            let navigationController =  (self.window?.rootViewController as! UINavigationController)
            
            if navigationController.viewControllers.count > 0 {
                let slideMenuController = navigationController.viewControllers.last as? FDASlideMenuViewController
                
                self.addAndRemoveProgress(add: false)
                
                if slideMenuController != nil{
                    
                    User.resetCurrentUser()
                    //DBHandler.deleteCurrentUser()
                    
                    let ud = UserDefaults.standard
                    ud.removeObject(forKey: kUserAuthToken)
                    ud.removeObject(forKey: kUserId)
                    ud.synchronize()
                    
                    
                    let leftController = slideMenuController?.leftViewController as! LeftMenuViewController
                    leftController.changeViewController(.studyList)
                    leftController.createLeftmenuItems()

                }
                
            }
            
            // FDASlideMenuViewController.fdaSlideMenuController().navigateToHomeAfterSingout()
            
            //let leftController = slideMenuController()?.leftViewController as! LeftMenuViewController
            // leftController.changeViewController(.studyList)
            //leftController.createLeftmenuItems()
            
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
            else if requestName as String == WCPMethods.eligibilityConsent.method.methodName {
                self.addAndRemoveProgress(add: false)
                self.createEligibilityConsentTask()
            }
                
            else if requestName as String == RegistrationMethods.logout.method.methodName {
                
                
                self.handleSignoutResponse()
                
                
            }
            else  if requestName as String == RegistrationMethods.updateEligibilityConsentStatus.method.methodName{
                
                self.addAndRemoveProgress(add: false)
            }
            
            
        }
        func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
            Logger.sharedInstance.info("requestname : \(requestName)")
            
            
            if requestName as String == RegistrationMethods.logout.method.methodName {
                self.addAndRemoveProgress(add: false)
                
            }
            
            
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
                
                if taskViewController.task?.identifier == kConsentTaskIdentifier{
                    ConsentBuilder.currentConsent?.consentResult?.consentDocument =   ConsentBuilder.currentConsent?.consentDocument
                    
                    ConsentBuilder.currentConsent?.consentResult?.initWithORKTaskResult(taskResult:taskViewController.result )
                    
                    //save consent to study
                    Study.currentStudy?.signedConsentVersion = ConsentBuilder.currentConsent?.version!
                    Study.currentStudy?.signedConsentFilePath = ConsentBuilder.currentConsent?.consentResult?.consentPath!
                    
                    // save also in DB
                    DBHandler.saveConsentInformation(study: Study.currentStudy!)
                    
                    DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails:nil)
                    
                    
                }
                else{

                taskResult = taskViewController.result
                let ud = UserDefaults.standard
                ud.set(false, forKey: kPasscodeIsPending)
                ud.synchronize()
                
                self.appIsResignedButDidNotEnteredBackground = false
                }
            case ORKTaskViewControllerFinishReason.failed:
                print("failed")
                taskResult = taskViewController.result
            case ORKTaskViewControllerFinishReason.discarded:
                
                if  taskViewController.task?.identifier == kConsentTaskIdentifier{
                    
                    self.popToStudyListViewController()
                }
                
                
                print("discarded")
                
                taskResult = taskViewController.result
            case ORKTaskViewControllerFinishReason.saved:
                print("saved")
                taskResult = taskViewController.restorationData
            }
            
            
            
            taskViewController.dismiss(animated: true, completion: nil)
            
            if taskViewController.task?.identifier == kConsentTaskIdentifier && reason == ORKTaskViewControllerFinishReason.completed{
                
                 ConsentBuilder.currentConsent?.consentStatus = .completed
                
                self.addAndRemoveProgress(add: true)
                
                UserServices().updateUserEligibilityConsentStatus(eligibilityStatus: true, consentStatus:(ConsentBuilder.currentConsent?.consentStatus)!  , delegate: self)
               
            }

            
            
            
            
        }
        
        
        func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
            
            
             if taskViewController.task?.identifier == kConsentTaskIdentifier{
            
            if (taskViewController.result.results?.count)! > 1{
                
                if activityBuilder?.actvityResult?.result?.count == taskViewController.result.results?.count{
                    //Removing the dummy result:Currentstep result which not presented yet
                    activityBuilder?.actvityResult?.result?.removeLast()
                }
                else{
                    
                }
            }
            
            //Handling show and hide of Back Button
            
            //For Verified Step , Completion Step, Visual Step, Review Step, Share Pdf Step
            
            if  stepViewController.step?.identifier == kConsentCompletionStepIdentifier || stepViewController.step?.identifier == "visual" || stepViewController.step?.identifier == "Review" || stepViewController.step?.identifier == kConsentSharePdfCompletionStep{
                
                
                if stepViewController.step?.identifier == kEligibilityVerifiedScreen{
                    stepViewController.continueButtonTitle = "Continue"
                }
                stepViewController.backButtonItem = nil
            }
                //checking if currentstep is View Pdf Step
            else if stepViewController.step?.identifier == kConsentViewPdfCompletionStep{
                
                //Back button is enabled
                stepViewController.backButtonItem?.isEnabled = true
                
                let orkStepResult:ORKStepResult? = taskViewController.result.results?[(taskViewController.result.results?.count)! - 2] as! ORKStepResult?
                
                let consentSignatureResult:ConsentCompletionTaskResult? = orkStepResult?.results?.first as? ConsentCompletionTaskResult
                
                //Checking if Signature is consented after Review Step
                
                if  consentSignatureResult?.didTapOnViewPdf == false{
                    //Directly moving to completion step by skipping Intermediate PDF viewer screen
                    stepViewController.goForward()
                }
                else{
                    
                }
            }
            else{
                //Back button is enabled
                stepViewController.backButtonItem?.isEnabled = true
                
            }
                
                
            }
        }
        
        
        //MARK:- StepViewController Delegate
        
        public func stepViewController(_ stepViewController: ORKStepViewController, didFinishWith direction: ORKStepViewControllerNavigationDirection){
            
        }
        
        public func stepViewControllerResultDidChange(_ stepViewController: ORKStepViewController){
            
        }
        
        public func stepViewControllerDidFail(_ stepViewController: ORKStepViewController, withError error: Error?){
            
        }
        
        func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
            
            
             if taskViewController.task?.identifier == kConsentTaskIdentifier{
            
            
            //CurrentStep is TokenStep
            
            if step.identifier == kEligibilityTokenStep {
                
                let gatewayStoryboard = UIStoryboard(name: kFetalKickCounterStep, bundle: nil)
                
                let ttController = gatewayStoryboard.instantiateViewController(withIdentifier: kEligibilityStepViewControllerIdentifier) as! EligibilityStepViewController
                ttController.descriptionText = step.text
                ttController.step = step
                
                return ttController
            }
            else if step.identifier == kConsentSharePdfCompletionStep {
                
                // let reviewStep:ORKStepResult? = taskViewController.result.results?[(taskViewController.result.results?.count)! - 1] as! ORKStepResult?
                
                var totalResults =  taskViewController.result.results
                let reviewStep:ORKStepResult?
                
                totalResults = totalResults?.filter({$0.identifier == "Review"})
                
                reviewStep = totalResults?.first as! ORKStepResult?
                
                if (reviewStep?.identifier)! == "Review" && (reviewStep?.results?.count)! > 0{
                    let consentSignatureResult:ORKConsentSignatureResult? = reviewStep?.results?.first as? ORKConsentSignatureResult
                    
                    if  consentSignatureResult?.consented == false{
                        taskViewController.dismiss(animated: true
                            , completion: nil)
                        
                        var topVC = UIApplication.shared.keyWindow?.rootViewController
                        while topVC?.presentedViewController != nil {
                            topVC = topVC?.presentedViewController
                        }

                        _ = topVC?.navigationController?.popViewController(animated: true)
                        return nil
                        
                    }
                    else{
                        
                        let documentCopy:ORKConsentDocument = (ConsentBuilder.currentConsent?.consentDocument)!.copy() as! ORKConsentDocument
                        
                        consentSignatureResult?.apply(to: documentCopy)
                        let gatewayStoryboard = UIStoryboard(name: kFetalKickCounterStep, bundle: nil)
                        let ttController = gatewayStoryboard.instantiateViewController(withIdentifier: kConsentSharePdfStoryboardId) as! ConsentSharePdfStepViewController
                        ttController.step = step
                        ttController.consentDocument =  documentCopy
                        return ttController
                    }
                }
                else {
                    return nil
                }
            }
            else if step.identifier == kConsentViewPdfCompletionStep {
                
                let reviewSharePdfStep:ORKStepResult? = taskViewController.result.results?.last as! ORKStepResult?
                
                let result = (reviewSharePdfStep?.results?.first as? ConsentCompletionTaskResult)
                
                if (result?.didTapOnViewPdf)!{
                    let gatewayStoryboard = UIStoryboard(name: kFetalKickCounterStep, bundle: nil)
                    
                    let ttController = gatewayStoryboard.instantiateViewController(withIdentifier: kConsentViewPdfStoryboardId) as! ConsentPdfViewerStepViewController
                    ttController.step = step
                    
                    ttController.pdfData = result?.pdfData
                    
                    return ttController
                }
                else{
                    //taskViewController.goForward()
                    return nil
                }
            }
            else {
                
                return nil
            }
                
            }
             else{
                // other than consent step mostly passcode step
                
                return nil
            }
        }

    }
    
    extension AppDelegate: ORKPasscodeDelegate {
        func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
            containerViewController?.contentHidden = false
            self.appIsResignedButDidNotEnteredBackground = false
            
            
            viewController.dismiss(animated: true, completion: nil)
        }
        
        func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
        }
        
        func passcodeViewControllerText(forForgotPasscode viewController: UIViewController) -> String {
            return "Forgot Passcode? Sign In Again"
        }
        
        func passcodeViewControllerForgotPasscodeTapped(_ viewController: UIViewController) {
            
            
                
            var topVC = UIApplication.shared.keyWindow?.rootViewController
            
            
            while topVC?.presentedViewController != nil {
                topVC = topVC?.presentedViewController
            }

            
                
                UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString("Passcode", comment: ""), errorMessage: NSLocalizedString("You will be signed out and will need to sign in again. Are you sure you want to proceed?", comment: ""), errorAlertActionTitle: NSLocalizedString("OK", comment: ""),
                                                                     errorAlertActionTitle2:NSLocalizedString("Cancel", comment: ""), viewControllerUsed: topVC!,
                                                                     action1: {
                                                                         viewController.dismiss(animated: true, completion: {
                                                                        
                                                                        self.sendRequestToSignOut()
                                                                        })
                },
                                                                     action2: {
                                                                        
                                                                       
                })

                
                
                
                
    
        }
        
    }
    
    
    
    
    @available(iOS 10, *)
    extension AppDelegate : UNUserNotificationCenterDelegate {
        
        //Receive displayed notifications for iOS 10 devices.
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            let userInfo = notification.request.content.userInfo
            print(userInfo)
            completionHandler([UNNotificationPresentationOptions.alert, .sound, .badge])
            
        }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
            let userInfo = response.notification.request.content.userInfo
            print(userInfo)
            
            if (UIApplication.shared.applicationState == UIApplicationState.active) {//|| (UIApplication.shared.applicationState == UIApplicationState.background){
                UIApplication.shared.applicationIconBadgeNumber = 0
                //self.handlePushNotificationResponse(userInfo : userInfo as NSDictionary)
            }
        }
    }

    
    
    
    
    
