//
//  StudyDashboardStatisticsTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit



enum SelectedTab:String{
    case Day
    case Week
    case Month
}
class StudyDashboardStatisticsTableViewCell: UITableViewCell {

    
   
    
    //Fifth cell Outlets
    @IBOutlet var statisticsCollectionView: UICollectionView?
    @IBOutlet var buttonDay : UIButton?
    @IBOutlet var buttonWeek : UIButton?
    @IBOutlet var buttonMonth : UIButton?
    @IBOutlet var buttonForward : UIButton?
    @IBOutlet var buttonBackward : UIButton?
    @IBOutlet var labelDateValue : UILabel?
    @IBOutlet var labelNoData : UILabel?
    
    var statisticsArrayData : NSMutableArray?
    var selectedTab:SelectedTab = .Day
    var todaysDate = Date()
    var startDateOfWeek:Date?
    var endDateOfWeek:Date?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //Configure the view for the selected state
        
    }
    
    func displayData(){
        
        let stringDate = StudyDashboardStatisticsTableViewCell.formatter.string(from: todaysDate)
        self.labelDateValue?.text = stringDate
        self.buttonForward?.isEnabled = false
        
        if StudyDashboard.instance.statistics.count == 0  {
            labelNoData?.isHidden = false
            self.statisticsCollectionView?.isHidden = true
        }
    }
    
