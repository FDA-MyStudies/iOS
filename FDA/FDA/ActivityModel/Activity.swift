//
//  Activity.swift
//  FDA
//
//  Created by Arun Kumar on 2/15/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation


enum ActivityType:String{
    case questionnaire = "questionnaire"
    case activeTask = "active task"
}



class Activity{
    
    var type:ActivityType?
    var actvityId:String?
    
    var studyId:String?
    var name:String?
    var version:String?
    var lastModified:Date?
    var userStatus:UserStudyStatus?
    var startDate:Date?
    var endDate:Date?
    var branching:Bool?
    var randomization:Bool?
    
    var schedule:Schedule?
    var steps:Array<Any>?
    var result:ActivityResult?
    
    
    init() {
        self.type = .questionnaire
        self.actvityId = ""
        self.studyId = ""
        self.name = ""
        self.version = "0"
        self.lastModified = Date()
        self.userStatus = .yetToJoin
        self.startDate = Date()
        self.endDate = Date()
        self.branching = false
        self.randomization = false
        self.schedule = schedule()
        self.steps = Array()
        self.result = ActivityResult()
    }
    
    func initWithInfo(infoDict:Dictionary<String,Any>) {
        if Utilities.isValidObject(someObject: infoDict as AnyObject?){
            if Utilities.isValidValue(someObject: stepDict[kActivityStepType] as AnyObject ){
                self.type = stepDict[kActivityStepType] as? ActivityStepType
            }
            if Utilities.isValidValue(someObject: stepDict[kActivityStepKey] as AnyObject ){
                self.key = stepDict[kActivityStepKey] as? String
            }
        }
        else{
            Logger.sharedInstance.debug("Step Result Dictionary is null:\(stepDict)")
        }
    }
    
}









