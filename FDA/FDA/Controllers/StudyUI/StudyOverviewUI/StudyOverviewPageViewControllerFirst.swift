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
        
        self.labelDescription?.text = overviewSectionDetail.text!
         WCPServices().getEligibilityConsentMetadata(studyId:(Study.currentStudy?.studyId)! , delegate: self)
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
            leftController.changeViewController(.profile_signin)
        }
        else{
           self.createEligibilityConsentTask()
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
        
        let consentTask:ORKOrderedTask? =  ConsentBuilder.currentConsent?.createConsentTask() as! ORKOrderedTask?
        
        for stepDict in (consentTask?.steps)!{
           eligibilitySteps?.append(stepDict)
        }
       
        
        
        let orkOrderedTask:ORKTask? = ORKOrderedTask(identifier: "Eligibility_ConsentTask", steps: eligibilitySteps)
        
        taskViewController = ORKTaskViewController(task:orkOrderedTask, taskRun: nil)
        taskViewController?.delegate = self
        taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        present(taskViewController!, animated: true, completion: nil)
        
        
    }

    
    
    func moviePlayBackDidFinish(notification: NSNotification) {
        //  println("moviePlayBackDidFinish:")
        moviePlayer.moviePlayer.stop()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
        moviePlayer.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func visitWebsiteButtonAction(_ sender: Any) {
        
        if overviewSectionDetail.websiteLink != nil {
            
            let loginStoryboard = UIStoryboard.init(name: "Main", bundle:Bundle.main)
            let webViewController = loginStoryboard.instantiateViewController(withIdentifier:"WebViewController") as! UINavigationController
            let webView = webViewController.viewControllers[0] as! WebViewController
            webView.requestLink = overviewSectionDetail.websiteLink!
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

extension StudyOverviewViewControllerFirst:ORKTaskViewControllerDelegate{
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
                activityBuilder?.activity?.restortionData = taskViewController.restorationData
            }
        }
        
        if  taskViewController.task?.identifier == "ConsentTask"{
            consentbuilder?.consentResult?.initWithORKTaskResult(taskResult:taskViewController.result )
        }
        else{
            activityBuilder?.actvityResult?.initWithORKTaskResult(taskResult: taskViewController.result)
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
