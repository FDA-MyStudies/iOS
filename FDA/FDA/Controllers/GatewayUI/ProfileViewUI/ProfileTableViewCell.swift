//
//  ProfileTableViewCell.swift
//  FDA
//
//  Created by Arun Kumar on 3/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit


let kLabelText = "LabelName"
let kToggleValue = "ToggleValue"

enum ProfileTableViewCellType:Int {
    case usePasscode = 3
    case useTouchId = 4
    case receivePushNotifications = 5
    case receiveStudyActivityReminder = 6
}


class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet var labelName : UILabel?
    @IBOutlet var switchToggle : UISwitch?
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//Mark:IBActions
    @IBAction func switchValueChanged(sender: UISwitch) {
        
    }
    
//Mark:Cell Utility Methods
    
    /*
     used to set default values
     @param dict    holds the dictionary of default values
     */
    func setCellData(dict : NSDictionary ){
        
        self.labelName?.text = NSLocalizedString((dict[kLabelText] as? String)!, comment: "")
        
    }
    /*
     used to set toggle value for switch
     @param toggleValue    switch Value
     */
    func setToggleValue(indexValue:Int)  {
        
        let user = User.currentUser
        switch ProfileTableViewCellType(rawValue:indexValue)! as ProfileTableViewCellType{
        case .usePasscode:
            if Utilities.isValidValue(someObject: user.settings?.passcode as AnyObject?){
                self.switchToggle?.isOn = (user.settings?.passcode)!
                
            }
            else{
                 self.switchToggle?.isOn =  false
                
            }
        case .useTouchId:
            if Utilities.isValidValue(someObject: user.settings?.touchId as AnyObject?){
                self.switchToggle?.isOn = (user.settings?.touchId)!
            }
            else{
                self.switchToggle?.isOn =  false
            }
        case .receivePushNotifications:
            if Utilities.isValidValue(someObject: user.settings?.remoteNotifications as AnyObject?){
                self.switchToggle?.isOn = (user.settings?.remoteNotifications)!
            }
            else{
                self.switchToggle?.isOn =  false
            }
        case .receiveStudyActivityReminder:
            if Utilities.isValidValue(someObject: user.settings?.localNotifications as AnyObject?){
                self.switchToggle?.isOn = (user.settings?.localNotifications)!
            }
            else{
                self.switchToggle?.isOn =  false
            }
       
            
        }
        

    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
