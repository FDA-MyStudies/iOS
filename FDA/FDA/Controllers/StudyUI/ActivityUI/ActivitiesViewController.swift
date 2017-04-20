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


enum ActivityAvailabilityStatus:Int{
    case current
    case upcoming
    case past
}

class ActivitiesViewController : UIViewController{
    
    var tableViewSections:Array<Dictionary<String,Any>> = []
    
    @IBOutlet var tableView : UITableView?
    var selectedIndexPath:IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load plist info
        //let plistPath = Bundle.main.path(forResource: "Activities", ofType: ".plist", inDirectory:nil)
       // tableViewRowDetails = Array(contente) //NSMutableArray.init(contentsOfFile: plistPath!)
        
        self.tableView?.estimatedRowHeight = 126
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.title = NSLocalizedString("STUDY ACTIVITIES", comment: "")
        self.tableView?.sectionHeaderHeight = 30
        
        
        
        if (Study.currentStudy?.studyId) != nil {
            
            WCPServices().getStudyActivityList(studyId: (Study.currentStudy?.studyId)!, delegate: self)
//            
//            DBHandler.loadActivityListFromDatabase(studyId: (Study.currentStudy?.studyId)!) { (activities) in
//                if activities.count > 0 {
//                    Study.currentStudy?.activities = activities
//                    self.handleActivityListResponse()
//                }
//                else {
//                     WCPServices().getStudyActivityList(studyId: (Study.currentStudy?.studyId)!, delegate: self)
//                }
//            }

           
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
        
        /*
        let filePath  = Bundle.main.path(forResource: "Acivity_Question", ofType: "json")
        
        //let filePath  = Bundle.main.path(forResource: "FetalKickTest", ofType: "json")
        
        let data = NSData(contentsOfFile: filePath!)
        do {
            let dataDict = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
            
            Study.currentActivity?.setActivityMetaData(activityDict:dataDict?["Result"] as! Dictionary<String, Any>)
            
        }
        catch let error as NSError{
            print("\(error)")
        }
    
       */
        
        if Utilities.isValidObject(someObject: Study.currentActivity?.steps as AnyObject?){
            
            ActivityBuilder.currentActivityBuilder = ActivityBuilder()
            ActivityBuilder.currentActivityBuilder.initWithActivity(activity:Study.currentActivity! )
        }

        //---------------
        
        
        let task:ORKTask?
        let taskViewController:ORKTaskViewController?
        
        task = ActivityBuilder.currentActivityBuilder.createTask()
        
        
        
        if Study.currentActivity?.restortionData != nil {
            let restoredData = Study.currentActivity?.restortionData 
            
            let result:ORKResult?
            taskViewController = ORKTaskViewController(task: task, restorationData: restoredData, delegate: self)
        }
        else{
    
         taskViewController = ORKTaskViewController(task:task, taskRun: nil)
             taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        
     
       taskViewController?.traitCollection
        
        UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self]).tintColor = kUIColorForSubmitButtonBackground
        
        taskViewController?.delegate = self
       //
        
      
        
        
        
        UIApplication.shared.statusBarStyle = .default
        
        present(taskViewController!, animated: true, completion: nil)
        
      
    }
    
    func getActivityAvailabilityStatus(activity:Activity) -> ActivityAvailabilityStatus {
        
        let todayDate = Date()
        
        
        if activity.startDate != nil && activity.endDate != nil {
        
        let startDateResult = (activity.startDate?.compare(todayDate))! as ComparisonResult
        let endDateResult = (activity.endDate?.compare(todayDate))! as ComparisonResult
        
        if startDateResult == .orderedAscending && endDateResult == .orderedDescending{
            print("current")
            return .current
        }
        else if startDateResult == .orderedDescending {
            print("upcoming")
            return .upcoming
        }
        else if endDateResult == .orderedAscending {
            print("past")
            return .past
        }
        }
        return .past
    }
    
    func handleActivityListResponse(){
        
        let activities = Study.currentStudy?.activities
        
        var currentActivities:Array<Activity> = []
        var upcomingActivities:Array<Activity> = []
        var pastActivities:Array<Activity> = []
        
        for activity in activities! {
            
          let status =  self.getActivityAvailabilityStatus(activity: activity)
            switch status {
            case .current:
                currentActivities.append(activity)
            case .upcoming:
                upcomingActivities.append(activity)
            case .past:
                pastActivities.append(activity)
           
            }
        }
        
        let currentDetails = ["title":"CURRENT","activities":currentActivities] as [String : Any]
        let upcomingDetails = ["title":"UPCOMING","activities":upcomingActivities] as [String : Any]
        let pastDetails = ["title":"PAST","activities":pastActivities] as [String : Any]
        
        tableViewSections.append(currentDetails)
        tableViewSections.append(upcomingDetails)
        tableViewSections.append(pastDetails)
        
        
        self.tableView?.reloadData()
        
    }
    
    func updateActivityRunStuatus(status:UserActivityStatus.ActivityStatus){
        
        let activity = Study.currentActivity!
        let status = User.currentUser.updateActivityStatus(studyId: activity.studyId!, activityId: activity.actvityId!,runId: String(activity.currentRunId), status:status)
        UserServices().updateUserActivityParticipatedStatus(activityStatus: status, delegate: self)
    }
    
    func updateActivityStatusToInProgress(){
        
        self.updateActivityRunStuatus(status: .inProgress)
        
    }
    
    func updateActivityStatusToComplete(){
        self.updateActivityRunStuatus(status: .completed)
    }
    
    //save completed staus in database
    func updateRunStatusToComplete(){
        
        let activity = Study.currentActivity!
        activity.compeltedRuns += 1
        DBHandler.updateRunToComplete(runId: activity.currentRunId, activityId: activity.actvityId!, studyId: activity.studyId!)
        self.updateActivityStatusToComplete()
    }

}

