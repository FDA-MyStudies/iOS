//
//  StudyDashboardCollectionViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/27/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StudyDashboardCollectionViewCell: UICollectionViewCell {
    
    //Todays activities cell
    @IBOutlet var labelTitle : UILabel?
    @IBOutlet var labelCompletedCount : UILabel?
    @IBOutlet var labelCompletedSurveyTask : UILabel?
    @IBOutlet var labelPendingCount : UILabel?
    @IBOutlet var labelPendingSurveyTask : UILabel?
    
    //Statistics cell
    @IBOutlet var statisticsImage : UIImageView?
    @IBOutlet var labelStatisticsText : UILabel?
    @IBOutlet var labelStatisticsCount : UILabel?
    
    
    //Used to display activity cell data
    func displayTodaysActivities(data : NSDictionary){
    
        labelTitle?.text = data["title"] as? String
        labelCompletedCount?.text = data["completedCount"] as? String
        labelPendingCount?.text = data["pendingCount"] as? String
        
        labelCompletedSurveyTask?.text = String(format: "%@ Survey, %@ Task",data["completedSurvey"] as! String , data["completedTask"] as! String)
        
        labelPendingSurveyTask?.text = String(format: "%@ Survey, %@ Task",data["pendingSurvey"] as! String , data["pendingTask"] as! String)
    }
    
    //Used to display Statistics cell data
    func displayStatisics(data : NSDictionary){
        
        if data["type"] as! String == "1"{
            statisticsImage?.image = UIImage(named:"staticIcon1")
            labelStatisticsText?.text = "TOTAL HOURS OF SLEEP"
            labelStatisticsCount?.text = data["sleepCount"] as? String
            
        }else if data["type"] as! String == "2"{
            statisticsImage?.image = UIImage(named:"staticIcon2")
            labelStatisticsText?.text = "TOTAL HOURS OF ACTIVITY"
            labelStatisticsCount?.text = data["activityCount"] as? String
        }else{
            statisticsImage?.image = UIImage(named:"staticIcon3")
            labelStatisticsText?.text = "TOTAL HOURS OF STEPS"
            labelStatisticsCount?.text = data["stepsCount"] as? String
        }
    }
}
