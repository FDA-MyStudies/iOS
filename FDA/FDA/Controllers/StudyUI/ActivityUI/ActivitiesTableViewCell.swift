//
//  ActivitiesTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

let kActivityTitle = "title"



class ActivitiesTableViewCell: UITableViewCell {

    @IBOutlet var imageIcon : UIImageView?
    @IBOutlet var labelDays : UILabel?
    @IBOutlet var labelHeading : UILabel?
    @IBOutlet var labelTime : UILabel?
    @IBOutlet var labelStatus : UILabel?
    @IBOutlet var labelRunStatus : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateCellDataWithActivity(activity:Activity){
        self.labelHeading?.text = activity.name
        //self.labelTime?.text = (activity.startDate?.description)! + "-" + (activity.endDate?.description)!
        self.labelDays?.text = activity.frequencyType.rawValue
        self.setUserStatusForActivity(activity: activity)
        
        if activity.totalRuns == 0 {
            Schedule().getRunsForActivity(activity: activity, handler: { (runs) in
                if runs.count > 0 {
                    
                    let date = Date()
                    
                    let runsBeforeToday = runs.filter({$0.startDate <= date})
                    let completedRuns = runs.filter({$0.isCompleted == true})
                    let incompleteRuns = runsBeforeToday.count - completedRuns.count
                    let run = runsBeforeToday.last
                    
                    activity.compeltedRuns = completedRuns.count
                    activity.incompletedRuns = incompleteRuns
                    activity.currentRunId = (run?.runId)!
                    activity.totalRuns = runs.count
                    
                    self.updateUserRunStatus(activity: activity)
                    
                    DBHandler.saveActivityRuns(activityId: (activity.actvityId)!, studyId: (Study.currentStudy?.studyId)!, runs: runs)
                }
            })

        }
        
        self.calculateActivityTimings(activity: activity)
        
        self.updateUserRunStatus(activity: activity)
       // self.labelRunStatus?.text = "Run: " + String(activity.currentRunId) + "/" + String(activity.totalRuns) + ", " + String(activity.compeltedRuns) + " done" + ", " + String(activity.incompletedRuns) + " missed"
        
    }
    
    func updateUserRunStatus(activity:Activity){
        
        self.labelRunStatus?.text = "Run: " + String(activity.currentRunId) + "/" + String(activity.totalRuns) + ", " + String(activity.compeltedRuns) + " done" + ", " + String(activity.incompletedRuns) + " missed"
    }
    
    func setUserStatusForActivity(activity:Activity){
        
        let currentUser = User.currentUser
        
        
        if let userActivityStatus = currentUser.participatedActivites.filter({$0.activityId == activity.actvityId}).first {
            
            //assign to study
            //activity.userParticipateState = userActivityStatus
            
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
            //study.userParticipateState = UserStudyStatus()
            //labelStudyUserStatus?.text = UserStudyStatus.StudyStatus.yetToJoin.description
            self.labelStatus?.backgroundColor = kBlueColor
            self.labelStatus?.text = UserActivityStatus.ActivityStatus.yetToJoin.description
        }
        
      
    }
    
    
    func calculateActivityTimings(activity:Activity){
        
        let startDate = activity.startDate
        let endDate   = activity.endDate
        let frequency = activity.frequencyType
        
        let activityStartTime = ActivitiesTableViewCell.timeFormatter.string(from: startDate!)
        let startDateString = ActivitiesTableViewCell.oneTimeFormatter.string(from: startDate!)
        let endDateString = ActivitiesTableViewCell.oneTimeFormatter.string(from: endDate!)
        
        
        
        //weekly
        let weeklyStartTime = ActivitiesTableViewCell.weeklyformatter.string(from: startDate!)
        print("weeklyStartTime: \(weeklyStartTime.replacingOccurrences(of: ",", with: "every"))")
        
        
        //monthly
        var monthlyStartTime = ActivitiesTableViewCell.monthlyformatter.string(from: startDate!)
        monthlyStartTime = monthlyStartTime.replacingOccurrences(of: ",", with: "on")
        monthlyStartTime = monthlyStartTime.replacingOccurrences(of: ":", with: "every month")
        print("monthlyStartTime :\(monthlyStartTime))")
        
        switch frequency {
        case .One_Time:
            
            labelTime?.text = startDateString + " - " + endDateString
            print("\(activityStartTime), \(startDateString) to \(endDateString)")
        case .Daily:
            
            let runStartTime =  ActivitiesTableViewCell.timeFormatter.string(from: startDate!)
            let dailyStartDate =  ActivitiesTableViewCell.timeFormatter.string(from: startDate!)
            let endDate = ActivitiesTableViewCell.formatter.string(from: endDate!)
            labelTime?.text = runStartTime  +  dailyStartDate + " to " + endDate
            
        case .Weekly:
            
            var weeklyStartTime = ActivitiesTableViewCell.weeklyformatter.string(from: startDate!)
            weeklyStartTime = weeklyStartTime.replacingOccurrences(of: ",", with: "every")
            let endDate = ActivitiesTableViewCell.formatter.string(from: endDate!)
            
            labelTime?.text = weeklyStartTime + " to " + endDate
            
            
        case .Monthly:
            var monthlyStartTime = ActivitiesTableViewCell.monthlyformatter.string(from: startDate!)
            monthlyStartTime = monthlyStartTime.replacingOccurrences(of: ",", with: "on")
            monthlyStartTime = monthlyStartTime.replacingOccurrences(of: ":", with: "every month")
            
            let endDate = ActivitiesTableViewCell.formatter.string(from: endDate!)
            
            labelTime?.text = monthlyStartTime + " to " + endDate

            
        case .Scheduled:
            labelTime?.text = startDateString + " - " + endDateString
        
            
        }
        
    }
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd YYYY"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
    
    private static let oneTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hha, MMM dd YYYY"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
    
    private static let weeklyformatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hha , EEE MMM dd YYYY"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()

    private static let monthlyformatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hha , dd : EEE MMM dd YYYY"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hha"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()

    
    
}
