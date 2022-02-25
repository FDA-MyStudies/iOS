//
//  ActivityDiskService.swift
//  HPHC
//
//  Created by Tushar Katyal on 02/03/20.
//  Copyright © 2020 BTC. All rights reserved.
//

import Foundation
import RealmSwift

enum ActivityDiskService {
    
    private static var realm: Realm? = {
        let key = FDAKeychain.shared[kRealmEncryptionKeychainKey]
        let data = Data.init(base64Encoded: key!)
        let encryptionConfig = Realm.Configuration(encryptionKey: data)
        return try? Realm()
    }()
    
    static func scheduleRunsFor(oneTime dbActivity: DBActivity,
                                anchorDate: Date,
                                externalIdValue: String? = nil,
                                dateOfEntryValue: String? = nil,
                                frequency: Frequency) {
        
        guard frequency == .One_Time,
            let updatedAnchorDate = DateHelper.updateTime(of: anchorDate) else {
                return
        }
        
        let lifeTime = DBHandler.getLifeTime(updatedAnchorDate,
                                   frequency:frequency,
                                   startDays: dbActivity.startDays,
                                   endDays: dbActivity.endDays,
                                   repeatInterval: dbActivity.repeatInterval)
        
        guard var anchorStartDate = lifeTime.0,
            let anchorEndDate = lifeTime.1 else {
                //
                return // TODO:
        }
        
        let currentDate = DBHandler.getCurrentDateWithTimeDifference()
        
        // Update Start date and time.
        if let startTime = dbActivity.startTime,
            let updatedStartDate = DateHelper.updateTime(of: anchorStartDate, with: startTime) {
            anchorStartDate = updatedStartDate
        } else {
            anchorStartDate = dbActivity.startDate ?? currentDate
        }
        
        var newEndDate: Date?
        // Update End date and time.
        if let endTime = dbActivity.endTime,
            let updatedEndDate = DateHelper.updateTime(of: anchorEndDate, with: endTime) {
            newEndDate = updatedEndDate
        } // else:- LifeTime Activity.
        
        
        // Calcuate runs for activity
        let activity = DBHandler.getActivityFromDBActivity(dbActivity, runDate: currentDate)
        activity.startDate = anchorStartDate
        activity.endDate = newEndDate
        activity.anchorDate?.anchorDateValue = anchorDate
        
        func adjustDateFor(newRun: ActivityRun, lastRun: ActivityRun) -> ActivityRun? {
            
            if lastRun.startDate > currentDate, lastRun.endDate > currentDate { // previous run upcoming
                
                lastRun.startDate = newRun.startDate
                lastRun.endDate = newRun.endDate
                
            } else if lastRun.startDate < currentDate, lastRun.endDate > currentDate { // previous run current
                if newRun.startDate < currentDate, newRun.endDate < currentDate {
                    return lastRun
                } else {
                    lastRun.endDate = newRun.endDate
                }
            } else if lastRun.startDate < currentDate, lastRun.endDate < currentDate { // previous run past
                if newRun.startDate < currentDate, newRun.endDate < currentDate {
                    return nil
                } else if newRun.startDate < currentDate, newRun.endDate > currentDate {
                    lastRun.endDate = newRun.endDate
                } else { //  newRun.startDate > currentDate, newRun.endDate > currentDate
                    lastRun.endDate = newRun.endDate
                }
            }
            return lastRun
        }
        
        Schedule().getRunsForActivity(activity: activity, handler: { (runs) in
            
            var oneTimeNewRun = runs.first
            
            let oldRun = activity.activityRuns.first
            
            var isOverLapping = false
            
            if let lastRun = oldRun, let newRun = oneTimeNewRun {
                
                guard !lastRun.isCompleted else {
                    return
                }
                if newRun.endDate != nil, lastRun.endDate != nil {
                    if (lastRun.startDate ... lastRun.endDate).contains(newRun.startDate)
                        || (lastRun.startDate ... lastRun.endDate).contains(newRun.endDate) {
                        isOverLapping = true
                    }
                    
                    if !isOverLapping,
                        let updatedLastRun = adjustDateFor(newRun: newRun, lastRun: lastRun) {
                        oneTimeNewRun = updatedLastRun
                    } else {
                        return
                    }
                } else {
                    if !((lastRun.startDate < currentDate && newRun.startDate > currentDate) ||
                        (lastRun.startDate < currentDate && newRun.startDate < currentDate)) {
                        oneTimeNewRun?.startDate = lastRun.startDate // Update start date only
                    }
                }
            }
            
            var dbRun: DBActivityRun?
            if let newRun = oneTimeNewRun {
                let dbActivityRun = DBActivityRun()
                dbActivityRun.startDate = newRun.startDate
                dbActivityRun.endDate = newRun.endDate
                dbActivityRun.activityId = activity.actvityId
                dbActivityRun.studyId = activity.studyId
                dbActivityRun.runId = 1
                dbActivityRun.isCompleted = newRun.isCompleted
                dbActivityRun.responseData = newRun.responseData
                dbActivityRun.restortionData = newRun.restortionData
                dbRun = dbActivityRun
            }
            
          try? realm!.write {
            realm!.delete(dbActivity.activityRuns) // Delete old scheduled runs
                if let dbRun = dbRun {
                    dbActivity.activityRuns.append(dbRun)
                }
                dbActivity.startDate = dbRun?.startDate ?? activity.startDate
                dbActivity.endDate = dbRun?.endDate ?? activity.endDate
            }
            
        })
    }
    
