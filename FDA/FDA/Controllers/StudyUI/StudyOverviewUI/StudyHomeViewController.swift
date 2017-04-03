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
        else{
            
            WCPServices().getEligibilityConsentMetadata(studyId:(Study.currentStudy?.studyId)!, delegate: self as NMWebServiceDelegate)
            
            
           
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
    
    func createEligibilityConsentTask()   {
        
        var eligibilitySteps =  EligibilityBuilder.currentEligibility?.getEligibilitySteps()
        
        let taskViewController:ORKTaskViewController?
        
        
        
        
        let filePath  = Bundle.main.path(forResource: "Consent", ofType: "json")
        let data = NSData(contentsOfFile: filePath!)
        do {
            let dataDict = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
            
            let consent = dataDict?["Result"]as! Dictionary<String, Any>
            ConsentBuilder.currentConsent = ConsentBuilder()
            ConsentBuilder.currentConsent?.initWithMetaData(metaDataDict: consent)
            
            
        }catch{
            
        }
        
        let consentTask:ORKOrderedTask? = ConsentBuilder.currentConsent?.createConsentTask() as! ORKOrderedTask?
        
        for stepDict in (consentTask?.steps)!{
            eligibilitySteps?.append(stepDict)
        }
        
        
        
        let orkOrderedTask:ORKTask? = ORKOrderedTask(identifier:kEligibilityConsentTask, steps: eligibilitySteps)
        
        taskViewController = ORKTaskViewController(task:orkOrderedTask, taskRun: nil)
        taskViewController?.delegate = self
        taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        present(taskViewController!, animated: true, completion: nil)
        
        
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
        //self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        //self.removeProgressIndicator()
        
        if requestName as String == WCPMethods.eligibilityConsent.method.methodName {
            self.createEligibilityConsentTask()
        }
        
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
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
            
            if taskViewController.task?.identifier == "ConsentTask"{
                
            }
            else{
                //activityBuilder?.activity?.restortionData = taskViewController.restorationData
            }
        }
        
        if  taskViewController.task?.identifier == kEligibilityConsentTask{
            ConsentBuilder.currentConsent?.consentResult?.initWithORKTaskResult(taskResult:taskViewController.result )
            
           User.currentUser.updateStudyStatus(studyId:(Study.currentStudy?.studyId)!  , status: .inProgress)
            
        }
        else{
            //activityBuilder?.actvityResult?.initWithORKTaskResult(taskResult: taskViewController.result)
        }
        
        
        taskViewController.dismiss(animated: true, completion: nil)
        
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
        
        if step.identifier == "EligibilityTokenStep" {
            
            let gatewayStoryboard = UIStoryboard(name: "FetalKickCounter", bundle: nil)
            
            let ttController = gatewayStoryboard.instantiateViewController(withIdentifier: "EligibilityStepViewController") as! EligibilityStepViewController
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
