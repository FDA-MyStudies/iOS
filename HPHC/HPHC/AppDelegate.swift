/*
 License Agreement for FDA My Studies
Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.
Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import Fabric
import Crashlytics
import UserNotifications
import RealmSwift
import CallKit
import IQKeyboardManagerSwift


let kBlockerScreenLabelText = "Please update to the latest version of the app to continue."
let kAppStoreUpdateText = "Please go to AppStore to update to the latest version of the app."

let kConsentUpdatedTitle = "Consent Updated"

let kMessageConsentUpdatedPartTwo = " Please review the revised Consent terms and provide your Informed Consent, to continue participating in the study."

let kMessageConsentUpdated = "The Consent Document for this study has been updated." + kMessageConsentUpdatedPartTwo

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
let kResultsForAppStore = "results"
let kAppStoreVersion = "version"

let kContinueButtonTitle =  NSLocalizedString("Continue", comment:"")
let kType = "type"

let kCurrentVersion = "currentVersion"
let kForceUpdate = "forceUpdate"
let kMessage = "message"
let kVisualStepId = "visual"
let kMessageString = "Message"


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
    
    var isAppLaunched: Bool? = false
    
    let healthStore = HKHealthStore()
    
    var containerViewController: ResearchContainerViewController? {
        return window?.rootViewController as? ResearchContainerViewController
    }
    
    var selectedController: UIViewController?
    
    var shouldAddForceUpgradeScreen = false
    
    var retryView: ComprehensionFailure?
    
    var blockerScreen: AppUpdateBlocker?
    
    var passcodeParentControllerWhileSetup: UIViewController?
    
    var consentToken: String? = "" //to be used in case of ineligible
    
    // MARK: App Delegates
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        self.isAppLaunched = true
        IQKeyboardManager.shared.enable = true
     
        self.customizeNavigationBar()
        Fabric.with([Crashlytics.self])
        
        UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self]).tintColor = kUIColorForSubmitButtonBackground
        
        self.checkForAppUpdate()
        
        if UIApplication.shared.applicationIconBadgeNumber > 0 {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        let ud1 = UserDefaults.standard
        
        //Check if App is launched because of Notification Received
        if (launchOptions != nil && launchOptions?[.sourceApplication] == nil) {
            
            ud1.set("not null", forKey: "launch")
            
            // Launched from push notification
            let notification = launchOptions?[.remoteNotification]
            
            if Utilities.isValidObject(someObject: notification as AnyObject) { // Launched from Remote Notification
                
                notificationDetails = notification as? Dictionary<String, Any>
                
                let ud = UserDefaults.standard
                ud.set(true, forKey: kShowNotification)
                ud.synchronize()
                
            } else if (launchOptions?[.localNotification] != nil) { //Launched from Local Notification
                
                ud1.set("local", forKey: "launch")
                let localNotification = (launchOptions?[.localNotification] as? UILocalNotification)!
                let notificationDetails = (localNotification.userInfo as? Dictionary<String, Any>)!
                
                NotificationHandler.instance.appOpenFromNotification = true
                NotificationHandler.instance.studyId = (notificationDetails[kStudyId] as? String)!
                NotificationHandler.instance.activityId = (notificationDetails[kActivityId] as? String)!
                ud1.synchronize()
                
            } else { //Regular Launch
                
                ud1.set("invalid", forKey: "launch")
                UIApplication.shared.applicationIconBadgeNumber = 0
                
                let ud = UserDefaults.standard
                ud.set(false, forKey: kShowNotification)
                ud.synchronize()
            }
        }
        
        //self.fireNotiffication(intervel: 10)
        //self.fireNotiffication(intervel: 15)
        
        //Check if Database needs migration
        self.checkForRealmMigration()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        self.appIsResignedButDidNotEnteredBackground = true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.appIsResignedButDidNotEnteredBackground = false
    }
    
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        self.checkPasscode(viewController: (application.windows[0].rootViewController)!)
        
        self.checkForStudyUpdates()
        
        let number = UIApplication.shared.applicationIconBadgeNumber
        if number >= 1 {
            self.updateNotification()
        }
        
        //Check For Updates
        self.checkForAppUpdate()
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        // self.window?.isHidden = false
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if self.appIsResignedButDidNotEnteredBackground! {
            
            let navController = application.windows[0].rootViewController
            
            
            let isTaskViewControllerVisible = (navController as? UINavigationController)?.visibleViewController?.isKind(of: ORKTaskViewController.self)
            
           // guard let navigation = (navController as? UINavigationController)?.visibleViewController as? ORKTaskViewController, let navigationTitle = navigation.title else {return}
            
            let navigationTitle = ((navController as? UINavigationController)?.visibleViewController as? ORKTaskViewController)?.title ?? ""
            
            if (navController as? UINavigationController) != nil &&  isTaskViewControllerVisible == false {
                
                if (navController as? UINavigationController)?.visibleViewController?.isKind(of: ORKPasscodeViewController.self) == false {
                    //Request for Passcode
                    //self.checkPasscode(viewController: navController!)
                }
                
            } else if(navController as? UINavigationController) != nil
                &&  isTaskViewControllerVisible == true
                && navigationTitle == "Activity" {
                
                if (navController as? UINavigationController)?.visibleViewController?.isKind(of: ORKPasscodeViewController.self) == false {
                    //Request for Passcode
                    //self.checkPasscode(viewController: navController!)
                }
            } else if(navController as? UIViewController) != nil {
               // self.checkPasscode(viewController: navController!)
            }
        }
        
        //Check if App running on Jailbreak Device
        if AppDelegate.jailbroken(application: application) {
            
            let navigationController =  (self.window?.rootViewController as? UINavigationController)!
            let appBlocker = JailbrokeBlocker.instanceFromNib(frame: navigationController.view.frame, detail: nil);
            UIApplication.shared.keyWindow?.addSubview(appBlocker);
            UIApplication.shared.keyWindow?.bringSubviewToFront(appBlocker)
            
        }
        
        //Update TimeZone Changes if any
        self.calculateTimeZoneChange()
        
        if self.isAppLaunched! {
            self.isAppLaunched = false
            
            //Update Local Notifications
            self.checkForRegisteredNotifications()
        }
    }
    
    //Register Remote Notification
  func askForNotification() {
    
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
      (granted, error) in
      
      // print("Permission granted: \(granted)")
      // 1. Check if permission granted
      guard granted else { return }
      // 2. Attempt registration for remote notifications on the main thread
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
    
  }
    
    /**
     Updates Key & InitializationVector for Encryption
     */
    func updateKeyAndInitializationVector() {
        
        let currentDate = "\(Date(timeIntervalSinceNow: 0))"
        let currentIndex = currentDate.index(currentDate.endIndex
            , offsetBy: -13)
        let subStringFromDate = String(currentDate[..<currentIndex])
        
        //let ud = UserDefaults.standard
        
        if User.currentUser.userType ==  .FDAUser { // Registered/LogedIn User
            
            let index =  User.currentUser.userId.index(User.currentUser.userId.endIndex
                , offsetBy: -16)
            let subKey = String(User.currentUser.userId[..<index]) //User.currentUser.userId.substring(to: index ) // 36 - 12 =  24 characters
            //ud.set("\(subKey + subStringFromDate)", forKey: kEncryptionKey)
            FDAKeychain.shared[kEncryptionKey] = subKey + subStringFromDate
        }else { // Anonymous User
            //ud.set(currentDate + kDefaultPasscodeString, forKey: kEncryptionKey)
            FDAKeychain.shared[kEncryptionKey] = kEncryptionKey
        }
        
        if UIDevice.current.model == kIsIphoneSimulator {
            // simulator
            //ud.set(kdefaultIVForEncryption, forKey: kEncryptionIV)
            FDAKeychain.shared[kEncryptionIV] = kdefaultIVForEncryption
        }else {
            // Device
            var udid = UIDevice.current.identifierForVendor?.uuidString
            let index =  udid?.index((udid?.endIndex)!
                , offsetBy: -20)
            udid = String((udid?[..<index!])!)//udid?.substring(to: index!)
            //ud.set(udid, forKey: kEncryptionIV)
            FDAKeychain.shared[kEncryptionIV] = udid
            
        }
        //ud.synchronize()
    }
    
    /**
     Handler for TimeZone changes, updates time zone in the local database
     */
    func calculateTimeZoneChange() {
        
        //let date = Date().utcDate()
        
        //let timeZoneUTC = TimeZone(abbreviation: "UTC")
        //let timeZoneAutoCurrent = TimeZone.autoupdatingCurrent
        let timeZoneCurrent = TimeZone.current
        
        //let differenceFromUTC = timeZoneUTC?.secondsFromGMT()
        let differenceFromCurrent = timeZoneCurrent.secondsFromGMT()
        //let differenceFromAutoCurrent = timeZoneCurrent.secondsFromGMT()
        
        //Saving TimeZone to User Defaults
        let ud = UserDefaults.standard
        let setuptimeDiff = ud.value(forKey: ksetUpTimeIdentifier) as? Int
        
        //Saving time difference
        if setuptimeDiff == nil {
            ud.set(differenceFromCurrent, forKey: ksetUpTimeIdentifier)
            ud.set(0, forKey: "offset")
            
        }else {
            
            let difference = differenceFromCurrent - setuptimeDiff!
            ud.set(difference, forKey: "offset")
            if difference == 0 {
                // Do Nothing
            }else {
                
                Schedule._formatter = nil
                Schedule._formatter2 = nil
            }
        }
        ud.synchronize()
    }
    
    func checkForAppReopenNotification() {
        
        //remove if notification is available
        LocalNotification.removeReopenAppNotification()
        LocalNotification.registerReopenAppNotification()
        
    }
    
    // MARK: Realm Migragion
    func generateRealmKeys() {
        
        //Realm Encryption key generation
        if FDAKeychain.shared[kRealmEncryptionKeychainKey] == nil{
            // Generate 64 bytes of random data to serve as the encryption key
            var realmKey = kRealmEncryptionDefaultKey
            var key = Data(count: 64)
            let result = key.withUnsafeMutableBytes {
                SecRandomCopyBytes(kSecRandomDefault, 64, $0.baseAddress!)
            }
            if result == errSecSuccess {
                realmKey = key.base64EncodedString()
            } else {
                print("Problem generating random bytes")
                
            }
            FDAKeychain.shared[kRealmEncryptionKeychainKey] = realmKey
        }
    }
    
    func checkForRealmMigration() {
        
        self.generateRealmKeys()
        
        let key = FDAKeychain.shared[kRealmEncryptionKeychainKey]
        let keyData = Data(base64Encoded: key!)
       
        let config = Realm.Configuration(
            encryptionKey:keyData,
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 2) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        print(config)
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration

    }
    
    // MARK:- NOTIFICATION
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // 1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        
        if  User.currentUser.userType == .FDAUser {
            
            User.currentUser.settings?.remoteNotifications = true
            User.currentUser.settings?.localNotifications = true
            //Update device Token to Local server
            UserServices().updateUserProfile(deviceToken: token , delegate: self)
            
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Token Registration failed  \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        //For iOS 8 & 9
        if (UIApplication.shared.applicationState == .background)||(UIApplication.shared.applicationState == .inactive) {
            
            self.updateNotification()
            self.handleLocalAndRemoteNotification(userInfoDetails: (userInfo as? Dictionary<String, Any>)!)
        }
        
        // userInfo is valid
        if userInfo.count > 0 && userInfo.keys.contains(kType) {
            self.updateNotification()
            
        }else {
            if (UIApplication.shared.applicationState == .background || (UIApplication.shared.applicationState == .inactive)) {
                //Handle local Notification Received
                self.handleLocalNotification(userInfoDetails: (userInfo as? Dictionary<String, Any>)!)
            }
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        self.handleLocalNotification(userInfoDetails: (notification.userInfo as? Dictionary<String, Any>)!)
    }
    
    // MARK: Jailbreak Methods
    
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
        }catch {
            return false
        }
    }
    
    static func canOpen(path: String) -> Bool {
        let file = fopen(path, "r")
        guard file != nil else { return false }
        fclose(file)
        return true
    }
    
    // MARK: Add Retry Screen
    
    func addRetryScreen(viewController: UIViewController?) {
        
        let navigationController =  (self.window?.rootViewController as? UINavigationController)!
        self.retryView = ComprehensionFailure.instanceFromNib(frame: navigationController.view.frame, detail: nil);
        
        if viewController != nil {
            retryView?.delegate = (viewController as? ComprehensionFailureDelegate)!
            
        }else {
            retryView?.delegate = (self as? ComprehensionFailureDelegate)!
        }
        UIApplication.shared.keyWindow?.addSubview(retryView!);
        UIApplication.shared.keyWindow?.bringSubviewToFront(retryView!)
    }
    
    // MARK:Custom Navigation Bar
    
    func customizeNavigationBar() {
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 18)!
        ]
    }
    
    // MARK: Checker Methods
    
    /**
     To get the current App version from App Store and Adds the blocker screen if it is of lower version
     */
    func checkForAppUpdate() {
        WCPServices().checkForAppUpdates(delegate: self)
    }
    
    func checkForRegisteredNotifications() {
        
        if User.currentUser.userType == .FDAUser {
           
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests(
                completionHandler: { requests in
                    print(requests)
                    if requests.count < 50 {
                        DispatchQueue.main.async {
                             LocalNotification.refreshAllLocalNotification()
                        }
                    }
                })
        }
    }
    
    func sendRequestToSignOut() {
        UserServices().logoutUser(self as NMWebServiceDelegate)
    }
    
    /**
     check the  current Consent Status for Updated Version
     */
    func checkConsentStatus(controller: UIViewController) {
        
        self.selectedController = controller
        
        if(StudyUpdates.studyConsentUpdated) {
            print("Study consent is updated: Please Present Consent UI")
            
            let navigationController =  (self.window?.rootViewController as? UINavigationController)!
            
            var topController: UIViewController = navigationController
            if navigationController.viewControllers.count > 0 {
                topController = navigationController.viewControllers.first!
            }
            
            UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString(kConsentUpdatedTitle, comment: ""), errorMessage: NSLocalizedString(kMessageConsentUpdated, comment: ""), errorAlertActionTitle: NSLocalizedString(kReviewTitle, comment: ""),
                                                                 errorAlertActionTitle2: nil, viewControllerUsed: topController,
                                                                 action1: {
                                                                    
                                                                    self.addAndRemoveProgress(add: true)
                                                                    WCPServices().getEligibilityConsentMetadata(studyId:(Study.currentStudy?.studyId)!, delegate: self as NMWebServiceDelegate)
                                                                    
            },
                                                                 action2: {
            })
        }else {
            print("Study consent not updated")
        }
    }
    
    /**
     Used to Create Eligibility Consent Task
     */
    func createEligibilityConsentTask() {
        
        let taskViewController: ORKTaskViewController?
        
        //create orderedTask
        let consentTask = ConsentBuilder.currentConsent?.createConsentTask()

        if consentHasLAR, let rule = ConsentBuilder.currentConsent?.LARBranchingRule() {//LAR
            (consentTask as? ORKNavigableOrderedTask)?.setNavigationRule(rule, forTriggerStepIdentifier: kLARConsentStep)
        }
        taskViewController = ORKTaskViewController(task: consentTask, taskRun: nil)
        
        taskViewController?.delegate = self
        taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        taskViewController?.navigationItem.title = nil
        
        UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self]).tintColor = kUIColorForSubmitButtonBackground
        
        //UIApplication.shared.statusBarStyle = .default
        
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        //Fetching the current Visible Controller
        while topVC?.presentedViewController != nil {
            topVC = topVC?.presentedViewController
        }
        
        self.addAndRemoveProgress(add: false)
        //present consent task
        taskViewController?.navigationBar.prefersLargeTitles = false
        taskViewController?.modalPresentationStyle = .fullScreen
        topVC?.present(taskViewController!, animated: true, completion: nil)
    }
    
    /**
     Handler for local notification
     @param userInfoDetails, contains the info for notification
     */
    
    func handleLocalNotification(userInfoDetails: Dictionary<String,Any>) {
        
        var initialVC: UIViewController?
        
        //getting topmost visible controller
        let navigationController =  (self.window?.rootViewController as? UINavigationController)!
        let menuVC = navigationController.viewControllers.last
        if  menuVC is FDASlideMenuViewController {
            let mainController =  (menuVC as? FDASlideMenuViewController)!.mainViewController
            if mainController is UINavigationController {
                let nav = (mainController as? UINavigationController)!
                initialVC = nav.viewControllers.last
            }
        }
        
        NotificationHandler.instance.appOpenFromNotification = true
        NotificationHandler.instance.studyId = (userInfoDetails[kStudyId] as? String)!
        NotificationHandler.instance.activityId = (userInfoDetails[kActivityId] as? String)!
        
        if !(initialVC is UITabBarController) {
            //push tabbar and switch to activty tab
            if !(initialVC is StudyListViewController) {
                
                let leftController = ((menuVC as? FDASlideMenuViewController)!.leftViewController as? LeftMenuViewController)!
                leftController.changeViewController(.studyList)
                leftController.createLeftmenuItems()
            }
        }
        else {
            //switch to activty tab
            (initialVC as? UITabBarController)!.selectedIndex =  0
        }
    }
    
    /**
     Handler for local & remote notification
     @param userInfoDetails, contains the info for notification
     */
    func handleLocalAndRemoteNotification(userInfoDetails: Dictionary<String,Any>) {
        
        var notificationType: String? = ""
        var notificationSubType: AppNotification.NotificationSubType? = .Announcement
        //User info is valid
        if (userInfoDetails.count) > 0 {
            
            if Utilities.isValidValue(someObject: userInfoDetails[kNotificationType] as AnyObject) {
                notificationType =  userInfoDetails[kNotificationType] as? String
            }
            if Utilities.isValidValue(someObject: userInfoDetails[kNotificationSubType] as AnyObject) {
                notificationSubType = AppNotification.NotificationSubType(rawValue: (userInfoDetails[kNotificationSubType] as? String)!)
            }
            
            if notificationType == AppNotification.NotificationType.Study.rawValue { //Study Level Notification
                
                var studyId: String? = ""
                
                if Utilities.isValidValue(someObject: userInfoDetails[kStudyId] as AnyObject) {
                    studyId = userInfoDetails[kStudyId] as? String
                }
                
                if studyId != nil || studyId != "" {
                    
                    var initialVC: UIViewController?
                    
                    if Gateway.instance.studies?.isEmpty == false {
                        
                        let study = Gateway.instance.studies?.filter({$0.studyId == studyId}).first
                        Study.updateCurrentStudy(study: study!)
                    }
                    //fetch the visible view controller
                    let navigationController =  (self.window?.rootViewController as? UINavigationController)!
                    let menuVC = navigationController.viewControllers.last
                    if  menuVC is FDASlideMenuViewController {
                        let mainController =  (menuVC as? FDASlideMenuViewController)!.mainViewController
                        if mainController is UINavigationController {
                            let nav = (mainController as? UINavigationController)!
                            initialVC = nav.viewControllers.last
                            
                        }
                        
                    }
                    //Handling Notifications based on SubType
                    switch notificationSubType! as AppNotification.NotificationSubType {
                    case .Activity, .Resource: //Activity & Resource  Notifications
                        
                        var activityId: String? = ""
                        
                        if Utilities.isValidValue(someObject: userInfoDetails[kActivityId] as AnyObject) {
                            activityId = userInfoDetails[kActivityId] as? String
                        }
                        
                        var resourceId: String? = ""
                        if Utilities.isValidValue(someObject: userInfoDetails[kResourceId] as AnyObject) {
                            resourceId = userInfoDetails[kResourceId] as? String
                        }
                        
                        if !(initialVC is UITabBarController) {
                            //push tabbar and switch to activty tab
                            
                            self.pushToTabbar(viewController: initialVC!, selectedTab: (notificationSubType! as AppNotification.NotificationSubType == .Activity) ? 0 : 2)
                            
                        }else {
                            //switch to activity tab
                            
                            (initialVC as? UITabBarController)!.selectedIndex =  (notificationSubType! as AppNotification.NotificationSubType == .Activity) ? 0 : 2
                        }
                        
                    case .Study,.studyEvent: // Study Notifications
                        
                        let leftController = ((menuVC as? FDASlideMenuViewController)!.leftViewController as? LeftMenuViewController)!
                        
                        if !(initialVC is StudyListViewController) {
                            
                            if initialVC is ProfileViewController  ||  initialVC is ReachoutOptionsViewController || initialVC is GatewayResourcesListViewController {
                                
                                NotificationHandler.instance.appOpenFromNotification = true
                                NotificationHandler.instance.studyId = studyId
                                
                                leftController.changeViewController(.studyList)
                                leftController.createLeftmenuItems()
                                
                            }else if initialVC is UITabBarController {
                                
                            }
                        }else {
                            
                            NotificationHandler.instance.appOpenFromNotification = true
                            NotificationHandler.instance.studyId = studyId
                            
                            leftController.changeViewController(.studyList)
                            leftController.createLeftmenuItems()
                        }
                        
                    case .Announcement: break
                        
                    //default: break
                        
                    }
                }else {
                    //studyId is Null
                }
            }else if notificationType == AppNotification.NotificationType.Gateway.rawValue { //Gateway level Notification
                // Do Nothing
            }
        }
        self.notificationDetails = nil
    }
    
    // Push to tabbar Controller with tabs Activity, Dashboard & Resource
    func pushToTabbar(viewController: UIViewController,selectedTab: Int) {
        
        let studyStoryBoard = UIStoryboard.init(name: kStudyStoryboard, bundle: Bundle.main)
        
        let studyDashboard = (studyStoryBoard.instantiateViewController(withIdentifier: kStudyDashboardTabbarControllerIdentifier) as? StudyDashboardTabbarViewController)!
        
        studyDashboard.selectedIndex = selectedTab
        viewController.navigationController?.navigationBar.isHidden = true
        viewController.navigationController?.pushViewController(studyDashboard, animated: true)
    }
    
    //Verify passcode if enabled or set passcode
    func checkPasscode(viewController: UIViewController) {
        
        if User.currentUser.userType == .FDAUser {//FDA user
            
            if User.currentUser.settings?.passcode! == true {
                //Passcode already exist
                if  ORKPasscodeViewController.isPasscodeStoredInKeychain() == false {
                    
                    let passcodeStep = ORKPasscodeStep(identifier: kPasscodeStepIdentifier)
                    passcodeStep.passcodeType = .type4Digit
                    let task = ORKOrderedTask(identifier: kPasscodeTaskIdentifier, steps: [passcodeStep])
                    let taskViewController = ORKTaskViewController.init(task: task, taskRun: nil)
                    
                    if viewController.isKind(of: UINavigationController.self) {
                        taskViewController.delegate = self
                        
                    }else {
                        taskViewController.delegate = viewController as? ORKTaskViewControllerDelegate
                    }
                    taskViewController.isNavigationBarHidden = true
                    passcodeParentControllerWhileSetup = viewController
                    isPasscodePresented = true
                    blockerScreen?.isHidden = true
                    taskViewController.navigationBar.prefersLargeTitles = false
                    taskViewController.modalPresentationStyle = .fullScreen
                    viewController.present(taskViewController, animated: false, completion: nil)
                    
                }else {
                    guard ORKPasscodeViewController.isPasscodeStoredInKeychain() && !(containerViewController?.presentedViewController is ORKPasscodeViewController) else { return }
                    window?.makeKeyAndVisible()
                    
                    let passcodeViewController = ORKPasscodeViewController.passcodeAuthenticationViewController(withText: "", delegate: self)
                    var topVC = UIApplication.shared.keyWindow?.rootViewController
                    var parentController: UIViewController?
                    
                    while topVC?.presentedViewController != nil {
                        
                        parentController = topVC
                        topVC = topVC?.presentedViewController
                    }
                    
                    if topVC is UIAlertController { //topmost Visible Controller is AlertController
                        alertVCPresented = (topVC as? UIAlertController)!
                        
                        if (parentController is ORKPasscodeViewController) == false {
                            topVC?.dismiss(animated: true, completion: nil)
                        }
                        topVC = parentController
                        parentViewControllerForAlert = topVC
                    }
                    passcodeParentControllerWhileSetup = nil
                    
                    //PasscodeController or TaskViewController is not presented
                    if (topVC?.presentedViewController?.isKind(of: ORKPasscodeViewController.self) == false && (topVC?.presentedViewController?.isKind(of: ORKTaskViewController.self))!) || ( topVC != nil && topVC?.isKind(of: ORKPasscodeViewController.self) == false) {
                        
                        isPasscodePresented = true
                        blockerScreen?.isHidden = true
                        
                        if isComprehensionFailed! {
                            self.retryView?.isHidden = true
                        }
                        passcodeViewController.navigationBar.prefersLargeTitles = false
                        passcodeViewController.modalPresentationStyle = .fullScreen
                        topVC!.present(passcodeViewController, animated: false, completion: nil)
                    }
                }
            }else {
                //Passcode is not set by user
            }
        }else {
            //Anonomous user
            
            // ORKPasscodeViewController.removePasscodeFromKeychain()
        }
    }
    
    func addAndRemoveProgress(add: Bool) {
        
        if add {
            self.window?.addProgressIndicatorOnWindow()
        }else {
            self.window?.removeProgressIndicatorFromWindow()
        }
    }
    
    func popToStudyListViewController() {
        
        let navigationController =  (self.window?.rootViewController as? UINavigationController)!
        
        var topController: UIViewController = navigationController
        if navigationController.viewControllers.count > 0 {
            topController = navigationController.viewControllers.first!
        }
        _ = topController.navigationController?.popViewController(animated: true)
    }
    
    //get study updates if exist
    func checkForStudyUpdates() {
        
        if Study.currentStudy != nil && Study.currentStudy?.userParticipateState.status == UserStudyStatus.StudyStatus.inProgress {
            
            let userStudyStatus =  (Study.currentStudy?.userParticipateState.status)!
            
            if userStudyStatus == .inProgress || userStudyStatus == .yetToJoin {
                WCPServices().getStudyUpdates(study: Study.currentStudy!, delegate: self)
            }
        }
    }
    
    /**
     Handler for User Signout response, resets all user related data from local database
     */
    func handleSignoutResponse() {
        
        if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            ORKPasscodeViewController.removePasscodeFromKeychain()
        }
        
        //Update User Defaults
        let ud = UserDefaults.standard
        ud.set(false, forKey: kPasscodeIsPending)
        ud.set(false, forKey: kShowNotification)
        ud.synchronize()
        
        //Update Key & InitializationVector
        self.updateKeyAndInitializationVector()
        
        let navigationController =  (self.window?.rootViewController as? UINavigationController)!
        
        if navigationController.viewControllers.count > 0 {
            let slideMenuController = navigationController.viewControllers.last as? FDASlideMenuViewController
            
            //Remove progress
            self.addAndRemoveProgress(add: false)
            
            if slideMenuController != nil {
                
                User.resetCurrentUser()
                
                let ud = UserDefaults.standard
                ud.removeObject(forKey: kUserAuthToken)
                ud.removeObject(forKey: kUserId)
                ud.synchronize()
                //Navigate to StudyHome
                slideMenuController?.fdaSlideMenuController()?.navigateToHomeAfterSingout()
            }
        }
    }
    
    /**
     Handler for updating User defaults
     */
    
    func handleSignoutAfterLogoutResponse(){
        
        if ORKPasscodeViewController.isPasscodeStoredInKeychain(){
            ORKPasscodeViewController.removePasscodeFromKeychain()
        }
        let ud = UserDefaults.standard
        ud.set(false, forKey: kPasscodeIsPending)
        ud.set(false, forKey: kShowNotification)
        ud.synchronize()
        
        let navigationController =  (self.window?.rootViewController as? UINavigationController)!
        
        //fetch the visible view controller
        if navigationController.viewControllers.count > 0 {
            let slideMenuController = (navigationController.viewControllers.last as? FDASlideMenuViewController)!
            
            if !Utilities.isStandaloneApp() {
                let leftController = (slideMenuController.leftViewController as? LeftMenuViewController)!
                leftController.changeViewController(.reachOut_signIn)
                leftController.createLeftmenuItems()
                self.addAndRemoveProgress(add: false)
            }
            else {
                UIApplication.shared.keyWindow?.removeProgressIndicatorFromWindow()
                navigationController.popToRootViewController(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    UIApplication.shared.keyWindow?.removeProgressIndicatorFromWindow()
                }
            }
           
            
        }
    }
    
    func updateNotification() {
        
        let ud = UserDefaults.standard
        ud.set(true, forKey: kShowNotification)
        ud.synchronize()
        var nav: UINavigationController?
        //fetch the visible view controller
        let navigationController =  (self.window?.rootViewController as? UINavigationController)!
        let menuVC = navigationController.viewControllers.last
        
        if  menuVC is FDASlideMenuViewController {
            let mainController =  (menuVC as? FDASlideMenuViewController)!.mainViewController
            
            if mainController is UINavigationController {
                nav = (mainController as? UINavigationController)!
                let studyListVC = nav?.viewControllers.last
                if studyListVC is StudyListViewController {
                    (studyListVC as? StudyListViewController)!.addRightNavigationItem()
                    
                }
            }
        }
    }
    
    /**
     Handler for Study Update Info
     */
    
    func handleStudyUpdatedInformation() {
        
        if Study.currentStudy != nil {
            
            Study.currentStudy?.newVersion = StudyUpdates.studyVersion
            if Study.currentStudy?.version == Study.currentStudy?.newVersion {
                return
                
            }else {
                DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
                
                //fetch the visible view controller
                var nav: UINavigationController?
                let navigationController =  (self.window?.rootViewController as? UINavigationController)!
                let menuVC = navigationController.viewControllers.last
                
                if  menuVC is FDASlideMenuViewController {
                    let mainController =  (menuVC as? FDASlideMenuViewController)!.mainViewController
                    
                    if mainController is UINavigationController {
                        nav = (mainController as? UINavigationController)!
                        let tabbarVC = nav?.viewControllers.last
                        
                        if tabbarVC is StudyDashboardTabbarViewController {
                            let studyTabBar = (tabbarVC as? StudyDashboardTabbarViewController)!
                            //Storing selected tabbar controller
                            selectedController = ((studyTabBar.viewControllers?[studyTabBar.selectedIndex]) as? UINavigationController)!.viewControllers.last
                        }
                    }
                }
                
                let studyStatus = StudyStatus(rawValue: StudyUpdates.studyStatus!)!
                
                if studyStatus != .Active { //Study is Active
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
                    
                    let alert = UIAlertController(title: "" as String,message: message as String,preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                }else {
                    
                    if selectedController != nil {
                        
                        if !self.isPasscodePresented! {
                            //Check for Consent Updated
                            self.checkConsentStatus(controller: self.selectedController!)
                        }
                        
                        if self.selectedController is ActivitiesViewController {
                            (self.selectedController as? ActivitiesViewController)!.checkForActivitiesUpdates()
                            
                        }else if self.selectedController is ResourcesViewController {
                            (self.selectedController as? ResourcesViewController)!.checkForResourceUpdate()
                        }
                    }
                }
            }
        }
    }
    
    @objc func updateEligibilityConsentStatus() {
        
        let notificationName = Notification.Name(kPDFCreationNotificationId)
        
        // Stop listening notification
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
        
        //Update Consent status to Server
        UserServices().updateUserEligibilityConsentStatus(eligibilityStatus: true, consentStatus:(ConsentBuilder.currentConsent?.consentStatus)!  , delegate: self)
    }
    
    func popViewControllerAfterConsentDisagree() {
        
        if self.selectedController is StudyDashboardViewController {
            (self.selectedController as? StudyDashboardViewController)!.homeButtonAction(UIButton())
            
        }else if self.selectedController is ActivitiesViewController {
            (self.selectedController as? ActivitiesViewController)!.homeButtonAction(UIButton())
            
        }else if self.selectedController is ResourcesViewController {
            (self.selectedController as? ResourcesViewController)!.homeButtonAction(UIButton())
        }
    }
    
    @objc func dismissTaskViewController() {
        passcodeParentControllerWhileSetup?.dismiss(animated: true, completion: nil)
        passcodeParentControllerWhileSetup = nil
        
    }
    
    //MARK: - Consent Handlers
    func studyEnrollmentFinished() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationStudyEnrollmentCompleted"), object: nil)
    }
    func studyEnrollmentFailed(error:NSError?) {
        
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "NotificationStudyEnrollmentFailed"), object: error)
        //let message = error.localizedDescription
        //UIUtilities.showAlertWithTitleAndMessage(title: NSLocalizedString(kErrorTitle, comment: "") as NSString, message: message as NSString)
    }
    
    func studyEnrollmentStarted(taskViewController:ORKTaskViewController) {
        
        //Saving Consent Document
        ConsentBuilder.currentConsent?.consentResult?.consentDocument =   ConsentBuilder.currentConsent?.consentDocument
        ConsentBuilder.currentConsent?.consentResult?.initWithORKTaskResult(taskResult: taskViewController.result )
        
        //save consent to study
        Study.currentStudy?.signedConsentVersion = ConsentBuilder.currentConsent?.version!
        Study.currentStudy?.signedConsentFilePath = ConsentBuilder.currentConsent?.consentResult?.consentPath!
        
        // save also in DB
        DBHandler.saveConsentInformation(study: Study.currentStudy!)
        
        
        //update consent is updaeted in db
        Study.currentStudy?.version = StudyUpdates.studyVersion
        Study.currentStudy?.newVersion = StudyUpdates.studyVersion
        
        if self.isComprehensionFailed! {
            self.isComprehensionFailed = false
        }
        
        ConsentBuilder.currentConsent?.consentStatus = .completed
        //self.addAndRemoveProgress(add: true)
        
        if ConsentBuilder.currentConsent?.consentResult?.consentPdfData?.count == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                self.updateEligibilityConsentStatus()
                StudyUpdates.studyConsentUpdated  = false
                DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
            }
        } else {
            // Update Consent Status to server
            UserServices().updateUserEligibilityConsentStatus(eligibilityStatus: true, consentStatus:(ConsentBuilder.currentConsent?.consentStatus)!  , delegate: self)
            StudyUpdates.studyConsentUpdated  = false
            DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
        }
  
    }
    
}

