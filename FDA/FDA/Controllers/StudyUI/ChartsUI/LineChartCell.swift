//
//  LineChartCell.swift
//  FDA
//
//  Created by Surender Rathore on 5/9/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class GraphChartTableViewCell: UITableViewCell {
    @IBOutlet weak var graphView: ORKGraphChartView!
}

class LineChartCell: GraphChartTableViewCell {
    @IBOutlet weak var labelTitle:UILabel!
    @IBOutlet weak var labelAxisValue:UILabel!
    @IBOutlet weak var buttonForward:UIButton!
    @IBOutlet weak var buttonBackward:UIButton!
    var currentChart:DashboardCharts!
    
    var hourOfDayDate = Date()
    var startDateOfWeek:Date?
    var endDateOfWeek:Date?

    var charActivity:Activity?
//    var plotPoints =
//        [
//            [
//                ORKValueRange(value: 10),
//                ORKValueRange(value: 20),
//                ORKValueRange(value: 25),
//                ORKValueRange(),
//                ORKValueRange(value: 30),
//                ORKValueRange(value: 40),
//                ORKValueRange(value: 40),
//                ORKValueRange(value: 8),
//                ORKValueRange(value: 40),
//                ORKValueRange(value: 7),
//                ORKValueRange(value: 40),
//                ORKValueRange(value: 9)
//        
//                ]
//    ]
   
    var plotPoints:Array<Array<ORKValueRange>> = []
    var xAxisTitles:Array! = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupLineChart(chart:DashboardCharts){
        
        currentChart = chart
        
        labelTitle.text = chart.displayName
        let array = chart.statList.map{$0.data}
        var points:Array<ORKValueRange> = []
        
        let timeRange = chart.dataSourceTimeRange!
        let chartTimeRange = ChartTimeRange(rawValue:timeRange)!
        let activity = Study.currentStudy?.activities.filter({$0.actvityId == chart.activityId}).last
        charActivity = activity
        
        switch chartTimeRange {
            
        case .days_of_month:
            
            //current date
            let stringDate = LineChartCell.monthFormatter.string(from: Date())
            labelAxisValue.text = stringDate
            self.buttonForward.isEnabled = false
            
            self.handleDaysOfMonthForDate(date: Date())
            
            
            
            
        case .days_of_week:
            
            print("start of Week \(Date().startOfWeek)")
            print("end of Week \(Date().endOfWeek)")
            
            startDateOfWeek = Date().startOfWeek
            endDateOfWeek = Date().endOfWeek
            //current year
            let stringStartDate = LineChartCell.formatter.string(from: startDateOfWeek!)
            let stringEndDate = LineChartCell.formatter.string(from: endDateOfWeek!)
            labelAxisValue.text = stringStartDate + " - " + stringEndDate
            self.buttonForward.isEnabled = false
            
            
            
            //check for back button to disable
            let result = hourOfDayDate.compare((self.charActivity?.startDate)!)
            if result == .orderedSame || result == .orderedAscending{
                self.buttonBackward.isEnabled = false
            }
            xAxisTitles = Calendar.current.veryShortWeekdaySymbols
            
            
            self.handleDaysOfWeekForStartDate(startDate: startDateOfWeek!, endDate: endDateOfWeek!)
            
            
            
            
           
            
            
            
        case .months_of_year:
            
            //current year
            let stringDate = LineChartCell.yearFormatter.string(from: Date())
            labelAxisValue.text = stringDate
            self.buttonForward.isEnabled = false
            
            //check for back button to disable
            let result = hourOfDayDate.compare((self.charActivity?.startDate)!)
            if result == .orderedSame || result == .orderedAscending{
                self.buttonBackward.isEnabled = false
            }


            
            
            xAxisTitles = Calendar.current.veryShortMonthSymbols
            
            self.handleMonthsOfYearForDate(date: Date())
            
           
            
            
            
        case .weeks_of_month:
            
            //current date
            let stringDate = LineChartCell.monthFormatter.string(from: Date())
            labelAxisValue.text = stringDate
            //self.buttonForward.isEnabled = false
            
            self.handleWeeksOfMonthForDate(date: Date())
        
            
        case .runs:
            break
        case .hours_of_day:
            
            
            
            
            
            //current date
            let stringDate = LineChartCell.formatter.string(from: Date())
            labelAxisValue.text = stringDate
            self.buttonForward.isEnabled = false
            
            self.handleHoursOfDayForDate(date: Date())
            
            
            
            
            
        default: break
            
        }
        
        
        
        (self.graphView as! ORKLineGraphChartView).dataSource = self
    }
    
