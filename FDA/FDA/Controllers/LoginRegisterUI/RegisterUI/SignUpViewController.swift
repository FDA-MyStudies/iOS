//
//  SIGNUPVIEWCONTROLLER.swift
//  FDA
//
//  Created by Ravishankar on 2/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class SignUpViewController : UIViewController{
    
    var tableViewRowDetails : NSMutableArray?
    var agreedToTerms : Bool = false
    var confirmPassword = ""
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var tableViewFooterView : UIView?
    @IBOutlet var buttonSubmit : UIButton?
    
    @IBOutlet var buttonAgree : UIButton?
    @IBOutlet var labelTermsAndConditions : FRHyperLabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonSubmit?.layer.borderColor = kUicolorForButtonBackground
        
        self.agreeToTermsAndConditions()
        self.title = NSLocalizedString(kSignUpTitleText, comment: "")
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "SignUpPlist", ofType: ".plist", inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
        //Automatically takes care  of text field become first responder and scroll of tableview
        IQKeyboardManager.sharedManager().enable = true
        
        //Used for background tap dismiss keyboard
        let gestureRecognizwe : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        self.tableView?.addGestureRecognizer(gestureRecognizwe)
        
        //unhide navigationbar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.addBackBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
   
    //Attributed string for Terms & Privacy Policy
    func agreeToTermsAndConditions(){
        
        labelTermsAndConditions?.numberOfLines = 0;
        
        //Step 1: Define a normal attributed string for non-link texts
        let string = NSLocalizedString(kAgreeToTermsAndConditionsText, comment: "")
        
        let attributes = [NSForegroundColorAttributeName: UIColor.black,
                          NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)]
        
        labelTermsAndConditions?.attributedText = NSAttributedString(string: string, attributes: attributes)
        
        //Step 2: Define a selection handler block
        let handler = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            
            if substring == NSLocalizedString(kTermsText, comment: ""){
                //self.performSegue(withIdentifier: "TermsOfUse", sender: nil)
                
            }
            else if substring == NSLocalizedString(kPrivacyPolicyText , comment: ""){
                //self.performSegue(withIdentifier: "TermsOfUse", sender: nil)
            }
        }
        
        //Step 3: Add link substrings
        labelTermsAndConditions?.setLinksForSubstrings([kPrivacyPolicyText, kTermsText], withLinkHandler: handler)
        
    }
    
    //Dismiss key board when clicked on Background
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    //All validation checks and Password,Email complexity checks
    func validateAllFields() -> Bool{
        if user.firstName == "" {
            self.showAlertMessages(textMessage: kMessageFirstNameBlank)
            return false
        }else if user.lastName == ""{
            self.showAlertMessages(textMessage: kMessageLastNameBlank)
            return false
        }else if user.emailId == "" {
            self.showAlertMessages(textMessage: kMessageEmailBlank)
            return false
        }else if !(Utilities.isValidEmail(testStr: user.emailId!)){
            self.showAlertMessages(textMessage: kMessageValidEmail)
            return false
        }else if user.password == ""{
            self.showAlertMessages(textMessage: kMessagePasswordBlank)
            return false
        }else if confirmPassword == ""{
            self.showAlertMessages(textMessage: kMessageConfirmPasswordBlank)
            return false
        }else if (user.password != confirmPassword){
            self.showAlertMessages(textMessage: kMessageValidatePasswords)
            return false
            
        }else if ((user.password?.characters.count)! < 8 && (user.password?.characters.count)! != 0) || ((confirmPassword.characters.count) < 8 && confirmPassword.characters.count != 0) {
            self.showAlertMessages(textMessage: kMessageValidatePasswordCharacters)
            return false
        }
        
        if Utilities.isPasswordValid(text: (user.password)!) == false || Utilities.isPasswordValid(text: (confirmPassword)) == false {
            self.showAlertMessages(textMessage: kMessageValidatePasswordComplexity)
            return false
        }
        
        return true
    }
    
    //Used to show the alert using Utility
    func showAlertMessages(textMessage : String){
        UIUtilities.showAlertMessage("", errorMessage: NSLocalizedString(textMessage, comment: ""), errorAlertActionTitle: NSLocalizedString("OK", comment: ""), viewControllerUsed: self)
    }
    
    //MARK: Submit Button Action and validation checks
    @IBAction func submitButtonAction(_ sender: Any) {
        
        if self.validateAllFields() == true {
            
            if !(agreedToTerms){
                self.showAlertMessages(textMessage: kMessageAgreeToTermsAndConditions)
            }else{
                //Call the Webservice
                
                self.navigateToVerificationController()
                
                
            }
        }
    }
    
    //MARK: Agree to Terms and Conditions checks
    @IBAction func agreeButtonAction(_ sender: Any) {
        if (sender as! UIButton).isSelected{
            (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
            agreedToTerms = false
        }else{
            agreedToTerms = true
            (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
        }
    }
    
    
    func navigateToVerificationController(){
        
        self.performSegue(withIdentifier: "verificationSegue", sender: nil)
    }
}

//MARK: TableView Data source
extension SignUpViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDetails!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        let cell = tableView.dequeueReusableCell(withIdentifier: kSignUpTableViewCellIdentifier, for: indexPath) as! SignUpTableViewCell
        
        var isSecuredEntry : Bool = false
        
        if indexPath.row == SignUpTableViewTags.Password.rawValue ||
            indexPath.row == SignUpTableViewTags.ConfirmPassword.rawValue{
            isSecuredEntry = true
        }
        
        cell.textFieldValue?.tag = indexPath.row
        cell.populateCellData(data: tableViewData, securedText: isSecuredEntry)
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

//MARK: TableView Delegates
extension SignUpViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //print(indexPath.row)
    }
}

//MARK: Textfield Delegate
extension SignUpViewController : UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.tag)
        

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text!)
        switch textField.tag {
        case SignUpTableViewTags.FirstNameTag.rawValue:
            user.firstName = textField.text
            break
            
        case SignUpTableViewTags.LastName.rawValue:
            user.lastName = textField.text
            break
            
        case SignUpTableViewTags.EmailId.rawValue:
            user.emailId = textField.text
            break
            
        case SignUpTableViewTags.Password.rawValue:
            user.password = textField.text
            break
            
        case SignUpTableViewTags.ConfirmPassword.rawValue:
            confirmPassword = textField.text!
            break
            
        default:
            print("No Matching data Found")
            break
        }
    }
}