    /// This will schedule runs for Daily, Weekly and Monthly frequency activities.
    static func scheduleRunsFor(other dbActivity: DBActivity,
                                anchorDate: Date ,
                                externalIdValue: String? = nil,
                                dateOfEntryValue: String? = nil,
                                frequency: Frequency) {
        
        guard frequency == .Daily || frequency == .Weekly || frequency == .Monthly,
            let updatedAnchorDate = DateHelper.updateTime(of: anchorDate) else {
                return
        }
        
        let lifeTime = DBHandler.getLifeTime(updatedAnchorDate,
                                             frequency:frequency,
                                             startDays: dbActivity.startDays,
                                             endDays: dbActivity.endDays,
                                             repeatInterval: dbActivity.repeatInterval)
        
        var anchorStartDate = lifeTime.0
        var anchorEndDate = lifeTime.1
        
        let currentDate = DBHandler.getCurrentDateWithTimeDifference()
        
        // Update Start date and time.
        if let startTime = dbActivity.startTime,
            let startDate = anchorStartDate,
            let updatedStartDate = DateHelper.updateTime(of: startDate, with: startTime) {
            anchorStartDate = updatedStartDate
        } else {
            anchorStartDate = dbActivity.startDate ?? currentDate
        }
        
        // Update End date and time.
        if let endTime = dbActivity.endTime {
            anchorEndDate = DateHelper.updateTime(of: anchorEndDate, with: endTime)
        } else {
            anchorEndDate = dbActivity.endDate
        }
        
        // Adjust the Start & End date, if Anchor date is refreshed.
        if let oldStartDate = dbActivity.startDate,
            let oldEndDate = dbActivity.endDate,
            let newStartDate = anchorStartDate,
            let newEndDate = anchorEndDate {
            
            if oldStartDate > currentDate, oldEndDate > currentDate { // previous run upcoming
                if newStartDate < currentDate, newEndDate > currentDate {
                    anchorStartDate = currentDate
                }
            } else if (oldStartDate < currentDate && oldEndDate > currentDate)
                || (oldStartDate < currentDate && oldEndDate < currentDate) {
                if newStartDate < currentDate, newEndDate < currentDate {
                    return
                } else {
                    anchorStartDate = oldStartDate
                    anchorEndDate = newEndDate
                }
            }
        }
        
      try? realm!.write {
          realm!.delete(dbActivity.activityRuns) // Delete old scheduled runs
        }
        
        // Calcuate runs for activity
        let activity = DBHandler.getActivityFromDBActivity(dbActivity, runDate: currentDate)
        activity.startDate = anchorStartDate
        activity.endDate = anchorEndDate
        activity.anchorDate?.anchorDateValue = anchorDate

        Schedule().getRunsForActivity(activity: activity, handler: { (runs) in
            
            // Create runs
            let dbActivityRuns = List<DBActivityRun>()
            for activityRun in runs {

                let dbActivityRun = DBActivityRun()
                dbActivityRun.startDate = activityRun.startDate
                dbActivityRun.endDate = activityRun.endDate
                dbActivityRun.activityId = activity.actvityId
                dbActivityRun.studyId = activity.studyId
                dbActivityRun.runId = activityRun.runId
                dbActivityRun.isCompleted = activityRun.isCompleted
                dbActivityRuns.append(dbActivityRun)
            }
            
          try? realm!.write {
            realm!.delete(dbActivity.activityRuns) // Delete old scheduled runs
                dbActivity.activityRuns.append(objectsIn: dbActivityRuns)
                dbActivity.startDate = activity.startDate
                dbActivity.endDate = activity.endDate
            }
            
        })
    }
    
}
