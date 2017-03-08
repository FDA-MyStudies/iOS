//
//  SecondViewController.swift
//  FDA
//
//  Created by Ravishankar on 2/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class SecondGatewayOverviewViewController : UIViewController{
    
    @IBOutlet var imageViewBackgroundImage : UIImageView?
    @IBOutlet var labelHeadingText : UILabel?
    @IBOutlet var labelDescriptionText : UILabel?
    @IBOutlet var buttonGetStarted : UIButton?
    var overviewSectionDetail : OverviewSection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonGetStarted?.layer.borderColor = kUicolorForButtonBackground
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        labelHeadingText?.text = overviewSectionDetail.title
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    //GetStarted Button Action
    @IBAction func getStartedButtonClicked(_ sender: Any){
        
        
    }
}
