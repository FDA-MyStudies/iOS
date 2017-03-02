//
//  SignInTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

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

}
