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
import AVKit

class FirstGatewayOverviewViewController : UIViewController{
    
    var tableViewRowDetails : NSMutableArray!
    
    @IBOutlet var imageViewBackgroundImage : UIImageView?
    @IBOutlet var buttonWatchVideo : UIButton?
    @IBOutlet var buttonGetStarted : UIButton?
    @IBOutlet var labelDescriptionText : UILabel?
    @IBOutlet var labelTitleText : UILabel?
    
    var pageIndex:Int!
    var overviewSectionDetail : OverviewSection!
    var moviePlayer:MPMoviePlayerViewController!
    var playerViewController:AVPlayerViewController!
    
    
//MARK:- View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create effect
        //let blur = UIBlurEffect(style: UIBlurEffectStyle.dark)
        
        // add effect to an effect view
        //let effectView = UIVisualEffectView(effect: blur)
        //effectView.frame = (imageViewBackgroundImage?.frame)!
        //self.imageViewBackgroundImage?.addSubview(effectView)
    
        
        if overviewSectionDetail.link == nil {
            buttonWatchVideo?.isHidden = true
        }
        
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
    
//MARK:- Movie Player methods
    
    /**
     
     Movie player completion method
     
     @param notification    receives the paticular video completion notification

     */
    func moviePlayBackDidFinish(notification: NSNotification) {
        //  println("moviePlayBackDidFinish:")
        moviePlayer.moviePlayer.stop()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
        moviePlayer.dismiss(animated: true, completion: nil)
    }
    func playerDidFinishPlaying(note: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        self.playerViewController.dismiss(animated: true, completion: nil)
    }
    
    
//MARK:- Button Action
    
    /**
     
     Watch video button clicked
     
     @param sender    accepts any kind of object

     */
    @IBAction func watchVideoButtonClicked(_ sender: Any){
        let urlString = overviewSectionDetail.link!
        if urlString.contains("youtube"){
            let url = URL.init(string: urlString)
            UIApplication.shared.openURL(url!)
        }
        else {
            
            let url = URL.init(string: urlString)
            
//            moviePlayer = MPMoviePlayerViewController(contentURL:url)
//            moviePlayer.moviePlayer.movieSourceType = .streaming
//            
//            NotificationCenter.default.addObserver(self, selector:#selector(StudyOverviewViewControllerFirst.moviePlayBackDidFinish(notification:)),
//            name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
//            object: moviePlayer.moviePlayer)
//            
//            self.present(moviePlayer, animated: true, completion: nil)
            
            let player = AVPlayer(url: url!)
            NotificationCenter.default.addObserver(self, selector:#selector(StudyOverviewViewControllerFirst.playerDidFinishPlaying(note:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                self.playerViewController.player!.play()
            }
        }
    }
    
    
    /**
     
     This method is used to create FDASlideMenuViewController and Gateway storyboard
     
     @param sender    accepts any kind of object

     */
    @IBAction func getStartedButtonClicked(_ sender: Any){
        self.createMenuView()
    }
    
    
    /**
     
     Create the menu view using FDASlideMenuViewController and Gateway storyboard

     */
    func createMenuView() {
        
        let storyboard = UIStoryboard(name: kStoryboardIdentifierGateway, bundle: nil)
        
        let fda = storyboard.instantiateViewController(withIdentifier: kStoryboardIdentifierSlideMenuVC) as! FDASlideMenuViewController
             fda.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.pushViewController(fda, animated: true)

    }
}

