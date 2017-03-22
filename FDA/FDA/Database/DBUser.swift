//
//  DBUser.swift
//  FDA
//
//  Created by Surender Rathore on 3/22/17.
//  Copyright © 2017 BTC. All rights reserved.
//


import RealmSwift

class DBUser: Object {
    
    dynamic var firstName : String = ""
    dynamic var lastName :String = ""
    dynamic var emailId : String = ""
   
    dynamic var userId : String = ""
    dynamic var verified : Bool = false
    dynamic var authToken: String = ""
    dynamic var userType:Int = UserType.AnonymousUser.rawValue
   
    override static func primaryKey() -> String? {
        return "userId"
    }
    
    
}
