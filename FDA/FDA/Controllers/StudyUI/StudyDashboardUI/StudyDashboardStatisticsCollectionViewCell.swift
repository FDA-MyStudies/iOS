//
//  StudyDashboardStatisticsCollectionViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/30/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StudyDashboardStatisticsCollectionViewCell: UICollectionViewCell {
    
    //Statistics cell
    @IBOutlet var statisticsImage : UIImageView?
    @IBOutlet var labelStatisticsText : UILabel?
    @IBOutlet var labelStatisticsCount : UILabel?
    
    
    //Used to display Statistics cell data
    func displayStatisics(data : DashboardStatistics){
        
        labelStatisticsText?.text = data.title
        
//        if data["type"] as! String == "1"{
//            statisticsImage?.image = UIImage(named:"staticIcon1")
//            labelStatisticsText?.text = "TOTAL HOURS OF SLEEP"
//            labelStatisticsCount?.text = data["sleepCount"] as? String
//            
//        }else if data["type"] as! String == "2"{
//            statisticsImage?.image = UIImage(named:"staticIcon2")
//            labelStatisticsText?.text = "TOTAL HOURS OF ACTIVITY"
//            labelStatisticsCount?.text = data["activityCount"] as? String
//        }else{
//            statisticsImage?.image = UIImage(named:"staticIcon3")
//            labelStatisticsText?.text = "TOTAL HOURS OF STEPS"
//            labelStatisticsCount?.text = data["stepsCount"] as? String
//        }
    }
}
