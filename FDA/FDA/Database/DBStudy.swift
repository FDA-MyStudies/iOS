//
//  DBStudy.swift
//  FDA
//
//  Created by Surender Rathore on 3/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import RealmSwift

class DBStudy: Object {
    
    dynamic var studyId:String!
    dynamic var name:String?
    dynamic var version:String?
    dynamic var updatedVersion:String?
    dynamic var identifer:String?
    dynamic var category:String?
    dynamic var startDate:String?
    dynamic var endEnd:String?
    dynamic var status:Int = 0
    dynamic var sponserName:String?
    dynamic var tagLine:String?
    dynamic var brandingConfiguration:String?
    dynamic var logoURL:String?
    dynamic  var websiteLink:String?
    dynamic  var bookmarked:String?
    dynamic  var participatedStatus:Int = 0
    dynamic var updateResources : Bool = false
    dynamic var updateActivities : Bool = false
    dynamic var updateConsent : Bool = false
    dynamic var updateInfo : Bool = false
    var sections = List<DBOverviewSection>()
    
    override static func primaryKey() -> String? {
        return "studyId"
    }
    
}

class DBOverviewSection: Object {
    
    dynamic  var title:String?
    dynamic  var type:String?
    dynamic  var imageURL:String?
    dynamic  var text:String?
    dynamic  var link:String?
    dynamic var  studyId:String!
    dynamic var  sectionId:String!
    
    override static func primaryKey() -> String? {
        return "sectionId"
    }
}
