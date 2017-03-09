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

let signupCellLastIndex = 3

let kProfileTitleText = "Profile"

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
        
       UserServices().getUserProfile(self as NMWebServiceDelegate)
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         self.setNavigationBarItem()
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
            self.editBarButtonItem?.tintColor = UIColor.lightGray
        }
        else{
            
            //self.isCellEditable =  false
            
            //self.editBarButtonItem?.title = "Edit"
            
            if self.editBarButtonItem?.tintColor == UIColor.lightGray {
                // it means no value have been changed
            }
            else{
                // it means value have been changed
                
                
                if self.validateAllFields() {
                     UserServices().updateUserProfile(self)
                }
                
                
                
               
                
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
                
                user.settings?.leadTime = title
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
        UIUtilities.showAlertMessageWithTwoActionsAndHandler("", errorMessage: "Are you sure? You want to Signout?", errorAlertActionTitle: "Ok", errorAlertActionTitle2: "Cancel", viewControllerUsed: self, action1: {
            
           // SignOut Action
            
            
        }, action2: {
            // Cancel action
        })

    }
    @IBAction func buttonActionDeleteAccount(_ sender: UIButton) {
         self.performSegue(withIdentifier: kConfirmationSegueIdentifier, sender: nil)
    }
    
    //MARK:Utility Methods
    /*
     Dismiss key board when clicked on Background
     */
    func dismissKeyboard(){
        self.view.endEditing(true)
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
            
         }else if (user.password?.characters.count)! < 8 && (user.password?.characters.count)! != 0  {
         self.showAlertMessages(textMessage: "Password should have minimum of 8 characters.")
         return false
         }
         
         if Utilities.isPasswordValid(text: (user.password)!) == false  {
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
            
          
            cell.isUserInteractionEnabled = self.isCellEditable!
            
            
            
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text!)
        switch textField.tag {
        case SignUpTableViewTags.FirstNameTag.rawValue:
            user.firstName! = textField.text!
            break
            
        case SignUpTableViewTags.LastName.rawValue:
            user.lastName! = textField.text!
            break
            
        case SignUpTableViewTags.EmailId.rawValue:
            user.emailId! = textField.text!
            break
            
        case SignUpTableViewTags.Password.rawValue:
            user.password! = textField.text!
            break
            
        default:
            print("No Matching data Found")
            break
        }
        
        self.editBarButtonItem?.tintColor = UIColor.black
    }
}

//MARK:UserService Response handler

extension ProfileViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString("Error", comment: "") as NSString, message: error.localizedDescription as NSString)
    }
}
