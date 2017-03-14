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
    
    func moviePlayBackDidFinish(notification: NSNotification) {
        //  println("moviePlayBackDidFinish:")
        moviePlayer.moviePlayer.stop()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
        moviePlayer.dismiss(animated: true, completion: nil)
    }
    
    //Watchvideo Button Action
    @IBAction func watchVideoButtonClicked(_ sender: Any){
        
        let url : NSURL = NSURL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
        moviePlayer = MPMoviePlayerViewController(contentURL:url as URL!)
        
        moviePlayer.moviePlayer.movieSourceType = .streaming
        
        NotificationCenter.default.addObserver(self, selector:#selector(StudyOverviewViewControllerFirst.moviePlayBackDidFinish(notification:)),
                                               name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
                                               object: moviePlayer.moviePlayer)
        
        self.present(moviePlayer, animated: true, completion: nil)
    
    }
    
    //GetStarted Button Action
    @IBAction func getStartedButtonClicked(_ sender: Any){
        
        self.createMenuView()
    }
    
    
    func createMenuView() {
        
        //self.performSegue(withIdentifier: "menuSegue", sender: self)
        
        //        // create viewController code...
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
        //
        //        let mainViewController = storyboard.instantiateViewController(withIdentifier: "StudyListViewController") as! UINavigationController
        //        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftMenuViewController") as! LeftMenuViewController
        //
        //        leftViewController.studyListViewController = mainViewController
        
        
        let fda = storyboard.instantiateViewController(withIdentifier: "FDASlideMenuViewController") as! FDASlideMenuViewController
        // fda.mainViewController = mainViewController
        // fda.leftViewController = leftViewController
        
        //let slideMenuController = FDASlideMenuViewController(mainViewController:mainViewController, leftMenuViewController: leftViewController)
        
        fda.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.pushViewController(fda, animated: true)

    }
}