//MARK:- Button action
    
    /**
     
     Day, Week and Month Button clicked
     
     @param sender    Accepts Any object

     */
    @IBAction func dayWeekMonthButtonAction(_ sender: AnyObject){
        
        if sender.tag == 11{
            //Day clicked
            buttonDay?.setTitle(kDaySpaces, for: UIControlState.normal)
            buttonWeek?.setTitle(kWeek, for: UIControlState.normal)
            buttonMonth?.setTitle(kMonth, for: UIControlState.normal)
            
            buttonDay?.setTitleColor(UIColor.white, for: UIControlState.normal)
            buttonWeek?.setTitleColor(kGreyColor, for: UIControlState.normal)
            buttonMonth?.setTitleColor(kGreyColor, for: UIControlState.normal)
            
            buttonDay?.backgroundColor = kDarkBlueColor
            buttonWeek?.backgroundColor = UIColor.white
            buttonMonth?.backgroundColor = UIColor.white
            
            self.selectedTab = .Day
             todaysDate = Date()
            
            let stringDate = StudyDashboardStatisticsTableViewCell.formatter.string(from: Date())
            self.labelDateValue?.text = stringDate
            self.buttonForward?.isEnabled = false
            
        }else if sender.tag == 12{
            //Week clicked
            buttonWeek?.setTitle(kWeekSpaces, for: UIControlState.normal)
            buttonDay?.setTitle(kDay, for: UIControlState.normal)
            buttonMonth?.setTitle(kMonth, for: UIControlState.normal)
            
            buttonWeek?.setTitleColor(UIColor.white, for: UIControlState.normal)
            buttonDay?.setTitleColor(kGreyColor, for: UIControlState.normal)
            buttonMonth?.setTitleColor(kGreyColor, for: UIControlState.normal)
            
            buttonWeek?.backgroundColor = kDarkBlueColor
            buttonDay?.backgroundColor = UIColor.white
            buttonMonth?.backgroundColor = UIColor.white
            
            self.selectedTab = .Week
            todaysDate = Date()
            
            
            
            startDateOfWeek = todaysDate.startOfWeek
            endDateOfWeek = todaysDate.endOfWeek
            //current year
            let stringStartDate = StudyDashboardStatisticsTableViewCell.formatter.string(from: startDateOfWeek!)
            let stringEndDate = StudyDashboardStatisticsTableViewCell.formatter.string(from: endDateOfWeek!)
            labelDateValue?.text = stringStartDate + " - " + stringEndDate
            self.buttonForward?.isEnabled = false

            
        }else if sender.tag == 13{
            
          
            
            //Months clicked
            buttonMonth?.setTitle(kMonthSpaces, for: UIControlState.normal)
            buttonDay?.setTitle(kDay, for: UIControlState.normal)
            buttonWeek?.setTitle(kWeek, for: UIControlState.normal)
            
            buttonMonth?.setTitleColor(UIColor.white, for: UIControlState.normal)
            buttonDay?.setTitleColor(kGreyColor, for: UIControlState.normal)
            buttonWeek?.setTitleColor(kGreyColor, for: UIControlState.normal)
            
            buttonMonth?.backgroundColor = kDarkBlueColor
            buttonDay?.backgroundColor = UIColor.white
            buttonWeek?.backgroundColor = UIColor.white
            
            self.selectedTab = .Month
            todaysDate = Date()
            
            let stringDate = StudyDashboardStatisticsTableViewCell.monthFormatter.string(from: todaysDate)
            self.labelDateValue?.text = stringDate
            self.buttonForward?.isEnabled = false
        }
        
        self.statisticsCollectionView?.reloadData()
    }
    
    @IBAction func buttonForwardClicked(_ sender:UIButton){
        
        let calendar = Calendar.current
        
        switch self.selectedTab {
        case .Day:
            
            self.buttonForward?.isEnabled = true
            self.buttonBackward?.isEnabled = true
            todaysDate = calendar.date(byAdding: .day, value: 1, to: todaysDate)!
            let stringDate = StudyDashboardStatisticsTableViewCell.formatter.string(from: todaysDate)
            labelDateValue?.text = stringDate
            
            
            
            let result = todaysDate.compare(Date())
            if result == .orderedSame || result == .orderedDescending{
                self.buttonForward?.isEnabled = false
            }
            
        case .Week:
            
            self.buttonForward?.isEnabled = true
            self.buttonBackward?.isEnabled = true
            
            startDateOfWeek = calendar.date(byAdding: .day, value: 7, to: startDateOfWeek!)
            endDateOfWeek = calendar.date(byAdding: .day, value: 7, to: endDateOfWeek!)
            let stringStartDate = StudyDashboardStatisticsTableViewCell.formatter.string(from: startDateOfWeek!)
            let stringEndDate = StudyDashboardStatisticsTableViewCell.formatter.string(from: endDateOfWeek!)
            labelDateValue?.text = stringStartDate + " - " + stringEndDate
            
            let result = todaysDate.compare(Date())
            if result == .orderedSame || result == .orderedDescending{
                self.buttonForward?.isEnabled = false
            }

            
        case .Month:
            
            self.buttonForward?.isEnabled = true
            self.buttonBackward?.isEnabled = true
            todaysDate = calendar.date(byAdding: .month, value: 1, to: todaysDate)!
            let stringDate = StudyDashboardStatisticsTableViewCell.monthFormatter.string(from: todaysDate)
            labelDateValue?.text = stringDate
            
            
            
            let result = todaysDate.compare(Date())
            if result == .orderedSame || result == .orderedDescending{
                self.buttonForward?.isEnabled = false
            }
        
        }
    }
    @IBAction func buttonBackwardClicked(_ sender:UIButton){
        
        let calendar = Calendar.current
        
        switch self.selectedTab {
        case .Day:
            
            self.buttonForward?.isEnabled = true
            self.buttonBackward?.isEnabled = true
            todaysDate = calendar.date(byAdding: .day, value: -1, to: todaysDate)!
            let stringDate = StudyDashboardStatisticsTableViewCell.formatter.string(from: todaysDate)
            labelDateValue?.text = stringDate
            
            
            
//            let result = todaysDate.compare(Date())
//            if result == .orderedSame || result == .orderedDescending{
//                self.buttonForward?.isEnabled = false
//            }
            
        case .Week:
            
            self.buttonForward?.isEnabled = true
            self.buttonBackward?.isEnabled = true
            
            startDateOfWeek = calendar.date(byAdding: .day, value: -7, to: startDateOfWeek!)
            endDateOfWeek = calendar.date(byAdding: .day, value: -7, to: endDateOfWeek!)
            let stringStartDate = StudyDashboardStatisticsTableViewCell.formatter.string(from: startDateOfWeek!)
            let stringEndDate = StudyDashboardStatisticsTableViewCell.formatter.string(from: endDateOfWeek!)
            labelDateValue?.text = stringStartDate + " - " + stringEndDate
            
        case .Month:
            
            self.buttonForward?.isEnabled = true
            self.buttonBackward?.isEnabled = true
            todaysDate = calendar.date(byAdding: .month, value: -1, to: todaysDate)!
            let stringDate = StudyDashboardStatisticsTableViewCell.monthFormatter.string(from: todaysDate)
            labelDateValue?.text = stringDate
            
            
            
//            let result = todaysDate.compare(Date())
//            if result == .orderedSame || result == .orderedDescending{
//                self.buttonForward?.isEnabled = false
//            }
            
        }
        
        self.statisticsCollectionView?.reloadData()
    }
    
    
        
    //MARK: - FORMATERS
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM YYYY"
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

//MARK:- Collection delegates
extension StudyDashboardStatisticsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StudyDashboard.instance.statistics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let activityCellData = statisticsArrayData?.object(at: indexPath.row) as! NSDictionary
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kStatisticsCollectionViewCell, for: indexPath) as! StudyDashboardStatisticsCollectionViewCell
        let stats = StudyDashboard.instance.statistics[indexPath.row]
        //cell.displayStatisics(data: stats)
        if selectedTab == .Week {
           cell.displayStatisics(data: stats, startDate: startDateOfWeek!, endDate: endDateOfWeek, tab: selectedTab)
        }
        else {
            cell.displayStatisics(data: stats, startDate: todaysDate, endDate: nil, tab: selectedTab)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
    }
}