// MARK:- Handle network responses
extension AppDelegate {
    
    /// Handle App update
    private func handleAppUpdateResponse(response: JSONDictionary){
        
        if let iosDict = response["ios"] as? JSONDictionary,
           let latestVersion = iosDict["latestVersion"] as? String,
            let ForceUpdate = iosDict["forceUpdate"] as? String {
            
            let appVersion = Utilities.getAppVersion()
            guard let isForceUpdate = Bool(ForceUpdate) else {return}
            
            if appVersion != latestVersion,
                latestVersion.compare(appVersion, options: .numeric, range: nil, locale: nil)
                    == ComparisonResult.orderedDescending,
                isForceUpdate {
        
                // load and Update blockerScreen
                self.shouldAddForceUpgradeScreen = true
                self.blockerScreen = AppUpdateBlocker.instanceFromNib(frame:(UIApplication.shared.keyWindow?.bounds)!,
                                                                      detail: [:])
                self.blockerScreen?.configureView(with: latestVersion)
                
                if User.currentUser.userType == .FDAUser {
                    //FDA user
                    if User.currentUser.settings?.passcode! == false {
                        UIApplication.shared.keyWindow?.addSubview(self.blockerScreen!)
                    }
                } else {
                    UIApplication.shared.keyWindow?.addSubview(self.blockerScreen!)
                }
                
            }
        
        }
        
    }

