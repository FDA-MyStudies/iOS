//
//  LeftMenuResourceTableViewCell.swift
//  FDA
//
//  Created by Arun Kumar on 3/10/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class LeftMenuResourceTableViewCell: UITableViewCell {

    @IBOutlet var menuIcon:UIImageView?
    @IBOutlet var labelTitle:UILabel?
    @IBOutlet var labelCounter:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    /**
     
     Used to populate Cell Data
     
     @param data    contains dictionary of type string(key and value)
     
     */
    func populateCellData(data:Dictionary<String,String>){
        menuIcon?.image = UIImage.init(named: data["iconName"]!)
        labelTitle?.text = data["menuTitle"]!
    }
}
