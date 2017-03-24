//
//  DBHandler.swift
//  FDA
//
//  Created by Surender Rathore on 3/22/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import RealmSwift

class DBHandler: NSObject {

    
    func saveCurrentUser(user:User){
        
        let dbUser = DBUser()
        dbUser.userType = (user.userType?.rawValue)!
        dbUser.emailId = user.emailId!
        dbUser.authToken = user.authToken
        dbUser.userId = user.userId
        dbUser.firstName = user.firstName!
        dbUser.lastName = user.lastName!
        dbUser.verified = user.verified
        
        let realm = try! Realm()
        print("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            realm.add(dbUser, update: true)
            
        })
        
    }
    
    func initilizeCurrentUser(){
        
        let realm = try! Realm()
        let dbUsers = realm.objects(DBUser.self)
        let dbUser = dbUsers.last
        
        let currentUser = User.currentUser
        currentUser.firstName = dbUser?.firstName
        currentUser.lastName  = dbUser?.lastName
        currentUser.verified = dbUser?.verified
        currentUser.authToken = dbUser?.authToken
        currentUser.userId = dbUser?.userId
        currentUser.emailId = dbUser?.emailId
        currentUser.userType =  (dbUser?.userType).map { UserType(rawValue: $0) }!
    }
    
    
     //MARK:Study
    func saveStudies(studies:Array<Study>){
        
        
        var dbStudies:Array<DBStudy> = []
        for study in studies {
            
            let dbStudy = DBStudy()
            
            dbStudy.studyId = study.studyId
            dbStudy.category = study.category
            dbStudy.name = study.name
            dbStudy.sponserName = study.sponserName
            dbStudy.tagLine = study.description
            dbStudy.version = study.version
            dbStudy.logoURL = study.logoURL
            dbStudy.startDate = study.startDate
            dbStudy.endEnd = study.endEnd
            
            dbStudies.append(dbStudy)
        }
        
        let realm = try! Realm()
        print("DBPath : \(realm.configuration.fileURL)")
        try! realm.write({
            realm.add(dbStudies, update: true)
            
        })
    }
    
    class func loadStudyListFromDatabase(completionHandler:@escaping (Array<Study>) -> ()){
        
        
        let realm = try! Realm()
        let dbStudies = realm.objects(DBStudy.self)
        
        var studies:Array<Study> = []
        for study in dbStudies {
            
            let dbStudy = Study()
            
            dbStudy.studyId = study.studyId
            dbStudy.category = study.category
            dbStudy.name = study.name
            dbStudy.sponserName = study.sponserName
            dbStudy.description = study.tagLine
            dbStudy.version = study.version
            dbStudy.logoURL = study.logoURL
            dbStudy.startDate = study.startDate
            dbStudy.endEnd = study.endEnd
            
            studies.append(dbStudy)
        }
        
        completionHandler(studies)
        
        
        
    }
    
}
