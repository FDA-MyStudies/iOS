//
//  StudyDashboardViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/27/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

enum TableViewCells: Int {
    case welcomeCell = 0
    //case studyActivityCell
    case percentageCell
}

class StudyDashboardViewController : UIViewController{
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var labelStudyTitle : UILabel?
    
    var dataSourceKeysForLabkey:Array<Dictionary<String,String>> = []
    
    var tableViewRowDetails = NSMutableArray()
    var todayActivitiesArray = NSMutableArray()
    var statisticsArray = NSMutableArray()
    
    
//MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "StudyDashboard", ofType: ".plist", inDirectory:nil)
        let tableViewRowDetailsdat = NSMutableArray.init(contentsOfFile: plistPath!)
        
        let tableviewdata = tableViewRowDetailsdat?[0] as! NSDictionary
        
        tableViewRowDetails = tableviewdata["studyActivity"] as! NSMutableArray
        todayActivitiesArray = tableviewdata["todaysActivity"] as! NSMutableArray
        statisticsArray = tableviewdata["statistics"] as! NSMutableArray
        
        labelStudyTitle?.text = Study.currentStudy?.name
        //check if consent is udpated
        
        //TO BE REMOVED FOLLOWING 
        
        //StudyUpdates.studyConsentUpdated = true
        if StudyUpdates.studyConsentUpdated {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
             appDelegate.checkConsentStatus(controller: self)
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        //unhide navigationbar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        DBHandler.loadStatisticsForStudy(studyId: (Study.currentStudy?.studyId)!) { (statiticsList) in
            
            if statiticsList.count != 0 {
                StudyDashboard.instance.statistics = statiticsList
                self.tableView?.reloadData()
            }
            else {
                self.sendRequestToGetDashboardInfo()
            }
        }
        
        self.getDataKeysForCurrentStudy()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
               
    }
    
    
//MARK:- Helper Methods
    
    /**
     
     Used to Create Eligibility Consent Task 
     
     */
    func createEligibilityConsentTask() {
        
        let taskViewController:ORKTaskViewController?
        
        let consentTask:ORKOrderedTask? = ConsentBuilder.currentConsent?.createConsentTask() as! ORKOrderedTask?
        
        taskViewController = ORKTaskViewController(task:consentTask, taskRun: nil)
        
        taskViewController?.delegate = self
        taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        taskViewController?.navigationItem.title = nil
        
        UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self]).tintColor = kUIColorForSubmitButtonBackground
        
        UIApplication.shared.statusBarStyle = .default
        present(taskViewController!, animated: true, completion: nil)
    }
    
    func getDataKeysForCurrentStudy(){
        
        DBHandler.getDataSourceKeyForActivity(studyId: (Study.currentStudy?.studyId)!) { (activityKeys) in
            print(activityKeys)
            if activityKeys.count > 0 {
                self.dataSourceKeysForLabkey = activityKeys
                self.sendRequestToGetDashboardResponse()
            }
        }

    }
        
    
    
    
    
    /**
     
     Used to send Request To Get Dashboard Info
     
     */
    func sendRequestToGetDashboardInfo(){
        WCPServices().getStudyDashboardInfo(studyId: (Study.currentStudy?.studyId)!, delegate: self)
    }
    
    
    
    func sendRequestToGetDashboardResponse(){
        
        
        if self.dataSourceKeysForLabkey.count != 0 {
            let details = self.dataSourceKeysForLabkey.first
            let activityId = "Q1"//details?["activityId"]
            let keys = "Q5,Q13"//details?["keys"]
            LabKeyServices().getParticipantResponse(activityId: activityId, keys: keys, participantId: "1a3d0d308df81024f8bfd7f11f7a0168", delegate: self)
        }
        else{
            self.removeProgressIndicator()
            
            //save response in database
            
            print("Labkey response \(StudyDashboard.instance.dashboardResponse)")
        }
        
        //https://hphci-fdama-te-ds-01.labkey.com/mobileAppStudy-executeSQL.api?participantId=1a3d0d308df81024f8bfd7f11f7a0168&sql=SELECT%20*%20FROM%20Q1
        
        
    }
    
    
    func handleExecuteSQLResonse(){
        
        self.dataSourceKeysForLabkey.removeFirst()
        self.sendRequestToGetDashboardResponse()
    }
    
//MARK:- Button Actions
    
    /**
     
     Home button clicked
     
     @param sender    Accepts any kind of object

     */
    @IBAction func homeButtonAction(_ sender: AnyObject){
        self.performSegue(withIdentifier: unwindToStudyListDashboard, sender: self)
    }
    
    
    /**
     
     Share to others button clicked
     
     @param sender    Accepts any kind of object
     
     */
    @IBAction func shareButtonAction(_ sender: AnyObject){
        
        
    }
}


