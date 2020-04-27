//
//  Data+Extensions.swift
//  HPHC
//
//  Created by Tushar Katyal on 14/02/20.
//  Copyright © 2020 BTC. All rights reserved.
//

import Foundation

extension Data {
    func toJSONDictionary() -> [String: AnyObject]? {
        
        guard let json = try? JSONSerialization.jsonObject(with: self as Data, options: [.allowFragments]) else {
            return nil
        }
        guard let jsonDic = json as? [String: AnyObject] else {
            return nil
        }
        return jsonDic
    }
}

