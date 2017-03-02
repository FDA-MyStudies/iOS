//
//  Schedule.swift
//  FDA
//
//  Created by Arun Kumar on 2/15/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation

enum AvailabilityStatus:Int{
    case runAvailable
    case runExpired
    case runCompleted
    case activityExpired
    case activityNotAvailable
}


class Schedule{
    
    enum Frequency:String {
        case One_Time
        case Daily
        case Weekly
        case Monthly
        case Scheduled
    }
    
    
    var frequency:Frequency = .One_Time
    var startTime:Date!
    var endTime:Date!
    var lastRunTime:Date? = nil
    var nextRunTime:Date!
    var activityRuns:Array<ActivityRun>! = []
    
    init(){
        
    }
    
    init(detail:Dictionary<String,Any>){
        
        if Utilities.isValidObject(someObject: detail as AnyObject?){
            
            if Utilities.isValidValue(someObject: detail[kActivityStartTime] as AnyObject ){
                self.startTime = Utilities.getDateFromString(dateString: detail[kActivityStartTime] as! String)
            }
            
            if Utilities.isValidValue(someObject: detail[kActivityEndTime] as AnyObject ){
                self.endTime = Utilities.getDateFromString(dateString: detail[kActivityEndTime] as! String)
            }
            
            if Utilities.isValidValue(someObject: detail[kActivityFrequency] as AnyObject ){
                self.frequency = Frequency.init(rawValue: detail[kActivityFrequency] as! String)!
            }
           
        }
        else{
            Logger.sharedInstance.debug("Schedule Dictionary is null:\(detail)")
        }
    }
    
    
    
    
    func isAvailable() -> Bool{
        
        let currentDate = Date()
        var availablityStatus = true
        
        let result = currentDate.compare(endTime)
        let startResult = currentDate.compare(startTime)
        if (startResult == .orderedSame || startResult == .orderedAscending) {
            availablityStatus = false
           
        }
        if result == .orderedDescending{
            availablityStatus = false
            
        }
        
        return availablityStatus
    }
    
   
    
    func setActivityRun(){
        
        switch self.frequency {
        case Frequency.One_Time: break
        case Frequency.Daily:
            self.setDailyRuns()
        case Frequency.Weekly:
            self.setWeeklyRuns()
        case Frequency.Monthly:
            self.setMonthlyRuns()
        case Frequency.Scheduled:break
        default: break
            
        }
    }
    
    func setDailyRuns(){
        
        
       
        
        let numberOfDays = self.getNumberOfDaysBetween(startDate: startTime, endDate: endTime)
        print("numberOfDays \(numberOfDays)")
        var runStartDate:Date? = startTime
        var runEndDate:Date? = nil
        let calendar = Calendar.current
        for day in 1...numberOfDays {
            
            
            runStartDate =  calendar.date(byAdding:.day, value: day, to: startTime)
            runEndDate =  calendar.date(byAdding:.second, value:86399, to: runStartDate!)
            
            //appent in activity
            let activityRun = ActivityRun()
            activityRun.runId = day
            activityRun.startDate = runStartDate
            activityRun.endDate = runEndDate
            activityRuns.append(activityRun)
            
           // print("start date \(runStartDate!) , end date \(runEndDate!)")
        }
        
        
    }
    
    func setWeeklyRuns() {
        
        let dayOfWeek = self.getCurrentWeekDay(date: startTime)
        let calendar = Calendar.current
        let targetDay = 1 //server configurable
        
        //first day
        var runStartDate = calendar.date(byAdding:.weekday, value:(targetDay - dayOfWeek), to: startTime)
        var runId = 1
        while runStartDate?.compare(endTime) == .orderedAscending {
            var runEndDate =  calendar.date(byAdding:.second, value:((7*86400) - 1), to: runStartDate!)
            if runEndDate?.compare(endTime) == .orderedDescending {
                runEndDate = endTime
            }
            
            //appent in activity
            let activityRun = ActivityRun()
            activityRun.runId = runId
            activityRun.startDate = runStartDate
            activityRun.endDate = runEndDate
            activityRuns.append(activityRun)
            
            //save range
            //debugPrint("start date \(runStartDate!) , end date \(runEndDate!)")
            
            runStartDate = calendar.date(byAdding:.second, value:1, to: runEndDate!)
            runId += 1
        }
        
    }
    
