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
    
    @IBOutlet var studyPercentagePie : KDCircularProgress?
    @IBOutlet var completedPercentagePie : KDCircularProgress?
    
    let blueColor = UIColor.init(red: 56/255, green: 124/255, blue: 186/255, alpha: 1)
    let greyColor = UIColor.init(red: 216/255, green: 227/255, blue: 230/255, alpha: 1)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    /**
     
     Used to display Study Percentage cell
     
     @param data    Accepts the data from Dictionary

     */
    func displayThirdCellData(data : NSDictionary){
        let currentUser = User.currentUser
        let study = Study.currentStudy
        
        studyPercentagePie?.startAngle = -90
        studyPercentagePie?.progressThickness = 0.3
        studyPercentagePie?.trackThickness = 0.3
        studyPercentagePie?.trackColor = greyColor
        studyPercentagePie?.clockwise = true
        studyPercentagePie?.gradientRotateSpeed = 2
        studyPercentagePie?.roundedCorners = false
        studyPercentagePie?.glowMode = .forward
        studyPercentagePie?.glowAmount = 0.1
        studyPercentagePie?.set(colors: blueColor)
        //studyPercentagePie?.angle = 99/0.27777778
        
        completedPercentagePie?.startAngle = -90
        completedPercentagePie?.progressThickness = 0.3
        completedPercentagePie?.trackThickness = 0.3
        completedPercentagePie?.trackColor = greyColor
        completedPercentagePie?.clockwise = true
        completedPercentagePie?.gradientRotateSpeed = 2
        completedPercentagePie?.roundedCorners = false
        completedPercentagePie?.glowMode = .forward
        completedPercentagePie?.glowAmount = 0.1
        completedPercentagePie?.set(colors: blueColor)
        //completedPercentagePie?.angle = 99/0.27777778
        
        if let userStudyStatus = currentUser.participatedStudies.filter({$0.studyId == study?.studyId}).first {
            //update completion %
            self.labelStudyCompletion?.text = String(userStudyStatus.adherence)// + "%"
            self.labelStudyAdherence?.text = String(userStudyStatus.completion) // + "%"
            //self.progressBarCompletion?.progress = Float(userStudyStatus.completion)/100
            //self.progressBarAdherence?.progress = Float(userStudyStatus.adherence)/100
            
            studyPercentagePie?.angle = Double(userStudyStatus.completion)/0.27777778
            completedPercentagePie?.angle = Double(userStudyStatus.adherence)/0.27777778
            
        }
        else {
            self.labelStudyCompletion?.text = "0" //+ "%"
            self.labelStudyAdherence?.text = "0"  //+ "%"
            
            studyPercentagePie?.angle = 0//Double(userStudyStatus.adherence)/0.23777778
            completedPercentagePie?.angle = 0//Double(userStudyStatus.completion)/0.23777778
        }
    }
}



