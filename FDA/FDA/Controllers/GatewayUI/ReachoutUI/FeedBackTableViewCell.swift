//
//  FeedBackTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/22/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class FeedBackTableViewCell: UITableViewCell {

    @IBOutlet var labelHeadingText : UILabel?
    @IBOutlet var textViewFeedbackText : UITextView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
