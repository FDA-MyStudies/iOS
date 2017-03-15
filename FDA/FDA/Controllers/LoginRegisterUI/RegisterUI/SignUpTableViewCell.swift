//
//  SignUpTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 2/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import Foundation

enum TextFieldTags : Int {
    case FirstNameTag = 0
    case LastName
    case EmailId
    case Password
    case ConfirmPassword
}

class SignUpTableViewCell: UITableViewCell {
    
    @IBOutlet var labelType : UILabel?
    @IBOutlet var textFieldValue : UITextField?
    
    @IBOutlet var buttonChangePassword : UIButton? // this button will be extensively used for profile screen
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //Populate cell data coming in dictionary
    func populateCellData(data : NSDictionary , securedText : Bool, keyboardType:UIKeyboardType?){
        
        textFieldValue?.isSecureTextEntry = false
        if securedText == true {
           textFieldValue?.isSecureTextEntry = true
        }
        labelType?.text = NSLocalizedString((data["helpText"] as? String)!, comment: "")
        textFieldValue?.placeholder = NSLocalizedString((data["placeHolder"] as? String)!, comment: "")
        
        if keyboardType == nil {
           textFieldValue?.keyboardType = .default
        } else {
            textFieldValue?.keyboardType = keyboardType!
        }
        
    }
    
    /* 
    Set cell data from User Object (for Profile Class)
     @param tag    is the cell index 
 */
    func setCellData(tag:TextFieldTags)  {
        let user = User.currentUser
        switch tag {
        case .FirstNameTag:
            if Utilities.isValidValue(someObject: user.firstName as AnyObject?) {
                self.textFieldValue?.text =  user.firstName
            }
            else{
                 self.textFieldValue?.text = ""
            }
        case .LastName:
            if Utilities.isValidValue(someObject: user.lastName as AnyObject?) {
                self.textFieldValue?.text =  user.lastName
            }
            else{
                self.textFieldValue?.text = ""
            }
        case .EmailId:
            if Utilities.isValidValue(someObject: user.emailId as AnyObject?) {
                self.textFieldValue?.text =  user.emailId
            }
            else{
                self.textFieldValue?.text = ""
            }
            
            
            
        case .Password:
            if Utilities.isValidValue(someObject: user.password as AnyObject?) {
                self.textFieldValue?.text =  user.password
            }
            else{
                self.textFieldValue?.text = ""
            }
            
        default: break
            
        }
        
        
    }
    
}



