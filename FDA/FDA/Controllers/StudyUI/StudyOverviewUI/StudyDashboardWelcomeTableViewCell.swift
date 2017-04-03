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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //Used to display First cell data
    func displayFirstCelldata(data : NSDictionary){
        //labelName?.text = String(format:"Welcome back %@,",data["name"] as! String)
        labelStatus?.text = data["status"] as? String
    }
    
}



