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
    var pageIndex:Int!
    
//MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonGetStarted?.layer.borderColor = kUicolorForButtonBackground
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        labelHeadingText?.text = overviewSectionDetail.title
       
        print("size: \(labelHeadingText?.text?.characters.count)")
        
        labelDescriptionText?.text = overviewSectionDetail.text
        imageViewBackgroundImage?.image = UIImage.init(named: overviewSectionDetail.imageURL!)
         UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
//MARK:- Button Actions
    
    /* GetStarted Button Clicked */
    @IBAction func getStartedButtonClicked(_ sender: Any){
        self.createMenuView()
    }
    
    /* Create the menu view using FDASlideMenuViewController and Gateway storyboard */
    func createMenuView() {
        
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
        
        let fda = storyboard.instantiateViewController(withIdentifier: "FDASlideMenuViewController") as! FDASlideMenuViewController
        fda.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.pushViewController(fda, animated: true)
        
    }}
