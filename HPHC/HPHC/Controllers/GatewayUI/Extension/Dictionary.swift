//
//  Dictionary.swift
//  HPHC
//
//  Created by Arun Kumar on 15/03/19.
//  Copyright © 2019 BTC. All rights reserved.
//

import UIKit

extension Dictionary {
    func preetyJSON() -> String {
        
        let jsonData = try! JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        return jsonString
    }
}
