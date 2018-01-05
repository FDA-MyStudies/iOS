//
//  LeftMenuCell.swift
//  FDA
//
//  Created by Surender Rathore on 3/8/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class LeftMenuCell: UITableViewCell {

    @IBOutlet var menuIcon:UIImageView?
    @IBOutlet var labelTitle:UILabel?
    @IBOutlet var labelSubTitle:UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
