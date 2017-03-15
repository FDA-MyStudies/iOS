//
//  Gateway.swift
//  FDA
//
//  Created by Surender Rathore on 2/14/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class Gateway: NSObject {

    var studies:Array<Study>? = []
    var resources:Array<Resource>? = []
    var notification:Array<AppNotification>? = []
    var overview:Overview?
    static var instance = Gateway()
}
