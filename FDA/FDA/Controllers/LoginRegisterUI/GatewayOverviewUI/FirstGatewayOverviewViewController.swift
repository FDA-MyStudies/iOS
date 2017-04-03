//
//  FirstViewController.swift
//  FDA
//
//  Created by Ravishankar on 2/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class FirstGatewayOverviewViewController : UIViewController{
    
    var tableViewRowDetails : NSMutableArray!
    
    @IBOutlet var imageViewBackgroundImage : UIImageView?
    @IBOutlet var buttonWatchVideo : UIButton?
    @IBOutlet var buttonGetStarted : UIButton?
    @IBOutlet var labelDescriptionText : UILabel?
    @IBOutlet var labelTitleText : UILabel?
    
    var overviewSectionDetail : OverviewSection!
    var moviePlayer:MPMoviePlayerViewController!
    
//MARK:View Controller Delegate
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
        labelDescriptionText?.text = overviewSectionDetail.text
        imageViewBackgroundImage?.image = UIImage.init(named: overviewSectionDetail.imageURL!)
        
        UIApplication.shared.statusBarStyle = .lightContent

    }
    override func viewDidDisappear(_ animated: Bool) {
       
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
//MARK: Movie Player methods
    func moviePlayBackDidFinish(notification: NSNotification) {
        //  println("moviePlayBackDidFinish:")
        moviePlayer.moviePlayer.stop()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
        moviePlayer.dismiss(animated: true, completion: nil)
    }
    
//MARK:Button Action
    @IBAction func watchVideoButtonClicked(_ sender: Any){
        
        
        let urlString = overviewSectionDetail.link!
        if urlString.contains("youtube"){
            let url = URL.init(string: urlString)
            UIApplication.shared.openURL(url!)
        }
        else {
            
            let url = URL.init(string: urlString)
            
            moviePlayer = MPMoviePlayerViewController(contentURL:url)
            moviePlayer.moviePlayer.movieSourceType = .streaming
            
            NotificationCenter.default.addObserver(self, selector:#selector(StudyOverviewViewControllerFirst.moviePlayBackDidFinish(notification:)),
            name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
            object: moviePlayer.moviePlayer)
            
            self.present(moviePlayer, animated: true, completion: nil)
        }
        
       
    
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

    }
}


