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
    
    @IBOutlet var tableView : UITableView?
    
    var tableViewSections:Array<Dictionary<String,Any>>! = []
    var lastFetelKickIdentifer:String = ""  //TEMP
    var selectedIndexPath:IndexPath? = nil
    var isAnchorDateSet:Bool = false
    var taskControllerPresented = false
    
//MARK:- Viewcontroller Lifecycle
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
            //WCPServices().getStudyActivityList(studyId: (Study.currentStudy?.studyId)!, delegate: self)
            //load from database
            //self.loadActivitiesFromDatabase()
           
            
            
            if StudyUpdates.studyConsentUpdated {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.checkConsentStatus(controller: self)
            }
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        UIApplication.shared.statusBarStyle = .default
        
        if !taskControllerPresented {
            taskControllerPresented = false
            self.checkForActivitiesUpdates()
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func checkForActivitiesUpdates(){
        
        if StudyUpdates.studyActivitiesUpdated {
            
            self.sendRequestToGetActivityStates()
            
        }
        else {
            
            self.loadActivitiesFromDatabase()
            // self.sendRequestToGetActivityStates()
        }
    }
    
    func registerNotificationForAnchorDate(){
        
        DBHandler.getResourcesWithAnchorDateAvailable(studyId: (Study.currentStudy?.studyId)!) { (resourcesList) in
            if resourcesList.count > 0 {
                
                for resource in resourcesList {
                    
                    if resource.startDate == nil && resource.endDate == nil {
                        
                        let anchorDateObject = Study.currentStudy?.anchorDate
                        if(anchorDateObject != nil && (anchorDateObject?.isAnchorDateAvailable())!) {
                            
                            let anchorDate = Study.currentStudy?.anchorDate?.date
                            
                            if anchorDate != nil {
                                
                                //also anchor date condition
                                let startDateInterval = TimeInterval(60*60*24*(resource.anchorDateStartDays))
                                
                                let endDateInterval = TimeInterval(60*60*24*(resource.anchorDateEndDays))
                               
                                
                                let startAnchorDate = anchorDate?.addingTimeInterval(startDateInterval)
                                let endAnchorDate = anchorDate?.addingTimeInterval(endDateInterval)
                                
                                self.isAnchorDateSet = false
                                
                                let notification = AppLocalNotification()
                                notification.id = resource.resourceId! + (Study.currentStudy?.studyId)!
                                notification.message = resource.notificationMessage
                                notification.title = "New Resource Available"
                                notification.startDate = startAnchorDate
                                notification.endDate = endAnchorDate
                                notification.type = AppNotification.NotificationType.Study
                                notification.subType = AppNotification.NotificationSubType.Resource
                                notification.audience = Audience.Limited
                                notification.studyId = (Study.currentStudy?.studyId)!
                                notification.activityId = Study.currentActivity?.actvityId
                                
                                DBHandler.saveLocalNotification(notification: notification)
                                
                                //register notification
                                let message = resource.notificationMessage
                                let userInfo = ["studyId":(Study.currentStudy?.studyId)!,
                                                "type":"resource"];
                                LocalNotification.scheduleNotificationOn(date: startAnchorDate!, message: message!, userInfo: userInfo)
                                
                               
                            }
                        }
                    }
                }
            }
        }
    }
    
    
//MARK:- Button Actions
    
    /**
     
     Home Button Clicked
     
     @param sender    Accepts any kind of object
     
     */
    @IBAction func homeButtonAction(_ sender: AnyObject){
        //_ = self.navigationController?.popToRootViewController(animated: true)
        self.performSegue(withIdentifier: "unwindeToStudyListIdentier", sender: self)
    }
    
    @IBAction func filterButtonAction(_ sender: AnyObject){
        
        
    }
    
    func checkForDashBoardInfo(){
        
        DBHandler.loadStatisticsForStudy(studyId: (Study.currentStudy?.studyId)!) { (statiticsList) in
            
            if statiticsList.count != 0 {
               
            }
            else {
                self.sendRequestToGetDashboardInfo()
            }
        }
    }

//MARK:- 
    
    /**
     
     Used to load the Actif=vities data from database
     
     */
    func loadActivitiesFromDatabase(){
        
        DBHandler.loadActivityListFromDatabase(studyId: (Study.currentStudy?.studyId)!) { (activities) in
            if activities.count > 0 {
                Study.currentStudy?.activities = activities
                self.handleActivityListResponse()
                
               
                
            }
            else {
                
                self.sendRequestToGetActivityStates()
                
               // WCPServices().getStudyActivityList(studyId: (Study.currentStudy?.studyId)!, delegate: self)
            }
        }
        
         self.checkForDashBoardInfo()
    }
    
    
    /**
     
     Used to create an activity using ORKTaskViewController
     
     */
    func createActivity(){
        
/*
        let filePath  = Bundle.main.path(forResource: "Labkey_Activity", ofType: "json")
        
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
        
        let task:ORKTask?
        let taskViewController:ORKTaskViewController?
        
        task = ActivityBuilder.currentActivityBuilder.createTask()
        
        
        if task != nil {
            
            
            if Study.currentActivity?.currentRun.restortionData != nil {
                let restoredData = Study.currentActivity?.currentRun.restortionData
                
                let result:ORKResult?
                taskViewController = ORKTaskViewController(task: task, restorationData: restoredData, delegate: self)
            }
            else{
                
                taskViewController = ORKTaskViewController(task:task, taskRun: nil)
                taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            }
            
            taskViewController?.showsProgressInNavigationBar = true
            
            UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self]).tintColor = kUIColorForSubmitButtonBackground
            
            taskViewController?.delegate = self
            UIApplication.shared.statusBarStyle = .default
            taskControllerPresented = true
            present(taskViewController!, animated: true, completion: nil)
        }
        else{
            UIUtilities.showAlertMessage(kAlertMessageText, errorMessage: NSLocalizedString("Invalid Data!", comment: ""), errorAlertActionTitle: NSLocalizedString("OK", comment: ""), viewControllerUsed: self)
        }
        
    }
    
    
    /**
     
     Used to get Activity Availability Status
     
     @param activity    Accepts data from Activity class
     @return ActivityAvailabilityStatus
     
     */
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
        return .current
    }
    
    
    /**
     
     Used to handle Activity list response
     
     */
    func handleActivityListResponse(){
        
        tableViewSections = []
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
        self.removeProgressIndicator()
        
        self.updateCompletionAdherence()
        
        if !(Study.currentStudy?.activitiesLocalNotificationUpdated)! {
            
            LocalNotification.registerAllLocalNotificationFor(activities: (Study.currentStudy?.activities)!) { (finished) in
                print("Notification set sucessfully")
                Study.currentStudy?.activitiesLocalNotificationUpdated = true
                
                DBHandler.updateLocalNotificaitonUpdated(studyId: (Study.currentStudy?.studyId)!)
            }

        }
        
        
    }
    
    
    /**
     
     Used to update Activity Run Status
     
     @param status    Accepts data from UserActivityStatus class and ActivityStatus enum
     
     */
    func updateActivityRunStuatus(status:UserActivityStatus.ActivityStatus){
        
        let activity = Study.currentActivity!
        
        let activityStatus = User.currentUser.updateActivityStatus(studyId: activity.studyId!, activityId: activity.actvityId!,runId: String(activity.currentRunId), status:status)
        activityStatus.compeltedRuns = activity.compeltedRuns
        activityStatus.incompletedRuns = activity.incompletedRuns
        activityStatus.totalRuns = activity.totalRuns
        
        UserServices().updateUserActivityParticipatedStatus(studyId:activity.studyId!, activityStatus: activityStatus, delegate: self)
        
        DBHandler.updateActivityParticipationStatus(activity: activity)
        
        if status == .completed{
            self.updateCompletionAdherence()
        }
        
    }
    
    
    
    func updateCompletionAdherence(){

        
       // let rowDetail = tableViewSections[indexPath.section]
        
        var totalRuns = 0
        var totalCompletedRuns = 0
        var totalIncompletedRuns = 0
        for detail in tableViewSections {
            let activities = detail["activities"] as! Array<Activity>
            for activity in activities {
                totalRuns += activity.totalRuns
                totalIncompletedRuns += activity.incompletedRuns
                totalCompletedRuns += activity.compeltedRuns
            }
        }
        
        
        
        
        let completion = ceil( Double(self.divide(lhs: (totalCompletedRuns + totalIncompletedRuns)*100, rhs: totalRuns)) )
        let adherence = ceil (Double(self.divide(lhs: totalCompletedRuns*100, rhs: (totalCompletedRuns + totalIncompletedRuns))))
        
        let studyid = (Study.currentStudy?.studyId)!
//        DBHandler.loadAllStudyRuns(studyId: studyid) { (completion, adherence) in
//            //
            let status = User.currentUser.udpateCompletionAndAdherence(studyId:studyid, completion: Int(completion), adherence: Int(adherence))
            UserServices().udpateCompletionAdherence(studyStauts: status, delegate: self)
            DBHandler.updateStudyParticipationStatus(study: Study.currentStudy!)
//        }
    }
    
    func divide(lhs: Int, rhs: Int) -> Int {
        if rhs == 0 {
            return 0
        }
        return lhs/rhs
    }
    /**
     
     Used to update Activity Status To InProgress
    
     */
    func updateActivityStatusToInProgress(){
        self.updateActivityRunStuatus(status: .inProgress)
    }
    
    
    /**
     
     Used to update Activity Status To Complete
     
     */
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
    
    
    /**
     
     Used to send Request To Get ActivityStates
     
     */
    func sendRequestToGetActivityStates(){
        UserServices().getUserActivityState(studyId: (Study.currentStudy?.studyId)!, delegate: self)
    }
    
    
    /**
     
     Used to send Request To Get ActivityList
     
     */
    func sendRequesToGetActivityList(){
        WCPServices().getStudyActivityList(studyId: (Study.currentStudy?.studyId)!, delegate: self)
    }
    
    func sendRequestToGetDashboardInfo(){
        WCPServices().getStudyDashboardInfo(studyId: (Study.currentStudy?.studyId)!, delegate: self)
    }
    

}


