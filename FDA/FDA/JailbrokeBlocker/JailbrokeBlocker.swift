//
//  JailbrokeBlocker.swift
//  FDA
//
//  Created by Arun Kumar on 5/2/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class JailbrokeBlocker: UIView {

    @IBOutlet var buttonUpgrade:UIButton!
    @IBOutlet var labelMessage:UILabel!
    @IBOutlet var labelVersionNumber:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        //Used to set border color for bottom view
        buttonUpgrade?.layer.borderColor = UIColor.white.cgColor
    }
    class func instanceFromNib(frame:CGRect,detail:Dictionary<String,Any>?) -> JailbrokeBlocker {
        
        let view = UINib(nibName: "JailbrokeBlocker", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! JailbrokeBlocker
        view.frame = frame
        view.layoutIfNeeded()
        return view
        
    }

    @IBAction func buttonUpgradeAction(){
        UIApplication.shared.openURL(URL(string:"https://itunes.apple.com/us/app/fda-my-studies/id1242835330?ls=1&mt=8")!)
    }

}
