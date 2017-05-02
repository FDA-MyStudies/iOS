//
//  AppUpdateBlocker.swift
//  FDA
//
//  Created by Surender Rathore on 5/2/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class AppUpdateBlocker: UIView {

    @IBOutlet var buttonUpgrade:UIButton!
    @IBOutlet var labelMessage:UILabel!
    @IBOutlet var labelVersionNumber:UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    class func instanceFromNib(frame:CGRect,detail:Dictionary<String,Any>) -> AppUpdateBlocker {
        
        let view = UINib(nibName: "AppUpdateBlocker", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AppUpdateBlocker
        view.frame = frame
        view.layoutIfNeeded()
        return view
        
    }

    @IBAction func buttonUpgradeAction(){
        UIApplication.shared.openURL(URL(string:"https://itunes.apple.com/us/app/hey-there.../id1032962936?ls=1&mt=8")!)
    }

}
