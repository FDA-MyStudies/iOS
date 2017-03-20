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
         UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        labelHeadingText?.text = overviewSectionDetail.title
        labelDescriptionText?.text = overviewSectionDetail.text
        imageViewBackgroundImage?.image = UIImage.init(named: overviewSectionDetail.imageURL!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    //GetStarted Button Action
    @IBAction func getStartedButtonClicked(_ sender: Any){
        
        
        self.createMenuView()
    }
    
    
    func createMenuView() {
        
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
        
        let fda = storyboard.instantiateViewController(withIdentifier: "FDASlideMenuViewController") as! FDASlideMenuViewController
        fda.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.pushViewController(fda, animated: true)
        
    }}