//MARK:- TableView Datasource
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


//MARK:- TableView Delegates
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
                    if activityRunParticipationStatus?.status == .yetToJoin || activityRunParticipationStatus?.status == .inProgress
                       {
                        
                        
                        Study.updateCurrentActivity(activity:activities[indexPath.row])
                        
                        //Following to be commented
                        //self.createActivity()
                        
                        //check in database
                        DBHandler.loadActivityMetaData(activity: activities[indexPath.row], completionHandler: { (found) in
                            if found {
                                self.createActivity()
                            }
                            else {
                                
                                WCPServices().getStudyActivityMetadata(studyId:(Study.currentStudy?.studyId)! , activityId: (Study.currentActivity?.actvityId)!, activityVersion: (Study.currentActivity?.version)!, delegate: self)
                            }
                        })
                        
//                        //To be uncommented
//                        WCPServices().getStudyActivityMetadata(studyId:(Study.currentStudy?.studyId)! , activityId: (Study.currentActivity?.actvityId)!, activityVersion: (Study.currentActivity?.version)!, delegate: self)
                        
                        self.updateActivityStatusToInProgress()
                        
                        self.selectedIndexPath = indexPath
                    }
                    else {
                        debugPrint("run is completed")
                        //Study.updateCurrentActivity(activity:activities[indexPath.row])
                        //self.updateRunStatusToComplete()
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

//MARK:- ActivitiesCell Delegate
extension ActivitiesViewController:ActivitiesCellDelegate{
    
    func activityCell(cell: ActivitiesTableViewCell, activity: Activity) {
        
        var frame = self.view.frame
        //frame.size.height -= 114
        
        let view = ActivitySchedules.instanceFromNib(frame: frame, activity: activity)
        //self.view.addSubview(view)
        UIApplication.shared.keyWindow?.addSubview(view)
    }
}


//MARK:- Webservice Delegates
extension ActivitiesViewController:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
       
        if (requestName as String == RegistrationMethods.updateStudyState.method.methodName) ||  (requestName as String == RegistrationMethods.updateActivityState.method.methodName) ||
            (requestName as String == WCPMethods.studyDashboard.method.methodName){
        }
        else {
             self.addProgressIndicator()
        }
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) Response : \(response)")
        
        if requestName as String == RegistrationMethods.activityState.method.methodName{
            self.sendRequesToGetActivityList()
        }
        else if requestName as String == WCPMethods.activityList.method.methodName {
                       
            //self.tableView?.reloadData()
            //self.handleActivityListResponse()
            self.loadActivitiesFromDatabase()
            
            StudyUpdates.studyActivitiesUpdated = false
            DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
            
        }
        else if requestName as String == WCPMethods.activity.method.methodName {
            self.removeProgressIndicator()
            self.createActivity()
        }
        else if requestName as String == ResponseMethods.processResponse.method.methodName{
            self.removeProgressIndicator()
             //self.updateRunStatusToComplete()
        }
    }
    
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        if error.code == 401 { //unauthorized
            UIUtilities.showAlertMessageWithActionHandler(kErrorTitle, message: error.localizedDescription, buttonTitle: kTitleOk, viewControllerUsed: self, action: {
                self.fdaSlideMenuController()?.navigateToHomeAfterUnauthorizedAccess()
            })
        }
        else
        {
        
        
        if requestName as String == RegistrationMethods.activityState.method.methodName{
            //self.sendRequesToGetActivityList()
            self.loadActivitiesFromDatabase()
        }
        else if requestName as String == ResponseMethods.processResponse.method.methodName {
            
            if (error.code == NoNetworkErrorCode) {
                //Users are notified when their responses don’t get submitted due to network issues and are notified that the responses will be automatically submitted once the app has network available again.
//                UIUtilities.showAlertWithMessage(alertMessage: "Your responses don’t get submitted due to network issue, but we have saved it locally, we will automatically submit once the app has network available again.")
//                
//                if error.code == CouldNotConnectToServerCode {
//                    UIUtilities.showAlertWithMessage(alertMessage: "Your responses don’t get submitted due to connectiviy with our server, but we have saved it locally, we will automatically submit once the app has network available again.")
//                }
               let data = ActivityBuilder.currentActivityBuilder.actvityResult?.getResultDictionary()
               DBHandler.saveResponseDataFor(activity: Study.currentActivity!, toBeSynced: true, data: data!)
                
            }
            
        }
        else {
            UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kErrorTitle, comment: "") as NSString, message: error.localizedDescription as NSString)
        }
    }
    }
}

