//
//  ViewController.swift
//  FDA
//
//  Created by Arun Kumar on 2/2/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

let user = User()


let resourceArray : Array<Any>? = nil
class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.userProfile()
        self.setPrefereneces()
        self.addResources()
    }

    //MARK: methods
    
    func addResources()  {
        
        if let path = Bundle.main.path(forResource: "Resources", ofType: "plist") {
            
           if let responseArray = NSArray(contentsOfFile: path) {
            
            if Utilities.isValidObject(someObject: responseArray) {
            
                for i in 0 ..< responseArray.count {
                    
                    if Utilities.isValidObject(someObject:responseArray[i] as AnyObject? )  {
                        let resource:Resource? = Resource()
                        
                        resource?.setResource(dict:(responseArray[i] as? NSDictionary)! )
                        responseArray.adding(resource as Any)
                    }
                    
                }
            }
            
            }
            
            if let dict = NSDictionary(contentsOfFile: path) as? [String:Any] {
                user.setUser(dict:dict as NSDictionary)
                
                Logger.sharedInstance.debug(dict)
                Logger.sharedInstance.info(dict)
                Logger.sharedInstance.error(dict)
                
                
            }
        }
        
    }

    
    
    func userProfile()  {
        
        if let path = Bundle.main.path(forResource: "UserProfile", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? [String:Any] {
                user.setUser(dict:dict as NSDictionary)
            
                Logger.sharedInstance.debug(dict)
                Logger.sharedInstance.info(dict)
                Logger.sharedInstance.error(dict)
              
                
            }
        }
        
    }
    
    func setPrefereneces()  {
        
        if let path = Bundle.main.path(forResource: "UserPreferences", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? [String:Any] {
                user.setUser(dict:dict as NSDictionary)
            }
        }
        
    }

    
    
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


