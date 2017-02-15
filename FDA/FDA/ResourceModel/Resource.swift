//
//  Resource.swift
//  FDA
//
//  Created by Arun Kumar on 2/7/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation




enum ResourceLevel:String{
  
    case gateway = "gateway"
    case study = "study"
}

let kResourceLevel = "level"
let kResourceKey = "key"
let kResourceType = "type"
let kResourceFile = "file"
let kResourceConfigration = "configration"



class Resource{
    var level:ResourceLevel?
    var key:String?
    var type:String?
    var file:File?
    var configration:Dictionary<String, Any>?
    
    init() {
        self.level = ResourceLevel.gateway
        self.key = ""
        self.type  = ""
        self.file = File()
        self.configration = Dictionary()
    }
    
    init(detail:Dictionary<String, Any>) {
        
        if Utilities.isValidObject(someObject: detail as AnyObject?){
            
            if (Utilities.isValidValue(someObject: (detail[kResourceLevel]) as AnyObject)) {
                self.level = detail[kResourceLevel] as? ResourceLevel
            }
            if (Utilities.isValidValue(someObject: (detail[kResourceKey]) as AnyObject)){
                self.key = detail[kResourceKey] as? String
            }
            if (Utilities.isValidValue(someObject: (detail[kResourceType]) as AnyObject)) {
                self.type = detail[kResourceType] as? String
            }
            if (Utilities.isValidValue(someObject: (detail[kResourceFile]) as AnyObject)) {
                self.file?.setFile(dict: detail[kResourceFile] as! NSDictionary)
            }
            if (Utilities.isValidObject(someObject: detail[kResourceConfigration] as AnyObject)) {
                self.configration = detail[kResourceConfigration] as? Dictionary
            }
        }
        else{
            Logger.sharedInstance.debug("Resource Dictionary is null:\(detail)")
        }
    }
    
    func setResource(dict:NSDictionary) {
        
        
        if Utilities.isValidObject(someObject: dict){
            
            if (Utilities.isValidValue(someObject: (dict[kResourceLevel]) as AnyObject)) {
                self.level = dict[kResourceLevel] as? ResourceLevel
            }
            if (Utilities.isValidValue(someObject: (dict[kResourceKey]) as AnyObject)){
                self.key = dict[kResourceKey] as? String
            }
            if (Utilities.isValidValue(someObject: (dict[kResourceType]) as AnyObject)) {
                self.type = dict[kResourceType] as? String
            }
            if (Utilities.isValidValue(someObject: (dict[kResourceFile]) as AnyObject)) {
                self.file?.setFile(dict: dict[kResourceFile] as! NSDictionary)
            }
            if (Utilities.isValidObject(someObject: dict[kResourceConfigration] as AnyObject)) {
                self.configration = dict[kResourceConfigration] as? Dictionary
            }
        }
        else{
            Logger.sharedInstance.debug("Resource Dictionary is null:\(dict)")
        }
        
}
    
}
