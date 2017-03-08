//
//  FirstViewController.swift
//  FDA
//
//  Created by Ravishankar on 2/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class FirstGatewayOverviewViewController : UIViewController{
    
    var tableViewRowDetails : NSMutableArray!
    
    @IBOutlet var imageViewBackgroundImage : UIImageView?
    @IBOutlet var buttonWatchVideo : UIButton?
    @IBOutlet var buttonGetStarted : UIButton?
    @IBOutlet var labelDescriptionText : UILabel?
    @IBOutlet var labelTitleText : UILabel?
    
    var overviewSectionDetail : OverviewSection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create effect
        //let blur = UIBlurEffect(style: UIBlurEffectStyle.dark)
        
        // add effect to an effect view
        //let effectView = UIVisualEffectView(effect: blur)
        //effectView.frame = (imageViewBackgroundImage?.frame)!
        //self.imageViewBackgroundImage?.addSubview(effectView)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        labelTitleText?.text = overviewSectionDetail.title

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    //Watchvideo Button Action
    @IBAction func watchVideoButtonClicked(_ sender: Any){
    
    
    }
    
    //GetStarted Button Action
    @IBAction func getStartedButtonClicked(_ sender: Any){
        
        
    }
}


