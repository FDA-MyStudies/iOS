//
//  ActivitiesViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit

let kActivities = "activities"

class ActivitiesViewController : UIViewController{
    
    var tableViewRowDetails : NSMutableArray?
    
    var dataArray:NSMutableArray? = NSMutableArray()
    
    @IBOutlet var tableView : UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "Activities", ofType: ".plist", inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
        
        
        self.navigationItem.title = NSLocalizedString("STUDY ACTIVITIES", comment: "")
        self.tableView?.sectionHeaderHeight = 30
        
        if (Study.currentStudy?.studyId) != nil {
            WCPServices().getStudyActivityList(studyId: (Study.currentStudy?.studyId)!, delegate: self)
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    
    
    
    @IBAction func homeButtonAction(_ sender: AnyObject){
        //_ = self.navigationController?.popToRootViewController(animated: true)
        
        
        
        self.performSegue(withIdentifier: "unwindeToStudyListIdentier", sender: self)
        
        
    }
    
    @IBAction func filterButtonAction(_ sender: AnyObject){
        
        
    }
    
    func createActivity(){
        
        
        let filePath  = Bundle.main.path(forResource: "Acivity_Question", ofType: "json")
        
        // let filePath  = Bundle.main.path(forResource: "FetalKickTest", ofType: "json")
        
        let data = NSData(contentsOfFile: filePath!)
        do {
            let dataDict = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
            
            Study.currentActivity?.setActivityMetaData(activityDict:dataDict?["Result"] as! Dictionary<String, Any>)
            
        }
        catch let error as NSError{
            print("\(error)")
        }
    
       
        
        if Utilities.isValidObject(someObject: Study.currentActivity?.steps as AnyObject?){
            
            ActivityBuilder.currentActivityBuilder = ActivityBuilder()
            ActivityBuilder.currentActivityBuilder.initWithActivity(activity:Study.currentActivity! )
        }

        //---------------
        
        
        let task:ORKTask?
        let taskViewController:ORKTaskViewController?
        task = ActivityBuilder.currentActivityBuilder.createTask()
        taskViewController = ORKTaskViewController(task:task, taskRun: nil)
        taskViewController?.delegate = self
        taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        UIApplication.shared.statusBarStyle = .default
        
        present(taskViewController!, animated: true, completion: nil)
        
      
    }

}

//MARK: TableView Data source
extension ActivitiesViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    private func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // let sectionHeader = tableViewRowDetails?[section] as! NSDictionary
        // let sectionHeaderData = sectionHeader["items"] as! NSArray
        
        if (dataArray?.count)! > 0 {
            return dataArray!.count
        }
        else{
            return 0
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        view.backgroundColor = kBackgroundTableViewColor
        
        let dayData = tableViewRowDetails?[section] as! NSDictionary
        
        let statusText = dayData["status"] as! String
        
        let label = UILabel.init(frame: CGRect(x: 18, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        label.textAlignment = NSTextAlignment.natural
        label.text = statusText
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = true
        label.textColor = kGreyColor
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewData = tableViewRowDetails?.object(at: indexPath.section) as! NSDictionary
        // let projectInfo = tableViewData["items"] as! NSArray
        // let project = projectInfo[indexPath.row] as! Dictionary<String,Any>
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kActivitiesTableViewCell, for: indexPath) as! ActivitiesTableViewCell
        
        //Cell Data Setup
        
        if indexPath.section == 0 {
            
            if (dataArray?.count)! > 0 {
                let activity = dataArray?[indexPath.row]
                cell.populateCellData(data: (activity as! Dictionary<String, Any>))
            }
            
        }
        else{
            //cell.populateCellData(data: project )
            
        }
        
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

//MARK: TableView Delegates
extension ActivitiesViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        Study.updateCurrentActivity(activity:(Study.currentStudy?.activities[indexPath.row])!)
        
        //Following to be commented
        self.createActivity()
        
        //To be uncommented
        //WCPServices().getStudyActivityMetadata(studyId:(Study.currentStudy?.studyId)! , activityId: (Study.currentActivity?.actvityId)!, activityVersion: "1", delegate: self)
    }
    
}

extension ActivitiesViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        //self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        //self.removeProgressIndicator()
        
        if requestName as String == WCPMethods.activityList.method.methodName {
            
            if Utilities.isValidObject(someObject: response?[kActivities] as AnyObject){
                dataArray?.addObjects(from: response?[kActivities] as! [Any])
            }
            
            self.tableView?.reloadData()
            
        }
        else if requestName as String == WCPMethods.activity.method.methodName {
            self.createActivity()
        }
        
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        //self.removeProgressIndicator()
        
        
        
    }
}


extension ActivitiesViewController:ORKTaskViewControllerDelegate{
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
                ActivityBuilder.currentActivityBuilder.activity?.restortionData = taskViewController.restorationData
            }
        }
        
        if  taskViewController.task?.identifier == "ConsentTask"{
            consentbuilder?.consentResult?.initWithORKTaskResult(taskResult:taskViewController.result )
        }
        else{
            
            if reason == ORKTaskViewControllerFinishReason.completed{
                ActivityBuilder.currentActivityBuilder.actvityResult?.initWithORKTaskResult(taskResult: taskViewController.result)
                print("\(ActivityBuilder.currentActivityBuilder.actvityResult?.getResultDictionary())")

            }
            
        }
        taskViewController.dismiss(animated: true, completion: nil)
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        
        if (taskViewController.result.results?.count)! > 1{
            
            
            if activityBuilder?.actvityResult?.result?.count == taskViewController.result.results?.count{
                activityBuilder?.actvityResult?.result?.removeLast()
            }
            else{
                
                if (ActivityBuilder.currentActivityBuilder.actvityResult?.result?.count)! < (taskViewController.result.results?.count)!{
                    
                    let orkStepResult:ORKStepResult? = taskViewController.result.results?[(taskViewController.result.results?.count)! - 2] as! ORKStepResult?
                    let activityStepResult:ActivityStepResult? = ActivityStepResult()
                    
                   
                    
                    
                    activityStepResult?.initWithORKStepResult(stepResult: orkStepResult! as ORKStepResult , activityType:(ActivityBuilder.currentActivityBuilder.actvityResult?.type)!)
                    
                     let index = (taskViewController.result.results?.count)! - 2
                    if index < (ActivityBuilder.currentActivityBuilder.activity?.activitySteps?.count)!{
                         activityStepResult?.step = ActivityBuilder.currentActivityBuilder.activity?.activitySteps?[index]
                    }
                    
                    ActivityBuilder.currentActivityBuilder.actvityResult?.result?.append(activityStepResult!)
                    
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
        
         let storyboard = UIStoryboard.init(name: "FetalKickCounter", bundle: nil)
        
        if step.identifier == "FetalKickCounterStep" {
            
            let ttController = storyboard.instantiateViewController(withIdentifier: "FetalKickCounterStepViewController") as! FetalKickCounterStepViewController
            ttController.step = step
            return ttController
        }
        else if  step.identifier == kFetalKickIntroductionStepIdentifier{
           
            
            let ttController = storyboard.instantiateViewController(withIdentifier: "FetalKickIntroStepViewControllerIdentifier") as! FetalKickIntroStepViewController
            ttController.step = step
            return ttController

        }
        else {
            return nil
        }
    }
    
    
}





