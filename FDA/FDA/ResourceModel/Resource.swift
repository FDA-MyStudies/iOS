//
//  Resource.swift
//  FDA
//
//  Created by Arun Kumar on 2/7/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation

enum ResourceLevel:String{
    case defaultLevel = ""
    case gateway = "Gateway"
    case study = "Study"
}

class Resource{
    var level:ResourceLevel?
    var key:String?
    var type:String?
    var file:File?
    var configration:NSMutableDictionary?
    
    init() {
        self.level = ResourceLevel.defaultLevel
        self.key = ""
        self.type  = ""
        self.file = File()
        self.configration = NSMutableDictionary()
    }
    
    func setResource(dict:NSDictionary) {
        if (dict["level"]) != nil &&  Utilities.isNull(someObject:dict["level"]  as AnyObject?) == false    {
            self.level = dict["level"] as? ResourceLevel
        }
        if (dict["key"]) != nil &&  Utilities.isNull(someObject:dict["key"]  as AnyObject?) == false {
            self.key = dict["key"] as? String
        }
        if (dict["type"]) != nil &&  Utilities.isNull(someObject:dict["type"]  as AnyObject?) == false {
            self.type = dict["type"] as? String
        }
        if (dict["file"]) != nil &&  Utilities.isNull(someObject:dict["file"]  as AnyObject?) == false {
            self.file?.setFile(dict: dict["file"] as! NSDictionary)
        }
        if (dict["configration"]) != nil &&  Utilities.isNull(someObject:dict["configration"]  as AnyObject?) == false {
            self.configration = dict["configration"] as? NSMutableDictionary
        }
    }
    
}