//MARK:- ORKTaskViewController Delegate
extension ActivitiesViewController:ORKTaskViewControllerDelegate{
    
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
            activity?.currentRun.restortionData = nil
            DBHandler.updateActivityRestortionDataFor(activity:activity!, studyId: (study?.studyId)!, restortionData:nil)
            
           // taskResult = taskViewController.result
            
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
                
                
                if ActivityBuilder.currentActivityBuilder.actvityResult?.type == ActivityType.activeTask{
                    
                    
                    if  (taskViewController.result.results?.count)! > 0 {
                        
                        let orkStepResult:ORKStepResult? = taskViewController.result.results?[2] as! ORKStepResult
                        if (orkStepResult?.results?.count)! > 0 {
                            
                            let fetalKickResult:FetalKickCounterTaskResult? = orkStepResult?.results?.first as! FetalKickCounterTaskResult
                            
                            let study = Study.currentStudy
                            let activity = Study.currentActivity
                          
                            
                            let value = Float((fetalKickResult?.totalKickCount)!)
                            let dict = ActivityBuilder.currentActivityBuilder.activity?.steps?.first!
                            let key = dict?[kActivityStepKey] as! String
                            
                            DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!, key: key, data:value)
                            
                        }
                        
                    }
                    
                }
                
                
                //send response to labkey
                LabKeyServices().processResponse(responseData:(ActivityBuilder.currentActivityBuilder.actvityResult?.getResultDictionary())! , delegate: self)
                
                
                
                
                
            }
            
        }
        taskViewController.dismiss(animated: true, completion: {
            //self.tableView?.reloadRows(at: [self.selectedIndexPath!], with: .automatic)
            self.tableView?.reloadData()
            if self.isAnchorDateSet {
                self.registerNotificationForAnchorDate()
            }
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
                
                if activity?.type != .activeTask{
                
                    DBHandler.updateActivityRestortionDataFor(activity:activity!, studyId: (study?.studyId)!, restortionData: taskViewController.restorationData!)
                    activity?.currentRun.restortionData = taskViewController.restorationData!
                }
                
               
                
                
                //Explain
                let orkStepResult:ORKStepResult? = taskViewController.result.results?[(taskViewController.result.results?.count)! - 2] as! ORKStepResult?
                let activityStepResult:ActivityStepResult? = ActivityStepResult()
                if (activity?.activitySteps?.count )! > 0 {
                    
                    let activityStepArray = activity?.activitySteps?.filter({$0.key == orkStepResult?.identifier
                    })
                    
                    if (activityStepArray?.count)! > 0 {
                        activityStepResult?.step  = activityStepArray?.first
                    }
                    
                }
                activityStepResult?.initWithORKStepResult(stepResult: orkStepResult! as ORKStepResult , activityType:(ActivityBuilder.currentActivityBuilder.actvityResult?.type)!)
                
                let dictionary = activityStepResult?.getActivityStepResultDict()
                print("dictionary \(dictionary)")
                
                //check for anchor date
                if study?.anchorDate != nil && study?.anchorDate?.anchorDateActivityId == activity?.actvityId {
                    
                    if (study?.anchorDate?.anchorDateQuestionKey)! ==  (activityStepResult?.key)!{
                        if let value1 = activityStepResult?.value as? String {
                            isAnchorDateSet = true
                            study?.anchorDate?.setAnchorDateFromQuestion(date: value1)
                        }
                    }
                }
                
                //save data for stats
                if ActivityBuilder.currentActivityBuilder.actvityResult?.type == .Questionnaire {
                   
                    if let value1 = activityStepResult?.value as? NSNumber {
                        let value = value1.floatValue
                        DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!, key: (activityStepResult?.key)!, data:value)
                    }
                    
                }
                
                
                
                
                
               
                
                /*
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
 */
 
            }
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
        
         let storyboard = UIStoryboard.init(name: "FetalKickCounter", bundle: nil)
        
       
        if step is FetalKickCounterStep {
           
            let ttController = storyboard.instantiateViewController(withIdentifier: "FetalKickCounterStepViewController") as! FetalKickCounterStepViewController
            ttController.step = step
            return ttController
        }
        else if  step is FetalKickIntroStep{
           
            
            let ttController = storyboard.instantiateViewController(withIdentifier: "FetalKickIntroStepViewControllerIdentifier") as! FetalKickIntroStepViewController
            ttController.step = step
            return ttController

        }
        else {
            return nil
        }
    }
}

//MARK:- ActivitySchedules Class
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

    
//MARK:- Button Action
    @IBAction func buttonCancelClicked(_:UIButton) {
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


