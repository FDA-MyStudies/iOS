//
//  SyncUpdate.swift
//  FDA
//
//  Created by Arun Kumar on 19/05/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation

class SyncUpdate{
    
    var isReachabilityChanged:Bool
     static var currentSyncUpdate:SyncUpdate? = nil
   
    init() {
        self.isReachabilityChanged = false
    }
    
    @objc func updateData(){
        
    }
    
    
}