    /// Updates the user LAR status from result to generate the Consent PDF
    /// - Parameter result: LAR steps result.
    fileprivate func updatedLARStatus(with result: ORKTaskResult) {
        if result.results?.last?.identifier == kLARConsentStep {
            if let val = result.stepResult(forStepIdentifier: kLARConsentStep) {

                let participantRelation = (val.result(forIdentifier: kLARConsentStep) as? ORKChoiceQuestionResult)?.choiceAnswers?.first as? String

                if let selectedChoice = participantRelation,
                    selectedChoice == "Choice_1" {
                    consentHasLAR = false
                } else {
                    consentHasLAR = true
                }
            }
        }
    }
    
}

//Handling for HTTPS
extension AppDelegate : NMAuthChallengeDelegate{
    
    func networkCredential(_ manager : NetworkManager, challenge : URLAuthenticationChallenge) -> URLCredential {
        var urlCredential: URLCredential = URLCredential()
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if challenge.protectionSpace.host == "hphci-fdama-te-ur-01.labkey.com" {
                urlCredential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            }
        }
        return urlCredential
    }
    
    func networkChallengeDisposition(_ manager: NetworkManager, challenge: URLAuthenticationChallenge) -> URLSession.AuthChallengeDisposition {
        return URLSession.AuthChallengeDisposition.useCredential
    }
}

