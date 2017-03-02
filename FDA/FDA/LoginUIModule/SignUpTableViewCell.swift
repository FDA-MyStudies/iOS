//
//  SignUpTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 2/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import Foundation
import IQKeyboardManagerSwift

enum TableViewTags : Int {
    case FirstNameTag = 0
    case LastName
    case EmailId
    case Password
    case ConfirmPassword
}

class SignUpTableViewCell: UITableViewCell {
    
    @IBOutlet var labelType : UILabel?
    @IBOutlet var textFieldValue : UITextField?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //Populate cell data coming in dictionary
    func populateCellData(data : NSDictionary , securedText : Bool){
        
        textFieldValue?.isSecureTextEntry = false
        if securedText == true {
           textFieldValue?.isSecureTextEntry = true
        }
        labelType?.text = NSLocalizedString((data["helpText"] as? String)!, comment: "")
        textFieldValue?.placeholder = NSLocalizedString((data["placeHolder"] as? String)!, comment: "")
    }
}



