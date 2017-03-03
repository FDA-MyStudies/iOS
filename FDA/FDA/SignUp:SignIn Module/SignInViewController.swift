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

class SignInViewController : UIViewController{
    
    var tableViewRowDetails : NSMutableArray?
    
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var buttonSignIn : UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonSignIn?.layer.borderColor = kUicolorForButtonBackground
        self.title = NSLocalizedString("SIGN IN", comment: "")
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "SignInPlist", ofType: ".plist", inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
        //Automatically takes care  of text field become first responder and scroll of tableview
        IQKeyboardManager.sharedManager().enable = true
        
        //Used for background tap dismiss keyboard
        let gestureRecognizwe : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(SignInViewController.dismissKeyboard))
        self.tableView?.addGestureRecognizer(gestureRecognizwe)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
            self.showAlertMessages(textMessage: "Please enter your email address.")
            
        }else if !(Utilities.isValidEmail(testStr: user.emailId!)) {
            self.showAlertMessages(textMessage: "Please enter valid email address.")
            
        }else if user.password == ""{
            self.showAlertMessages(textMessage: "Please enter your password.")
            
        }else{
            print("Call the webservice")
            
            
        }
    }
}

//MARK: TableView Data source
extension SignInViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell", for: indexPath) as! SignInTableViewCell
        
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

