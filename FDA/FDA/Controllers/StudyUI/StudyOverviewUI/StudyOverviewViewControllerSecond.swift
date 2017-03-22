//
//  StudyOverviewViewControllerSecond.swift
//  FDA
//
//  Created by Ravishankar on 3/1/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class StudyOverviewViewControllerSecond : UIViewController{
    
    @IBOutlet var buttonJoinStudy : UIButton?
    @IBOutlet var buttonLearnMore : UIButton?
    @IBOutlet var buttonVisitWebsite : UIButton?
    @IBOutlet var labelTitle : UILabel?
    @IBOutlet var labelDescription : UILabel?
    @IBOutlet var imageViewStudy : UIImageView?
    
    var overviewSectionDetail : OverviewSection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonJoinStudy?.layer.borderColor = kUicolorForButtonBackground
        if overviewSectionDetail.imageURL != nil {
            let url = URL.init(string:overviewSectionDetail.imageURL!)
            imageViewStudy?.sd_setImage(with: url, placeholderImage:#imageLiteral(resourceName: "OverViewBg"))
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

        //labelDescription?.text = overviewSectionDetail.text
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @IBAction func buttonActionJoinStudy(_ sender: Any){
        
        if User.currentUser.userType == UserType.AnonymousUser{
            let leftController = slideMenuController()?.leftViewController as! LeftMenuViewController
            leftController.changeViewController(.profile_signin)
        }
    }
    
    @IBAction func visitWebsiteButtonAction(_ sender: Any) {
        
        let loginStoryboard = UIStoryboard.init(name: "Main", bundle:Bundle.main)
        let webViewController = loginStoryboard.instantiateViewController(withIdentifier:"WebViewController") as! UINavigationController
        let webView = webViewController.viewControllers[0] as! WebViewController
        webView.requestLink = "http://www.fda.gov"
        self.navigationController?.present(webViewController, animated: true, completion: nil)    }
    
}
