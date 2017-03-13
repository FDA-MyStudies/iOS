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
    @IBOutlet var termsAndCondition:LinkTextView?
    
    
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
        
        
//        let info = NSMutableAttributedString()
//        let firstPart:NSMutableAttributedString = NSMutableAttributedString(string: "Lorem ipsum dolor set amit ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 13)])
//        
//        firstPart.addAttribute(NSForegroundColorAttributeName, value: UIColor.black,
//                               range: NSRange(location: 0, length: firstPart.length))
//        info.append(firstPart)
//        
//        // The "Read More" string that should be touchable
//        let secondPart:NSMutableAttributedString = NSMutableAttributedString(string: "READ MORE", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
//        secondPart.addAttribute(NSForegroundColorAttributeName, value: UIColor.black,
//                                range: NSRange(location: 0, length: secondPart.length))
//        info.append(secondPart)
        
        
        self.termsAndCondition?.delegate = self
        let attributedString =  termsAndCondition?.attributedText.mutableCopy() as! NSMutableAttributedString
        //let str = "I Agree to the Terms and Privacy Policy"
        //let attributedString = NSMutableAttributedString(string: str)
        var foundRange = attributedString.mutableString.range(of: "Terms")
        attributedString.addAttribute(NSLinkAttributeName, value:kTermsAndConditionLink, range: foundRange)
        //attributedString.addAttribute(NSForegroundColorAttributeName, value:Utilities.getUIColorFromHex(0x007CBA), range: foundRange)
        
        
        //attributedString.addAttributes([NSFontAttributeName: UIFont.], range: foundRange)

        
        foundRange = attributedString.mutableString.range(of: "Privacy Policy")
        attributedString.addAttribute(NSLinkAttributeName, value:kPrivacyPolicyLink, range: foundRange)
        //attributedString.addAttribute(NSForegroundColorAttributeName, value:Utilities.getUIColorFromHex(0x007CBA), range: foundRange)
        termsAndCondition?.attributedText = attributedString
        
        termsAndCondition?.linkTextAttributes = [NSForegroundColorAttributeName:Utilities.getUIColorFromHex(0x007CBA)]
        
//        labelTermsAndConditions?.numberOfLines = 0;
//        
//        //Step 1: Define a normal attributed string for non-link texts
//        let string = NSLocalizedString(kAgreeToTermsAndConditionsText, comment: "")
//        
//        let attributes = [NSForegroundColorAttributeName: UIColor.black,
//                          NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)]
//        
//        labelTermsAndConditions?.attributedText = NSAttributedString(string: string, attributes: attributes)
//        
//        //Step 2: Define a selection handler block
//        let handler = {
//            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
//            
//            if substring == NSLocalizedString(kTermsText, comment: ""){
//                //self.performSegue(withIdentifier: "TermsOfUse", sender: nil)
//                
//            }
//            else if substring == NSLocalizedString(kPrivacyPolicyText , comment: ""){
//                //self.performSegue(withIdentifier: "TermsOfUse", sender: nil)
//            }
//        }
//        
//        //Step 3: Add link substrings
//        labelTermsAndConditions?.setLinksForSubstrings([kPrivacyPolicyText, kTermsText], withLinkHandler: handler)
        
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
                
                //self.navigateToVerificationController()
                UserServices().registerUser(self)
                
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

extension SignUpViewController:UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.classForCoder()) {
            if gestureRecognizer.numberOfTouches == 2 {
                return false
            }
        }
        return true
    }
}

//MARK: UITextViewDelegate

class LinkTextView:UITextView{
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.classForCoder()) {
            let tap = gestureRecognizer as! UITapGestureRecognizer
            if tap.numberOfTapsRequired == 2 {
                return false
            }
        }
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.classForCoder()){
            return false
        }
        return true
    }
}

extension SignUpViewController:UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
       
        var link:String = kTermsAndConditionLink
        if (URL.absoluteString == kPrivacyPolicyLink) {
            print("terms")
            link = kPrivacyPolicyLink
            
        }
        let loginStoryboard = UIStoryboard.init(name: "Main", bundle:Bundle.main)
        let webViewController = loginStoryboard.instantiateViewController(withIdentifier:"WebViewController") as! UINavigationController
        let webview = webViewController.viewControllers[0] as! WebViewController
        webview.requestLink = link
        self.navigationController?.present(webViewController, animated: true, completion: nil)
        
        return false
    }
   
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        return false
    }
    

    
    
    
//    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
//        if gestureRecognizer.isKindOfClass(UITapGestureRecognizer) && ((gestureRecognizer as UITapGestureRecognizer).numberOfTapsRequired == 1) {
//            let touchPoint = gestureRecognizer.locationOfTouch(0, inView: self)
//            let cursorPosition = closestPositionToPoint(touchPoint)
//            selectedTextRange = textRangeFromPosition(cursorPosition, toPosition: cursorPosition)
//            return true
//        }
//        else {
//            return false
//        }
//    }
    
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
        
        if indexPath.row == TextFieldTags.Password.rawValue ||
            indexPath.row == TextFieldTags.ConfirmPassword.rawValue{
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
        if textField.tag == TextFieldTags.EmailId.rawValue{
            textField.keyboardType = .emailAddress
        }

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text!)
        
        let tag:TextFieldTags = TextFieldTags(rawValue: textField.tag)!
    
        switch tag {
        case .FirstNameTag:
            user.firstName = textField.text!
            break
            
        case .LastName:
            user.lastName = textField.text!
            break
            
        case .EmailId:
            user.emailId = textField.text!
            break
            
        case .Password:
            user.password = textField.text!
            break
            
        case .ConfirmPassword:
            confirmPassword = textField.text!
            break
            
        default:
            print("No Matching data Found")
            break
        }
        
    }

}

//MARK:
extension SignUpViewController:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.navigateToVerificationController()
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString("Error", comment: "") as NSString, message: error.localizedDescription as NSString)
    }
}