    @IBAction func buttonForwardAction(_ sender:UIButton){
        
        let timeRange = currentChart.dataSourceTimeRange!
        let chartTimeRange = ChartTimeRange(rawValue:timeRange)!
        let calendar = Calendar.current
        
        switch chartTimeRange {
        case .days_of_month:
            
            
            self.buttonForward.isEnabled = true
            self.buttonBackward.isEnabled = true
            hourOfDayDate = calendar.date(byAdding: .month, value: 1, to: hourOfDayDate)!
            let stringDate = LineChartCell.monthFormatter.string(from: hourOfDayDate)
            labelAxisValue.text = stringDate
            
            
            self.handleDaysOfMonthForDate(date: hourOfDayDate)
            
            let result = hourOfDayDate.compare(Date())
            if result == .orderedSame || result == .orderedDescending{
                self.buttonForward.isEnabled = false
            }
            
            
        case .days_of_week:
            
            
            self.buttonForward.isEnabled = true
            self.buttonBackward.isEnabled = true
            
            startDateOfWeek = calendar.date(byAdding: .day, value: 7, to: startDateOfWeek!)
            endDateOfWeek = calendar.date(byAdding: .day, value: 7, to: endDateOfWeek!)
            let stringStartDate = LineChartCell.formatter.string(from: startDateOfWeek!)
            let stringEndDate = LineChartCell.formatter.string(from: endDateOfWeek!)
            labelAxisValue.text = stringStartDate + " - " + stringEndDate
            
            self.handleDaysOfWeekForStartDate(startDate: startDateOfWeek!, endDate: endDateOfWeek!)
            
            let result = endDateOfWeek?.compare(Date())
            if result == .orderedSame || result == .orderedDescending{
                self.buttonForward.isEnabled = false
            }
            
            
        case .months_of_year:
            
            self.buttonForward.isEnabled = true
            self.buttonBackward.isEnabled = true
            hourOfDayDate = calendar.date(byAdding: .year, value: 1, to: hourOfDayDate)!
            let stringDate = LineChartCell.yearFormatter.string(from: hourOfDayDate)
            labelAxisValue.text = stringDate
            
            self.handleMonthsOfYearForDate(date: hourOfDayDate)
            
            let result = hourOfDayDate.compare(Date())
            if result == .orderedSame || result == .orderedDescending{
                self.buttonForward.isEnabled = false
            }
            
        case .weeks_of_month:
            
            self.buttonForward.isEnabled = true
            self.buttonBackward.isEnabled = true
            hourOfDayDate = calendar.date(byAdding: .month, value: 1, to: hourOfDayDate)!
            let stringDate = LineChartCell.monthFormatter.string(from: hourOfDayDate)
            labelAxisValue.text = stringDate
            
            self.handleWeeksOfMonthForDate(date: hourOfDayDate)
            
        case .runs:
            break
        case .hours_of_day:
           
            
            
            
            self.buttonForward.isEnabled = true
            self.buttonBackward.isEnabled = true
            hourOfDayDate = calendar.date(byAdding: .day, value: 1, to: hourOfDayDate)!
            let stringDate = LineChartCell.formatter.string(from: hourOfDayDate)
            labelAxisValue.text = stringDate
            
            self.handleHoursOfDayForDate(date: hourOfDayDate)
            
            let result = hourOfDayDate.compare(Date())
            if result == .orderedSame || result == .orderedDescending{
                self.buttonForward.isEnabled = false
            }
            
            
            
        }
    }
    @IBAction func buttonBackwardAction(_ sender:UIButton){
        
        
        let timeRange = currentChart.dataSourceTimeRange!
        let chartTimeRange = ChartTimeRange(rawValue:timeRange)!
        
        switch chartTimeRange {
        case .days_of_month:
            
            
            self.buttonBackward.isEnabled = true
            self.buttonForward.isEnabled = true
            let calendar = Calendar.current
            
            hourOfDayDate = calendar.date(byAdding: .month, value: -1, to: hourOfDayDate)!
            let stringDate = LineChartCell.monthFormatter.string(from: hourOfDayDate)
            labelAxisValue.text = stringDate
            
            self.handleDaysOfMonthForDate(date: hourOfDayDate)
            
            let result = hourOfDayDate.compare((self.charActivity?.startDate)!)
            if result == .orderedSame || result == .orderedAscending{
                self.buttonBackward.isEnabled = false
            }
            
            
            
        case .days_of_week:
            
            let calendar = Calendar.current
            
            self.buttonBackward.isEnabled = true
            self.buttonForward.isEnabled = true
            
            
            startDateOfWeek = calendar.date(byAdding: .day, value: -7, to: startDateOfWeek!)
            endDateOfWeek = calendar.date(byAdding: .day, value: -7, to: endDateOfWeek!)
            let stringStartDate = LineChartCell.formatter.string(from: startDateOfWeek!)
            let stringEndDate = LineChartCell.formatter.string(from: endDateOfWeek!)
            labelAxisValue.text = stringStartDate + " - " + stringEndDate
            
            self.handleDaysOfWeekForStartDate(startDate: startDateOfWeek!, endDate: endDateOfWeek!)
            
            let result = startDateOfWeek?.compare((self.charActivity?.startDate)!)
            if result == .orderedSame || result == .orderedAscending{
                self.buttonBackward.isEnabled = false
            }
            
            
        case .months_of_year:
            
            self.buttonBackward.isEnabled = true
            self.buttonForward.isEnabled = true
            let calendar = Calendar.current
            
            hourOfDayDate = calendar.date(byAdding: .year, value: -1, to: hourOfDayDate)!
            let stringDate = LineChartCell.yearFormatter.string(from: hourOfDayDate)
            labelAxisValue.text = stringDate
            
            self.handleMonthsOfYearForDate(date: hourOfDayDate)
            
            let result = hourOfDayDate.compare((self.charActivity?.startDate)!)
            if result == .orderedSame || result == .orderedAscending{
                self.buttonBackward.isEnabled = false
            }
            
        case .weeks_of_month:
            
            self.buttonBackward.isEnabled = true
            self.buttonForward.isEnabled = true
            let calendar = Calendar.current
            
            hourOfDayDate = calendar.date(byAdding: .month, value: -1, to: hourOfDayDate)!
            let stringDate = LineChartCell.monthFormatter.string(from: hourOfDayDate)
            labelAxisValue.text = stringDate
            
            self.handleWeeksOfMonthForDate(date: hourOfDayDate)
            
        case .runs:
            break
        case .hours_of_day:
            
            
            
            self.buttonBackward.isEnabled = true
            self.buttonForward.isEnabled = true
            let calendar = Calendar.current
            
            hourOfDayDate = calendar.date(byAdding: .day, value: -1, to: hourOfDayDate)!
            let stringDate = LineChartCell.formatter.string(from: hourOfDayDate)
            labelAxisValue.text = stringDate
            
            self.handleHoursOfDayForDate(date: hourOfDayDate)
            
            let result = hourOfDayDate.compare((self.charActivity?.startDate)!)
            if result == .orderedSame || result == .orderedAscending{
                self.buttonBackward.isEnabled = false
            }
            
           
            
        }
    }
    
