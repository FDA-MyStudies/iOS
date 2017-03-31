//
//  StudyHomeViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/9/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit


protocol StudyHomeViewDontrollerDelegate {
    func studyHomeJoinStudy()
}

class StudyHomeViewController : UIViewController{
    
    @IBOutlet weak var container : UIView!
    @IBOutlet var pageControlView : UIPageControl?
    @IBOutlet var buttonBack : UIButton!
    @IBOutlet var buttonStar : UIButton!
    @IBOutlet var buttonJoinStudy : UIButton?
    @IBOutlet var visitWebsiteButtonLeadingConstraint:NSLayoutConstraint?
    @IBOutlet var buttonVisitWebsite : UIButton?
    @IBOutlet var buttonViewConsent : UIButton?
    
    @IBOutlet var viewBottombarBg :UIView?
    
    @IBOutlet var viewSeperater: UIView?
    
    var delegate:StudyHomeViewDontrollerDelegate?
    
    var pageViewController: PageViewController? {
        didSet {
            pageViewController?.pageViewDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.loadTestData()
        self.automaticallyAdjustsScrollViewInsets = false
        //Added to change next screen
        pageControlView?.addTarget(self, action:#selector(StudyHomeViewController.didChangePageControlValue), for: .valueChanged)
        
        
        // pageViewController?.overview = Gateway.instance.overview
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if User.currentUser.userType == UserType.AnonymousUser {
            buttonStar.isHidden = true
        }
        
        
        
        if Study.currentStudy?.studyId != nil {
            WCPServices().getConsentDocument(studyId: (Study.currentStudy?.studyId)!, delegate: self as NMWebServiceDelegate)
        }
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //hide navigationbar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        
        
        
        
        if Utilities.isValidValue(someObject: Study.currentStudy?.overview.websiteLink as AnyObject? ) ==  false{
            // if website link is nil
            
            buttonVisitWebsite?.isHidden =  true
            visitWebsiteButtonLeadingConstraint?.constant = UIScreen.main.bounds.size.width/2 - 13
            viewSeperater?.isHidden = true
        }
        else{
            buttonVisitWebsite?.isHidden = false
            visitWebsiteButtonLeadingConstraint?.constant = 0
            viewSeperater?.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func loadTestData(){
        //        let filePath  = Bundle.main.path(forResource: "GatewayOverview", ofType: "json")
        //        let data = NSData(contentsOfFile: filePath!)
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "StudyOverview", ofType: ".plist", inDirectory:nil)
        let arrayContent = NSMutableArray.init(contentsOfFile: plistPath!)
        
        do {
            //let response = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
            
            
            //let overviewList = response[kOverViewInfo] as! Array<Dictionary<String,Any>>
            var listOfOverviews:Array<OverviewSection> = []
            for overview in arrayContent!{
                let overviewObj = OverviewSection(detail: overview as! Dictionary<String, Any>)
                listOfOverviews.append(overviewObj)
            }
            
            //create new Overview object
            let overview = Overview()
            overview.type = .study
            overview.sections = listOfOverviews
            
            //assgin to Gateway
            Gateway.instance.overview = overview
            
            
        } catch {
            print("json error: \(error.localizedDescription)")
        }
    }
    
    
    
    @IBAction func buttonActionJoinStudy(_ sender: UIButton){
        if User.currentUser.userType == UserType.AnonymousUser{
            //let leftController = slideMenuController()?.leftViewController as! LeftMenuViewController
            //leftController.changeViewController(.reachOut_signIn)
            
            
            
//            let loginStoryBoard = UIStoryboard(name: "Login", bundle: nil)
//            let signInController = loginStoryBoard.instantiateViewController(withIdentifier:  String(describing: SignInViewController.classForCoder())) as! SignInViewController
//            signInController.viewLoadFrom = .joinStudy
//            self.navigationController?.pushViewController(signInController, animated: true)
            
            
            _ = self.navigationController?.popViewController(animated: true)
            self.delegate?.studyHomeJoinStudy()
            
        }
        else {
              UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kAlertMessageText, comment: "") as NSString, message:NSLocalizedString(kAlertMessageReachoutText, comment: "") as NSString)
        }
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func starButtonAction(_ sender: Any) {
        if (sender as! UIButton).isSelected{
            (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
            
        }else{
            (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
        }
    }
    
    @IBAction func visitWebsiteButtonAction(_ sender: UIButton) {
        
        let loginStoryboard = UIStoryboard.init(name: "Main", bundle:Bundle.main)
        let webViewController = loginStoryboard.instantiateViewController(withIdentifier:"WebViewController") as! UINavigationController
        let webView = webViewController.viewControllers[0] as! WebViewController
       
        
        
        if sender.tag == 1188 {
            //Visit Website
            webView.requestLink = Study.currentStudy?.overview.websiteLink
            
        } else {
            //View Consent
            webView.htmlString = (Study.currentStudy?.consentDocument?.htmlString)
        }
        
        
        self.navigationController?.present(webViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func unwindeToStudyHome(_ segue:UIStoryboardSegue){
        //unwindStudyHomeSegue
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageViewController = segue.destination as? PageViewController {
            pageViewController.pageViewDelegate = self
            pageViewController.overview = Study.currentStudy?.overview
        }
    }
    
    //Fired when the user taps on the pageControl to change its current page (Commented as this is not working)
    func didChangePageControlValue() {
        pageViewController?.scrollToViewController(index: (pageControlView?.currentPage)!)
    }
}

//MARK: Page Control Delegates for handling Counts
extension StudyHomeViewController: PageViewControllerDelegate {
    
    func pageViewController(pageViewController: PageViewController, didUpdatePageCount count: Int){
        pageControlView?.numberOfPages = count
        
    }
    
    func pageViewController(pageViewController: PageViewController, didUpdatePageIndex index: Int) {
        pageControlView?.currentPage = index
        
        buttonJoinStudy?.layer.borderColor = kUicolorForButtonBackground
        if index == 0 {
            // for First Page
            
            
            
            UIView.animate(withDuration: 0.1, animations: {
                self.buttonJoinStudy?.backgroundColor = kUIColorForSubmitButtonBackground
                self.buttonJoinStudy?.setTitleColor(UIColor.white, for: .normal)
               
            })
            
            
            
        } else {
            // for All other pages
            
            UIView.animate(withDuration: 0.1, animations: {
                
                self.buttonJoinStudy?.backgroundColor = UIColor.white
                self.buttonJoinStudy?.setTitleColor(kUIColorForSubmitButtonBackground, for: .normal)
            })
        }
    }
    
}


extension StudyHomeViewController:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
    }
}
