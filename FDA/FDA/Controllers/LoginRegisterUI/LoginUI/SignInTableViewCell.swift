//
//  SignInTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import Foundation

enum SignInTableViewTags : Int {
    case EmailId = 0
    case Password
}

class SignInTableViewCell: UITableViewCell {
    
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

    
    /**
     
     Populate cell data coming from dictionary
     
     @param data    dictionary data from from signinVC
     @param securedText    Used to check weather the text fiels is secured or not
    
    */
    func populateCellData(data : NSDictionary , securedText : Bool){
        
        textFieldValue?.isSecureTextEntry = false
        if securedText == true {
            textFieldValue?.isSecureTextEntry = true
        }
        labelType?.text = NSLocalizedString((data["helpText"] as? String)!, comment: "")
        textFieldValue?.placeholder = NSLocalizedString((data["placeHolder"] as? String)!, comment: "")
    }
}


