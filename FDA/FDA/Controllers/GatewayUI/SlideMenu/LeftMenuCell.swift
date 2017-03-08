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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func populateCellData(data:Dictionary<String,String>){
        
        menuIcon?.image = UIImage.init(named: data["iconName"]!)
        labelTitle?.text = data["menuTitle"]!
    }
}
