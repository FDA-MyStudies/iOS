//
//  StudyDashboardTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/27/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StudyDashboardTableViewCell: UITableViewCell {

    //First cell Outlets
    @IBOutlet var labelName : UILabel?
    @IBOutlet var labelStatus : UILabel?
    
    //Second cell Outlets
    @IBOutlet var labelCompletedNumber : UILabel?
    @IBOutlet var labelSurveyNumber : UILabel?
    @IBOutlet var labelTaskNumber : UILabel?
    @IBOutlet var labelSurveyList : UILabel?
    @IBOutlet var labelTaskList : UILabel?
    
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
    
    //Used to display First cell data
    func displayFirstCelldata(data : NSDictionary){
        labelName?.text = String(format:"Welcome back %@,",data["name"] as! String)
        labelStatus?.text = data["status"] as? String
    }
    
    //Used to display Second cell data
    func displaySecondCelldata(data : NSDictionary){
        labelCompletedNumber?.text = String(format:"%@/10",data["completedNumber"] as! String)
        labelSurveyNumber?.text = data["surveyNumber"] as? String
        labelTaskNumber?.text = data["taskNumber"] as? String
    
        labelSurveyList?.text = String(format:"%@ Completed, %@ Pending, %@ Missed",data["surveyCompleted"] as! String , data["surveyPending"] as! String , data["surveyMissed"] as! String)
        
        labelTaskList?.text = String(format:"%@ Completed, %@ Pending, %@ Missed",data["taskCompleted"] as! String , data["taskPending"] as! String , data["taskMissed"] as! String)
    }
    
    //Used to display Third cell data
    func displayThirdCellData(data : NSDictionary){
        labelStudyCompletion?.text = String(format: "%@%%", (data["studyCompletion"] as? String)!)
        labelStudyAdherence?.text = String(format: "%@%%", (data["studyAdherence"] as? String)!)
    }
}



