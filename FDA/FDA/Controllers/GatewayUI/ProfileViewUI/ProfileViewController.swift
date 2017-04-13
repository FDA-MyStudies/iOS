//
//  ProfileViewController.swift
//  FDA
//
//  Created by Arun Kumar on 3/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

let kProfileTableViewCellIdentifier = "ProfileTableViewCell"

let kLeadTimeSelectText = "Select Lead Time"
let kActionSheetDoneButtonTitle = "Done"
let kActionSheetCancelButtonTitle = "Cancel"

let kChangePasswordSegueIdentifier = "changePasswordSegue"
let kErrorTitle = ""
let kProfileAlertTitleText = "Profile"
let kProfileAlertUpdatedText = "Profile updated Successfully."

let signupCellLastIndex = 3

let kProfileTitleText = "PROFILE"


// Cell Toggle Switch Types
enum ToggelSwitchTags:Int{
    case usePasscode = 4
    case useTouchId = 5
    case receivePush = 6
    case receiveStudyActivityReminders = 7
}

class ProfileViewController: UIViewController {
    
    var tableViewRowDetails : NSMutableArray?
    var datePickerView:UIDatePicker?
    
    var isCellEditable:Bool?
    var user = User.currentUser
    
    
    @IBOutlet var tableViewProfile : UITableView?
    @IBOutlet var tableViewFooterViewProfile : UIView?
    @IBOutlet var buttonLeadTime:UIButton?
    
    @IBOutlet var editBarButtonItem:UIBarButtonItem?
    @IBOutlet var tableTopConstraint:NSLayoutConstraint?
    
//MARK: ViewController delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //First responder handler for textfields
        IQKeyboardManager.sharedManager().enable = true
        
        
        //Load plist info
        let plistPath = Bundle.main.path(forResource: "Profile", ofType: ".plist", inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
        //Resigning First Responder on outside tap
        let gestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ProfileViewController.dismissKeyboard))
        self.tableViewProfile?.addGestureRecognizer(gestureRecognizer)
        
        //Initial data setup
        self.setInitialDate()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        user = User.currentUser
        UserServices().getUserProfile(self as NMWebServiceDelegate)
        self.setNavigationBarItem()
        
        UIApplication.shared.statusBarStyle = .default
        self.tableViewProfile?.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
