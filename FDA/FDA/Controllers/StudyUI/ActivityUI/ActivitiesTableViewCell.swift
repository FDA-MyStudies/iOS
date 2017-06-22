//
//  ActivitiesTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

let kActivityTitle = "title"

protocol ActivitiesCellDelegate {
    func activityCell(cell:ActivitiesTableViewCell, activity:Activity)
}

class ActivitiesTableViewCell: UITableViewCell {

    @IBOutlet var imageIcon : UIImageView?
    @IBOutlet var labelDays : UILabel?
    @IBOutlet var labelHeading : UILabel?
    @IBOutlet var labelTime : UILabel?
    @IBOutlet var labelStatus : UILabel?
    @IBOutlet var labelRunStatus : UILabel?
    @IBOutlet var buttonMoreSchedules : UIButton?
    @IBOutlet var buttonMoreSchedulesBottomLine : UIView?
    
    var delegate:ActivitiesCellDelegate?
    var currentActivity:Activity! = nil
    var availabilityStatus:ActivityAvailabilityStatus = .current
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    /**
     
     Used to change the cell background color
     
     @param selected    checks if particular cell is selected
     @param animated    used to animate the cell
     
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = labelStatus?.backgroundColor
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if(selected) {
            labelStatus?.backgroundColor = color
        }
    }
    
    
    /**
     
     Used to set the cell state ie Highlighted
     
     @param highlighted    should cell be highlightened
     @param animated    used to animate the cell
     
     */
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = labelStatus?.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        if(highlighted) {
            labelStatus?.backgroundColor = color
        }
    }
    
    
    /**
     
     Populate the cell data with Activity
     
     @param activity    Access the value from Activity class
     @param availablityStatus Access the value from ActivityAvailabilityStatus enum

     */
    func populateCellDataWithActivity(activity:Activity ,availablityStatus:ActivityAvailabilityStatus){
        
        self.availabilityStatus = availablityStatus
        self.currentActivity = activity
        self.labelHeading?.text = activity.name
        self.labelDays?.text = activity.frequencyType.description
        
        if availablityStatus != .upcoming {
            
            labelRunStatus?.isHidden = false
           
            
            

            //update user activity status
            //self.setUserStatusForActivity(activity: activity)
            
            
            if activity.currentRunId == 0 {
                labelStatus?.isHidden = true
            }
            else {
                labelStatus?.isHidden = false
            }
            
            
            
            
        }
        else {
            
            labelRunStatus?.isHidden = true
            labelStatus?.isHidden = true
        }
        self.calculateActivityTimings(activity: activity)
        self.setUserStatusForActivity(activity: activity)
        
        //update activity run details as compelted and missed
        self.updateUserRunStatus(activity: activity)
        
        if availablityStatus == .past{
            
            if activity.incompletedRuns != 0 || activity.totalRuns == 0 {
                self.labelStatus?.backgroundColor =  UIColor.red
                self.labelStatus?.text = UserActivityStatus.ActivityStatus.abandoned.description
            }
            else {
                self.labelStatus?.backgroundColor =  kGreenColor
                self.labelStatus?.text = UserActivityStatus.ActivityStatus.completed.description
            }
        }
    }
    
    
    /**
     
     Used to update User Run Status
     
     @param activity    Access the value from Activity class

     */
    func updateUserRunStatus(activity:Activity){
        
        let currentRunId = (activity.totalRuns != 0) ? String(activity.currentRunId) : "0"
        
        self.labelRunStatus?.text = "Run: " + currentRunId + "/" + String(activity.totalRuns) + ", " + String(activity.compeltedRuns) + " done" + ", " + String(activity.incompletedRuns) + " missed"
        
        if activity.totalRuns <= 1 {
            self.buttonMoreSchedules?.isHidden = true
            self.buttonMoreSchedulesBottomLine?.isHidden = true
        }
        else {
            self.buttonMoreSchedules?.isHidden = false
            self.buttonMoreSchedulesBottomLine?.isHidden = false
            let moreSchedulesTitle =  "+" + String(activity.totalRuns - 1) + " more"
            self.buttonMoreSchedules?.setTitle(moreSchedulesTitle, for: .normal)
        }
    }
    
    
    /**
     
     Used to set User Status For Activity
     
     @param activity    Access the value from Activity class

     */
    func setUserStatusForActivity(activity:Activity){
        
        let currentUser = User.currentUser
        
        if let userActivityStatus = currentUser.participatedActivites.filter({$0.activityId == activity.actvityId && $0.studyId == activity.studyId && $0.activityRunId == String(activity.currentRunId)}).first {
            
            //assign to study
            activity.userParticipationStatus = userActivityStatus
            
            //user study status
            labelStatus?.text = userActivityStatus.status.description
            
            switch userActivityStatus.status {
            case .inProgress:
                self.labelStatus?.backgroundColor = kYellowColor
                //self.labelStatus?.text = kResumeSpaces
            case .yetToJoin:
                self.labelStatus?.backgroundColor = kBlueColor
                //self.labelStatus?.text = kStartSpaces
            case .abandoned:
                self.labelStatus?.backgroundColor =  UIColor.red
                //self.labelStatus?.text = kInCompletedSpaces
            case .completed:
                self.labelStatus?.backgroundColor = kGreenColor
                //self.labelStatus?.text = kCompletedSpaces
                
            }
            //bookMarkStatus
            //buttonBookmark?.isSelected = userStudyStatus.bookmarked
        }
        else {
            
            self.labelStatus?.backgroundColor = kBlueColor
            
            //if in database their is no staus update for past activities 
            //assigning abandoned status by default
            if self.availabilityStatus == .past {
                
                self.labelStatus?.backgroundColor =  UIColor.red
                self.labelStatus?.text = UserActivityStatus.ActivityStatus.abandoned.description
            }
            else {
                
                let activityStatus = UserActivityStatus()
                activityStatus.status = .yetToJoin
                activity.userParticipationStatus = activityStatus
                
                self.labelStatus?.backgroundColor = kBlueColor
                self.labelStatus?.text = UserActivityStatus.ActivityStatus.yetToJoin.description
            }
        }
    }
    
    
    /**
     
     Used to calculate Activity Timings
     
     @param activity    Access the value from Activity class

     */
    func calculateActivityTimings(activity:Activity){
        
        print("name: \(activity.name) - start \(activity.startDate) , end \(activity.endDate)")
        
        var startDate = activity.startDate//?.utcDate()
        var endDate   = activity.endDate//?.utcDate()
        
        var difference = UserDefaults.standard.value(forKey: "offset") as? Int
        if difference != nil {
            difference = difference! * -1
            startDate = startDate?.addingTimeInterval(TimeInterval(difference!))
            endDate = endDate?.addingTimeInterval(TimeInterval(difference!))
        }
        
    
        let frequency = activity.frequencyType
        
        //let activityStartTime = ActivitiesTableViewCell.timeFormatter.string(from: startDate!)
        let startDateString = ActivitiesTableViewCell.oneTimeFormatter.string(from: startDate!)
        var endDateString = ""
        if endDate != nil {
            endDateString = ActivitiesTableViewCell.oneTimeFormatter.string(from: endDate!)
        }
        
        if activity.type == ActivityType.activeTask{
             imageIcon?.image = UIImage.init(named: "taskIcon")
        }
        else {
            
            imageIcon?.image = UIImage.init(named: "surveyIcon")
        }
       
        switch frequency {
        case .One_Time:
            
           
            if endDate != nil {
                
                labelTime?.text = startDateString + " - " + endDateString
            }
            else {
                labelTime?.text = startDateString
                
            }
            
            //print("\(activityStartTime), \(startDateString) to \(endDateString)")
        case .Daily:
            
            var runStartTimingsList:Array<String> = []
            for dict in activity.frequencyRuns!{
                let startTime = dict[kScheduleStartTime] as! String
                let runStartTime = ActivitiesTableViewCell.dailyFormatter.date(from: startTime)
                let runStartTimeAsString =  ActivitiesTableViewCell.timeFormatter.string(from: runStartTime!)
                runStartTimingsList.append(runStartTimeAsString)
            }
            let runStartTime =  runStartTimingsList.joined(separator: " | ") //ActivitiesTableViewCell.timeFormatter.string(from: startDate!)
            let dailyStartDate =  ActivitiesTableViewCell.dailyActivityFormatter.string(from: startDate!)
            let endDate = ActivitiesTableViewCell.dailyActivityFormatter.string(from: endDate!)
            labelTime?.text = runStartTime  + "\n" +  dailyStartDate + " to " + endDate
            
        case .Weekly:
            
            var weeklyStartTime = ActivitiesTableViewCell.weeklyformatter.string(from: startDate!)
            weeklyStartTime = weeklyStartTime.replacingOccurrences(of: ",", with: "every")
            let endDate = ActivitiesTableViewCell.formatter.string(from: endDate!)
            
            labelTime?.text = weeklyStartTime + " to " + endDate
            
        case .Monthly:
            var monthlyStartTime = ActivitiesTableViewCell.monthlyformatter.string(from: startDate!)
            monthlyStartTime = monthlyStartTime.replacingOccurrences(of: ",", with: "on")
            monthlyStartTime = monthlyStartTime.replacingOccurrences(of: ";", with: "every month\n")
            
            let endDate = ActivitiesTableViewCell.formatter.string(from: endDate!)
            
            labelTime?.text = monthlyStartTime + " to " + endDate

        case .Scheduled:
            labelTime?.text = startDateString + " - " + endDateString
        
        }
    }
    
    
//MARK:- Button Action
    
    /**
     
     Clicked on  MoreSchedules
     
     @param _    Accepts UIButton object

     */
    @IBAction func buttonMoreSchedulesClicked(_ :UIButton){
        self.delegate?.activityCell(cell: self, activity: self.currentActivity)
    }
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd YYYY"
        //formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
    
    private static let dailyActivityFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd YYYY"
        //formatter.timeZone = TimeZone.current //.init(abbreviation:"GMT")
        return formatter
    }()
    
    private static let oneTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma, MMM dd YYYY"
        //formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
    
    private static let weeklyformatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma , EEE MMM dd YYYY"
        //formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()

    private static let monthlyformatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma , dd ;MMM dd YYYY"
        //formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        //formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
    private static let dailyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        //formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
}


