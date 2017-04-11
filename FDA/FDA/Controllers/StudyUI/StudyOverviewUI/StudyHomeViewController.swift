//
//  StudyHomeViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/9/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit

let kEligibilityConsentTask = "EligibilityConsentTask"
let kEligibilityTokenStep = "EligibilityTokenStep"
let kFetalKickCounterStep = "FetalKickCounter"
let kEligibilityStepViewControllerIdentifier = "EligibilityStepViewController"

let kConsentTaskIdentifier = "ConsentTask"
let kStudyDashboardViewControllerIdentifier = "StudyDashboardViewController"

let kStudyDashboardTabbarControllerIdentifier = "StudyDashboardTabbarViewControllerIdentifier"


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
//MARK:View controller Delegates
    
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
        else {
            if User.currentUser.isStudyBookmarked(studyId: (Study.currentStudy?.studyId)!) {
                buttonStar.isSelected = true
            }
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
    
    
//MARK:Button Actions
    
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
        
        else{
            
            let currentStudy = Study.currentStudy!
            let participatedStatus = (currentStudy.userParticipateState.status)
            if currentStudy.status == .active {
                if participatedStatus == .yetToJoin || participatedStatus == .notEligible {
                    
                    WCPServices().getEligibilityConsentMetadata(studyId:(Study.currentStudy?.studyId)!, delegate: self as NMWebServiceDelegate)
                }
            }
            
//            //let studyStatus = User.currentUser.updateStudyStatus(studyId:(Study.currentStudy?.studyId)!, status: .inProgress)
//           // UserServices().updateUserParticipatedStatus(studyStauts: studyStatus, delegate: self)
//            
//            WCPServices().getEligibilityConsentMetadata(studyId:(Study.currentStudy?.studyId)!, delegate: self as NMWebServiceDelegate)
//            // self.createEligibilityConsentTask()
            
            
        }
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func starButtonAction(_ sender: Any) {
        
        let button = sender as! UIButton
        var userStudyStatus:UserStudyStatus!
        let study = Study.currentStudy
        let user = User.currentUser
        if button.isSelected{
            button.isSelected = false
            userStudyStatus =  user.removeBookbarkStudy(studyId: (study?.studyId)!)
            
        }else{
            button.isSelected = true
            userStudyStatus =  user.bookmarkStudy(studyId: (study?.studyId)!)
        }
        
        UserServices().updateStudyBookmarkStatus(studyStauts: userStudyStatus, delegate: self)
    }
    
    func createEligibilityConsentTask()   {
        
        var eligibilitySteps =  EligibilityBuilder.currentEligibility?.getEligibilitySteps()
        
        let taskViewController:ORKTaskViewController?
        
        
        /*
         
         let filePath  = Bundle.main.path(forResource: "Consent", ofType: "json")
         let data = NSData(contentsOfFile: filePath!)
         do {
         let dataDict = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
         
         let consent = dataDict?["Result"]as! Dictionary<String, Any>
         ConsentBuilder.currentConsent = ConsentBuilder()
         ConsentBuilder.currentConsent?.initWithMetaData(metaDataDict: consent)
         
         
         }catch{
         
         }
         */
        let consentTask:ORKOrderedTask? = ConsentBuilder.currentConsent?.createConsentTask() as! ORKOrderedTask?
        
        for stepDict in (consentTask?.steps)!{
            eligibilitySteps?.append(stepDict)
        }
        
        let orkOrderedTask:ORKTask? = ORKOrderedTask(identifier:kEligibilityConsentTask, steps: eligibilitySteps)
        
        
        taskViewController = ORKTaskViewController(task:orkOrderedTask, taskRun: nil)
        
        taskViewController?.delegate = self
        taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        
        taskViewController?.navigationItem.title = "Consent"
        
        present(taskViewController!, animated: true, completion: nil)
        
        
    }
    
    
    
    func displayConsentDocument() {
        
        
        if Study.currentStudy?.consentDocument != nil {
            if Study.currentStudy?.consentDocument?.htmlString != nil {
                self.navigateToWebView(link: nil, htmlText: (Study.currentStudy?.consentDocument?.htmlString)!)
            }
        }
      
        
    }
    
    @IBAction func visitWebsiteButtonAction(_ sender: UIButton) {
        
//        let loginStoryboard = UIStoryboard.init(name: "Main", bundle:Bundle.main)
//        let webViewController = loginStoryboard.instantiateViewController(withIdentifier:"WebViewController") as! UINavigationController
//        let webView = webViewController.viewControllers[0] as! WebViewController
        
        
        
        if sender.tag == 1188 {
            //Visit Website
           // webView.requestLink = Study.currentStudy?.overview.websiteLink
            //self.navigationController?.present(webViewController, animated: true, completion: nil)
            
            self.navigateToWebView(link:  Study.currentStudy?.overview.websiteLink, htmlText: nil)
            
        } else {
            //View Consent
            
            if Study.currentStudy?.studyId != nil {
                WCPServices().getConsentDocument(studyId: (Study.currentStudy?.studyId)!, delegate: self as NMWebServiceDelegate)
            }
            
        }
        
        
        
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
    
    
    func navigateToWebView(link:String?,htmlText:String?){
        
        let loginStoryboard = UIStoryboard.init(name: "Main", bundle:Bundle.main)
        let webViewController = loginStoryboard.instantiateViewController(withIdentifier:"WebViewController") as! UINavigationController
        let webView = webViewController.viewControllers[0] as! WebViewController
        
        if link != nil {
             webView.requestLink = Study.currentStudy?.overview.websiteLink
        }
        if htmlText != nil {
            webView.htmlString = htmlText
        }
        
        
        self.navigationController?.present(webViewController, animated: true, completion: nil)
    }
    
    //Fired when the user taps on the pageControl to change its current page (Commented as this is not working)
    func didChangePageControlValue() {
        pageViewController?.scrollToViewController(index: (pageControlView?.currentPage)!)
    }
    
    
    
    func pushToStudyDashboard(){
        
        let studyDashboard = self.storyboard?.instantiateViewController(withIdentifier: kStudyDashboardTabbarControllerIdentifier) as! StudyDashboardTabbarViewController
        
        self.navigationController?.pushViewController(studyDashboard, animated: true)
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
        
        if requestName as String == WCPMethods.consentDocument.method.methodName {
            self.addProgressIndicator()
        }
        
        //self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        //self.removeProgressIndicator()
        
        if requestName as String == WCPMethods.eligibilityConsent.method.methodName {
            self.createEligibilityConsentTask()
        }
        
        if requestName as String == RegistrationMethods.updatePreferences.method.methodName{
            
             UserServices().updateUserEligibilityConsentStatus(eligibilityStatus: true, consentStatus:(ConsentBuilder.currentConsent?.consentStatus)!  , delegate: self)
        }
        
        
        //self.removeProgressIndicator()
        
        
        if requestName as String == WCPMethods.consentDocument.method.methodName {
             self.removeProgressIndicator()
            self.displayConsentDocument()
           
        }
        
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        //self.removeProgressIndicator()
        
        if requestName as String == WCPMethods.consentDocument.method.methodName {
            self.removeProgressIndicator()
        }
        
        
        //self.removeProgressIndicator()
        
        
        
    }
}


extension StudyHomeViewController:ORKTaskViewControllerDelegate{
    //MARK:ORKTaskViewController Delegate
    
    
    func taskViewControllerSupportsSaveAndRestore(_ taskViewController: ORKTaskViewController) -> Bool {
        return true
    }
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        
        var taskResult:Any?
        
        switch reason {
            
        case ORKTaskViewControllerFinishReason.completed:
            print("completed")
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.failed:
            print("failed")
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.discarded:
            print("discarded")
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.saved:
            print("saved")
            taskResult = taskViewController.restorationData
            
            if taskViewController.task?.identifier == kEligibilityConsentTask{
               
            }
            else{
                //activityBuilder?.activity?.restortionData = taskViewController.restorationData
            }
        }
        
        if  taskViewController.task?.identifier == kEligibilityConsentTask && reason == ORKTaskViewControllerFinishReason.completed{
            ConsentBuilder.currentConsent?.consentResult?.initWithORKTaskResult(taskResult:taskViewController.result )
            
            let currentUserStudyStatus =  User.currentUser.updateStudyStatus(studyId:(Study.currentStudy?.studyId)!  , status: .inProgress)
            
            ConsentBuilder.currentConsent?.consentStatus = .completed
            
            UserServices().updateUserParticipatedStatus(studyStauts: currentUserStudyStatus, delegate: self)
            
        }
        else{
            //activityBuilder?.actvityResult?.initWithORKTaskResult(taskResult: taskViewController.result)
        }
        
        
        taskViewController.dismiss(animated: true, completion: nil)
        
        if( User.currentUser.getStudyStatus(studyId:(Study.currentStudy?.studyId)! ) == UserStudyStatus.StudyStatus.inProgress){
             self.pushToStudyDashboard()
        }
        
        
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        
        if (taskViewController.result.results?.count)! > 1{
            
            
            if activityBuilder?.actvityResult?.result?.count == taskViewController.result.results?.count{
                activityBuilder?.actvityResult?.result?.removeLast()
            }
            else{
                
                if (activityBuilder?.actvityResult?.result?.count)! < (taskViewController.result.results?.count)!{
                    
                    let orkStepResult:ORKStepResult? = taskViewController.result.results?[(taskViewController.result.results?.count)! - 2] as! ORKStepResult?
                    let activityStepResult:ActivityStepResult? = ActivityStepResult()
                    
                    activityStepResult?.initWithORKStepResult(stepResult: orkStepResult! as ORKStepResult , activityType:(activityBuilder?.actvityResult?.activity?.type)!)
                    activityBuilder?.actvityResult?.result?.append(activityStepResult!)
                    
                }
            }
        }
    }
    
    //MARK:StepViewController Delegate
    public func stepViewController(_ stepViewController: ORKStepViewController, didFinishWith direction: ORKStepViewControllerNavigationDirection){
        
    }
    
    public func stepViewControllerResultDidChange(_ stepViewController: ORKStepViewController){
        
    }
    public func stepViewControllerDidFail(_ stepViewController: ORKStepViewController, withError error: Error?){
        
    }
    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        
        if step.identifier == kEligibilityTokenStep {
            
            let gatewayStoryboard = UIStoryboard(name: kFetalKickCounterStep, bundle: nil)
            
            let ttController = gatewayStoryboard.instantiateViewController(withIdentifier: kEligibilityStepViewControllerIdentifier) as! EligibilityStepViewController
            ttController.step = step
            
            
            return ttController
        } else {
            return nil
        }
    }
    
    
    func buildTask()  {
        
        // let filePath  = Bundle.main.path(forResource: "LatestActive_Taskdocument", ofType: "json")
        
        //let filePath  = Bundle.main.path(forResource: "ActiveTask", ofType: "json")
        
        let filePath  = Bundle.main.path(forResource: "Consent", ofType: "json")
        
        //let filePath  = Bundle.main.path(forResource: "Acivity_Question", ofType: "json")
        
        let data = NSData(contentsOfFile: filePath!)
        
        
        do {
            let dataDict = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
            
            if  Utilities.isValidObject(someObject: dataDict as AnyObject?) && (dataDict?.count)! > 0 {
                
                
                let task:ORKTask?
                let taskViewController:ORKTaskViewController?
                
                if Utilities.isValidObject(someObject: dataDict?["Result"] as? Dictionary<String, Any> as AnyObject?){
                    
                    
                    // activityBuilder?.initActivityWithDict(dict: dataDict?["Result"] as! Dictionary<String, Any>)
                    
                    
                    
                    task = activityBuilder?.createTask()
                    
                    
                    // consentbuilder?.initWithMetaData(metaDataDict:dataDict?["Result"] as! Dictionary<String, Any> )
                    // task = consentbuilder?.createConsentTask()
                    
                    taskViewController = ORKTaskViewController(task:task, taskRun: nil)
                    
                    
                    // consentbuilder?.consentResult =   ConsentResult()
                    // consentbuilder?.consentResult?.consentDocument =  consentbuilder?.consentDocument
                    
                    taskViewController?.delegate = self
                    taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    present(taskViewController!, animated: true, completion: nil)
                }
            }
            
            // use anyObj here
        } catch {
            print("json error: \(error.localizedDescription)")
        }
    }
}
