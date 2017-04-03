//
//  StudyDashboardStudyPercentageTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/30/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StudyDashboardStudyPercentageTableViewCell: UITableViewCell {

    //Third cell Outlets
    @IBOutlet var labelStudyCompletion : UILabel?
    @IBOutlet var labelStudyAdherence : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //Used to display Third cell data
    func displayThirdCellData(data : NSDictionary){
        labelStudyCompletion?.text = String(format: "%@%%", (data["studyCompletion"] as? String)!)
        labelStudyAdherence?.text = String(format: "%@%%", (data["studyAdherence"] as? String)!)
    }
    
}