//MARK: TableView Data source
extension ActivitiesViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewSections.count
    }
    
    private func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // let sectionHeader = tableViewRowDetails?[section] as! NSDictionary
        // let sectionHeaderData = sectionHeader["items"] as! NSArray
        
        let rowDetail = tableViewSections[section] 
        let activities = rowDetail["activities"] as! Array<Activity>
        if activities.count == 0 {
            return 1
        }
        return activities.count
        
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        view.backgroundColor = kBackgroundTableViewColor
        
        let dayData = tableViewSections[section]
        
        let statusText = dayData["title"] as! String
        
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
        
        let rowDetail = tableViewSections[indexPath.section]
        let activities = rowDetail["activities"] as! Array<Activity>
        
        if activities.count == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "noData", for: indexPath)
            cell.isUserInteractionEnabled = false
            return cell
        }
        else {
            var cell = tableView.dequeueReusableCell(withIdentifier: kActivitiesTableViewCell, for: indexPath) as! ActivitiesTableViewCell
            cell.delegate = self
            
            //Cell Data Setup
            cell.backgroundColor = UIColor.clear
            //kActivitiesTableViewScheduledCell
            let availabilityStatus = ActivityAvailabilityStatus(rawValue:indexPath.section)
            
            let activity = activities[indexPath.row]
            
            //check for scheduled frequency
            if activity.frequencyType == .Scheduled {
                
                cell = tableView.dequeueReusableCell(withIdentifier: kActivitiesTableViewScheduledCell, for: indexPath) as! ActivitiesTableViewCell
                cell.delegate = self
            }
            
            cell.populateCellDataWithActivity(activity:activity, availablityStatus:availabilityStatus!)
            
            return cell
        }
        
        
    }
}

//MARK: TableView Delegates
extension ActivitiesViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let availabilityStatus = ActivityAvailabilityStatus(rawValue:indexPath.section)!
        
        switch availabilityStatus {
        case .current:
            
            let rowDetail = tableViewSections[indexPath.section]
            let activities = rowDetail["activities"] as! Array<Activity>
            
            let activity = activities[indexPath.row]
            //Check for activity run status & if run is available
            if activity.currentRun != nil {
                if activity.userParticipationStatus != nil {
                    let activityRunParticipationStatus = activity.userParticipationStatus
                    if activityRunParticipationStatus?.status == .yetToJoin || activityRunParticipationStatus?.status == .inProgress {
                        
                        
                        Study.updateCurrentActivity(activity:activities[indexPath.row])
                        
                        //Following to be commented
                        //self.createActivity()
                        
                        //To be uncommented
                        WCPServices().getStudyActivityMetadata(studyId:(Study.currentStudy?.studyId)! , activityId: (Study.currentActivity?.actvityId)!, activityVersion: "1", delegate: self)
                        
                        self.updateActivityStatusToInProgress()
                        
                        self.selectedIndexPath = indexPath
                    }
                    else {
                        debugPrint("run is completed")
                    }
                }
               
            }
            else {
                debugPrint("run not available")
            }
            
            //Following to be commented
           // self.createActivity()
            
            //To be uncommented
        //WCPServices().getStudyActivityMetadata(studyId:(Study.currentStudy?.studyId)! , activityId: (Study.currentActivity?.actvityId)!, activityVersion: "1", delegate: self)
            
        case .upcoming,.past: break
       
        }
        
        
    }
    
}

 //MARK: ActivitiesCellDelegate
extension ActivitiesViewController:ActivitiesCellDelegate{
    
    func activityCell(cell: ActivitiesTableViewCell, activity: Activity) {
        
        var frame = self.view.frame
        //frame.size.height -= 114
        
        let view = ActivitySchedules.instanceFromNib(frame: frame, activity: activity)
        //self.view.addSubview(view)
        UIApplication.shared.keyWindow?.addSubview(view)
    }
    
    
    
}

