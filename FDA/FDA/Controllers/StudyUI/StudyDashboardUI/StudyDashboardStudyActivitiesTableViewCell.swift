//
//  StudyDashboardStudyActivitiesTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/30/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StudyDashboardStudyActivitiesTableViewCell: UITableViewCell {
    
    //Second cell Outlets
    @IBOutlet var labelCompletedNumber : UILabel?
    @IBOutlet var labelSurveyNumber : UILabel?
    @IBOutlet var labelTaskNumber : UILabel?
    @IBOutlet var labelSurveyList : UILabel?
    @IBOutlet var labelTaskList : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    /**
     Used to display Study Activities cell
     @param data    Accepts data from Dictionary
     */
    func displaySecondCelldata(data : NSDictionary){
        labelCompletedNumber?.text = String(format:"%@/10",data["completedNumber"] as! String)
        labelSurveyNumber?.text = data["surveyNumber"] as? String
        labelTaskNumber?.text = data["taskNumber"] as? String
        
        labelSurveyList?.text = String(format:"%@ Completed, %@ Pending, %@ Missed",data["surveyCompleted"] as! String , data["surveyPending"] as! String , data["surveyMissed"] as! String)
        
        labelTaskList?.text = String(format:"%@ Completed, %@ Pending, %@ Missed",data["taskCompleted"] as! String , data["taskPending"] as! String , data["taskMissed"] as! String)
    }
}



