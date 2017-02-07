//
//  ViewController.swift
//  FDA
//
//  Created by Arun Kumar on 2/2/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

let user = User()


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.userProfile()
        self.setPrefereneces()
    }

    //MARK: methods
    
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


