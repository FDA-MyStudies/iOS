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
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var tableViewFooterView : UIView?
    @IBOutlet var buttonSubmit : UIButton?
    
    @IBOutlet var buttonAgree : UIButton?
    @IBOutlet var labelTermsAndConditions : FRHyperLabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonSubmit?.layer.borderColor = UIColor.init(colorLiteralRed: 0/255.0, green: 124/255.0, blue: 186/255.0, alpha: 1.0).cgColor
        
        self.agreeToTermsAndConditions()
        self.title = "SIGN UP"
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "SignUpPlist", ofType: ".plist", inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
        //Automatically takes care  of text field become first responder and scroll of tableview
        IQKeyboardManager.sharedManager().enable = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    //MARK: Attributed string for Terms & Privacy Policy
    func agreeToTermsAndConditions(){
        
        labelTermsAndConditions?.numberOfLines = 0;
        
        //Step 1: Define a normal attributed string for non-link texts
        let string = "I Agree to the Terms and Privacy Policy"
        
        let attributes = [NSForegroundColorAttributeName: UIColor.black,
                          NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)]
        
        labelTermsAndConditions?.attributedText = NSAttributedString(string: string, attributes: attributes)
        
        //Step 2: Define a selection handler block
        let handler = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            
            if substring == "Terms"{
                //self.performSegue(withIdentifier: "TermsOfUse", sender: nil)
                
            }
            else if substring == "Privacy Policy" {
                //self.performSegue(withIdentifier: "TermsOfUse", sender: nil)
            }
        }
        
        //Step 3: Add link substrings
        labelTermsAndConditions?.setLinksForSubstrings(["Privacy Policy", "Terms"], withLinkHandler: handler)
        
    }
    
    func validateAllFields() -> Bool{
        if user.firstName == "" {//(Utilities.isValidValue(someObject: user.firstName as AnyObject?)){
            UIUtilities.showAlertWithMessage(alertMessage: "Please enter your first name.")
            return false
        }else if user.lastName == ""{//(Utilities.isValidValue(someObject: user.lastName as AnyObject?)){
            UIUtilities.showAlertWithMessage(alertMessage: "Please enter your last name.")
            return false
        }else if user.emailId == "" {//(Utilities.isValidValue(someObject: user.emailId as AnyObject?)){
            UIUtilities.showAlertWithMessage(alertMessage: "Please enter your email address.")
            return false
        }else if user.password == ""{//(Utilities.isValidValue(someObject: user.password as AnyObject?)){
            UIUtilities.showAlertWithMessage(alertMessage: "Please enter your password.")
            return false
        }else if user.confirmPassword == ""{//(Utilities.isValidValue(someObject: user.confirmPassword as AnyObject?)){
            UIUtilities.showAlertWithMessage(alertMessage: "Please enter confirm password.")
            return false
        }else if (user.password != user.confirmPassword){
            UIUtilities.showAlertWithMessage(alertMessage: "New password and confirm password does not match.")
            return false
            
        }else if ((user.password?.characters.count)! < 8 && (user.password?.characters.count)! != 0) || ((user.confirmPassword?.characters.count)! < 8 && user.confirmPassword?.characters.count != 0) {
            UIUtilities.showAlertWithMessage(alertMessage: "Password should have minimum of 8 characters.")
            return false
        }
        
        if self.checkTextSufficientComplexity(text: (user.password)!) == false || self.checkTextSufficientComplexity(text: (user.confirmPassword)!) == false {
            UIUtilities.showAlertWithMessage(alertMessage: "Password should have minimum of 1 special character, 1 upper case letter and 1 numeric number.")
            return false
        }
        
        return true
    
    }
    
    //Used to check all the validations for password
    func checkTextSufficientComplexity( text : String) -> Bool{
        let text = text
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluate(with: text)
        print("\(capitalresult)")

        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = texttest1.evaluate(with: text)
        print("\(numberresult)")
        
        let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        
        let specialresult = texttest2.evaluate(with: text)
        print("\(specialresult)")
        
        if capitalresult == false || numberresult == false || specialresult == false {
            return false
        }
        
        return true
    }
    
    //MARK: Submit Button Action and validation checks
    @IBAction func submitButtonAction(_ sender: Any) {
        
        if self.validateAllFields() == true {
            
            if agreedToTerms{
                //Call the Webservice
                
                
            }else{
                UIUtilities.showAlertWithMessage(alertMessage: "Please agree to terms and conditions")
            }
        }
    }
    
    //MARK: Agree to Aerms and Conditions checks
    @IBAction func agreeButtonAction(_ sender: Any) {
        if (sender as! UIButton).isSelected{
            (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
            agreedToTerms = false
        }else{
            agreedToTerms = true
            (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
        }
    }
}

//MARK: TableView Data source
extension SignUpViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDetails!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonDetailsCell", for: indexPath) as! SignUpTableViewCell
        
        var isSecuredEntry : Bool = false
        if indexPath.row == 3 || indexPath.row == 4{
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
        
        //        if textField.tag == 3{
        //            textField.isSecureTextEntry = true
        //        }else if textField.tag == 4{
        //            textField.isSecureTextEntry = true
        //        }else{
        //            textField.isSecureTextEntry = false
        //        }
    }
    
    //    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //
    //
    //    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text!)
        switch textField.tag {
        case TableViewTags.FirstNameTag.rawValue:
            
            user.firstName = textField.text
            
            break
            
        case TableViewTags.LastName.rawValue:
            
            user.lastName = textField.text
            
            break
            
        case TableViewTags.EmailId.rawValue:
            
            user.emailId = textField.text
            
            break
            
        case TableViewTags.Password.rawValue:
            
            user.password = textField.text
            
            break
            
        case TableViewTags.ConfirmPassword.rawValue:
            
            user.confirmPassword = textField.text
            
            break
        default:
            print("No Matching data Found")
            break
        }
        
        
        
    }
    
    
}