extension ActivitiesViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) Response : \(response)")
        
        self.removeProgressIndicator()
        
        if requestName as String == WCPMethods.activityList.method.methodName {
                       
            //self.tableView?.reloadData()
            self.handleActivityListResponse()
            
        }
        else if requestName as String == WCPMethods.activity.method.methodName {
            self.createActivity()
        }
        
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        
        
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
            self.updateRunStatusToComplete()
        case ORKTaskViewControllerFinishReason.failed:
            print("failed")
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.discarded:
            print("discarded")
            
            let study = Study.currentStudy
            let activity = Study.currentActivity
            activity?.restortionData = nil
            DBHandler.updateActivityRestortionDataFor(activityId:(activity?.actvityId)!, studyId: (study?.studyId)!, restortionData:nil)
            
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
                
               
                Study.currentActivity?.userStatus = .completed
                
                //To be Uncommented
                
                //let status = User.currentUser.updateActivityStatus(studyId: activity.studyId!, activityId: activity.actvityId!, status: .inProgress)
                //UserServices().updateUserActivityParticipatedStatus(activityStatus: status, delegate: self)
                
                
            }
            
        }
        taskViewController.dismiss(animated: true, completion: {
            self.tableView?.reloadRows(at: [self.selectedIndexPath!], with: .automatic)
        })
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        
        if (taskViewController.result.results?.count)! > 1{
            
            
            if activityBuilder?.actvityResult?.result?.count == taskViewController.result.results?.count{
                activityBuilder?.actvityResult?.result?.removeLast()
            }
            else{
                
                let study = Study.currentStudy
                let activity = Study.currentActivity
                DBHandler.updateActivityRestortionDataFor(activityId:(activity?.actvityId)!, studyId: (study?.studyId)!, restortionData: taskViewController.restorationData!)
                
                //Explain
                if (ActivityBuilder.currentActivityBuilder.actvityResult?.result?.count)! < (taskViewController.result.results?.count)!{
                    
                    //Explain
                    let orkStepResult:ORKStepResult? = taskViewController.result.results?[(taskViewController.result.results?.count)! - 2] as! ORKStepResult?
                    let activityStepResult:ActivityStepResult? = ActivityStepResult()
                    
                   
                     UserDefaults.standard.set(taskViewController.restorationData, forKey: "RESTORED-RESULT")
                     UserDefaults.standard.synchronize()
                    
           
                    
                    activityStepResult?.initWithORKStepResult(stepResult: orkStepResult! as ORKStepResult , activityType:(ActivityBuilder.currentActivityBuilder.actvityResult?.type)!)
                    
                     let index = (taskViewController.result.results?.count)! - 2
                    if index < (ActivityBuilder.currentActivityBuilder.activity?.activitySteps?.count)!{
                         activityStepResult?.step = ActivityBuilder.currentActivityBuilder.activity?.activitySteps?[index]
                    }
                    
                    ActivityBuilder.currentActivityBuilder.actvityResult?.result?.append(activityStepResult!)
                    
                    //save result in db
                    
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

class ActivitySchedules:UIView,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var tableview:UITableView?
    @IBOutlet var buttonCancel:UIButton!
    @IBOutlet var heightLayoutConstraint:NSLayoutConstraint!
    var activity:Activity!
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        let view = self.instanceFromNib()
//        addSubview(view)
//        tableview?.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    class func instanceFromNib(frame:CGRect , activity:Activity) -> ActivitySchedules {
        let view = UINib(nibName: "ActivitySchedules", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ActivitySchedules
        view.frame = frame
        view.activity = activity
        view.tableview?.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.tableview?.delegate = view
        view.tableview?.dataSource = view
        let height = (activity.activityRuns.count*44) + 104
        let maxViewHeight = Int(UIScreen.main.bounds.size.height - 67)
        view.heightLayoutConstraint.constant = CGFloat((height > maxViewHeight) ? maxViewHeight:height)
        view.layoutIfNeeded()
        
        return view
    }
    
    @IBAction func buttonCancelClicked(_:UIButton){
        self.removeFromSuperview()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.activity.activityRuns.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        let activityRun = self.activity.activityRuns[indexPath.row]
        cell.textLabel?.text = ActivitySchedules.formatter.string(from: activityRun.startDate) + " - "
        + ActivitySchedules.formatter.string(from: activityRun.endDate)
        if activityRun.runId == self.activity.currentRunId {
            cell.textLabel?.textColor = kBlueColor
        }
        else if activityRun.runId < self.activity.currentRunId {
            cell.textLabel?.textColor = UIColor.gray
        }
        
        cell.textLabel?.textAlignment = .center
        return cell
        
        
    }
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hha, MMM dd YYYY"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
}