// MARK: Webservices delegates

extension AppDelegate: NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        
        if requestName as String == WCPMethods.versionInfo.method.methodName {
            
            if let response = response as? JSONDictionary {
                handleAppUpdateResponse(response: response)
            }
            

        }else if requestName as String == WCPMethods.eligibilityConsent.method.methodName {
            self.createEligibilityConsentTask()
            
        }else if requestName as String == RegistrationMethods.logout.method.methodName {
            
            if iscomingFromForgotPasscode! {
                self.handleSignoutAfterLogoutResponse()
            }else {
                self.handleSignoutResponse()
            }
        }else if requestName as String == RegistrationMethods.updateEligibilityConsentStatus.method.methodName {
            
            self.addAndRemoveProgress(add: false)
            self.studyEnrollmentFinished()
            
        }else if (requestName as String == WCPMethods.studyUpdates.rawValue) {
            self.handleStudyUpdatedInformation()
            
        }else if (requestName as String == RegistrationMethods.updateUserProfile.description) {
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: kNotificationRegistrationIsPending)
            ud.synchronize()
        }
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        //Remove Progress
        self.addAndRemoveProgress(add: false)
        if requestName as String == RegistrationMethods.logout.method.methodName {
            self.addAndRemoveProgress(add: false)
            
        }else if requestName as String == WCPMethods.eligibilityConsent.method.methodName {
            self.popViewControllerAfterConsentDisagree()
        }
    }
}

 // MARK: - ORKTaskViewController Delegate

