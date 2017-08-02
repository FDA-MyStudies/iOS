//
//  FilterListTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 7/26/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class FilterListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name : UILabel?
    @IBOutlet weak var imageSelected : UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func populateCellWith(filterValue: FilterValues){
        self.name?.text = filterValue.title
        
        
        if filterValue.isSelected{
            self.imageSelected?.image = UIImage(named:"checked")
        }else{
            self.imageSelected?.image = UIImage(named:"notChecked")
        }
    }
}