//MARK:IBActions
    
    @IBAction func editBarButtonAction(_ sender:UIBarButtonItem){
        
        if self.isCellEditable! == false  {
            self.isCellEditable =  true
            
            self.buttonLeadTime?.isUserInteractionEnabled =  true
            
            self.editBarButtonItem?.title = "Save"
            self.editBarButtonItem?.tintColor = UIColor.black
        }
        else{
            
            self.view.endEditing(true)
            
            if self.validateAllFields() {
                UserServices().updateUserProfile(self)
            }
        }
        
        
        self.tableViewProfile?.reloadData()
    }
    
    
    
    /*
     button action for LeadtimeButton, CancelButton & DoneButton
     @param sender  UIButton
     */
    @IBAction func buttonActionLeadTime(_ sender: UIButton) {
        
        
        let alertView = UIAlertController(title: kLeadTimeSelectText, message: "\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.actionSheet);
        
        
        datePickerView = UIDatePicker.init(frame:CGRect(x: 10, y: 30, width: alertView.view.frame.size.width - 40, height: 216) )
        
        datePickerView?.datePickerMode = .countDownTimer
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        datePickerView?.date = dateFormatter.date(from: "00:00")!
        
        alertView.view.addSubview(datePickerView!)
        
        let action =   UIAlertAction(title: kActionSheetDoneButtonTitle, style: UIAlertActionStyle.default, handler: {
            action in
            
            let calender:Calendar? = Calendar.current
            
            if Utilities.isValidValue(someObject:self.datePickerView?.date as AnyObject? )  {
                
                let dateComponent = calender?.dateComponents([.hour, .minute], from: (self.datePickerView?.date)!)
                
                
                // title =  hour : minute,  if hour < 10, hour =  "0" + hour ,if minute < 10, minute =  "0" + minute
                
                let title:String! = (((dateComponent?.hour)! as Int) < 10 ? "0\((dateComponent?.hour)! as Int)" : "\((dateComponent?.hour)! as Int)") + ":"
                    
                    + (((dateComponent?.minute)! as Int) < 10 ? "0\((dateComponent?.minute)! as Int)" : "\((dateComponent?.minute)! as Int)")
                
                self.buttonLeadTime?.setTitle(title!, for: .normal)
                
                self.user.settings?.leadTime = title
            }
            
        })
        let actionCancel =   UIAlertAction(title: kActionSheetCancelButtonTitle, style: UIAlertActionStyle.default, handler: {
            action in
            
        })
        
        
        alertView.addAction(action)
        alertView.addAction(actionCancel)
        present(alertView, animated: true, completion: nil)
        
    }
    
    @IBAction func buttonActionSignOut(_ sender: UIButton) {
        
        UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString("Sign Out", comment: ""), errorMessage: NSLocalizedString("Are you sure you want to Sign Out ?", comment: ""), errorAlertActionTitle: NSLocalizedString("Sign out", comment: ""),
                                                             errorAlertActionTitle2: NSLocalizedString("Cancel", comment: ""), viewControllerUsed: self,
                                                             action1: {
                                                                
                                                                
                                                                self.sendRequestToSignOut()
                                                                
                                                                
        },
                                                             action2: {
                                                                
        })
        
    }
    @IBAction func buttonActionDeleteAccount(_ sender: UIButton) {
        //self.performSegue(withIdentifier: kConfirmationSegueIdentifier, sender: nil)
        UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString(kTitleDeleteAccount, comment: ""), errorMessage: NSLocalizedString(kDeleteAccountConfirmationMessage, comment: ""), errorAlertActionTitle: NSLocalizedString(kTitleDeleteAccount, comment: ""),
                                                             errorAlertActionTitle2: NSLocalizedString(kTitleCancel, comment: ""), viewControllerUsed: self,
                                                             action1: {
                                                                
                                                                
                                                                self.sendRequestToDeleteAccount()
                                                                
                                                                
        },
                                                             action2: {
                                                                
        })
    }
    
