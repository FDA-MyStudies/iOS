//
//  StudyDashboardCollectionViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/27/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StudyDashboardActivityCollectionViewCell: UICollectionViewCell {
    
    //Todays activities cell
    @IBOutlet var labelTitle : UILabel?
    @IBOutlet var labelCompletedCount : UILabel?
    @IBOutlet var labelCompletedSurveyTask : UILabel?
    @IBOutlet var labelPendingCount : UILabel?
    @IBOutlet var labelPendingSurveyTask : UILabel?
    

    //Used to display activity cell data
    func displayTodaysActivities(data : NSDictionary){
        labelTitle?.text = data["title"] as? String
        labelCompletedCount?.text = data["completedCount"] as? String
        labelPendingCount?.text = data["pendingCount"] as? String
        
        labelCompletedSurveyTask?.text = String(format: "%@ Survey, %@ Task",data["completedSurvey"] as! String , data["completedTask"] as! String)
        
        labelPendingSurveyTask?.text = String(format: "%@ Survey, %@ Task",data["pendingSurvey"] as! String , data["pendingTask"] as! String)
    }
    

}