extension AppDelegate: ORKTaskViewControllerDelegate {

    func taskViewController(_ taskViewController: ORKTaskViewController, didChange result: ORKTaskResult) {
        updatedLARStatus(with: result)
    }

    func taskViewControllerSupportsSaveAndRestore(_ taskViewController: ORKTaskViewController) -> Bool {
        return true
    }
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        var taskResult: Any?
        
        switch reason {
            
        case ORKTaskViewControllerFinishReason.completed:
            print("completed")
            
            if taskViewController.task?.identifier == kConsentTaskIdentifier {
                
                //Saving Consent Document
//                ConsentBuilder.currentConsent?.consentResult?.consentDocument =   ConsentBuilder.currentConsent?.consentDocument
//                ConsentBuilder.currentConsent?.consentResult?.initWithORKTaskResult(taskResult: taskViewController.result )
//
//                //save consent to study
//                Study.currentStudy?.signedConsentVersion = ConsentBuilder.currentConsent?.version!
//                Study.currentStudy?.signedConsentFilePath = ConsentBuilder.currentConsent?.consentResult?.consentPath!
//
//                // save also in DB
//                DBHandler.saveConsentInformation(study: Study.currentStudy!)
//
//
//                //update consent is updaeted in db
//                Study.currentStudy?.version = StudyUpdates.studyVersion
//                Study.currentStudy?.newVersion = StudyUpdates.studyVersion
//                StudyUpdates.studyConsentUpdated  = false
//                DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
//
//                if self.isComprehensionFailed! {
//                    self.isComprehensionFailed = false
//                }
                
            }else { //other surveys/Active tasks/ Passcode
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
            
            if  taskViewController.task?.identifier == kConsentTaskIdentifier {
                self.popViewControllerAfterConsentDisagree()
            }
            print("discarded")
            taskResult = taskViewController.result
            
            if self.isComprehensionFailed! {
                self.isComprehensionFailed = false
            }
            
            
        case ORKTaskViewControllerFinishReason.saved:
            print("saved")
            taskResult = taskViewController.restorationData
            
            if  taskViewController.task?.identifier == kConsentTaskIdentifier {
                
                self.popViewControllerAfterConsentDisagree()
            }
        }
        
        if passcodeParentControllerWhileSetup != nil {
            
            //Adding delay to allow Keypad to dismiss
            if #available(iOS 10.3.0, *) {
                self.perform(#selector(dismissTaskViewController), with: self, afterDelay: 2)
            } else {
                self.dismissTaskViewController()
            }
            
        }else {
            taskViewController.dismiss(animated: true, completion: nil)
        }

    }
    
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        
        let stepIdentifier = stepViewController.step?.identifier

