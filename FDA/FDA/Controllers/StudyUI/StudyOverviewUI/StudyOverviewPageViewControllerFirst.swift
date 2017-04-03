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
import ResearchKit

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
            imageViewStudy?.sd_setImage(with: url, placeholderImage:nil)
        }
        
        if overviewSectionDetail.link != nil {
            buttonWatchVideo?.isHidden = false
        }
        else{
             buttonWatchVideo?.isHidden =  true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         labelTitle?.text = overviewSectionDetail.title
        
        var fontSize = 18.0
        if DeviceType.IS_IPAD || DeviceType.IS_IPHONE_4_OR_LESS {
            fontSize = 13.0
        }
        else if DeviceType.IS_IPHONE_5 {
            fontSize = 14.0
        }
        
        
        let attrStr = try! NSAttributedString(
            data: (overviewSectionDetail.text?.data(using: String.Encoding.unicode, allowLossyConversion: true)!)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(attributedString: attrStr)
        attributedText.addAttributes([NSFontAttributeName:UIFont(
            name: "HelveticaNeue",
            size: CGFloat(fontSize))!], range:(attrStr.string as NSString).range(of: attrStr.string))
        attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: (attrStr.string as NSString).range(of: attrStr.string))
        
        
        
        
        if Utilities.isValidValue(someObject: attrStr.string as AnyObject?){
             self.labelDescription?.attributedText = attributedText
        }
        else{
             self.labelDescription?.text = ""
        }
       self.labelDescription?.textAlignment = .center
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        //self.labelDescription?.text = overviewSectionDetail.text!
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
      
    }
   
    
    @IBAction func watchVideoButtonAction(_ sender: Any) {
        
        let urlString = overviewSectionDetail.link!
        let url = URL.init(string: urlString)
        let extenstion = url?.pathExtension
    
        if  extenstion == nil || extenstion?.characters.count == 0 {
            
            
            UIApplication.shared.openURL(url!)
            
        }
        else {
            
            let url : NSURL = NSURL(string: overviewSectionDetail.link!)!
            moviePlayer = MPMoviePlayerViewController(contentURL:url as URL!)
            
            moviePlayer.moviePlayer.movieSourceType = .streaming
            
            NotificationCenter.default.addObserver(self, selector:#selector(StudyOverviewViewControllerFirst.moviePlayBackDidFinish(notification:)),
                                                   name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
                                                   object: moviePlayer.moviePlayer)
            
            self.present(moviePlayer, animated: true, completion: nil)

        }
        
        
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

//MARK:WCPServices Response handler

extension StudyOverviewViewControllerFirst:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        if requestName as String ==  RegistrationMethods.logout.description {
            
            
        }
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
       
        
    }
}

    

    
    

