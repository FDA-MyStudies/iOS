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
    dynamic var identifer:String?
    dynamic var category:String?
    dynamic var startDate:String?
    dynamic var endEnd:String?
    dynamic var status:Int = 0
    dynamic var sponserName:String?
    dynamic var tagLine:String?
    dynamic var brandingConfiguration:String?
    dynamic var logoURL:String?
    
    
    override static func primaryKey() -> String? {
        return "studyId"
    }
    
}
