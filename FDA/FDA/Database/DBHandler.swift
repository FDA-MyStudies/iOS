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
    
}
