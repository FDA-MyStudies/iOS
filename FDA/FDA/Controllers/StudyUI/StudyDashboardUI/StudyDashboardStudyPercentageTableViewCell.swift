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
        
        
        let currentUser = User.currentUser
        let study = Study.currentStudy
        
        if let userStudyStatus = currentUser.participatedStudies.filter({$0.studyId == study?.studyId}).first {
            
            
            //update completion %
            self.labelStudyCompletion?.text = String(userStudyStatus.completion) + "%"
            self.labelStudyAdherence?.text = String(userStudyStatus.adherence)  + "%"
            //self.progressBarCompletion?.progress = Float(userStudyStatus.completion)/100
            //self.progressBarAdherence?.progress = Float(userStudyStatus.adherence)/100
            
           
        }
        else {
            self.labelStudyCompletion?.text = "0" + "%"
            self.labelStudyAdherence?.text = "0"  + "%"
        }
        
       
    }
    
}
