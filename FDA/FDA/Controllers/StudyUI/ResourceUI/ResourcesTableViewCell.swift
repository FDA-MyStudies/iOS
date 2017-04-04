//
//  ResourcesTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/24/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class ResourcesTableViewCell: UITableViewCell {

    @IBOutlet var labelTitle : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func populateCellData(data : String){
        labelTitle?.text = data
    
    }
    
}
