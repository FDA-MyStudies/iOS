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
    import RealmSwift
    import CallKit
    
    let kEncryptionKey = "EncryptionKey"
    let kEncryptionIV =  "EncryptionIV"
    let kBlockerScreenLabelText = "Please update to the latest version of app to continue."
    let kConsentUpdatedTitle = "Consent Updated"
    
    let kMessageConsentUpdated = "The Consent Document for this study has been updated. Please review the revised Consent terms and provide your Informed Consent, to continue participating in the study."
    
    let kReviewTitle = "Review"
    
    let kPasscodeStepIdentifier = "PasscodeStep"
    let kPasscodeTaskIdentifier = "PassCodeTask"
    
    let kMessagePasscode = "Passcode"
    
    let kMessagePasscodeSignOut = "You will be signed out and will need to sign in again. Are you sure you want to proceed?"
    
    let kNewProgressViewNIB = "NewProgressView"
    let kforgotPasscodeTitle = "Forgot Passcode? Sign In Again"
    
    let kStudyStoryboard = "Study"
    
    let kPasscodeSetUpText = "Set up a passcode for the app"
    
    let kIphoneSimulator =  "iPhone Simulator"
    
    let kBundleIdentier = "CFBundleIdentifier"
    let kPDFCreationNotificationId = "pdfCreationNotificationIdentifier"
    let ksetUpTimeIdentifier = "setUPTime"
    let kCFBundleShortVersion = "CFBundleShortVersionString"
    
    let kResultCount = "resultCount"
    
    let kContinueButtonTitle =  NSLocalizedString("Continue", comment:"")
    let kType = "type"
    
    let kCurrentVersion = "currentVersion"
    let kForceUpdate = "forceUpdate"
    let kMessage = "message"
    let kVisualStepId = "visual"
    
 
    
    @UIApplicationMain
    
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
        var window: UIWindow?
        
        var notificationDetails:Dictionary<String,Any>? = Dictionary<String,Any>()
        
        var appIsResignedButDidNotEnteredBackground:Bool? = false
        
        var alertVCPresented:UIAlertController?
        
        var isPasscodePresented:Bool? =  false
        
        var isComprehensionFailed:Bool? = false
        
        var parentViewControllerForAlert:UIViewController?
        
        var iscomingFromForgotPasscode:Bool? =  false
        
        let healthStore = HKHealthStore()
        var containerViewController: ResearchContainerViewController? {
            return window?.rootViewController as? ResearchContainerViewController
        }
        
        var selectedController:UIViewController?
        
        var shouldAddForceUpgradeScreen = false
        
        var blockerScreen:AppUpdateBlocker?
        var passcodeParentControllerWhileSetup:UIViewController?
        
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
        
        func updateKeyAndInitializationVector(){
            
            
            let currentDate = "\(Date(timeIntervalSinceNow: 0))"
            
            let currentIndex = currentDate.index(currentDate.endIndex
                , offsetBy: -13)
            let subStringFromDate = currentDate.substring(to: currentIndex)
            
            
            let ud = UserDefaults.standard
            
            if User.currentUser.userType ==  .FDAUser{
                
                let index =  User.currentUser.userId.index(User.currentUser.userId.endIndex
                    , offsetBy: -16)
                
                let subKey = User.currentUser.userId.substring(to:index ) // 36 - 12 =  24 characters
                
                ud.set("\(subKey + subStringFromDate)", forKey: kEncryptionKey)
                
            }
            else{
                ud.set(currentDate + kDefaultPasscodeString, forKey: kEncryptionKey)
            }
            
            if UIDevice.current.model == kIsIphoneSimulator {
                // simulator
                
                ud.set(kdefaultIVForEncryption, forKey: kEncryptionIV)
            }
            else{
                // not a simulator
                
                
                var udid = UIDevice.current.identifierForVendor?.uuidString
                
                let index =  udid?.index((udid?.endIndex)!
                    , offsetBy: -20)
                
                udid = udid?.substring(to: index!)
                
                ud.set(udid, forKey: kEncryptionIV)
            }
            ud.synchronize()
        }
        
        
        func calculateTimeZoneChange(){
            
            let date = Date().utcDate()
            
            let timeZoneUTC = TimeZone(abbreviation: "UTC")
            let timeZoneAutoCurrent = TimeZone.autoupdatingCurrent
            let timeZoneCurrent = TimeZone.current
            
            print("auto \(timeZoneAutoCurrent.description)")
            print("current \(timeZoneCurrent.description)")
            
            let differenceFromUTC = timeZoneUTC?.secondsFromGMT()
            let differenceFromCurrent = timeZoneCurrent.secondsFromGMT()
            let differenceFromAutoCurrent = timeZoneCurrent.secondsFromGMT()
            
            print("utc \(differenceFromUTC) current \(differenceFromCurrent) autoCurrent\(differenceFromAutoCurrent)")
            
            let ud = UserDefaults.standard
            let setuptimeDiff = ud.value(forKey: ksetUpTimeIdentifier) as? Int
            if setuptimeDiff == nil {
                ud.set(differenceFromCurrent, forKey: ksetUpTimeIdentifier)
                ud.set(0, forKey: "offset")
            }
            else {
                
                let difference = differenceFromCurrent - setuptimeDiff!
                
                ud.set(difference, forKey: "offset")
                
                if difference == 0 {
                    
                    print("not changed")
                }
                else {
                    
                    
                    Schedule._formatter = nil
                    Schedule._formatter2 = nil
                    print("timezoneChange")
                    let date2 = date.addingTimeInterval(TimeInterval(difference))
                    print("currentUTC \(date.description)")
                    print("date \(date2.description)")
                }
                
            }
            
            ud.synchronize()
        }
        
        func checkForAppReopenNotification() {
            
            //remove if notificatin is available
            LocalNotification.removeReopenAppNotification()
            
            LocalNotification.registerReopenAppNotification()
            
        }
        //MARK: Realm Migragion
        func checkForRealmMigration(){
            
            // Inside your application(application:didFinishLaunchingWithOptions:)
            
            let config = Realm.Configuration(
                // Set the new schema version. This must be greater than the previously used
                // version (if you've never set a schema version before, the version is 0).
                schemaVersion: 1,
                
                // Set the block which will be called automatically when opening a Realm with
                // a schema version lower than the one set above
                migrationBlock: { migration, oldSchemaVersion in
                    // We haven’t migrated anything yet, so oldSchemaVersion == 0
                    if (oldSchemaVersion < 1) {
                        // Nothing to do!
                        // Realm will automatically detect new properties and removed properties
                        // And will update the schema on disk automatically
                    }
            })
            
            // Tell Realm to use this new configuration object for the default Realm
            Realm.Configuration.defaultConfiguration = config
            
            // Now that we've told Realm how to handle the schema change, opening the file
            // will automatically perform the migration
            let realm = try! Realm()
        }
        
        //MARK: App Delegates
        
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            
            
            
            self.customizeNavigationBar()
            Fabric.with([Crashlytics.self])
            
            UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self]).tintColor = kUIColorForSubmitButtonBackground
            
            
            
            
            self.checkForAppUpdateForVersion()
            
            
            
            if UIApplication.shared.applicationIconBadgeNumber > 0 {
                
                
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            
            
            SyncUpdate.currentSyncUpdate = SyncUpdate()
            
            NotificationCenter.default.addObserver(SyncUpdate.currentSyncUpdate as Any , selector: #selector(SyncUpdate.currentSyncUpdate?.updateData), name:ReachabilityChangedNotification, object: nil)
            
            
            let date = Date()
            print("date \(LineChartCell.shortDayFormatter.string(from: date))")
            
            
            //let ud1 = UserDefaults.standard
            
            if (launchOptions != nil) {
                
                
                //ud1.set("not null", forKey: "launch")
                //ud1.synchronize()
                print("launchOptions : \(launchOptions)")
                
                // Launched from push notification
                let notification = launchOptions?[.remoteNotification]
                
                if Utilities.isValidObject(someObject: notification as AnyObject){
                    
                    
                   // ud1.set("valid", forKey: "launch")
                    notificationDetails = notification as! Dictionary<String, Any>?
                    
                    let ud = UserDefaults.standard
                    ud.set(true, forKey: kShowNotification)
                    ud.synchronize()

                    
                }
                else{
                    
                   // ud1.set("invalid", forKey: "launch")
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: kShowNotification)
                    ud.synchronize()

                }
                
            }
            
            self.checkForRealmMigration()
            
            //LabKeyServices().getParticipantResponse(activityId: "Q1", participantId: "1a3d0d308df81024f8bfd7f11f7a0168", delegate: self)
            
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
            
           
            self.checkForStudyUpdates()
            
            let number = UIApplication.shared.applicationIconBadgeNumber
            if number >= 1 {
                self.updateNotification()
            }
            
            
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
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            if self.appIsResignedButDidNotEnteredBackground! {
                
                let navController = application.windows[0].rootViewController
                
                if (navController as? UINavigationController) != nil &&  (navController as? UINavigationController)?.visibleViewController?.isKind(of: ORKTaskViewController.self) == false {
                    
                    
                    if (navController as? UINavigationController)?.visibleViewController?.isKind(of: ORKPasscodeViewController.self) == false{
                        self.checkPasscode(viewController: navController!)
                    }
                    
                }
            }
            
            if AppDelegate.jailbroken(application: application) {
                
                let navigationController =  (self.window?.rootViewController as! UINavigationController)
                
                let appBlocker = JailbrokeBlocker.instanceFromNib(frame: navigationController.view.frame, detail: nil);
                
                UIApplication.shared.keyWindow?.addSubview(appBlocker);
                
                UIApplication.shared.keyWindow?.bringSubview(toFront: appBlocker)
                
            }
            
            self.calculateTimeZoneChange()
            
        }
        
        
        func applicationWillTerminate(_ application: UIApplication) {
            // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        }
        
        //MARK:- NOTIFICATION
        
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            
            let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
            print(deviceTokenString)
            //UserDetails.deviceToken = deviceTokenString
            
            if  User.currentUser.userType == .FDAUser{
            
            User.currentUser.settings?.remoteNotifications = true
            User.currentUser.settings?.localNotifications = true
            UserServices().updateUserProfile(deviceToken: deviceTokenString , delegate: self)
            
            
            print("APNs token retrieved: \(deviceToken)")
            }
            
        }
        func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            
            print("Token Registration failed in simulator \(error)")
            
        }
        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
            print("REMOTE NOTIFICATION:" + "\(userInfo)")
            
            //For iOS 8 & 9
            if (UIApplication.shared.applicationState == UIApplicationState.background)||(UIApplication.shared.applicationState == UIApplicationState.inactive){
                
            }
            
            if userInfo.count > 0 && userInfo.keys.contains(kType){
                self.updateNotification()
            }
            
        }
        
        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            
           
            print("REMOTE NOTIFICATION:" + "\(userInfo)")
            
            
            if( UIApplication.shared.applicationState == UIApplicationState.inactive )
            {
                
                completionHandler( .newData );
            }
            else if( UIApplication.shared.applicationState == UIApplicationState.background )
            {
                
                completionHandler( .newData );
            }  
            else  
            {  
               
                completionHandler( .newData );
            }
            
            
            if (UIApplication.shared.applicationState == UIApplicationState.active || (UIApplication.shared.applicationState == UIApplicationState.inactive)) {//|| (UIApplication.shared.applicationState == UIApplicationState.background){
                UIApplication.shared.applicationIconBadgeNumber = 0
                
                self.handleLocalAndRemoteNotification(userInfoDetails: userInfo as! Dictionary<String, Any>)
                
                //self.handlePushNotificationResponse(userInfo : userInfo as NSDictionary)
            }
            
            if userInfo.count > 0 && userInfo.keys.contains(kType){
                self.updateNotification()
            }

            
        }
        
        func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
            print("Notificatio received\(notification.userInfo)")
        }
        
        //MARK: Jailbreak Methods
        
        public static func jailbroken(application: UIApplication) -> Bool {
            guard let cydiaUrlScheme = NSURL(string: "cydia://package/com.example.package") else { return isJailbroken() }
            return application.canOpenURL(cydiaUrlScheme as URL) || isJailbroken()
        }
        
        
        static func isJailbroken() -> Bool {
            
            if UIDevice.current.model != kIphoneSimulator {
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
        
        
        //MARK: Add Retry Screen
        
        func addRetryScreen(viewController:UIViewController?)  {
            
            let navigationController =  (self.window?.rootViewController as! UINavigationController)
            
            let retryView = ComprehensionFailure.instanceFromNib(frame: navigationController.view.frame, detail: nil);
            
            if viewController != nil{
                retryView.delegate = viewController as! ComprehensionFailureDelegate
            }
            else{
                retryView.delegate = self as! ComprehensionFailureDelegate
            }
            UIApplication.shared.keyWindow?.addSubview(retryView);
            
            UIApplication.shared.keyWindow?.bringSubview(toFront: retryView)
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
        
        
        /*
         To get the current App version from App Store and Adds the blocker screen if it is of lower version
        */
        
        func checkForAppUpdateForVersion(){
            
            let infoDict = Bundle.main.infoDictionary
            
            let appId = infoDict?[kBundleIdentier]
            
            let url:URL = URL.init(string:"http://itunes.apple.com/lookup?bundleId=\(appId!)" )!
            
            let request =   URLRequest(url:url)
            
            
            let session = URLSession.shared
            session.dataTask(with: request) {(data, response, error) -> Void in
                if data != nil {
                    DispatchQueue.main.async {
                        //self.handleResponse(data, response: response, requestName: requestName, error: error as NSError?)
                        do {
                            
                            let data = try Data.init(contentsOf: url)
                            let parsedDict = try JSONSerialization.jsonObject(with: data, options:[])
                            
                            if ((parsedDict as! [String:Any])[kResultCount] as! Int) == 1{
                                
                                let resultArray = ((parsedDict as! [String:Any])["results"]) as! Array<Dictionary<String,Any>>
                                
                                let appStoreVersion = (resultArray.first)?["version"]  as! String
                                
                                let currentVersion = infoDict?[kCFBundleShortVersion]
                                
                                if appStoreVersion != (currentVersion as! String) {
                                    
                                    self.shouldAddForceUpgradeScreen = true
                                    
                                    self.blockerScreen = AppUpdateBlocker.instanceFromNib(frame:(UIApplication.shared.keyWindow?.bounds)!, detail: parsedDict as! Dictionary<String, Any>);
                                    
                                    self.blockerScreen?.labelVersionNumber.text = "V-" + appStoreVersion
                                    self.blockerScreen?.labelMessage.text = kBlockerScreenLabelText
                                    
                                    
                                    if User.currentUser.userType == .FDAUser {
                                        //FDA user
                                        
                                        if User.currentUser.settings?.passcode! == false {
                                            UIApplication.shared.keyWindow?.addSubview(self.blockerScreen!)
                                        }
                                    }
                                    else {
                                        UIApplication.shared.keyWindow?.addSubview(self.blockerScreen!)
                                    }
                                }
                                else {
                                    
                                }
                            }
                        }
                        catch{
                            
                        }
                        
                    }
                    
                }
                else {
                    DispatchQueue.main.async {
                        //self.delegate?.failedRequest(self.networkManager!, requestName: requestName!,error: error! as NSError)
                    }
                }
                }.resume()
            
            
            //            let task2 =  URLSession.shared.dataTask(with: request) {
            //                (data, response, error) -> Void in
            //                if let data = data {
            //
            //                }
            //                else {
            //                    DispatchQueue.main.async {
            //                    }
            //                }
            //                }.resume()
        }
        
        
        func sendRequestToSignOut() {
            
          // self.window?.addProgressIndicatorOnWindowFromTop()
            
            UserServices().logoutUser(self as NMWebServiceDelegate)
            
        }
        
        /*
          check the  current Consent Status
        */
        
        func checkConsentStatus(controller:UIViewController) {
            
            self.selectedController = controller
            
            if(StudyUpdates.studyConsentUpdated){
                print("Study consent is updated: Please Present Consent UI")
                
                
                
                let navigationController =  (self.window?.rootViewController as! UINavigationController)
                
                var topController:UIViewController = navigationController
                if navigationController.viewControllers.count > 0 {
                    topController = navigationController.viewControllers.first!
                }
                
                
                UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString(kConsentUpdatedTitle, comment: ""), errorMessage: NSLocalizedString(kMessageConsentUpdated, comment: ""), errorAlertActionTitle: NSLocalizedString(kReviewTitle, comment: ""),
                                                                     errorAlertActionTitle2:nil, viewControllerUsed: topController,
                                                                     action1: {
                                                                        
                                                                        self.addAndRemoveProgress(add: true)
                                                                        
                                                                        
                                                                        WCPServices().getEligibilityConsentMetadata(studyId:(Study.currentStudy?.studyId)!, delegate: self as NMWebServiceDelegate)
                                                                        
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
            
            self.addAndRemoveProgress(add: false)
            
            topVC?.present(taskViewController!, animated: true, completion: nil)
        }
        
        func handleLocalAndRemoteNotification(userInfoDetails:Dictionary<String,Any>){
            /*
             let filePath  = Bundle.main.path(forResource: "Labkey_Activity", ofType: "json")
             
             let userInfo:Dictionary<String,Any>?
             
             let data = NSData(contentsOfFile: filePath!)
             do {
             userInfo = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
             
             }
             catch let error as NSError{
             print("\(error)")
             }
             
             */
            
            var notificationType:String? = ""
            var notificationSubType:AppNotification.NotificationSubType? = .Announcement
            
            
            if (userInfoDetails.count) > 0 {
                
                
                if Utilities.isValidValue(someObject: userInfoDetails[kNotificationType] as AnyObject){
                    notificationType =  userInfoDetails[kNotificationType] as? String
                }
                if Utilities.isValidValue(someObject: userInfoDetails[kNotificationSubType] as AnyObject){
                    notificationSubType = AppNotification.NotificationSubType(rawValue:userInfoDetails[kNotificationSubType] as! String)
                }
                
                if notificationType == AppNotification.NotificationType.Study.rawValue{
                    
                    var studyId:String? = ""
                    
                    if Utilities.isValidValue(someObject: userInfoDetails[kStudyId] as AnyObject){
                        studyId = userInfoDetails[kStudyId] as? String
                    }
                    
                    
                    if studyId != nil || studyId != ""{
                        
                        var initialVC:UIViewController?
                        
                        
                        let navigationController =  (self.window?.rootViewController as! UINavigationController)
                        let menuVC = navigationController.viewControllers.last
                        if  menuVC is FDASlideMenuViewController {
                            let mainController =  (menuVC as! FDASlideMenuViewController).mainViewController
                            if mainController is UINavigationController {
                                let nav = (mainController as! UINavigationController)
                                initialVC = nav.viewControllers.last
                                
                                
                                
                                //                                if tabbarVC is StudyDashboardTabbarViewController{
                                //                                    let studyTabBar = tabbarVC as! StudyDashboardTabbarViewController
                                //                                    selectedController = ((studyTabBar.viewControllers?[studyTabBar.selectedIndex]) as! UINavigationController).viewControllers.last
                                //
                                //                                }
                                
                                
                            }
                            
                        }
                        
                        if Gateway.instance.studies!.contains(where: { $0.studyId == studyId }){
                            
                            let index =  Gateway.instance.studies?.index(where: { $0.studyId == studyId })
                            
                            //check status for study
                            if NotificationViewController.checkForStudyStateAndParticiapantState(study: (Gateway.instance.studies?[index!])!) {
                                Study.updateCurrentStudy(study:(Gateway.instance.studies?[index!])! )
                                
                                
                                
                                switch notificationSubType! as AppNotification.NotificationSubType {
                                case .Activity, .Resource:
                                    
                                    var activityId:String? = ""
                                    
                                    if Utilities.isValidValue(someObject: userInfoDetails[kActivityId] as AnyObject){
                                        activityId = userInfoDetails[kActivityId] as? String
                                    }
                                    
                                    var resourceId:String? = ""
                                    if Utilities.isValidValue(someObject: userInfoDetails[kResourceId] as AnyObject){
                                        resourceId = userInfoDetails[kResourceId] as? String
                                    }
                                    
                                    
                                    
                                    if !(initialVC is UITabBarController){
                                        //push tabbar and switch to activty tab
                                        
                                        print("push tabbar and switch to activty tab")
                                        
                                        
                                        self.pushToTabbar(viewController: initialVC!, selectedTab: (notificationSubType! as AppNotification.NotificationSubType == .Activity) ? 0 : 2)
                                        
                                    }
                                    else {
                                        //switch to activty tab
                                        
                                        (initialVC as! UITabBarController).selectedIndex =  (notificationSubType! as AppNotification.NotificationSubType == .Activity) ? 0 : 2
                                        
                                        print("switch to activty tab")
                                    }
                                    
                                    //                       if !(initialVC is ActivitiesViewController){
                                    //
                                    //                            if initialVC is StudyListViewController {
                                    //
                                    //                            }
                                    //                            else if initialVC is ResourcesViewController{
                                    //
                                    //                            }
                                    //                            else if initialVC is ReachoutOptionsViewController{
                                    //
                                    //                            }
                                    //                            else if initialVC is ProfileViewController{
                                    //
                                    //                            }
                                    
                                    //                       }
                                    
                                    
                                    
                                case .Study:
                                    
                                    
                                    let leftController = (menuVC as! FDASlideMenuViewController).leftViewController as! LeftMenuViewController
                                    
                                    if !(initialVC is StudyListViewController){
                                        
                                        
                                        if initialVC is ProfileViewController  ||  initialVC is ReachoutOptionsViewController || initialVC is GatewayResourcesListViewController{
                                            leftController.changeViewController(.studyList)
                                            leftController.createLeftmenuItems()
                                        }
                                            
                                        else if initialVC is UITabBarController {
                                            
                                            initialVC?.performSegue(withIdentifier: kActivityUnwindToStudyListIdentifier, sender: initialVC)
                                            
                                        }
                                        
                                    }
                                    else {
                                        
                                        leftController.changeViewController(.studyList)
                                        leftController.createLeftmenuItems()
                                    }
                                    
                                case .Announcement:break
                                    
                                default:break
                                    
                                }
                                
                                
                                
                                
                            }
                            else{
                                //study is not joined
                            }
                        }
                        else{
                            //Study is not in the list
                        }
                        
                        
                    }
                    else{
                        //studyId is Null
                    }
                }
                else if notificationType == AppNotification.NotificationType.Gateway.rawValue{
                    
                    if notificationSubType == AppNotification.NotificationSubType.Announcement{
                        
                    }
                    else{
                        
                    }
                    
                }
                
            }
            
            
            self.notificationDetails = nil
            
        }
        
        
        func pushToTabbar(viewController:UIViewController,selectedTab:Int){
            
            let studyStoryBoard = UIStoryboard.init(name: kStudyStoryboard, bundle: Bundle.main)
            
            
            let studyDashboard = studyStoryBoard.instantiateViewController(withIdentifier: kStudyDashboardTabbarControllerIdentifier) as! StudyDashboardTabbarViewController
            
            studyDashboard.selectedIndex = selectedTab
            
            
            viewController.navigationController?.navigationBar.isHidden = true
            viewController.navigationController?.pushViewController(studyDashboard, animated: true)
        }
        
        
        
        func checkPasscode(viewController:UIViewController) {
            
            
            
            if User.currentUser.userType == .FDAUser {
                //FDA user
                
                
                if User.currentUser.settings?.passcode! == true {
                    
                    if  ORKPasscodeViewController.isPasscodeStoredInKeychain() == false{
                        
                        let passcodeStep = ORKPasscodeStep(identifier: kPasscodeStepIdentifier)
                        passcodeStep.passcodeType = .type4Digit
                        
                        //passcodeStep.text = kPasscodeSetUpText
                        let task = ORKOrderedTask(identifier: kPasscodeTaskIdentifier, steps: [passcodeStep])
                        
                        
                        let taskViewController = ORKTaskViewController.init(task: task, taskRun: nil)
                        
                        if viewController.isKind(of: UINavigationController.self){
                            taskViewController.delegate = self
                        }
                        else{
                            taskViewController.delegate = viewController as? ORKTaskViewControllerDelegate
                        }
                        taskViewController.isNavigationBarHidden = true
                        
                        passcodeParentControllerWhileSetup = viewController
                        
                        isPasscodePresented = true
                        blockerScreen?.isHidden = true
                        viewController.present(taskViewController, animated: false, completion: nil)
                    }
                    else{
                        guard ORKPasscodeViewController.isPasscodeStoredInKeychain() && !(containerViewController?.presentedViewController is ORKPasscodeViewController) else { return }
                        window?.makeKeyAndVisible()
                        
                        let passcodeViewController = ORKPasscodeViewController.passcodeAuthenticationViewController(withText: "", delegate: self)
                        
                        
                        
                        var topVC = UIApplication.shared.keyWindow?.rootViewController
                        
                        var parentController:UIViewController?
                        
                        while topVC?.presentedViewController != nil {
                            
                            parentController = topVC
                            
                            topVC = topVC?.presentedViewController
                        }
                        
                        
                        if topVC is UIAlertController{
                            
                            alertVCPresented = topVC as! UIAlertController?
                            
                            if (parentController is ORKPasscodeViewController) == false{
                                 topVC?.dismiss(animated: true, completion: nil)
                            }
                            
                           
                            topVC = parentController
                            
                            parentViewControllerForAlert = topVC
                        }
                        
                        passcodeParentControllerWhileSetup = nil
                        
                        
                        
                        if (topVC?.presentedViewController?.isKind(of: ORKPasscodeViewController.self) == false && (topVC?.presentedViewController?.isKind(of: ORKTaskViewController.self))!) || ( topVC != nil && topVC?.isKind(of: ORKPasscodeViewController.self) == false) {
                            isPasscodePresented = true
                            
                            blockerScreen?.isHidden = true
                            
                            //passcodeViewController.view.bringSubview(toFront: keyboard)
                            
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
            
            if add{
                self.window?.addProgressIndicatorOnWindow()
            }
            else {
                self.window?.removeProgressIndicatorFromWindow()
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
        
        func checkForStudyUpdates(){
            
            if Study.currentStudy != nil && Study.currentStudy?.userParticipateState.status == UserStudyStatus.StudyStatus.inProgress{
                
                let userStudyStatus =  (Study.currentStudy?.userParticipateState.status)!
                
                if userStudyStatus == .inProgress || userStudyStatus == .yetToJoin
                {
                    WCPServices().getStudyUpdates(study: Study.currentStudy!, delegate: self)
                }
                
                
            }
        }
        
        
        func handleSignoutResponse(){
            
            
            if ORKPasscodeViewController.isPasscodeStoredInKeychain(){
                ORKPasscodeViewController.removePasscodeFromKeychain()
            }
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: kPasscodeIsPending)
            ud.set(false, forKey: kShowNotification)
            ud.synchronize()
            
            self.updateKeyAndInitializationVector()
            
            
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
                    //following to be removed it has to be moved to studylist
                     slideMenuController?.fdaSlideMenuController()?.navigateToHomeAfterSingout()
                    
                    //let leftController = slideMenuController?.leftViewController as! LeftMenuViewController
                    //leftController.changeViewController(.studyList)
                    //leftController.createLeftmenuItems()
                    
                }
                
            }
            
            
        }
        
        
        
        func handleSignoutAfterLogoutResponse(){
            
            if ORKPasscodeViewController.isPasscodeStoredInKeychain(){
                ORKPasscodeViewController.removePasscodeFromKeychain()
            }
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: kPasscodeIsPending)
            ud.set(false, forKey: kShowNotification)
            ud.synchronize()
            
            let navigationController =  (self.window?.rootViewController as! UINavigationController)
            
            if navigationController.viewControllers.count > 0 {
                let slideMenuController = navigationController.viewControllers.last as? FDASlideMenuViewController
                
                self.addAndRemoveProgress(add: false)
                if slideMenuController != nil{
                    User.resetCurrentUser()
                    let ud = UserDefaults.standard
                    ud.removeObject(forKey: kUserAuthToken)
                    ud.removeObject(forKey: kUserId)
                    ud.synchronize()
                    
                    let leftController = slideMenuController?.leftViewController as! LeftMenuViewController
                    leftController.changeViewController(.reachOut_signIn)
                    leftController.createLeftmenuItems()

                    
                }
                
            }
        }
        
        
        
        func updateNotification(){
            
            let ud = UserDefaults.standard
            ud.set(true, forKey: kShowNotification)
            ud.synchronize()
            
            var nav:UINavigationController?
            let navigationController =  (self.window?.rootViewController as! UINavigationController)
            let menuVC = navigationController.viewControllers.last
            if  menuVC is FDASlideMenuViewController {
                let mainController =  (menuVC as! FDASlideMenuViewController).mainViewController
                if mainController is UINavigationController {
                    nav = (mainController as! UINavigationController)
                    let studyListVC = nav?.viewControllers.last
                    if studyListVC is StudyListViewController{
                        (studyListVC as! StudyListViewController).addRightNavigationItem()
                        
                    }
                }
            }
        }
        
        
        func handleStudyUpdatedInformation(){
            
            if Study.currentStudy != nil {
                
                Study.currentStudy?.newVersion = StudyUpdates.studyVersion
                if Study.currentStudy?.version == Study.currentStudy?.newVersion{
                    return
                }
                else {
                    
                    DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
                    
                    
                    var nav:UINavigationController?
                    let navigationController =  (self.window?.rootViewController as! UINavigationController)
                    let menuVC = navigationController.viewControllers.last
                    if  menuVC is FDASlideMenuViewController {
                        let mainController =  (menuVC as! FDASlideMenuViewController).mainViewController
                        if mainController is UINavigationController {
                            nav = (mainController as! UINavigationController)
                            let tabbarVC = nav?.viewControllers.last
                            if tabbarVC is StudyDashboardTabbarViewController{
                                let studyTabBar = tabbarVC as! StudyDashboardTabbarViewController
                                selectedController = ((studyTabBar.viewControllers?[studyTabBar.selectedIndex]) as! UINavigationController).viewControllers.last
                                
                            }
                            
                            
                        }
                        
                    }
                    
                    let studyStatus = StudyStatus(rawValue:StudyUpdates.studyStatus!)!
                    
                    if studyStatus != .Active {
                        _ = nav?.popToRootViewController(animated: true)
                        var message = ""
                        switch studyStatus {
                            
                        case .Upcoming:
                            message = NSLocalizedString(kMessageForStudyUpcomingState, comment: "")
                            
                        case .Paused:
                            message = NSLocalizedString(kMessageForStudyPausedState, comment: "")
                        
                        case .Closed:
                            message = NSLocalizedString(kMessageForStudyClosedState, comment: "")
                        
                        default: break
                            
                        }
                        
                        let alert = UIAlertController(title:"" as String,message:message as String,preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title:NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                        //                    var rootViewController = UIApplication.shared.keyWindow?.rootViewController
                        //                    if let navigationController = rootViewController as? UINavigationController {
                        //                        rootViewController = navigationController.viewControllers.first
                        //                    }
                        //                    if let tabBarController = rootViewController as? UITabBarController {
                        //                        rootViewController = tabBarController.selectedViewController
                        //                    }
                        
                        //let vc =  nav?.viewControllers.first
                        //nav?.present(alert, animated: true, completion: nil)
                        
                    }
                    else {
                        
                        if selectedController != nil {
                            
                            if !self.isPasscodePresented! {
                                self.checkConsentStatus(controller: self.selectedController!)
                            }
                            
                            
                            if self.selectedController is ActivitiesViewController {
                                (self.selectedController as! ActivitiesViewController).checkForActivitiesUpdates()
                            }
                            else if self.selectedController is ResourcesViewController {
                                (self.selectedController as! ResourcesViewController).checkForResourceUpdate()
                            }
                            
                        }
                    }
                }
            }
            
            
            
        }
        
        
        func updateEligibilityConsentStatus(){
            
            let notificationName = Notification.Name(kPDFCreationNotificationId)
            // Post notification
          
            // Stop listening notification
            NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
            
             UserServices().updateUserEligibilityConsentStatus(eligibilityStatus: true, consentStatus:(ConsentBuilder.currentConsent?.consentStatus)!  , delegate: self)
        }
        
        func popViewControllerAfterConsentDisagree(){
            //self.popToStudyListViewController()
            if self.selectedController is StudyDashboardViewController {
                (self.selectedController as! StudyDashboardViewController).homeButtonAction(UIButton())
            }
            else if self.selectedController is ActivitiesViewController {
                (self.selectedController as! ActivitiesViewController).homeButtonAction(UIButton())
            }
            else if self.selectedController is ResourcesViewController {
                (self.selectedController as! ResourcesViewController).homeButtonAction(UIButton())
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
    
    //MARK: Webservices delegates
    
    extension AppDelegate:NMWebServiceDelegate {
        func startedRequest(_ manager: NetworkManager, requestName: NSString) {
            Logger.sharedInstance.info("requestname : \(requestName)")
            //self.addProgressIndicator()
            
        }
        func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
            Logger.sharedInstance.info("requestname : \(requestName) Response : \(response)")
            
            if requestName as String == WCPMethods.appUpdates.method.methodName {
                
                let appVersion = Utilities.getAppVersion()
                if appVersion != response?[kCurrentVersion] as! String {
                    
                    if response?[kForceUpdate] as! Bool {
                        
                        self.shouldAddForceUpgradeScreen = true
                        
                        let version = response?[kCurrentVersion] as! String
                        
                        blockerScreen = AppUpdateBlocker.instanceFromNib(frame:(UIApplication.shared.keyWindow?.bounds)!, detail: response as! Dictionary<String, Any>);
                        
                        blockerScreen?.labelVersionNumber.text = "V-" + version
                        blockerScreen?.labelMessage.text = response?[kMessage] as? String
                        
                        
                        if User.currentUser.userType == .FDAUser {
                            //FDA user
                            
                            if User.currentUser.settings?.passcode! == false {
                                UIApplication.shared.keyWindow?.addSubview(blockerScreen!)
                            }
                        }
                        else {
                            UIApplication.shared.keyWindow?.addSubview(blockerScreen!)
                        }
                        
                       
                        
                        
                    }
                    else {
                        UIUtilities.showAlertWithMessage(alertMessage: response?[kMessage] as! String);
                    }
                    
                    
                }
                
                
            }
            else if requestName as String == WCPMethods.eligibilityConsent.method.methodName {
                
                self.createEligibilityConsentTask()
            }
                
            else if requestName as String == RegistrationMethods.logout.method.methodName {
                
                
                if iscomingFromForgotPasscode! {
                    self.handleSignoutAfterLogoutResponse()
                }
                else{
                    self.handleSignoutResponse()
                }
                
                
                
            }
            else  if requestName as String == RegistrationMethods.updateEligibilityConsentStatus.method.methodName{
                
                self.addAndRemoveProgress(add: false)
            }
            else if (requestName as String == WCPMethods.studyUpdates.rawValue){
                //self.removeProgressIndicator()
                self.handleStudyUpdatedInformation()
            }
            else if (requestName as String == RegistrationMethods.updateUserProfile.description){
                
                let ud = UserDefaults.standard
                ud.set(false, forKey: kNotificationRegistrationIsPending)
                ud.synchronize()
            }
            
            
        }
        func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
            Logger.sharedInstance.info("requestname : \(requestName)")
            
            self.addAndRemoveProgress(add: false)
            if requestName as String == RegistrationMethods.logout.method.methodName {
                self.addAndRemoveProgress(add: false)
                
            }
            else if requestName as String == WCPMethods.eligibilityConsent.method.methodName{
                self.popViewControllerAfterConsentDisagree()
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
                    
                    
                    //update consent is updaeted in db
                    Study.currentStudy?.version = StudyUpdates.studyVersion
                    Study.currentStudy?.newVersion = StudyUpdates.studyVersion
                    StudyUpdates.studyConsentUpdated  = false
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
                    
                    self.popViewControllerAfterConsentDisagree()
                }
                
                
                print("discarded")
                
                taskResult = taskViewController.result
            case ORKTaskViewControllerFinishReason.saved:
                print("saved")
                taskResult = taskViewController.restorationData
                
                if  taskViewController.task?.identifier == kConsentTaskIdentifier{
                    
                    self.popViewControllerAfterConsentDisagree()
                }
            }
            
            if passcodeParentControllerWhileSetup != nil {
                passcodeParentControllerWhileSetup?.dismiss(animated: true, completion:nil)
                
                passcodeParentControllerWhileSetup = nil
            }
            else{
                taskViewController.dismiss(animated: true, completion: nil)
            }
            
            
            if taskViewController.task?.identifier == kConsentTaskIdentifier && reason == ORKTaskViewControllerFinishReason.completed{
                
                ConsentBuilder.currentConsent?.consentStatus = .completed
                
                self.addAndRemoveProgress(add: true)
                
                
                if ConsentBuilder.currentConsent?.consentResult?.consentPdfData?.count == 0 {
                    
                    // Define identifier
                    let notificationName = Notification.Name(kPDFCreationNotificationId)
                    
                    // Register to receive notification
                    NotificationCenter.default.addObserver(self, selector: #selector(self.updateEligibilityConsentStatus), name: notificationName, object: nil)
                    
                    
                    self.perform(#selector(self.updateEligibilityConsentStatus), with: self, afterDelay: 2.0)
                }
                else{
                     UserServices().updateUserEligibilityConsentStatus(eligibilityStatus: true, consentStatus:(ConsentBuilder.currentConsent?.consentStatus)!  , delegate: self)
                }
                
                
               
                
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
                
                
                
                
                
                if  stepViewController.step?.identifier == kConsentCompletionStepIdentifier || stepViewController.step?.identifier == kVisualStepId  || stepViewController.step?.identifier == kConsentSharePdfCompletionStep || stepViewController.step?.identifier == kEligibilityVerifiedScreen{
                    
                    
                    if stepViewController.step?.identifier == kEligibilityVerifiedScreen{
                        stepViewController.continueButtonTitle = kContinueButtonTitle
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
                    
                    totalResults = totalResults?.filter({$0.identifier == kReviewTitle})
                    
                    reviewStep = totalResults?.first as! ORKStepResult?
                    
                    if (reviewStep?.identifier)! == kReviewTitle && (reviewStep?.results?.count)! > 0{
                        let consentSignatureResult:ORKConsentSignatureResult? = reviewStep?.results?.first as? ORKConsentSignatureResult
                        
                        if  consentSignatureResult?.consented == false{
                            taskViewController.dismiss(animated: true
                                , completion: nil)
                            
                            self.popViewControllerAfterConsentDisagree()
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
                else if step.identifier == kReviewTitle{
                    
                    
                    // comprehension test is available
                    if (ConsentBuilder.currentConsent?.comprehension?.questions?.count)! > 0 {
                        
                        
                        let visualStepIndex:Int = (taskViewController.result.results?.index(where: {$0.identifier == kVisualStepId}))!
                        
                        if visualStepIndex >= 0 {
                            
                            var  i = visualStepIndex + 1 // holds the index of  question
                            var j = 0 // holds the index of correct answer
                            
                            var userScore = 0
                            
                            while  i < (taskViewController.result.results?.count)! {
                                
                                
                                let textChoiceResult:ORKChoiceQuestionResult = ((taskViewController.result.results?[i] as! ORKStepResult).results?.first) as! ORKChoiceQuestionResult
                                
                                
                                
                                let correctAnswerDict:Dictionary<String,Any>? = ConsentBuilder.currentConsent?.comprehension?.correctAnswers?[j]
                                
                                let answerArray:[String] = (correctAnswerDict?[kConsentComprehensionAnswer] as? [String])!
                                
                                let evaluationType:Evaluation? = Evaluation(rawValue: correctAnswerDict?[kConsentComprehensionEvaluation] as! String)
                                
                                let answeredSet = Set(textChoiceResult.choiceAnswers! as! [String])
                                
                                let correctAnswerSet = Set(answerArray)
                                
                                switch evaluationType! {
                                case .any:
                                    
                                    
                                    if answeredSet.isSubset(of: correctAnswerSet){
                                        userScore = userScore + 100
                                    }
                                    else if (answeredSet.intersection(correctAnswerSet)).isEmpty == false{
                                        userScore = userScore + 100
                                    }
                                    
                                case .all:
                                    
                                    if answeredSet == correctAnswerSet{
                                        userScore = userScore + 100
                                    }
                                    
                                    
                                default: break
                                    
                                }
                                
                                j+=1
                                i+=1
                            }
                            
                            if userScore >= (ConsentBuilder.currentConsent?.comprehension?.passScore)! {
                                return nil
                            }
                            else{
                                
                                
                                self.isComprehensionFailed = true
                                self.addRetryScreen(viewController: nil)
                                
                                taskViewController.dismiss(animated: true
                                    , completion: nil)
                            }
                            
                        }
                        else{
                            // if by chance we didnt get visualStepIndex i.e there no visual step
                            // logically should never occur
                        }
                        
                        return nil
                    }
                    else{
                        // comprehension test is not available
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
    
    //MARK: Passcode Delegate
    extension AppDelegate: ORKPasscodeDelegate {
        func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
            containerViewController?.contentHidden = false
            self.appIsResignedButDidNotEnteredBackground = false
            
            
            
            
            viewController.dismiss(animated: true, completion: {
                self.isPasscodePresented = false
                
                if self.shouldAddForceUpgradeScreen {
                    
                    if self.blockerScreen?.isHidden == true {
                        self.blockerScreen?.isHidden = false
                    }
                    else {
                        UIApplication.shared.keyWindow?.addSubview(self.blockerScreen!)
                    }
                    
                    
                }
                
                if self.selectedController != nil {
                    self.checkConsentStatus(controller: self.selectedController!)
                }
                
            })
            
            if alertVCPresented != nil {
                
                //let controller = alertVCPresented
                parentViewControllerForAlert?.present(alertVCPresented!, animated: true, completion: {
                    self.alertVCPresented = nil
                })
            }
            
            
        }
        
        func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
            
            
            
        }
        
        func passcodeViewControllerText(forForgotPasscode viewController: UIViewController) -> String {
            return kforgotPasscodeTitle
        }
        
        func passcodeViewControllerForgotPasscodeTapped(_ viewController: UIViewController) {
            
            
            
            var topVC = UIApplication.shared.keyWindow?.rootViewController
            
           
            
            while topVC?.presentedViewController != nil {
                
                topVC = topVC?.presentedViewController
            }
            
            
            
            UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString(kMessagePasscode, comment: ""), errorMessage: NSLocalizedString(kMessagePasscodeSignOut, comment: ""), errorAlertActionTitle: NSLocalizedString(kTitleOK, comment: ""),
                                                                 errorAlertActionTitle2:NSLocalizedString(kTitleCancel, comment: ""), viewControllerUsed: topVC!,
                                                                 action1: {
                                                                    
                                                                     self.window?.addProgressIndicatorOnWindowFromTop()
                                                                    
                                                                    viewController.dismiss(animated: true, completion: {
                                                                        
                                                                        var topVC = UIApplication.shared.keyWindow?.rootViewController
                                                                        while topVC?.presentedViewController != nil {
                                                                            
                                                                            topVC = topVC?.presentedViewController
                                                                        }
                                                                        
                                                                        if topVC is ORKTaskViewController{
                                                                             topVC?.dismiss(animated: true, completion: nil)
                                                                        }
                                                                        
                                                                       self.iscomingFromForgotPasscode = true
                                                                        
                                                                        self.sendRequestToSignOut()
                                                                    })
            },
                                                                 action2: {
                                                                    
                                                                    
            })
            
            
            
            
            
            
        }
        
    }
    
    //MARK:ComprehensionFailureDelegate
    
    extension AppDelegate:ComprehensionFailureDelegate{
        func didTapOnCancel() {
            self.popViewControllerAfterConsentDisagree()
        }

        func didTapOnRetry() {
            self.createEligibilityConsentTask()
        }
    }
    
    
    
    
    //MARK: UNUserNotification Delegate
    
    @available(iOS 10, *)
    extension AppDelegate : UNUserNotificationCenterDelegate {
        
        //Receive displayed notifications for iOS 10 devices.
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            let userInfo = notification.request.content.userInfo
            print("REMOTE NOTIFICATION:" + "\(userInfo)")
            
             print("keys:" + "\(userInfo.keys)")
            
            if userInfo.count > 0 && userInfo.keys.contains(kType){
                 self.updateNotification()
            }
            
           
            
            completionHandler([UNNotificationPresentationOptions.alert, .sound, .badge])
            
            //self.handleLocalAndRemoteNotification(userInfoDetails: userInfo as! Dictionary<String, Any>)
            
        }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
            let userInfo = response.notification.request.content.userInfo
            print("REMOTE NOTIFICATION:" + "\(userInfo)")
            
            if (UIApplication.shared.applicationState == UIApplicationState.active || (UIApplication.shared.applicationState == UIApplicationState.inactive)) {//|| (UIApplication.shared.applicationState == UIApplicationState.background){
                UIApplication.shared.applicationIconBadgeNumber = 0
                
                self.handleLocalAndRemoteNotification(userInfoDetails: userInfo as! Dictionary<String, Any>)
                
                //self.handlePushNotificationResponse(userInfo : userInfo as NSDictionary)
            }
            
            if userInfo.count > 0 && userInfo.keys.contains(kType){
                self.updateNotification()
            }
            
            
            
        }
    }
    
    extension UIWindow{
        
        func addProgressIndicatorOnWindow(){
            
            
            let view = UINib(nibName: kNewProgressViewNIB, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
            
            
            let url = Bundle.main.url(forResource: kResourceName, withExtension: "gif")!
            let data = try! Data(contentsOf: url)
            let webView =  view?.subviews.first as! UIWebView
            
            
            //webView.load(data, mimeType: "image/gif", textEncodingName: "UTF-8", baseURL: URL())
            webView.loadRequest(URLRequest.init(url: url))
            webView.scalesPageToFit = true
            webView.contentMode = UIViewContentMode.scaleAspectFit
            
            var frame = UIScreen.main.bounds
            frame.origin.y += 64
            view?.frame = frame
            view?.tag = 50000
            self.addSubview(view!)
            view?.alpha = 0
            UIView.animate(withDuration: 0.3) {
                view?.alpha = 1
            }
        }
        func addProgressIndicatorOnWindowFromTop(){
            
            var view = self.viewWithTag(5000)
            if view == nil {
            
            let view = UINib(nibName: kNewProgressViewNIB, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
            
            
            let url = Bundle.main.url(forResource: kResourceName, withExtension: "gif")!
            let data = try! Data(contentsOf: url)
            let webView =  view?.subviews.first as! UIWebView
            
            
            //webView.load(data, mimeType: "image/gif", textEncodingName: "UTF-8", baseURL: URL())
            webView.loadRequest(URLRequest.init(url: url))
            webView.scalesPageToFit = true
            webView.contentMode = UIViewContentMode.scaleAspectFit
            
            var frame = UIScreen.main.bounds
            
            view?.frame = frame
            view?.tag = 50000
            self.addSubview(view!)
            view?.alpha = 0
            UIView.animate(withDuration: 0.3) {
                view?.alpha = 1
            }
            }
        }
        
        func removeProgressIndicatorFromWindow(){
            
            let view = self.viewWithTag(50000) //as UIView
            UIView.animate(withDuration: 0.2, animations: {
                view?.alpha = 0
            }) { (completed) in
                view?.removeFromSuperview()
            }
        }
        
        /*
         
         func addProgressIndicatorOnWindow(){
         
         let view = UINib(nibName: "ProgressView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
         var frame = UIScreen.main.bounds
         frame.origin.y += 64
         view?.frame = frame
         view?.tag = 50000
         self.addSubview(view!)
         view?.alpha = 0
         UIView.animate(withDuration: 0.3) {
         view?.alpha = 1
         }
         }
         
         func removeProgressIndicatorFromWindow(){
         
         let view = self.viewWithTag(50000) //as UIView
         UIView.animate(withDuration: 0.2, animations: {
         view?.alpha = 0
         }) { (completed) in
         view?.removeFromSuperview()
         }
         }
         
         
         */
        
        
        
    }
    extension UIApplication {
        func topMostViewController() -> UIViewController? {
            return self.keyWindow?.rootViewController?.topMostViewController()
        }
    }
    
    
    
    
    
    