    func setMonthlyRuns(){
        
        let calendar = Calendar.current
        
        var runStartDate = startTime
        var runId = 1
        while runStartDate?.compare(endTime) == .orderedAscending {
            let nextRunStartDate =  calendar.date(byAdding:.month, value:1*runId, to: startTime!)
            var runEndDate = calendar.date(byAdding: .second, value: -1, to: nextRunStartDate!)
            //save range
            if runEndDate?.compare(endTime) == .orderedDescending {
                runEndDate = endTime
            }
            
            //appent in activity
            let activityRun = ActivityRun()
            activityRun.runId = runId
            activityRun.startDate = runStartDate
            activityRun.endDate = runEndDate
            activityRuns.append(activityRun)
            
            //debugPrint("start date \(runStartDate!) , end date \(runEndDate!)")
            runStartDate = nextRunStartDate
            runId += 1
        }
    }
    
    func setDailyFrequenyRuns(){
        
        
        
        let timings = [["start":"10:00","end":"12:59"],
                       ["start":"13:00","end":"15:59"]]
        
        let numberOfDays = self.getNumberOfDaysBetween(startDate: startTime, endDate: endTime)
        print("numberOfDays \(numberOfDays)")
        var runStartDate:Date? = startTime
        var runEndDate:Date? = nil
        let calendar = Calendar.current
        for day in 1...numberOfDays {
            
            
            runStartDate =  calendar.date(byAdding:.day, value: day, to: startTime)
            runEndDate =  calendar.date(byAdding:.second, value:86399, to: runStartDate!)
            
            //appent in activity
            let activityRun = ActivityRun()
            activityRun.runId = day
            activityRun.startDate = runStartDate
            activityRun.endDate = runEndDate
            activityRuns.append(activityRun)
            
            // print("start date \(runStartDate!) , end date \(runEndDate!)")
        }
    }
    func setScheduledRuns(){
        
    }
    
    
    
     //MARK:Utility Methods
    func getCurrentWeekDay(date:Date) -> Int{
        
        
        
        let calendar = Calendar.current
        let component = calendar.dateComponents([.weekday], from: date)
        print(component.weekday! as Int)
        let dayOfWeek = component.weekday! as Int
        return dayOfWeek
        
        
    }
    func endOfDay(date: Date) -> (Date) {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: 1, to: date)
        return (endDate!)
    }
    
    func getNumberOfWeeksBetween(startDate:Date,endDate:Date) -> Int {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: startDate)
        let date2 = calendar.startOfDay(for: endDate) //calendar.startOfDay(for: endDate)
        
        let components = calendar.dateComponents([Calendar.Component.weekOfYear], from: date1, to: date2)
        
        print(components.weekOfYear! as Int)
        
        return components.weekOfYear! as Int
    }
    
    func getNumberOfDaysBetween(startDate:Date,endDate:Date) -> Int {
        
        let calendar = Calendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: startDate)
        let date2 = calendar.startOfDay(for: endDate) //calendar.startOfDay(for: endDate)
        
        let components = calendar.dateComponents([Calendar.Component.day], from: date1, to: date2)
        
        print(components.day! as Int)
        
        return components.day! as Int
    }
    
}

class ActivityRun {
  
    var startDate:Date!
    var endDate:Date!
    var complitionDate:Date!
    var runId:Int = 1
    var studyId:String!
    var activityId:String!
    var isCompleted:Bool = false
    
}
