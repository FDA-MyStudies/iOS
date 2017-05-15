//
//  StudyDashboardStatisticsCollectionViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/30/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

enum StatisticsType:String{
   case  Activity
   case  Sleep
   case  Weight
   case  Nutrition
   case  HeartRate
   case  BloodGlucose
   case  ActiveTask
   case  BabyKicks
   case  Mood
   case  Other
    
    var description:String{
        switch self {
        case  .Activity:
            return "Activity"
        case  .Sleep:
            return "Sleep"
        case  .Weight:
            return "Weight"
        case  .Nutrition:
            return "Nutrition"
        case  .HeartRate:
            return "Heart Rate"
        case  .BloodGlucose:
            return "Blood Glucose"
        case  .ActiveTask:
            return "Active Task"
        case  .BabyKicks:
            return "Baby Kicks"
        case  .Mood:
            return "Mood"
        case  .Other:
            return "Other"
        }
    }
}


class StudyDashboardStatisticsCollectionViewCell: UICollectionViewCell {
    
    //Statistics cell
    @IBOutlet var statisticsImage : UIImageView?
    @IBOutlet var labelStatisticsText : UILabel?
    @IBOutlet var labelStatisticsCount : UILabel?
    var stats:DashboardStatistics!
    
    
    func displayStatisics(data : DashboardStatistics,startDate:Date,endDate:Date?,tab:SelectedTab){
        
         stats = data
         labelStatisticsText?.text = data.displayName
        
        self.displayStateTypeImage()
        
        switch tab {
        case .Day:
            self.handleForDay(date: startDate)
        case .Week:
            self.handleForWeek(startDate: startDate, endDate: endDate!)
        case .Month:
            self.handleForMonth(date: startDate)
        }
    }
    
    func displayStateTypeImage(){
        
        if stats.statType == nil {
            statisticsImage?.image = UIImage(named: "activity")
        }
        else {
            let type = StatisticsType(rawValue:stats.statType!)!
            
            switch type {
            case  .Activity:
                statisticsImage?.image = UIImage(named: "stat_icn_active_task")
            case  .Sleep:
                statisticsImage?.image = UIImage(named: "stat_icn_sleep")
            case  .Weight:
                statisticsImage?.image = UIImage(named: "stat_icn_weight")
            case  .Nutrition:
                statisticsImage?.image = UIImage(named: "stat_icn_nutrition")
            case  .HeartRate:
                statisticsImage?.image = UIImage(named: "stat_icn_heart_rate")
            case  .BloodGlucose:
                statisticsImage?.image = UIImage(named: "stat_icn_glucose")
            case  .ActiveTask:
                statisticsImage?.image = UIImage(named: "stat_icn_active_task")
            case  .BabyKicks:
                statisticsImage?.image = UIImage(named: "stat_icn_baby_kicks")
            case  .Mood:
                statisticsImage?.image = UIImage(named: "stat_icn_mood")
            case  .Other:
                statisticsImage?.image = UIImage(named: "stat_icn_other")
            }
        }
        
       
    }
    
    /**
     
     Used to display Statistics cell
     
     @param data    Accepts the data from Dictionary
     
     */
    func displayStatisics(data : DashboardStatistics){
        
        labelStatisticsText?.text = data.displayName
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
    
    
    //MARK:- Data Handler
    func handleForDay(date:Date){
        
        let dataList:Array<DBStatisticsData> = stats.statList.filter({$0.startDate! >= date.startOfDay && $0.startDate! <= date.endOfDay!})
        
        let array = dataList.map{$0.data}
        
        if array.count == 0{
            labelStatisticsCount?.text = "NA"
        }
        else {
            self.calculate(array: array)
        }
    }
    func handleForWeek(startDate:Date,endDate:Date){
        
        let dataList:Array<DBStatisticsData> = stats.statList.filter({$0.startDate! >= startDate && $0.startDate! <= endDate})
        
        let array = dataList.map{$0.data}
        
        if array.count == 0{
            labelStatisticsCount?.text = "NA"
        }
        else {
            self.calculate(array: array)
        }
        
    }
    func handleForMonth(date:Date){
        
        let dataList:Array<DBStatisticsData> = stats.statList.filter({$0.startDate! >= date.startOfMonth() && $0.startDate! <= date.endOfMonth()})
        
        let array = dataList.map{$0.data}
        
        if array.count == 0{
            labelStatisticsCount?.text = "NA"
        }
        else {
           self.calculate(array: array)
        }
        
    }
    
    func calculate(array:Array<Float>){
        
        
       // let array = data.statList.map{$0.data}
        let data = self.stats!
        
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
    }

}
