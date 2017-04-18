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
    
    
    var availabilityStatus:ActivityAvailabilityStatus = .current
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateCellDataWithActivity(activity:Activity ,availablityStatus:ActivityAvailabilityStatus){
        
        self.availabilityStatus = availablityStatus
        
        self.labelHeading?.text = activity.name
        
        self.labelDays?.text = activity.frequencyType.description
        
        
        if availablityStatus != .upcoming {
            
            labelRunStatus?.isHidden = false
            labelStatus?.isHidden = false
            
            //update activity run details as compelted and missed
            self.updateUserRunStatus(activity: activity)

            
            //update user activity status
            self.setUserStatusForActivity(activity: activity)
            
            
            //calculate activity runs and save in database
            if activity.totalRuns == 0 {
                Schedule().getRunsForActivity(activity: activity, handler: { (runs) in
                    if runs.count > 0 {
                        
                        let date = Date()
                        
                        var runsBeforeToday = runs.filter({$0.startDate <= date})
                        let run = runsBeforeToday.last //current run
                        if runsBeforeToday.count >= 1 {
                            runsBeforeToday.removeLast()
                        }
                        
                        let completedRuns = runs.filter({$0.isCompleted == true})
                        let incompleteRuns = runsBeforeToday.count - completedRuns.count
                        
                        
                        activity.compeltedRuns = completedRuns.count
                        activity.incompletedRuns = incompleteRuns
                        activity.currentRunId =  (run != nil) ? (run?.runId)! : 1
                        activity.totalRuns = runs.count
                        
                        self.updateUserRunStatus(activity: activity)
                        
                        DBHandler.saveActivityRuns(activityId: (activity.actvityId)!, studyId: (Study.currentStudy?.studyId)!, runs: runs)
                    }
                })
                
            }
        }
        else {
            
            labelRunStatus?.isHidden = true
            labelStatus?.isHidden = true
        }
        
        
        
        self.calculateActivityTimings(activity: activity)
        self.setUserStatusForActivity(activity: activity)
        
       
        
    }
    
    func updateUserRunStatus(activity:Activity){
        
        self.labelRunStatus?.text = "Run: " + String(activity.currentRunId) + "/" + String(activity.totalRuns) + ", " + String(activity.compeltedRuns) + " done" + ", " + String(activity.incompletedRuns) + " missed"
    }
    
    func setUserStatusForActivity(activity:Activity){
        
        let currentUser = User.currentUser
        
        
        if let userActivityStatus = currentUser.participatedActivites.filter({$0.activityId == activity.actvityId && $0.activityRunId == String(activity.currentRunId)}).first {
            
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
            
            self.labelStatus?.backgroundColor = kBlueColor
            
            //if in database their is no staus update for past activities 
            //assigning abandoned status by default
            if self.availabilityStatus == .past {
                
                self.labelStatus?.backgroundColor =  UIColor.red
                self.labelStatus?.text = UserActivityStatus.ActivityStatus.abandoned.description
            }
            else {
                
                self.labelStatus?.backgroundColor = kBlueColor
                self.labelStatus?.text = UserActivityStatus.ActivityStatus.yetToJoin.description
            }
            
        }
        
      
    }
    
    
    func calculateActivityTimings(activity:Activity){
        
        let startDate = activity.startDate
        let endDate   = activity.endDate
        let frequency = activity.frequencyType
        
        //let activityStartTime = ActivitiesTableViewCell.timeFormatter.string(from: startDate!)
        let startDateString = ActivitiesTableViewCell.oneTimeFormatter.string(from: startDate!)
        let endDateString = ActivitiesTableViewCell.oneTimeFormatter.string(from: endDate!)
        
        
        
        
        
        switch frequency {
        case .One_Time:
            
            labelTime?.text = startDateString + " - " + endDateString
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
            let dailyStartDate =  ActivitiesTableViewCell.formatter.string(from: startDate!)
            let endDate = ActivitiesTableViewCell.formatter.string(from: endDate!)
            labelTime?.text = runStartTime  + "\n" +  dailyStartDate + " to " + endDate
            
        case .Weekly:
            
            var weeklyStartTime = ActivitiesTableViewCell.weeklyformatter.string(from: startDate!)
            weeklyStartTime = weeklyStartTime.replacingOccurrences(of: ",", with: "every")
            let endDate = ActivitiesTableViewCell.formatter.string(from: endDate!)
            
            labelTime?.text = weeklyStartTime + " to " + endDate
            
            
        case .Monthly:
            var monthlyStartTime = ActivitiesTableViewCell.monthlyformatter.string(from: startDate!)
            monthlyStartTime = monthlyStartTime.replacingOccurrences(of: ",", with: "on")
            monthlyStartTime = monthlyStartTime.replacingOccurrences(of: ":", with: "every month\n")
            
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
        formatter.dateFormat = "hha , dd :MMM dd YYYY"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hha"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
    private static let dailyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
    
    
}
