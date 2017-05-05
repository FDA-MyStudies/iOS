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
    
    
    /**
     
     Used to display Statistics cell
     
     @param data    Accepts the data from Dictionary
     
     */
    func displayStatisics(data : DashboardStatistics){
        
        labelStatisticsText?.text = data.title
        let array = data.statList.map{$0.data}
        
        if  data.calculation! == StatisticsFormula.Maximum.rawValue {
             let max = array.max()
            labelStatisticsCount?.text = String(describing: max)
        }
        if  data.calculation! == StatisticsFormula.Minimum.rawValue {
             let min = array.min()
            labelStatisticsCount?.text = String(describing: min)
        }
        if  data.calculation! == StatisticsFormula.Average.rawValue {
            let sumArray = array.reduce(0, +)
            let avgArrayValue = sumArray / Float(array.count)
            labelStatisticsCount?.text = String(describing: avgArrayValue)
        }
        if  data.calculation! == StatisticsFormula.Summation.rawValue {
            let sumArray = array.reduce(0, +)
            labelStatisticsCount?.text = String(describing: sumArray)
        }
      //  let max = array.max()
        
      //  let min = array.min()
        
      //  let sumArray = array.reduce(0, +)
      //  let avgArrayValue = sumArray / Float(array.count)
        
      //  let sumArray1 = array.reduce(0, +)
        
      //  print("sum:\(sumArray1) min:\(min) avg:\(avgArrayValue) max: \(max)")
        
        
//        let (position, min) = reduce(enumerate(array), (-1, Int.max)) {
//            $0.1 < $1.1 ? $0 : $1
//        }

    }
}
