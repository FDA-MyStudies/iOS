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
let kResourceConfigration = "availability"
let kResourceTitle = "title"


class Resource{
    var level:ResourceLevel?
    var key:String?
    var type:String?
    var file:File?
    var audience:Audience?
    var resourcesId:String?
    var configration:Dictionary<String, Any>?
    var startDate:Date?
    var endDate:Date?
    var anchorDateStartDays:Int?
    var anchorDateEndDays:Int?
    var title:String?
    
    init() {
        self.level = ResourceLevel.gateway
        self.key = ""
        self.type  = ""
        self.file = File()
        self.configration = Dictionary()
        self.title = ""
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
                let configuration = detail[kResourceConfigration] as! Dictionary<String,Any>
                
                if (Utilities.isValidValue(someObject: (configuration["availableDate"]) as AnyObject)) {
                    self.startDate = Utilities.getDateFromStringWithFormat("YYYY-MM-dd", resultDate: configuration["availableDate"] as! String)
                }
                if (Utilities.isValidValue(someObject: (configuration["expiryDate"]) as AnyObject)) {
                    self.startDate = Utilities.getDateFromStringWithFormat("YYYY-MM-dd", resultDate: configuration["expiryDate"] as! String)
                }
                
                self.anchorDateStartDays = configuration["startDays"] as? Int
                self.anchorDateEndDays = configuration["endDays"] as? Int
                
            }
            
            if (Utilities.isValidValue(someObject: (detail[kResourceTitle]) as AnyObject)) {
                self.title = detail[kResourceTitle] as? String
            }
            
            self.file = File()
            self.file?.setFileForStudy(dict:detail as NSDictionary)
            
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
            
            if self.level != nil {
                
                if self.level == ResourceLevel.study {
                    // level = study
                    self.file?.setFileForStudy(dict:dict)
                }
                else if self.level == ResourceLevel.gateway {
                    // level = gateway
                    
                    if (Utilities.isValidValue(someObject: (dict[kResourceFile]) as AnyObject)) {
                        self.file?.setFile(dict: dict[kResourceFile] as! NSDictionary)
                    }
                }
            }
            
            
            if (Utilities.isValidObject(someObject: dict[kResourceConfigration] as AnyObject)) {
                let configuration = dict[kResourceConfigration] as! Dictionary<String,Any>
                
                if (Utilities.isValidValue(someObject: (configuration["availableDate"]) as AnyObject)) {
                    self.startDate = Utilities.getDateFromStringWithFormat("YYYY-MM-dd", resultDate: configuration["availableDate"] as! String)
                }
                if (Utilities.isValidValue(someObject: (configuration["expiryDate"]) as AnyObject)) {
                    self.endDate = Utilities.getDateFromStringWithFormat("YYYY-MM-dd", resultDate: configuration["expiryDate"] as! String)
                }
                
                self.anchorDateStartDays = configuration["startDays"] as! Int
                self.anchorDateEndDays = configuration["endDays"] as! Int
                
            }
            if (Utilities.isValidValue(someObject: (dict[kResourceTitle]) as AnyObject)) {
                self.title = dict[kResourceTitle] as? String
            }

        }
        else{
            Logger.sharedInstance.debug("Resource Dictionary is null:\(dict)")
        }
        
    }
    
}