        if taskViewController.task?.identifier == kConsentTaskIdentifier {
            
            if (taskViewController.result.results?.count)! > 1{
                if activityBuilder?.actvityResult?.result?.count == taskViewController.result.results?.count {
                    //Removing the dummy result:Currentstep result which not presented yet
                    activityBuilder?.actvityResult?.result?.removeLast()
                }
            }
            
            //Handling show and hide of Back Button
            
            //For Verified Step , Completion Step, Visual Step, Review Step, Share Pdf Step
            
            if  stepIdentifier == kConsentCompletionStepIdentifier
                || stepIdentifier == kVisualStepId
                || stepIdentifier == kConsentSharePdfCompletionStep
                || stepIdentifier == kEligibilityVerifiedScreen {

                if stepIdentifier == kEligibilityVerifiedScreen {
                    stepViewController.continueButtonTitle = kContinueButtonTitle
                }
                stepViewController.backButtonItem = nil
            } else if stepIdentifier == kConsentViewPdfCompletionStep {
                
                //Back button is enabled
                stepViewController.backButtonItem = nil
                
                let orkStepResult: ORKStepResult? = taskViewController.result.results?[(taskViewController.result.results?.count)! - 2] as! ORKStepResult?
                
                let consentSignatureResult: ConsentCompletionTaskResult? = orkStepResult?.results?.first as? ConsentCompletionTaskResult
                
                //Checking if Signature is consented after Review Step
                if  consentSignatureResult?.didTapOnViewPdf == false {
                    //Directly moving to completion step by skipping Intermediate PDF viewer screen
                    stepViewController.goForward()
                }
            } else if stepIdentifier == kLARConsentParticipantStep {
                stepViewController.backButtonItem?.isEnabled = true
                stepViewController.cancelButtonItem?.isEnabled = true
            } else {
                if taskViewController.task?.identifier == "ConsentTask" {
                    stepViewController.backButtonItem = nil
                }
                else {
                    stepViewController.backButtonItem?.isEnabled = true
                }
            }
        }
    }
    
    // MARK:- StepViewController Delegate
    
    public func stepViewController(_ stepViewController: ORKStepViewController, didFinishWith direction: ORKStepViewControllerNavigationDirection) {
    }
    
    public func stepViewControllerResultDidChange(_ stepViewController: ORKStepViewController) {
    }
    
    public func stepViewControllerDidFail(_ stepViewController: ORKStepViewController, withError error: Error?) {
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        
        if taskViewController.task?.identifier == kConsentTaskIdentifier {
            
            
            //CurrentStep is TokenStep
            if step.identifier != kEligibilityTokenStep && step.identifier != kConsentSharePdfCompletionStep && step.identifier != kConsentViewPdfCompletionStep && step.identifier != kComprehensionCompletionStepIdentifier && step.identifier != kReviewTitle {
                
                return nil
                
            }else  if step.identifier == kEligibilityTokenStep { //For EligibilityTokenStep
                
                let gatewayStoryboard = UIStoryboard(name: kFetalKickCounterStep, bundle: nil)
                
                let ttController = (gatewayStoryboard.instantiateViewController(withIdentifier: kEligibilityStepViewControllerIdentifier) as? EligibilityStepViewController)!
                ttController.descriptionText = step.text
                ttController.step = step
                
                return ttController
                
            }else if step.identifier == kConsentSharePdfCompletionStep { //For ConsentShareCompletion Step
                
                var totalResults =  taskViewController.result.results
                let reviewStep: ORKStepResult?
                
                totalResults = totalResults?.filter({$0.identifier == kReviewTitle})
                
                reviewStep = (totalResults?.first as? ORKStepResult)!
                
                if (reviewStep?.identifier)! == kReviewTitle && (reviewStep?.results?.count)! > 0 {
                    let consentSignatureResult: ORKConsentSignatureResult? = reviewStep?.results?.first as? ORKConsentSignatureResult
                    
                    if  consentSignatureResult?.consented == false { //Disgreed
                        taskViewController.dismiss(animated: true
                            , completion: nil)
                        
                        self.popViewControllerAfterConsentDisagree()
                        return nil
                        
                    }else { //Consented
                        
                        //Copying consent document
                        let documentCopy: ORKConsentDocument = ((ConsentBuilder.currentConsent?.consentDocument)!.copy() as? ORKConsentDocument)!
                        
                        consentSignatureResult?.apply(to: documentCopy)
                        //instantiating ConsentSharePdfStep
                        let gatewayStoryboard = UIStoryboard(name: kFetalKickCounterStep, bundle: nil)
                        let ttController = (gatewayStoryboard.instantiateViewController(withIdentifier: kConsentSharePdfStoryboardId) as? ConsentSharePdfStepViewController)!
                        ttController.step = step
                        ttController.consentDocument =  documentCopy
                        
                        //start enrollment process
                       
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.studyEnrollmentStarted(taskViewController: taskViewController)
                            }
                        
                        
                        return ttController
                    }
                }else {
                    return nil
                }
                
            }else if step.identifier == kConsentViewPdfCompletionStep { //For PDFViewerStep
                
                //fetching reviewStep
                let reviewSharePdfStep: ORKStepResult? = taskViewController.result.results?.last as! ORKStepResult?
                
                let result = (reviewSharePdfStep?.results?.first as? ConsentCompletionTaskResult)
                
                if (result?.didTapOnViewPdf)!{
                    let gatewayStoryboard = UIStoryboard(name: kFetalKickCounterStep, bundle: nil)
                    
                    let ttController = (gatewayStoryboard.instantiateViewController(withIdentifier: kConsentViewPdfStoryboardId) as? ConsentPdfViewerStepViewController)!
                    ttController.step = step
                    //Pdf data is passed to Viewer for display
                    ttController.pdfData = result?.pdfData
                    
                    return ttController
                    
                }else {
                    return nil
                }
                
            }else if step.identifier == kComprehensionCompletionStepIdentifier {
                // comprehension test is available
                if (ConsentBuilder.currentConsent?.comprehension?.questions?.count)! > 0 {
                    
                    
                    let visualStepIndex: Int = (taskViewController.result.results?.index(where: {$0.identifier == kVisualStepId}))!
                    
                    if visualStepIndex >= 0 {
                        
                        var  i = visualStepIndex + 2 // holds the index of  question
                        var j = 0 // holds the index of correct answer
                        
                        var userScore = 0
                        
                        //Pass score Calculation
                        while  i < (taskViewController.result.results?.count)! {


                            let textChoiceResult: ORKChoiceQuestionResult = (((taskViewController.result.results?[i] as? ORKStepResult)!.results?.first) as? ORKChoiceQuestionResult)!

                            let correctAnswerDict: Dictionary<String,Any>? = ConsentBuilder.currentConsent?.comprehension?.correctAnswers?[j]
                            let answerArray: [String] = (correctAnswerDict?[kConsentComprehensionAnswer] as? [String])!
                            let evaluationType: Evaluation? = Evaluation(rawValue: (correctAnswerDict?[kConsentComprehensionEvaluation] as? String)!)
                            let answeredSet = Set((textChoiceResult.choiceAnswers! as? [String])!)
                            
                            let correctAnswerSet = Set(answerArray)
                            //Evaluation Type
                            switch evaluationType! {
                            case .any:
                                
                                if answeredSet.isSubset(of: correctAnswerSet) {
                                    userScore = userScore + 1
                                }
                            case .all:
                                
                                if answeredSet == correctAnswerSet {
                                    userScore = userScore + 1
                                }
                            //default: break
                            }
                            
                            j+=1
                            i+=1
                        }
                        
                        if userScore >= (ConsentBuilder.currentConsent?.comprehension?.passScore)! {
                            //User Failed to pass the Score
                            return nil
                        }else {
                            //User passed the Score
                            self.isComprehensionFailed = true
                            self.addRetryScreen(viewController: nil)
                            
                            taskViewController.dismiss(animated: true, completion: nil)
                        }
                        
                    }else {
                        // if by chance we didnt get visualStepIndex i.e there no visual step
                        // Do Nothing
                    }
                    
                    return nil
                    
                }else {
                    // comprehension test is not available
                    return nil
                }
                
            }else if step.identifier == kReviewTitle {
                // if sharing step exists && allowWithoutSharing is set
                
                let shareStep: ORKStepResult? = taskViewController.result.results?.last as! ORKStepResult?
                
                ConsentBuilder.currentConsent?.sharingConsent?.allowWithoutSharing = true
                
                if shareStep?.identifier == kConsentSharing && ConsentBuilder.currentConsent?.sharingConsent != nil && (ConsentBuilder.currentConsent?.sharingConsent?.allowWithoutSharing)! == false {
                    
                    let result = (shareStep?.results?.first as? ORKChoiceQuestionResult)
                    
                    if (result?.choiceAnswers?.first as? Bool)! == true { //User agreed to share
                        return nil
                        
                    }else { //User disagreed to share
                        taskViewController.dismiss(animated: true, completion: {
                            
                            self.popViewControllerAfterConsentDisagree()
                            
                            //Alert User
                            UIUtilities.showAlertWithTitleAndMessage(title: "Message", message: NSLocalizedString(kShareConsentFailureAlert, comment: "") as NSString)
                        })
                        return nil
                    }
                    
                }else {
                    return nil
                }
                
            }else {
                return nil
            }
            
        }else {
            // other than consent step mostly passcode step
            return nil
        }
    }
}