//MARK:Utility Methods
    
    /*
     Dismiss key board when clicked on Background
     */
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    /* Api Call to SignOut
     */
    func sendRequestToSignOut() {
        UserServices().logoutUser(self)
    }
    func sendRequestToDeleteAccount(){
        UserServices().deActivateAccount(self)
    }
    
    /*
     SignOut Response handler for slider menu setup
    */
    func handleSignoutResponse(){
        debugPrint("singout")
        //fdaSlideMenuController()?.navigateToHomeAfterSingout()
        let leftController = slideMenuController()?.leftViewController as! LeftMenuViewController
        leftController.changeViewController(.studyList)
        leftController.createLeftmenuItems()
        
    }
    func handleDeleteAccountResponse(){
        // fdaSlideMenuController()?.navigateToHomeAfterSingout()
        
        
        UIUtilities.showAlertMessageWithActionHandler(NSLocalizedString(kTitleMessage, comment: ""), message: NSLocalizedString(kMessageAccountDeletedSuccess, comment: ""), buttonTitle: NSLocalizedString(kTitleOk, comment: ""), viewControllerUsed: self) {
            
            let leftController = self.slideMenuController()?.leftViewController as! LeftMenuViewController
            leftController.changeViewController(.studyList)
            leftController.createLeftmenuItems()
            
        }
        
        
        
    }
    
    
    /*
     setInitialData sets lead Time
     */
    func setInitialDate()  {
        
        if user.settings != nil &&  Utilities.isValidValue(someObject: user.settings?.leadTime as AnyObject?) {
            self.buttonLeadTime?.setTitle(user.settings?.leadTime, for: .normal)
        }
        else{
            Logger.sharedInstance.debug("settings/LeadTime is null")
        }
        
        
        self.title = NSLocalizedString(kProfileTitleText, comment: "")
        self.isCellEditable =  false
        
        self.buttonLeadTime?.isUserInteractionEnabled =  false
    }
    
    
    /*
     toggle Value change  method for cell Togges
     @param Sender  has to be a UISwitch
    */
    func toggleValueChanged(_ sender:UISwitch)  {
        
        let toggle:UISwitch? = sender as UISwitch
        
        if  user.settings != nil {
            
            switch ToggelSwitchTags(rawValue:sender.tag)! as ToggelSwitchTags{
            case .usePasscode:
                user.settings?.passcode = toggle?.isOn
            case .useTouchId:
                user.settings?.touchId = toggle?.isOn
            case .receivePush:
                user.settings?.remoteNotifications = toggle?.isOn
            case .receiveStudyActivityReminders:
                user.settings?.localNotifications = toggle?.isOn
            
            }
            
            self.editBarButtonItem?.tintColor = UIColor.black
        }
        else{
            Logger.sharedInstance.debug("settings is null")
        }
        
    }
    
    /*
     Segue Delegate method for Navigation based on segue connected
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let changePassword = segue.destination as? ChangePasswordViewController {
            changePassword.viewLoadFrom = .profile
            
        }
        
    }
    /*
     Button action for Change password button
    */
    func pushToChangePassword(_ sender:UIButton)  {
        self.performSegue(withIdentifier: kChangePasswordSegueIdentifier, sender: nil)
    }
    
    
    /*
     Validation of Profile data
     */
    func validateAllFields() -> Bool{
        
        //(user.firstName?.isEmpty)! && (user.lastName?.isEmpty)! &&
        
        if (user.emailId?.isEmpty)! {
            self.showAlertMessages(textMessage: kMessageAllFieldsAreEmpty)
            return false
        } /*
        else if  user.firstName == ""{
            self.showAlertMessages(textMessage: kMessageFirstNameBlank)
            return false
        }
        else if (user.firstName?.isAlphanumeric)! == false || (user.firstName?.characters.count)! > 100 {
            self.showAlertMessages(textMessage: kMessageValidFirstName)
            return false
        }
        else if user.lastName == ""{
            self.showAlertMessages(textMessage: kMessageLastNameBlank)
            return false
            
        }else if user.lastName == "" ||  (user.lastName?.isAlphanumeric)! == false || (user.lastName?.characters.count)! > 100{
            self.showAlertMessages(textMessage: kMessageValidLastName)
            return false
        }*/ else if user.emailId == "" {
            self.showAlertMessages(textMessage: kMessageEmailBlank)
            return false
        }else if !(Utilities.isValidEmail(testStr: user.emailId!)){
            self.showAlertMessages(textMessage: kMessageValidEmail)
            return false
        }
        
        return true
    }
    
    /*
     Method to show the alert using Utility
     @param textMessage    message to be displayed
     */
    func showAlertMessages(textMessage : String){
        UIUtilities.showAlertMessage("", errorMessage: NSLocalizedString(textMessage, comment: ""), errorAlertActionTitle: NSLocalizedString("OK", comment: ""), viewControllerUsed: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


//MARK: TableView Data source
extension ProfileViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDetails!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        
        if indexPath.row <= signupCellLastIndex {
            // for SignUp Cell data
            
            let  cell = tableView.dequeueReusableCell(withIdentifier: "CommonDetailsCell", for: indexPath) as! SignUpTableViewCell
            cell.textFieldValue?.text = ""
            
            var isSecuredEntry : Bool = false
            cell.isUserInteractionEnabled = self.isCellEditable!
            
            cell.textFieldValue?.tag = indexPath.row
            cell.textFieldValue?.delegate = self
            
            var keyBoardType:UIKeyboardType? =  UIKeyboardType.default
            let textFieldTag = TextFieldTags(rawValue:indexPath.row)!
            
            // TextField properties set up according to index
            switch  textFieldTag {
            /*
            case .FirstNameTag,.LastName:
                cell.textFieldValue?.autocapitalizationType = .sentences
                
                isSecuredEntry = false
            */
            case  .Password:
                
                cell.buttonChangePassword?.isUserInteractionEnabled =  true
                cell.buttonChangePassword?.isHidden =  false
                cell.buttonChangePassword?.addTarget(self, action:#selector(pushToChangePassword), for: .touchUpInside)
                cell.textFieldValue?.isHidden = true
                cell.isUserInteractionEnabled = true
                
                isSecuredEntry = true
            case .EmailId :
                keyBoardType = .emailAddress
                isSecuredEntry = false
            default: break
            }
            //Cell data setup
            cell.populateCellData(data: tableViewData, securedText: isSecuredEntry,keyboardType: keyBoardType)
            
            cell.backgroundColor = UIColor.clear
            
            
            cell.setCellData(tag: TextFieldTags(rawValue: indexPath.row)!)
            
            
            if TextFieldTags(rawValue: indexPath.row) ==  .EmailId{
                cell.textFieldValue?.isUserInteractionEnabled = false
            }
            
            return cell
        }
        else{
            // for ProfileTableViewCell data
            
            let cell = tableView.dequeueReusableCell(withIdentifier: kProfileTableViewCellIdentifier, for: indexPath) as! ProfileTableViewCell
            cell.setCellData(dict: tableViewData)
            
            
            //TODO: handle toggle Value based on user settings
            
            if (user.settings != nil) {
                cell.setToggleValue(indexValue: indexPath.row)
            }
            cell.switchToggle?.tag =  indexPath.row
            // Toggle button Action
            cell.switchToggle?.addTarget(self, action: #selector(ProfileViewController.toggleValueChanged), for: .valueChanged)
            
            cell.isUserInteractionEnabled = self.isCellEditable!
            return cell
        }
        
        
        
        
    }
}

//MARK: TableView Delegates
extension ProfileViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //print(indexPath.row)
    }
}

