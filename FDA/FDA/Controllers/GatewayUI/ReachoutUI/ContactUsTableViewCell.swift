//
//  ContactUsTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/22/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

enum ContactTextFieldTags : Int {
    case FirstName = 0
    case Email
    case Subject
}

class ContactUsTableViewCell: UITableViewCell {

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

    
    /*
     Populate cell data coming in dictionary
     */
    func populateCellData(data : NSDictionary, keyboardType:UIKeyboardType?){
        
        labelType?.text = NSLocalizedString((data["helpText"] as? String)!, comment: "")
        textFieldValue?.placeholder = NSLocalizedString((data["placeHolder"] as? String)!, comment: "")
        
//        if keyboardType == nil {
//            textFieldValue?.keyboardType = .default
//        } else {
//            textFieldValue?.keyboardType = keyboardType!
//        }
        
        textFieldValue?.keyboardType = keyboardType!
    }
    
    
}
