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

import Foundation
import UIKit

enum CompletionLoadFrom: Int{
    case signup
    case joinStudy
}
class SignUpCompleteViewController: UIViewController{
    
    @IBOutlet var buttonNext: UIButton?
    var shouldCreateMenu: Bool = true
    var viewLoadFrom: CompletionLoadFrom = .signup
    let kPasscodeDoYouWish =
        NSLocalizedStrings(
            "Do you wish to set up Passcode or FaceID/TouchID protection for this app? (You can do this later in the My Account area).",
            comment: "")
    
    // MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonNext?.layer.borderColor = kUicolorForButtonBackground
        self.title = NSLocalizedStrings("", comment: "")
        
        
        let settings: Settings? = Settings.init()
        
        settings?.remoteNotifications = true
        settings?.localNotifications = true
        //settings?.touchId = true
        //settings?.passcode = true
        
        self.hideViews()
        
        UIUtilities.showAlertMessageWithTwoActionsAndHandler("",
                                                             errorMessage: kPasscodeDoYouWish,
                                                             errorAlertActionTitle: kNo,
                                                             errorAlertActionTitle2: kYes,
                                                             viewControllerUsed: self,
                                                             action1: {
                                                                //No
                                                                settings?.touchId = false
                                                                settings?.passcode = false
                                                                User.currentUser.settings = settings
                                                                UserServices().updateUserProfile(self as NMWebServiceDelegate)
                                                                
                                                                
        }) {
            //Yes
            print("hello")
            settings?.touchId = true
            settings?.passcode = true
            User.currentUser.settings = settings
            UserServices().updateUserProfile(self as NMWebServiceDelegate)
            
            
        }
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
    
    func hideViews() {
        for view in self.view.subviews {
            view.isHidden = true
        }
    }
    
    func unUideViews() {
        for view in self.view.subviews {
            view.isHidden = false
        }
    }
    
    // MARK:- button Actions
    
    /**
     
     Next button clicked and navigate the screen to GateWay dashboard
     
     @param sender  accepts any object
     
     */
    @IBAction func nextButtonAction(_ sender: Any) {
        
        //Updating Key & Vector
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.updateKeyAndInitializationVector()
        
       
        if self.viewLoadFrom == .joinStudy {
            let leftController = slideMenuController()?.leftViewController as! LeftMenuViewController
            leftController.createLeftmenuItems()
            self.performSegue(withIdentifier: "unwindStudyHomeSegue", sender: self)
        } else {
            self.navigateToGatewayDashboard()
        }
        
    }
    
    
    // MARK:- Utility Methods
    
    /**
     
     Used to Navigate StudyList after completion
     
     */
    func navigateToGatewayDashboard() {
        if shouldCreateMenu {
            self.createMenuView()
        } else {
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



// MARK:- UserService Response handler
extension SignUpCompleteViewController: NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        if requestName as String ==  RegistrationMethods.updateUserProfile.description {
            
            DBHandler.saveUserSettingsToDatabase()
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: kPasscodeIsPending)
            ud.set(false, forKey: kShowNotification)
            ud.synchronize()
            
            
            
            if User.currentUser.settings!.passcode! {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.checkPasscode(viewController: self.navigationController!)
                self.unUideViews()
            }
            else {
                self.navigateToGatewayDashboard()
            }
            
            
            
            
            
        }
    }
    
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        let errorMsg = base64DecodeError(error.localizedDescription)
        UIUtilities.showAlertWithTitleAndMessage(title: NSLocalizedStrings(kErrorTitle, comment: "") as NSString, message: errorMsg as NSString)
    }
}