//MARK:- TableView Datasource
extension StudyDashboardViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewRowDetails.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //Used for the last cell Height (trends cell)
        if indexPath.section == tableViewRowDetails.count{
            return 50
        }
        
        let data = self.tableViewRowDetails[indexPath.section] as! NSDictionary
        
        var heightValue : CGFloat = 0
        if data["isTableViewCell"] as! String == "YES" {
            
            //Used for Table view Height in a cell
            switch indexPath.section {
            case TableViewCells.welcomeCell.rawValue:
                heightValue = 70
            case TableViewCells.percentageCell.rawValue:
                heightValue = 200
            default:
                return 0
            }
            
        }else{
            //Used for Collection View Height in a cell
            if data["isStudy"] as! String == "YES" {
                heightValue = 130
            }else{
                heightValue = 210
            }
        }
        return heightValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell?
        
        //Used to display the last cell trends
        if indexPath.section == tableViewRowDetails.count{
            
            cell = tableView.dequeueReusableCell(withIdentifier: kTrendTableViewCell, for: indexPath) as! StudyDashboardTrendsTableViewCell
            return cell!
        }
        
        let tableViewData = tableViewRowDetails.object(at: indexPath.section) as! NSDictionary
        
        if tableViewData["isTableViewCell"] as! String == "YES" {
            
            //Used for Table view Cell
            switch indexPath.section {
            case TableViewCells.welcomeCell.rawValue:
                cell = tableView.dequeueReusableCell(withIdentifier: kWelcomeTableViewCell, for: indexPath) as! StudyDashboardWelcomeTableViewCell
                (cell as! StudyDashboardWelcomeTableViewCell).displayFirstCelldata(data: tableViewData)
                
//            case TableViewCells.studyActivityCell.rawValue:
//                cell = tableView.dequeueReusableCell(withIdentifier: kStudyActivityTableViewCell, for: indexPath) as! StudyDashboardStudyActivitiesTableViewCell
//                (cell as! StudyDashboardStudyActivitiesTableViewCell).displaySecondCelldata(data: tableViewData)
                
            case TableViewCells.percentageCell.rawValue:
                cell = tableView.dequeueReusableCell(withIdentifier: kPercentageTableViewCell, for: indexPath) as! StudyDashboardStudyPercentageTableViewCell
                (cell as! StudyDashboardStudyPercentageTableViewCell).displayThirdCellData(data: tableViewData)
                
            default:
                return cell!
            }
            
        }else{
            
            //Used for Collection View cell
           // if tableViewData["isStudy"] as! String == "YES"{
                
             //   cell = tableView.dequeueReusableCell(withIdentifier: kActivityTableViewCell, for: indexPath) as! StudyDashboardActivityTableViewCell
            //    (cell as! StudyDashboardActivityTableViewCell).activityArrayData = todayActivitiesArray
            //    (cell as! StudyDashboardActivityTableViewCell).activityCollectionView?.reloadData()
            //}
                
            //else if tableViewData["isStudy"] as! String == "NO"{
                
                cell = tableView.dequeueReusableCell(withIdentifier: kStatisticsTableViewCell, for: indexPath) as! StudyDashboardStatisticsTableViewCell
               // (cell as! StudyDashboardStatisticsTableViewCell).statisticsArrayData = statisticsArray
                
                (cell as! StudyDashboardStatisticsTableViewCell).displayData()
                
                //Used for setting it initially
                (cell as! StudyDashboardStatisticsTableViewCell).buttonDay?.setTitle("  DAY  ", for: UIControlState.normal)
                
                (cell as! StudyDashboardStatisticsTableViewCell).statisticsCollectionView?.reloadData()
            //}
        }
        return cell!
    }
}


//MARK:- TableView Delegates
extension StudyDashboardViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == tableViewRowDetails.count {
            self.performSegue(withIdentifier: "chartSegue", sender: nil)
        }
    }
}


//MARK:- Webservice Delegates
extension StudyDashboardViewController:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) response ; \(response)")
        
       
        
        if requestName as String == WCPMethods.eligibilityConsent.method.methodName {
            self.removeProgressIndicator()
            self.createEligibilityConsentTask()
        }
        else if requestName as String == WCPMethods.studyDashboard.method.methodName {
            self.removeProgressIndicator()
            self.tableView?.reloadData()
        }
        else if requestName as String == ResponseMethods.executeSQL.description{
            self.handleExecuteSQLResonse()
        }
    }
    
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        
        if requestName as String == WCPMethods.consentDocument.method.methodName {
            self.removeProgressIndicator()
        }
        else if requestName as String == ResponseMethods.executeSQL.description{
            self.handleExecuteSQLResonse()
        }
        else {
            self.removeProgressIndicator()
        }
        //self.removeProgressIndicator()
    }
}


//MARK:- ORKTaskViewController Delegate
extension StudyDashboardViewController:ORKTaskViewControllerDelegate{
    
