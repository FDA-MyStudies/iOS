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
let signupCellLastIndex = 3

enum PickerButtonTags:Int {
    case leadTimeButtonTag = 1100
    case cancelButtonTag = 1101
    case doneButtonTag = 1102
}


enum ToggelSwitchTags:Int{
    case usePasscode = 4
    case useTouchId = 5
    case receivePush = 6
    case receiveStudyActivityReminders = 7
}

class ProfileViewController: UIViewController {
    
    var tableViewRowDetails : NSMutableArray?
    @IBOutlet var tableViewProfile : UITableView?
    @IBOutlet var tableViewFooterViewProfile : UIView?
    @IBOutlet var buttonLeadTime:UIButton?
    
    @IBOutlet var viewDatePickerContainer:UIView?
    @IBOutlet var datePicker:UIDatePicker?
    
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
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
//MARK:IBActions
    
    /*
     button action for LeadtimeButton, CancelButton & DoneButton
     @param sender  UIButton
     */
    
    
    @IBAction func buttonActionLeadTime(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5, options: [], animations:
            {
                //self.yourView.transform = CGAffineTransformMakeScale(1, 1)
                
                if self.tableTopConstraint?.constant ==  45.0 {
                    self.tableTopConstraint?.constant = (self.tableTopConstraint?.constant)! - 216.0
                }
                else{
                    self.tableTopConstraint?.constant = (self.tableTopConstraint?.constant)! + 216.0
                }
                
                
        }, completion: nil)
        
        // for done button action
        if PickerButtonTags(rawValue:sender.tag) == .doneButtonTag {
            
            
            let calender:Calendar? = Calendar.current
            let dateComponent = calender?.dateComponents([.hour, .minute], from: (self.datePicker?.date)!)
            
            
            // title =  hour : minute,  if hour < 10, hour =  "0" + hour ,if minute < 10, minute =  "0" + minute
            
            let title:String! = (((dateComponent?.hour)! as Int) < 10 ? "0\((dateComponent?.hour)! as Int)" : "\((dateComponent?.hour)! as Int)") + ":"
                
                + (((dateComponent?.minute)! as Int) < 10 ? "0\((dateComponent?.minute)! as Int)" : "\((dateComponent?.minute)! as Int)")
            
            self.buttonLeadTime?.setTitle(title!, for: .normal)
            
            user.settings?.leadTime = title
            
        }
        
    }
    
    @IBAction func buttonActionSignOut(_ sender: UIButton) {
        
    }
    @IBAction func buttonActionDeleteAccount(_ sender: UIButton) {
        
    }
    
//MARK:Utility Methods
    /*
     Dismiss key board when clicked on Background
     */
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func setInitialDate()  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        datePicker?.datePickerMode = .countDownTimer
        datePicker?.date = dateFormatter.date(from: "00:00")!
        
        if user.settings != nil &&  Utilities.isValidValue(someObject: user.settings?.leadTime as AnyObject?) {
            self.buttonLeadTime?.setTitle(user.settings?.leadTime, for: .normal)
        }
        else{
             Logger.sharedInstance.debug("settings/LeadTime is null")
        }
        
    }
    
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
        default: break
            
        }
        }
        else{
            Logger.sharedInstance.debug("settings is null")
        }
        
        
    }
    
    /*
     Validation of Profile data
     */
    func validateAllFields() -> Bool{
        if user.firstName == "" {
            self.showAlertMessages(textMessage: "Please enter your first name.")
            return false
        }else if user.lastName == ""{
            self.showAlertMessages(textMessage: "Please enter your last name.")
            return false
        }else if user.emailId == "" {
            self.showAlertMessages(textMessage: "Please enter your email address.")
            return false
        }else if !(Utilities.isValidEmail(testStr: user.emailId!)){
            self.showAlertMessages(textMessage: "Please enter valid email address.")
            return false
        }else if user.password == ""{
            self.showAlertMessages(textMessage: "Please enter your password.")
            return false
        }else if user.confirmPassword == ""{
            self.showAlertMessages(textMessage: "Please enter confirm password.")
            return false
        }else if (user.password != user.confirmPassword){
            self.showAlertMessages(textMessage: "New password and confirm password does not match.")
            return false
            
        }else if ((user.password?.characters.count)! < 8 && (user.password?.characters.count)! != 0) || ((user.confirmPassword?.characters.count)! < 8 && user.confirmPassword?.characters.count != 0) {
            self.showAlertMessages(textMessage: "Password should have minimum of 8 characters.")
            return false
        }
        
        if Utilities.isPasswordValid(text: (user.password)!) == false || Utilities.isPasswordValid(text: (user.confirmPassword)!) == false {
            self.showAlertMessages(textMessage: "Password should have minimum of 1 special character, 1 upper case letter and 1 numeric number.")
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
            
            var isSecuredEntry : Bool = false
            
            if indexPath.row == SignUpTableViewTags.Password.rawValue ||
                indexPath.row == SignUpTableViewTags.ConfirmPassword.rawValue{
                isSecuredEntry = true
            }
            
            cell.textFieldValue?.tag = indexPath.row
            cell.textFieldValue?.delegate = self
            
            cell.populateCellData(data: tableViewData, securedText: isSecuredEntry)
            
            cell.backgroundColor = UIColor.clear
            
            
            cell.setCellData(tag: SignUpTableViewTags(rawValue: indexPath.row)!)
            
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
           
            cell.switchToggle?.addTarget(self, action: #selector(ProfileViewController.toggleValueChanged), for: .valueChanged)
            
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
            user.confirmPassword = textField.text
            break
            
        default:
            print("No Matching data Found")
            break
        }
    }
}


