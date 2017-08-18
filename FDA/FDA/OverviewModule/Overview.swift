//
//  Overview.swift
//  FDA
//
//  Created by Surender Rathore on 2/14/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

let kOverViewWebsiteLink = "studyWebsite"

class Overview {
    enum OverviewType:Int {
        case gateway
        case study
    }
    var sections:Array<OverviewSection>!
    var type:OverviewType = .gateway
    var websiteLink:String?
}

class OverviewSection {
    
    var title:String?           //title of overview
    var type:String?            //type of overview video/image
    var imageURL:String?        //download url of image
    var text:String?            //short description
    var link:String?            //used for media link
    var websiteLink:String?     //used for Website link
    
    init(){
        
    }
    
    init(detail:Dictionary<String, Any>){
        
        /* Checks the Object (Array or Dictionary) is valid or not */
        if Utilities.isValidObject(someObject: detail as AnyObject?){
            
            /* Checks the Title value (Null, Nil, empty etc) is valid or not */
            if Utilities.isValidValue(someObject: detail[kOverviewTitle] as AnyObject ){
                self.title = detail[kOverviewTitle] as? String
            }
            /* Checks the Type value (Null, Nil, empty etc) is valid or not */
            if Utilities.isValidValue(someObject: detail[kOverviewType] as AnyObject ){
                self.type = detail[kOverviewType] as? String
            }
            /* Checks the Text value (Null, Nil, empty etc) is valid or not */
            if Utilities.isValidValue(someObject: detail[kOverviewText] as AnyObject ){
                self.text = detail[kOverviewText] as? String
            }
            /* Checks the Link value (Null, Nil, empty etc) is valid or not */
            if Utilities.isValidValue(someObject: detail[kOverviewImageLink] as AnyObject ){
                self.imageURL = detail[kOverviewImageLink] as? String
            }
            /* Checks the MediaLink value (Null, Nil, empty etc) is valid or not */
            if Utilities.isValidValue(someObject: detail[kOverviewMediaLink] as AnyObject ) {
                self.link = detail[kOverviewMediaLink] as? String
            }
            /* Checks the WebsiteLink value (Null, Nil, empty etc) is valid or not */
            if Utilities.isValidValue(someObject: detail[kOverviewWebsiteLink] as AnyObject ) {
                self.websiteLink = detail[kOverviewWebsiteLink] as? String
            }
        }
        else{
            Logger.sharedInstance.debug("Overview Dictionary is null:\(detail)")
        }
    }
}