    func taskViewControllerSupportsSaveAndRestore(_ taskViewController: ORKTaskViewController) -> Bool {
        return true
    }
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        var taskResult:Any?
        switch reason {
            
        case ORKTaskViewControllerFinishReason.completed:
            print("completed")
            taskResult = taskViewController.result
            
            ConsentBuilder.currentConsent?.consentResult?.consentDocument =   ConsentBuilder.currentConsent?.consentDocument
            
            ConsentBuilder.currentConsent?.consentResult?.initWithORKTaskResult(taskResult:taskViewController.result )
            
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
        taskViewController.dismiss(animated: true, completion: nil)
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        
        if (taskViewController.result.results?.count)! > 1{
            
            if activityBuilder?.actvityResult?.result?.count == taskViewController.result.results?.count{
                //Removing the dummy result:Currentstep result which not presented yet
                activityBuilder?.actvityResult?.result?.removeLast()
            }
            else{
                
            }
        }
        
        //Handling show and hide of Back Button
        
        //For Verified Step , Completion Step, Visual Step, Review Step, Share Pdf Step
        
        if  stepViewController.step?.identifier == kConsentCompletionStepIdentifier || stepViewController.step?.identifier == "visual" || stepViewController.step?.identifier == "Review" || stepViewController.step?.identifier == kConsentSharePdfCompletionStep{
            
            
            if stepViewController.step?.identifier == kEligibilityVerifiedScreen{
                stepViewController.continueButtonTitle = "Continue"
            }
            stepViewController.backButtonItem = nil
        }
            //checking if currentstep is View Pdf Step
        else if stepViewController.step?.identifier == kConsentViewPdfCompletionStep{
            
            //Back button is enabled
            stepViewController.backButtonItem?.isEnabled = true
            
            let orkStepResult:ORKStepResult? = taskViewController.result.results?[(taskViewController.result.results?.count)! - 2] as! ORKStepResult?
            
            let consentSignatureResult:ConsentCompletionTaskResult? = orkStepResult?.results?.first as? ConsentCompletionTaskResult
            
            //Checking if Signature is consented after Review Step
            
            if  consentSignatureResult?.didTapOnViewPdf == false{
                //Directly moving to completion step by skipping Intermediate PDF viewer screen
                stepViewController.goForward()
            }
            else{
                
            }
        }
        else{
            //Back button is enabled
            stepViewController.backButtonItem?.isEnabled = true
            
        }
    }
    

//MARK:- StepViewController Delegate
    
    public func stepViewController(_ stepViewController: ORKStepViewController, didFinishWith direction: ORKStepViewControllerNavigationDirection){
        
    }
    
    public func stepViewControllerResultDidChange(_ stepViewController: ORKStepViewController){
        
    }
    
    public func stepViewControllerDidFail(_ stepViewController: ORKStepViewController, withError error: Error?){
        
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        
        //CurrentStep is TokenStep
        
        if step.identifier == kEligibilityTokenStep {
            
            let gatewayStoryboard = UIStoryboard(name: kFetalKickCounterStep, bundle: nil)
            
            let ttController = gatewayStoryboard.instantiateViewController(withIdentifier: kEligibilityStepViewControllerIdentifier) as! EligibilityStepViewController
            ttController.descriptionText = step.text
            ttController.step = step
            
            return ttController
        }
        else if step.identifier == kConsentSharePdfCompletionStep {
            
            // let reviewStep:ORKStepResult? = taskViewController.result.results?[(taskViewController.result.results?.count)! - 1] as! ORKStepResult?
            
            var totalResults =  taskViewController.result.results
            let reviewStep:ORKStepResult?
            
            totalResults = totalResults?.filter({$0.identifier == "Review"})
            
            reviewStep = totalResults?.first as! ORKStepResult?
            
            if (reviewStep?.identifier)! == "Review" && (reviewStep?.results?.count)! > 0{
                let consentSignatureResult:ORKConsentSignatureResult? = reviewStep?.results?.first as? ORKConsentSignatureResult
                
                if  consentSignatureResult?.consented == false{
                    taskViewController.dismiss(animated: true
                        , completion: nil)
                    _ = self.navigationController?.popViewController(animated: true)
                    return nil
                    
                }
                else{
                    
                    let documentCopy:ORKConsentDocument = (ConsentBuilder.currentConsent?.consentDocument)!.copy() as! ORKConsentDocument
                    
                    consentSignatureResult?.apply(to: documentCopy)
                    let gatewayStoryboard = UIStoryboard(name: kFetalKickCounterStep, bundle: nil)
                    let ttController = gatewayStoryboard.instantiateViewController(withIdentifier: kConsentSharePdfStoryboardId) as! ConsentSharePdfStepViewController
                    ttController.step = step
                    ttController.consentDocument =  documentCopy
                    return ttController
                }
            }
            else {
                return nil
            }
        }
        else if step.identifier == kConsentViewPdfCompletionStep {
            
            let reviewSharePdfStep:ORKStepResult? = taskViewController.result.results?.last as! ORKStepResult?
            
            let result = (reviewSharePdfStep?.results?.first as? ConsentCompletionTaskResult)
            
            if (result?.didTapOnViewPdf)!{
                let gatewayStoryboard = UIStoryboard(name: kFetalKickCounterStep, bundle: nil)
                
                let ttController = gatewayStoryboard.instantiateViewController(withIdentifier: kConsentViewPdfStoryboardId) as! ConsentPdfViewerStepViewController
                ttController.step = step
                
                ttController.pdfData = result?.pdfData
                
                return ttController
            }
            else{
                //taskViewController.goForward()
                return nil
            }
        }
        else {
            
            return nil
        }
    }
}





