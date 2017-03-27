//
//  StudyOverviewPageViewControllerFirst.swift
//  FDA
//
//  Created by Ravishankar on 3/1/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import SDWebImage

class StudyOverviewViewControllerFirst : UIViewController{
    
    @IBOutlet var buttonJoinStudy : UIButton?
    @IBOutlet var buttonWatchVideo : UIButton?
    @IBOutlet var buttonVisitWebsite : UIButton?
    @IBOutlet var labelTitle : UILabel?
    @IBOutlet var labelDescription : UILabel?
    @IBOutlet var imageViewStudy : UIImageView?
    
    var overViewWebsiteLink : String?
    var overviewSectionDetail : OverviewSection!
    
    var moviePlayer:MPMoviePlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonJoinStudy?.layer.borderColor = kUicolorForButtonBackground
        if overviewSectionDetail.imageURL != nil {
            let url = URL.init(string:overviewSectionDetail.imageURL!)
            imageViewStudy?.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "OverViewBg"))
        }
        
        if overviewSectionDetail.link != nil {
            buttonWatchVideo?.isHidden = false
        }
        else{
             buttonWatchVideo?.isHidden =  true
        }
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         labelTitle?.text = overviewSectionDetail.title
        
        
        let attrStr = try! NSAttributedString(
            data: (overviewSectionDetail.text?.data(using: String.Encoding.unicode, allowLossyConversion: true)!)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        if Utilities.isValidValue(someObject: attrStr.string as AnyObject?){
             self.labelDescription?.text = attrStr.string
        }
        else{
             self.labelDescription?.text = ""
        }
       
        
        
        //self.labelDescription?.text = overviewSectionDetail.text!
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
   
    
    @IBAction func watchVideoButtonAction(_ sender: Any) {
        
        let url : NSURL = NSURL(string: overviewSectionDetail.link!)!
        moviePlayer = MPMoviePlayerViewController(contentURL:url as URL!)
        
        moviePlayer.moviePlayer.movieSourceType = .streaming
        
        NotificationCenter.default.addObserver(self, selector:#selector(StudyOverviewViewControllerFirst.moviePlayBackDidFinish(notification:)),
                                               name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
                                               object: moviePlayer.moviePlayer)
        
        self.present(moviePlayer, animated: true, completion: nil)
        
    }
    
    @IBAction func buttonActionJoinStudy(_ sender: Any){
        
        if User.currentUser.userType == UserType.AnonymousUser{
            let leftController = slideMenuController()?.leftViewController as! LeftMenuViewController
            leftController.changeViewController(.reachOut_signIn)
        }
    }
    
    func moviePlayBackDidFinish(notification: NSNotification) {
        //  println("moviePlayBackDidFinish:")
        moviePlayer.moviePlayer.stop()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
        moviePlayer.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func visitWebsiteButtonAction(_ sender: Any) {
        
        if overViewWebsiteLink != nil {
            
            let loginStoryboard = UIStoryboard.init(name: "Main", bundle:Bundle.main)
            let webViewController = loginStoryboard.instantiateViewController(withIdentifier:"WebViewController") as! UINavigationController
            let webView = webViewController.viewControllers[0] as! WebViewController
            
            webView.requestLink = overViewWebsiteLink!
            self.navigationController?.present(webViewController, animated: true, completion: nil)
        }
    }
    
}
