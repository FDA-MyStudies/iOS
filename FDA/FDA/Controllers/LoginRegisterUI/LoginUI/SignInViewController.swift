//
//  SignInViewController.swift
//  FDA
//
//  Created by Ravishankar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import SlideMenuControllerSwift


enum SignInLoadFrom:Int{
    case gatewayOverview
    case menu
}

class SignInViewController : UIViewController{
    
    var tableViewRowDetails : NSMutableArray?
    var user = User.currentUser
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var buttonSignIn : UIButton?
    
    @IBOutlet var buttonSignUp: UIButton?
    var viewLoadFrom:SignInLoadFrom = .menu
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonSignIn?.layer.borderColor = kUicolorForButtonBackground
        self.title = NSLocalizedString(kSignInTitleText, comment: "")
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "SignInPlist", ofType: ".plist", inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
        //Automatically takes care  of text field become first responder and scroll of tableview
        IQKeyboardManager.sharedManager().enable = true
        
        //Used for background tap dismiss keyboard
        let gestureRecognizwe : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(SignInViewController.dismissKeyboard))
        self.tableView?.addGestureRecognizer(gestureRecognizwe)
        
        
        //unhide navigationbar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
       
        
        if let attributedTitle = buttonSignUp?.attributedTitle(for: .normal) {
            let mutableAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
           
             mutableAttributedTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(colorLiteralRed: 0/255.0, green: 124/255.0, blue: 186/255.0, alpha: 1.0), range: NSRange(location:10,length:7))
            
            buttonSignUp?.setAttributedTitle(mutableAttributedTitle, for: .normal)
        }
        
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewLoadFrom == .gatewayOverview {
            self.addBackBarButton()
        }
        else {
            self.setNavigationBarItem()
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        //hide navigationbar
        if viewLoadFrom == .gatewayOverview {
             self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
       
    }
    
    //Used to show the alert using Utility
    func showAlertMessages(textMessage : String){
        UIUtilities.showAlertMessage("", errorMessage: NSLocalizedString(textMessage, comment: ""), errorAlertActionTitle: NSLocalizedString("OK", comment: ""), viewControllerUsed: self)
    }
    
    //Dismiss key board when clicked on Background
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    //MARK: Signin Button Action and validation checks
    @IBAction func signInButtonAction(_ sender: Any) {
        
        if user.emailId == "" {
            self.showAlertMessages(textMessage: kMessageEmailBlank)
            
        }else if !(Utilities.isValidEmail(testStr: user.emailId!)) {
            self.showAlertMessages(textMessage: kMessageValidEmail)
            
        }else if user.password == ""{
            self.showAlertMessages(textMessage: kMessagePasswordBlank)
            
        }else{
            print("Call the webservice")
            user.userType = .FDAUser
            //self.navigateToGatewayDashboard()
            UserServices().loginUser(self)
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        
        if let signUpController = segue.destination as? SignUpViewController {
            signUpController.viewLoadFrom = .gatewayOverview
            
        }
        
        
    }
    
    func navigateToGatewayDashboard(){
        
        self.createMenuView()
    }
    
    func navigateToChangePassword(){
        
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
        
        let changePassword = storyboard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        if viewLoadFrom == .menu {
            changePassword.viewLoadFrom = .menu_login
        }
        else {
            changePassword.viewLoadFrom = .login
        }
        self.navigationController?.pushViewController(changePassword, animated: true)
    }
    
    func navigateToVerifyController(){
        self.performSegue(withIdentifier: "verificationSegue", sender: nil)
    }
    
    func createMenuView() {
        
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
        
        let fda = storyboard.instantiateViewController(withIdentifier: "FDASlideMenuViewController") as! FDASlideMenuViewController
        fda.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.pushViewController(fda, animated: true)
    }

}

//MARK: TableView Data source
extension SignInViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kSignInTableViewCellIdentifier, for: indexPath) as! SignInTableViewCell
        
        var isSecuredEntry : Bool = false
        if indexPath.row == SignInTableViewTags.Password.rawValue{
            isSecuredEntry = true
        }
        
        cell.textFieldValue?.tag = indexPath.row
        cell.populateCellData(data: tableViewData, securedText: isSecuredEntry)
        
        return cell
    }
}

//MARK: TableView Delegates
extension SignInViewController :  UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

//MARK: Textfield Delegate
extension SignInViewController : UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.tag)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text!)
        switch textField.tag {
        case SignInTableViewTags.EmailId.rawValue:
            user.emailId = textField.text
            break
            
        case SignInTableViewTags.Password.rawValue:
            user.password = textField.text
            break
            
        default:
            print("No Matching data Found")
            break
        }
    }
}

extension SignInViewController:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        if User.currentUser.verified == true {
            
            if User.currentUser.isLoginWithTempPassword {
                self.navigateToChangePassword()
            }
            else {
                
                if viewLoadFrom == .gatewayOverview {
                    self.navigateToGatewayDashboard()
                }
                else {
                    
                    let leftController = slideMenuController()?.leftViewController as! LeftMenuViewController
                    leftController.createLeftmenuItems()
                    leftController.changeViewController(.studyList)
                }
            }
            
            
            
        }
        else {
            
           self.navigateToVerifyController()
        }

        
       
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        
        UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString("Error", comment: "") as NSString, message: error.localizedDescription as NSString)
    }
}


