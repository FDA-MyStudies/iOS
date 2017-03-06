//
//  Study.swift
//  FDA
//
//  Created by Surender Rathore on 2/14/17.
//  Copyright © 2017 BTC. All rights reserved.
//


import Foundation

enum StudyStatus:String{
    case active
    case upcoming
    case closed
}
class Study {

    //MARK:Properties
    var name:String?
    var version:String?
    var identifer:String?
    var category:String?
    var startDate:String?
    var endEnd:String?
    var status:StudyStatus = .active
    var sponserName:String?
    var description:String?
    var brandingConfiguration:String?
    var logoURL:String?
    var overview:Overview!
    var activities:Array<Activity>!
    
    static var currentStudy:Study? = nil
    
    init(studyDetail:Dictionary<String,Any>) {
        
        if Utilities.isValidObject(someObject: studyDetail as AnyObject?){
            
            if Utilities.isValidValue(someObject: studyDetail[kStudyTitle] as AnyObject ){
                self.name = studyDetail[kStudyTitle] as? String
            }
            
            if Utilities.isValidValue(someObject: studyDetail[kStudyCategory] as AnyObject ){
                self.category = studyDetail[kStudyCategory] as? String
            }
            if Utilities.isValidValue(someObject: studyDetail[kStudySponserName] as AnyObject ){
                self.sponserName = studyDetail[kStudySponserName] as? String
            }
            if Utilities.isValidValue(someObject: studyDetail[kStudyDescription] as AnyObject ){
                self.description = studyDetail[kStudyDescription] as? String
            }
            if Utilities.isValidObject(someObject: studyDetail[kStudyLogoURL] as AnyObject ) {
                self.logoURL = studyDetail[kStudyLogoURL] as? String
            }
            if Utilities.isValidValue(someObject: studyDetail[kStudyStatus] as AnyObject )  {
                self.status = StudyStatus.init(rawValue: studyDetail[kStudyStatus] as! String)!
            }
            
        }
        else{
            Logger.sharedInstance.debug("Study Dictionary is null:\(studyDetail)")
        }

    }
    
    
    func updateCurrentStudy(study:Study){
        Study.currentStudy = study
    }
    
     
    
}