// MARK: Passcode Delegate
extension AppDelegate: ORKPasscodeDelegate {
    func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
        containerViewController?.contentHidden = false
        self.appIsResignedButDidNotEnteredBackground = false
        
        viewController.dismiss(animated: true, completion: {
            self.isPasscodePresented = false
            
            if self.shouldAddForceUpgradeScreen {
                
                if self.blockerScreen?.isHidden == true {
                    self.blockerScreen?.isHidden = false
                    
                }else {
                    UIApplication.shared.keyWindow?.addSubview(self.blockerScreen!)
                }
            }
            
            if self.isComprehensionFailed! {
                
                if self.retryView != nil {
                    self.retryView?.isHidden = false
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
                                                             errorAlertActionTitle2: NSLocalizedString(kTitleCancel, comment: ""), viewControllerUsed: topVC!,
                                                             action1: {
                                                                self.window?.addProgressIndicatorOnWindowFromTop()
                                                                
                                                                viewController.dismiss(animated: true, completion: {
                                                                    //fetch top view controller
                                                                    var topVC = UIApplication.shared.keyWindow?.rootViewController
                                                                    while topVC?.presentedViewController != nil {
                                                                        
                                                                        topVC = topVC?.presentedViewController
                                                                    }
                                                                    
                                                                    if topVC is ORKTaskViewController {
                                                                        topVC?.dismiss(animated: true, completion: nil)
                                                                    }
                                                                    
                                                                    self.iscomingFromForgotPasscode = true
                                                                    //Signout if User Forgot Passcode
                                                                    self.sendRequestToSignOut()
                                                                })
        },
                                                             action2: {
                                                                
        })
    }
}

// MARK:ComprehensionFailureDelegate

extension AppDelegate: ComprehensionFailureDelegate {
    func didTapOnCancel() {
        self.popViewControllerAfterConsentDisagree()
    }
    
    func didTapOnRetry() {
        //Create Consent Task on Retry
        self.createEligibilityConsentTask()
    }
}

// MARK: UNUserNotification Delegate

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    //Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if userInfo.count > 0 && userInfo.keys.contains(kType) {
            self.updateNotification()
        }
        