//MARK: Textfield Delegate
extension ProfileViewController : UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.tag)
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let tag:TextFieldTags = TextFieldTags(rawValue: textField.tag)!
        // Disabling space editing
       
        let finalString = textField.text! + string
        
        /*
        if tag == .FirstNameTag || tag == .LastName {
            if string == " "  || finalString.characters.count > 100 {
                return false
            }
            else{
                return true
            }
        }
        else */
        if  tag == .EmailId {
            if string == " " || finalString.characters.count > 255{
                return false
            }
            else{
                return true
            }
        }
        else{
            return true
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text!)
        
        // trimming white spaces
        textField.text =  textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        switch textField.tag {
        /*
        case TextFieldTags.FirstNameTag.rawValue:
            
            user.firstName! =  textField.text!
            
            break
            
        case TextFieldTags.LastName.rawValue:
            
            user.lastName! = textField.text!
            break
        */
        case TextFieldTags.EmailId.rawValue:
            user.emailId! = textField.text!
            
            break
            
        case TextFieldTags.Password.rawValue:
            
            user.password! = textField.text!
            break
            
        default:
            print("No Matching data Found")
            break
        }
        
    }
}

//MARK:UserService Response handler

extension ProfileViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        if requestName as String ==  RegistrationMethods.logout.description {
            
            self.handleSignoutResponse()
        }
        else if requestName as String ==  RegistrationMethods.userProfile.description {
            self.tableViewProfile?.reloadData()
            
            if (user.settings?.leadTime?.characters.count)! > 0 {
                self.buttonLeadTime?.setTitle(user.settings?.leadTime, for: .normal)
            }
            
        }
        else if requestName as String ==  RegistrationMethods.updateUserProfile.description {
            
            UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kProfileAlertTitleText, comment: "") as NSString, message: NSLocalizedString(kProfileAlertUpdatedText, comment: "") as NSString)
            self.isCellEditable = false
            self.editBarButtonItem?.title = "Edit"
            self.tableViewProfile?.reloadData()
            self.buttonLeadTime?.isUserInteractionEnabled = self.isCellEditable!
            
        }
        else if requestName as String == RegistrationMethods.deactivate.description{
            self.handleDeleteAccountResponse()
        }
        
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        if error.code == 401 { //unauthorized
            UIUtilities.showAlertMessageWithActionHandler(kErrorTitle, message: error.localizedDescription, buttonTitle: kTitleOk, viewControllerUsed: self, action: {
                self.fdaSlideMenuController()?.navigateToHomeAfterUnauthorizedAccess()
            })
        }
        else {
            
            UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kErrorTitle, comment: "") as NSString, message: error.localizedDescription as NSString)
        }
        
    }
}
