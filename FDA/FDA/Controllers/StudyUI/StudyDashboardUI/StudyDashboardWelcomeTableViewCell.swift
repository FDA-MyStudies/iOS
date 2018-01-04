//
//  StudyDashboardTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/27/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StudyDashboardWelcomeTableViewCell: UITableViewCell {
    
    //First cell Outlets
    @IBOutlet var labelName : UILabel?
    @IBOutlet var labelStatus : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    /**
     Used to display Welcome cell
     @param data    Accepts data from Dictionary
     */
    func displayFirstCelldata(data : NSDictionary){
        labelStatus?.text = data["status"] as? String
    }
    
}