    //MARK: - Data Calculation
    
    func handleDaysOfMonthForDate(date:Date){
        
        let dataList:Array<DBStatisticsData> = currentChart.statList.filter({$0.startDate! >= date.startOfMonth() && $0.startDate! <= date.endOfMonth()})
        
        let array = dataList.map{$0.data}
        var points:Array<ORKValueRange> = []
        xAxisTitles = []
        plotPoints = []
        
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        print("days \(numDays)") // 31
        
        for i in 1...numDays{
            
            if array.count > i {
                let value = array[i]
                points.append(ORKValueRange(value:Double(value)))
            }
            else {
                points.append(ORKValueRange())
            }
            
            xAxisTitles.append(String(i))
        }
        plotPoints.append(points)
        
        self.graphView.reloadData()
        
    }
    
    func handleDaysOfWeekForStartDate(startDate:Date,endDate:Date){
        
        let dataList:Array<DBStatisticsData> = currentChart.statList.filter({$0.startDate! >= startDate && $0.startDate! <= endDate})
        
        let array = dataList.map{$0.data}
        var points:Array<ORKValueRange> = []
       
        plotPoints = []
        
        
        for i in 1...xAxisTitles.count{
            
            if array.count > i {
                let value = array[i]
                points.append(ORKValueRange(value:Double(value)))
            }
            else {
                points.append(ORKValueRange())
            }
        }
        plotPoints.append(points)
        
        self.graphView.reloadData()
    }
    
