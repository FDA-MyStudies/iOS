//
//  StringEncoder.swift
//  FDA
//
//  Created by Surender Rathore on 3/10/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}


extension String {
    var isAlphanumeric: Bool {
        
        
        if (Int(self) != nil){
            return false
        }
        else if !self.isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil{
           return true
        }
        else{
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
        }
    }
}