        completionHandler([UNNotificationPresentationOptions.alert, .sound, .badge])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        print("application state \(UIApplication.shared.applicationState.rawValue)")
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if (UIApplication.shared.applicationState == UIApplication.State.background || (UIApplication.shared.applicationState == UIApplication.State.inactive)) {
            
            self.handleLocalAndRemoteNotification(userInfoDetails: (userInfo as? Dictionary<String, Any>)!)
        }
        
        //UserInfo is valid & contains Type for Notification
        if userInfo.count > 0 && userInfo.keys.contains(kType) {
            self.updateNotification()
            
        }else {
            if (UIApplication.shared.applicationState == UIApplication.State.background || (UIApplication.shared.applicationState == UIApplication.State.inactive)) {
                self.handleLocalNotification(userInfoDetails: (userInfo as? Dictionary<String, Any>)!)
            }
        }
    }
}

extension UIWindow{
    
    /**
     Adds progress below navigation bar
     */
    func addProgressIndicatorOnWindow() {

        let view = UINib(nibName: kNewProgressViewNIB, bundle: nil).instantiate(
            withOwner: nil, options: nil)[0] as? UIView

        let fdaGif = UIImage.gifImageWithName(kResourceName)
        let imageView = view?.subviews.first as? UIImageView
        imageView?.image = fdaGif
        
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
    
    /**
     Adds Progress on complete screen, including navigation bar
     */
    func addProgressIndicatorOnWindowFromTop() {
        
        let view = self.viewWithTag(50000)
        if view == nil {

            let view = UINib(nibName: kNewProgressViewNIB, bundle: nil).instantiate(
                withOwner: nil, options: nil)[0] as? UIView
            
            let fdaGif = UIImage.gifImageWithName(kResourceName)
            let imageView = view?.subviews.first as? UIImageView
            imageView?.image = fdaGif
            
            let frame = UIScreen.main.bounds
            
            view?.frame = frame
            view?.tag = 50000
            self.addSubview(view!)
            view?.alpha = 0
            UIView.animate(withDuration: 0.3) {
                view?.alpha = 1
            }
        }
    }
    
    /**
     Removes progress from window
     */
    func removeProgressIndicatorFromWindow(){
        
        let view = self.viewWithTag(50000) //as UIView
        UIView.animate(withDuration: 0.2, animations: {
            view?.alpha = 0
        }) { (completed) in
            view?.removeFromSuperview()
        }
    }
}
extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}