    func handleMonthsOfYearForDate(date:Date){
        
        let dataList:Array<DBStatisticsData> = currentChart.statList.filter({$0.startDate! >= date.startOfMonth() && $0.startDate! <= date.endOfMonth()})
        
        let array = dataList.map{$0.data}
        var points:Array<ORKValueRange> = []
       
        plotPoints = []
        
        for i in 1...xAxisTitles.count{
            
            if array.count > i {
                let value = array[i]
                points.append(ORKValueRange(value:Double(value)))
            }
            else {
                points.append(ORKValueRange())
            }
        }
        plotPoints.append(points)
        
        self.graphView.reloadData()
    }
    
    func handleWeeksOfMonthForDate(date:Date){
        
        let array = currentChart.statList.map{$0.data}
        var points:Array<ORKValueRange> = []
        xAxisTitles = []
        plotPoints = []
        
        let calendar = Calendar.current
        let range = calendar.range(of: .weekOfMonth, in: .month, for: date)!
        let numWeeks = range.count
        for i in 1...numWeeks{
            
            if array.count > i {
                let value = array[i]
                points.append(ORKValueRange(value:Double(value)))
            }
            else {
                points.append(ORKValueRange())
            }
            
            xAxisTitles.append("W" + String(i))
        }
        plotPoints.append(points)
        
        self.graphView.reloadData()
    }
    
    func handleHoursOfDayForDate(date:Date){
        
        
        let dataList:Array<DBStatisticsData> = currentChart.statList.filter({$0.startDate! >= date.startOfDay && $0.startDate! <= date.endOfDay!})
        
        let array = dataList.map{$0.data}
        var points:Array<ORKValueRange> = []
        xAxisTitles = []
        plotPoints = []
        
        
        if ((charActivity?.frequencyRuns?.count)! > 0){
            
            for i in 0...(charActivity?.frequencyRuns?.count)! - 1 {
                if array.count > i {
                    let value = array[i]
                    points.append(ORKValueRange(value:Double(value)))
                }
                else {
                    points.append(ORKValueRange())
                }
                
                
                //x axis title
                xAxisTitles.append(String(i+1))
                
            }
            
        }
        plotPoints.append(points)
        
        self.graphView.reloadData()
    }
    
    
    
    //MARK: - FORMATERS
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd YYYY"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
    private static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM YYYY"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()

}
extension LineChartCell:ORKValueRangeGraphChartViewDataSource{
    
    func numberOfPlots(in graphChartView: ORKGraphChartView) -> Int {
        return plotPoints.count
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, dataPointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKValueRange {
        return plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, numberOfDataPointsForPlotIndex plotIndex: Int) -> Int {
        return plotPoints[plotIndex].count
    }
    
    func maximumValue(for graphChartView: ORKGraphChartView) -> Double {
        return 70
    }
    
    func minimumValue(for graphChartView: ORKGraphChartView) -> Double {
        return 0
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
       
        return xAxisTitles[pointIndex] as? String
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, drawsPointIndicatorsForPlotIndex plotIndex: Int) -> Bool {
        if plotIndex == 1 {
            return false
        }
        return true
    }
}


extension Date {
    struct Gregorian {
        static let calendar = Calendar.current //Calendar(identifier: .curr)
    }
    var startOfWeek: Date? {
        return Gregorian.calendar.date(from: Gregorian.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
    var endOfWeek :Date? {
        return Gregorian.calendar.date(byAdding: .second, value: (7*86400)-1, to: startOfWeek!)
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)
    }
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}
