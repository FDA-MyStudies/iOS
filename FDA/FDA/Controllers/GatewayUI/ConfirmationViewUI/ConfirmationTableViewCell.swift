//
//  ConfirmationTableViewCell.swift
//  FDA
//
//  Created by Arun Kumar on 3/8/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class ConfirmationTableViewCell: UITableViewCell {

     @IBOutlet var labelTitle:UILabel?
     @IBOutlet var labelTitleDescription:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
