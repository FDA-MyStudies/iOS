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
            let schedule = Schedule()
            schedule.frequency = activity.frequencyType
            schedule.startTime = activity.startDate
            schedule.endTime = activity.endDate
            schedule.activity = activity
            schedule.setActivityRun()
        }
        
        self.labelRunStatus?.text = "Run: " + String(activity.currentRunId) + "/" + String(activity.totalRuns) + ", " + String(activity.compeltedRuns) + "done" + ", " + String(activity.incompletedRuns) + "missed"
        
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
    
    
    

    func populateCellData(data: Dictionary<String, Any>){
        
        let frequency:Dictionary<String,Any> = data[kActivityFrequency] as! Dictionary<String, Any>
        
        if Utilities.isValidObject(someObject: frequency as AnyObject?){
            if Utilities.isValidValue(someObject: frequency[kActivityType] as AnyObject?){
               self.labelDays?.text = frequency[kActivityType] as! String?
            }
            else{
                self.labelDays?.text = "Everyday"
            }
        }
        else{
            
        }
        
        if Utilities.isValidValue(someObject: data[kActivityTitle] as AnyObject?){
            self.labelHeading?.text = data[kActivityTitle] as! String?
        }
        else{
              self.labelHeading?.text = ""
        }
        
        if Utilities.isValidValue(someObject: data[kActivityStartTime] as AnyObject?){
            self.labelTime?.text = data[kActivityStartTime] as! String?
        }
        else{
            self.labelTime?.text = ""
        }

        //Status Pending
        self.labelStatus?.text = data["operation"] as? String
        
        if data["day"] as? String == "Weekely"{
            self.imageIcon?.image = UIImage.init(named: "taskIcon")
        }
        
        
        //Temp
        self.labelStatus?.isHidden = true
        if data["operation"] as? String != ""{
            self.labelStatus?.isHidden = false
            
            if data["operation"] as? String == "Resume"{
                self.labelStatus?.backgroundColor = kYellowColor
                self.labelStatus?.text = kResumeSpaces
                
            }else if data["operation"] as? String == "Start"{
                self.labelStatus?.backgroundColor = kBlueColor
                self.labelStatus?.text = kStartSpaces
                
            }else{
                self.labelStatus?.backgroundColor = kGreenColor
                self.labelStatus?.text = kCompletedSpaces
                
            }
        }
        
        
        //Need to change Temp
        
        
    }
    
}
