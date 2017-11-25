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
import IQKeyboardManagerSwift

let kActivities = "activities"

let kActivityUnwindToStudyListIdentifier = "unwindeToStudyListIdentier"

enum ActivityAvailabilityStatus:Int{
    case current
    case upcoming
    case past
}

class ActivitiesViewController : UIViewController{
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var labelNoNetworkAvailable:UILabel?
    
    var tableViewSections:Array<Dictionary<String,Any>>! = []
    var lastFetelKickIdentifer:String = ""  //TEMP
    var selectedIndexPath:IndexPath? = nil
    var isAnchorDateSet:Bool = false
    var taskControllerPresented = false
    var refreshControl:UIRefreshControl?
    
    var allActivityList:Array<Dictionary<String,Any>>! = []
    var selectedFilter: ActivityFilterType?
    
    //MARK:- Viewcontroller Lifecycle
    fileprivate func presentUpdatedConsent() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.checkConsentStatus(controller: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load plist info
        //let plistPath = Bundle.main.path(forResource: "Activities", ofType: ".plist", inDirectory:nil)
        // tableViewRowDetails = Array(contente) //NSMutableArray.init(contentsOfFile: plistPath!)
        
        selectedFilter = ActivityFilterType.all
        
        
        self.tableView?.estimatedRowHeight = 126
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        
         self.tabBarController?.delegate = self
        
        self.navigationItem.title = NSLocalizedString("STUDY ACTIVITIES", comment: "")
        self.tableView?.sectionHeaderHeight = 30
        
       self.navigationController?.navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
        
        if (Study.currentStudy?.studyId) != nil {
            //WCPServices().getStudyActivityList(studyId: (Study.currentStudy?.studyId)!, delegate: self)
            //load from database
            //self.loadActivitiesFromDatabase()
            
            
            //StudyUpdates.studyConsentUpdated = true
            
            if StudyUpdates.studyConsentUpdated {
                
                NotificationHandler.instance.activityId = ""
                presentUpdatedConsent()
            }
            
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView?.addSubview(refreshControl!)
       

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        UIApplication.shared.statusBarStyle = .default
        
        self.addHomeButton()
        
        if !taskControllerPresented {
            taskControllerPresented = false
            self.checkForActivitiesUpdates()
        }
        
        if tableViewSections.count == 0{
            self.tableView?.isHidden = true
            self.labelNoNetworkAvailable?.isHidden = false
        }
        else{
            self.tableView?.isHidden = false
            self.labelNoNetworkAvailable?.isHidden = true
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
            
            if self.refreshControl != nil && (self.refreshControl?.isRefreshing)!{
                self.refreshControl?.endRefreshing()
            }
            self.loadActivitiesFromDatabase()
           
        }
    }
    
    func checkIfFetelKickCountRunning(){
        
        let ud = UserDefaults.standard
        
        
        if (ud.bool(forKey: "FKC") && ud.object(forKey: "FetalKickStartTimeStamp") != nil) {
            
            let studyId = ud.object(forKey: "FetalKickStudyId")  as! String
            let activityId = ud.object(forKey: "FetalKickActivityId")  as! String
            let activity  = Study.currentStudy?.activities?.filter({$0.actvityId == activityId}).last
            
           
            
            Study.updateCurrentActivity(activity:activity!)
            //check in database
            DBHandler.loadActivityMetaData(activity: activity!, completionHandler: { (found) in
                if found {
                    
                   
                    self.createActivity()
                }
                
            })

        }
        else {
            //check if user navigated from notification
            
            if NotificationHandler.instance.activityId.characters.count > 0 {
                
                let activityId = NotificationHandler.instance.activityId
                
                let rowDetail = tableViewSections[0]
                let activities = rowDetail["activities"] as! Array<Activity>
                let index = activities.index(where: {$0.actvityId == activityId})
                let ip = IndexPath.init(row: index!, section: 0)
                self.selectedIndexPath = ip
                self.tableView?.selectRow(at: ip, animated: true, scrollPosition:.middle)
                self.tableView?.delegate?.tableView!(self.tableView!, didSelectRowAt: ip)
                
                NotificationHandler.instance.activityId = ""
            }
        }
        
        
    }
    
    func registerNotificationForAnchorDate(){
        
        DBHandler.getResourcesWithAnchorDateAvailable(studyId: (Study.currentStudy?.studyId)!) { (resourcesList) in
            if resourcesList.count > 0 {
                let todayDate = Date()
                for resource in resourcesList {
                    
                    if resource.startDate == nil && resource.endDate == nil {
                        
                        let anchorDateObject = Study.currentStudy?.anchorDate
                        if(anchorDateObject != nil && (anchorDateObject?.isAnchorDateAvailable())!) {
                            
                            let anchorDate = Study.currentStudy?.anchorDate?.date?.startOfDay
                            
                            if anchorDate != nil {
                                
                                
                                //also anchor date condition
                                let startDateInterval = TimeInterval(60*60*24*(resource.anchorDateStartDays))
                                
                                let endDateInterval = TimeInterval(60*60*24*(resource.anchorDateEndDays))
                                
                                
                                let startAnchorDate = anchorDate?.addingTimeInterval(startDateInterval)
                                var endAnchorDate = anchorDate?.addingTimeInterval(endDateInterval)
                                
                                endAnchorDate = endAnchorDate?.endOfDay
                                let startDateResult = (startAnchorDate?.compare(todayDate))! as ComparisonResult
                                let endDateResult = (endAnchorDate?.compare(todayDate))! as ComparisonResult
                                self.isAnchorDateSet = false
//                                var notificationDate = startAnchorDate?.startOfDay
//                                notificationDate = notificationDate?.addingTimeInterval(43200)
//                                let message = resource.notificationMessage
//                                let userInfo = ["studyId":(Study.currentStudy?.studyId)!,
//                                                "type":"resource"];
//                                LocalNotification.scheduleNotificationOn(date: notificationDate!, message: message!, userInfo: userInfo)
                                
                                if startDateResult == .orderedDescending {
                                    //upcoming
                                    let notfiId = resource.resourceId! + (Study.currentStudy?.studyId)!
                                    DBHandler.isNotificationSetFor(notification: notfiId
                                        , completionHandler: { (found) in
                                            if !found {
                                                
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
                                                //notification.activityId = Study.currentActivity?.actvityId
                                                
                                                DBHandler.saveLocalNotification(notification: notification)
                                                
                                                //register notification
                                                var notificationDate = startAnchorDate?.startOfDay
                                                notificationDate = notificationDate?.addingTimeInterval(43200)
                                                let message = resource.notificationMessage
                                                let userInfo = ["studyId":(Study.currentStudy?.studyId)!,
                                                                "type":"resource"];
                                                LocalNotification.scheduleNotificationOn(date: notificationDate!, message: message!, userInfo: userInfo)
                                            }
                                    })
                                    
                                    
                                }
                              
                                
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
        self.performSegue(withIdentifier: kActivityUnwindToStudyListIdentifier, sender: self)
    }
    
    @IBAction func filterButtonAction(_ sender: AnyObject){
         let frame = self.view.frame
        
        if self.selectedFilter == nil {
            self.selectedFilter = ActivityFilterType.all
        }
        
        let view = ActivityFilterView.instanceFromNib(frame:frame , selectedIndex:self.selectedFilter!)
        view.delegate = self
        self.tabBarController?.view.addSubview(view)
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
    
    
    func refresh(sender:AnyObject) {
        
         Logger.sharedInstance.info("Request for study Updated...")
         WCPServices().getStudyUpdates(study: Study.currentStudy!, delegate: self)
        //self.sendRequesToGetActivityList()
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
        
       // self.checkForDashBoardInfo()
    }
    
    
    /**
     
     Used to create an activity using ORKTaskViewController
     
     */
    func createActivity(){
        
       // Labkey_Activity_Latest
        //Labkey_Activity
        /*
         let filePath  = Bundle.main.path(forResource: "Labkey_Activity_Latest3", ofType: "json")
         
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
        
        
        
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
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
            
            taskViewController?.title = "Activity"
            
            UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self]).tintColor = kUIColorForSubmitButtonBackground
            
            taskViewController?.delegate = self
            UIApplication.shared.statusBarStyle = .default
            taskControllerPresented = true
            present(taskViewController!, animated: true, completion: nil)
            
            
// -----------NEEDED FOR NEXT PHASE
//              if Study.currentActivity?.currentRun.restortionData != nil {
//                while (taskViewController?.result.results?.count)! > 1 {
//                    
//                    taskViewController?.goBackward()
//                    
//                    let questionstepViewArray = (taskViewController?.currentStepViewController?.view?.subviews)?.filter({$0.isKind(of: UIScrollView.self)})
//                    let questionStepView = questionstepViewArray?.first
//                    
//                    if questionStepView != nil {
//                    
//                    for subView in (questionStepView?.accessibilityElements)!{
//                        
//                        if (subView as AnyObject).isKind(of: UIButton.self) == false{
//                            ((subView as Any) as AnyObject).isUserInteractionEnabled = false
//                            
//                            print("subview : \(subView)")
//                            
//                        }
//                        
//                        
//                    }
//                    
//                    }
//                }
//                
//            }
            
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
        
        var todayDate = Date().utcDate()
        
        let difference = UserDefaults.standard.value(forKey: "offset") as? Int
        if difference != nil {
            todayDate = todayDate.addingTimeInterval(TimeInterval(difference!))
        }
       
        
        if activity.startDate != nil && activity.endDate != nil {
            

            
            let startDateResult = (activity.startDate?.compare(todayDate))! as ComparisonResult
            let endDateResult = (activity.endDate?.compare(todayDate))! as ComparisonResult
            
            if startDateResult == .orderedAscending && endDateResult == .orderedDescending{
                
                return .current
            }
            else if startDateResult == .orderedDescending {
                
                return .upcoming
            }
            else if endDateResult == .orderedAscending {
                
                return .past
            }
        }
        else if activity.startDate != nil {
            
            let startDateResult = (activity.startDate?.compare(todayDate))! as ComparisonResult
            
            if startDateResult == .orderedAscending{
                
                return .current
            }
            else if startDateResult == .orderedDescending {
                
                return .upcoming
            }
            
            
        }
        return .current
    }
    
    
    /**
     
     Used to handle Activity list response
     
     */
    func handleActivityListResponse(){
        
        tableViewSections = []
        allActivityList = []
        let activities = Study.currentStudy?.activities
        
        var currentActivities:Array<Activity> = []
        var upcomingActivities:Array<Activity> = []
        var pastActivities:Array<Activity> = []
        
        for activity in activities! {
            
            if activity.state == "active" || activity.state == nil{
                
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
            else {
                //remove notification for inactive activites
                
                //remove local notification
                LocalNotification.removeLocalNotificationfor(studyId:activity.studyId!, activityid:activity.actvityId!)
            }
            
           
        }
        
        //sort as per start date
        currentActivities.sort(by: {$0.startDate?.compare($1.startDate!) == .orderedAscending})
        upcomingActivities.sort(by: {$0.startDate?.compare($1.startDate!) == .orderedAscending})
        pastActivities.sort(by: {$0.startDate?.compare($1.startDate!) == .orderedAscending})
        
        
        let  sortedCurrentActivities =  currentActivities.sorted(by: { (activity1:Activity, activity2:Activity) -> Bool in
            
            //if activity1.status == activity1.status {
                return (activity1.userParticipationStatus.status.sortIndex < activity2.userParticipationStatus.status.sortIndex)
            //}
            //return (activity1.status.sortIndex < activity1.status.sortIndex)
        })
        
        
        let currentDetails = ["title":"CURRENT","activities":sortedCurrentActivities] as [String : Any]
        let upcomingDetails = ["title":"UPCOMING","activities":upcomingActivities] as [String : Any]
        let pastDetails = ["title":"PAST","activities":pastActivities] as [String : Any]
        
        
        
        
        allActivityList.append(currentDetails)
        allActivityList.append(upcomingDetails)
        allActivityList.append(pastDetails)
        
        tableViewSections = allActivityList
        
        if self.selectedFilter == .tasks || self.selectedFilter == .surveys{
            
             let filterType:ActivityType! =  (selectedFilter == .surveys ? .Questionnaire : .activeTask)
            self.updateSectionArray(activityType: filterType)
        }
        
        
        
        self.tableView?.reloadData()
        //--Commented
        
         //self.removeProgressIndicator()
        //---
       
        
        self.tableView?.isHidden = false
        self.labelNoNetworkAvailable?.isHidden = true
        
        self.updateCompletionAdherence()
        
        if (User.currentUser.settings?.localNotifications)! {
            
            if !(Study.currentStudy?.activitiesLocalNotificationUpdated)! {
                
                LocalNotification.registerAllLocalNotificationFor(activities: (Study.currentStudy?.activities)!) { (finished,notificationlist) in
                    print("Notification set sucessfully")
                    Study.currentStudy?.activitiesLocalNotificationUpdated = true
                    DBHandler.saveRegisteredLocaNotification(notificationList: notificationlist)
                    DBHandler.updateLocalNotificaitonUpdated(studyId: (Study.currentStudy?.studyId)!,status: true)
                }
                
            }
        }
        
        
        self.checkIfFetelKickCountRunning()
        
        Logger.sharedInstance.info("Activities Displayed to user")
        
        
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
        activityStatus.activityVersion = activity.version
        
        UserServices().updateUserActivityParticipatedStatus(studyId:activity.studyId!, activityStatus: activityStatus, delegate: self)
        
        DBHandler.updateActivityParticipationStatus(activity: activity)
        
        if status == .completed{
            self.updateCompletionAdherence()
        }
        
    }
    
    
    
    func updateCompletionAdherence(){
        
        
        
        //let deletedActivities = Study.currentStudy?.activities.filter({$0.totalRuns != ($0.incompletedRuns + $0.compeltedRuns)})
        var totalRuns = 0
        var totalCompletedRuns = 0
        var totalIncompletedRuns = 0
        let activities = Study.currentStudy?.activities //.filter({$0.state == "active"})
        //for detail in tableViewSections {
           // let activities = detail["activities"] as! Array<Activity>
            for activity in activities! {
                totalRuns += activity.totalRuns
                totalIncompletedRuns += activity.incompletedRuns
                totalCompletedRuns += activity.compeltedRuns
                
                // print("id \(activity.name), totalStudyRuns \(totalRuns), totalIncompletedRuns \(totalIncompletedRuns), totalCompletedRuns \(totalCompletedRuns)")
                //print("id \(activity.name!), totalIncompletedRuns \(activity.incompletedRuns)")
            }
        //}
        
        
        Study.currentStudy?.totalCompleteRuns = totalCompletedRuns
        Study.currentStudy?.totalIncompleteRuns = totalIncompletedRuns
        
        let completion = ceil( Double(self.divide(lhs: (totalCompletedRuns + totalIncompletedRuns)*100, rhs: totalRuns)) )
        let adherence = ceil (Double(self.divide(lhs: totalCompletedRuns*100, rhs: (totalCompletedRuns + totalIncompletedRuns))))
        
        let studyid = (Study.currentStudy?.studyId)!
       
        let status = User.currentUser.udpateCompletionAndAdherence(studyId:studyid, completion: Int(completion), adherence: Int(adherence))
        UserServices().udpateCompletionAdherence(studyStauts: status, delegate: self)
        DBHandler.updateStudyParticipationStatus(study: Study.currentStudy!)
       
        
        let halfCompletionKey = "50pcShown"  + (Study.currentStudy?.studyId)!
        let fullCompletionKey = "100pcShown"  + (Study.currentStudy?.studyId)!
        let missedKey = "totalMissed"  + (Study.currentStudy?.studyId)!
        
        let ud = UserDefaults.standard
        if completion > 50 && completion < 100 {
            
            if !(ud.bool(forKey: halfCompletionKey)){
                let message =  "The study " + (Study.currentStudy?.name!)! + " is now 50 percent complete. We look forward to your continued participation as the study progresses."
                UIUtilities.showAlertWithMessage(alertMessage: message)
                ud.set(true, forKey: halfCompletionKey)

            }
            
        }
        
        if completion == 100 {
            
            if !(ud.bool(forKey: fullCompletionKey)){
                let message =  "The study " + (Study.currentStudy?.name!)! + " is 100 percent complete. Thank you for your participation."
                UIUtilities.showAlertWithMessage(alertMessage: message)
                ud.set(true, forKey: fullCompletionKey)
                
            }
        }
        
        
        if ud.object(forKey: missedKey) == nil {
            ud.set(totalIncompletedRuns, forKey: missedKey)
        }
        else {
            let previousMissed = ud.object(forKey: missedKey) as! Int
             ud.set(totalIncompletedRuns, forKey: missedKey)
            if previousMissed < totalIncompletedRuns {
                //sho alert
               
                let message = "We noticed you missed an activity in " + (Study.currentStudy?.name!)! + " today. That’s ok! We know you’re busy, but we encourage you to complete study activities before they expire."
                UIUtilities.showAlertWithMessage(alertMessage: message)
            }
        }
        
        ud.synchronize()
        
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
    
    func updateRunStatusForRunId(runId:Int){
        
        let activity = Study.currentActivity!
        activity.compeltedRuns += 1
        DBHandler.updateRunToComplete(runId: runId, activityId: activity.actvityId!, studyId: activity.studyId!)
        
        //update run count information
        let incompleteRuns = activity.currentRunId - activity.compeltedRuns
        activity.incompletedRuns = (incompleteRuns < 0) ? 0 :incompleteRuns
        if activity.currentRun == nil {
            //userStatus.status = UserActivityStatus.ActivityStatus.abandoned
            
        }
        else {
            
            if activity.userParticipationStatus.status != UserActivityStatus.ActivityStatus.completed {
                
                var incompleteRuns = activity.currentRunId - activity.compeltedRuns
                incompleteRuns -= 1
                activity.incompletedRuns = (incompleteRuns < 0) ? 0 :incompleteRuns
            }
            
        }
        
        let activityStatus = User.currentUser.updateActivityStatus(studyId: activity.studyId!, activityId: activity.actvityId!,runId: String(runId), status:.completed)
        activityStatus.compeltedRuns = activity.compeltedRuns
        activityStatus.incompletedRuns = activity.incompletedRuns
        activityStatus.totalRuns = activity.totalRuns
        activityStatus.activityVersion = activity.version
        
        UserServices().updateUserActivityParticipatedStatus(studyId:activity.studyId!, activityStatus: activityStatus, delegate: self)
        
        DBHandler.updateActivityParticipationStatus(activity: activity)
        
       
        self.updateCompletionAdherence()
        
        self.tableView?.reloadData()

    }
    
    
     func handleStudyUpdatesResponse() {
        
        Study.currentStudy?.newVersion = StudyUpdates.studyVersion
        DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
        
        if StudyUpdates.studyConsentUpdated {
            presentUpdatedConsent()
        }
        else if StudyUpdates.studyInfoUpdated{
            WCPServices().getStudyInformation(studyId: (Study.currentStudy?.studyId)!, delegate: self)
        }
        else {
            self.checkForActivitiesUpdates()
        }
        
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
    func sendRequestToGetResourcesInfo(){
        WCPServices().getResourcesForStudy(studyId:(Study.currentStudy?.studyId)!, delegate: self)
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
                        Logger.sharedInstance.info("Activity Fetching from db")
                        //check in database
                        DBHandler.loadActivityMetaData(activity: activities[indexPath.row], completionHandler: { (found) in
                            if found {
                                self.createActivity()
                            }
                            else {
                                
                                WCPServices().getStudyActivityMetadata(studyId:(Study.currentStudy?.studyId)! , activityId: (Study.currentActivity?.actvityId)!, activityVersion: (Study.currentActivity?.version)!, delegate: self)
                            }
                        })
                        
                      
                        
                        self.updateActivityStatusToInProgress()
                        
                        self.selectedIndexPath = indexPath
                    }
                    else {
                        debugPrint("run is completed")
                        //UIUtilities.showAlertWithMessage(alertMessage: NSLocalizedString("You missed the previous run of this activity. Please wait till the next run becomes available. Run timings are given on the Activities list screen.", comment: ""))
                    }
                }
                
            }
            else if activity.userParticipationStatus?.status == .abandoned {
                debugPrint("run not available")
                 UIUtilities.showAlertWithMessage(alertMessage: NSLocalizedString("You missed the previous run of this activity. Please wait till the next run becomes available. Run timings are given on the Activities list screen.", comment: ""))
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
        //frame.size.height += 114
        
        let view = ActivitySchedules.instanceFromNib(frame: frame, activity: activity)
        self.tabBarController?.view.addSubview(view)
        //self.view.bringSubview(toFront: view)
        //UIApplication.shared.keyWindow?.addSubview(view)
    }
}

//MARK:- ActivityFilterDelegate
extension ActivitiesViewController:ActivityFilterViewDelegate{
    func setSelectedFilter(selectedIndex: ActivityFilterType) {
        
        // current filter is not same as existing filter
        if self.selectedFilter != selectedIndex{
            
           // currently filter type is all so no need to fetch all activities
            if self.selectedFilter == .all{
                
                let filterType:ActivityType! =  (selectedIndex == .surveys ? .Questionnaire : .activeTask)
                self.updateSectionArray(activityType: filterType)
                
            }
            else{// existing filterType is either Task or Surveys
                
                //load all the sections from scratch
                self.tableViewSections = []
                self.tableViewSections = allActivityList
                
                // applying the new filter Type
                if selectedIndex == .surveys || selectedIndex == .tasks{
                    let filterType:ActivityType! =  (selectedIndex == .surveys ? .Questionnaire : .activeTask)
                    self.updateSectionArray(activityType: filterType)
                }
            }
            self.selectedFilter = selectedIndex
            self.tableView?.reloadData()
        }
        else{
            //current and newly selected filter types are same
        }
    }
    
    func updateSectionArray(activityType:ActivityType)  {
        
        var updatedSectionArray:Array<Dictionary<String,Any>>! = []
        for section in tableViewSections{
            let activities = section[kActivities] as! Array<Activity>
            var sectionDict:Dictionary<String,Any>! = section
            sectionDict[kActivities] = activities.filter({$0.type == activityType
            })
            
            updatedSectionArray.append(sectionDict)
        }
        tableViewSections = []
        tableViewSections = updatedSectionArray
    }
    
    
}


//MARK:- Webservice Delegates
extension ActivitiesViewController:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info(" START requestname : \(requestName)")
        
        if (requestName as String == RegistrationMethods.updateStudyState.method.methodName) ||  (requestName as String == RegistrationMethods.updateActivityState.method.methodName) ||
            (requestName as String == WCPMethods.studyDashboard.method.methodName) || (requestName as String == WCPMethods.resources.method.methodName){
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
            
            //--Calling Dashboard
            self.sendRequestToGetDashboardInfo()
            //--
            self.loadActivitiesFromDatabase()
            
            if self.refreshControl != nil && (self.refreshControl?.isRefreshing)!{
                self.refreshControl?.endRefreshing()
            }
            
            
            StudyUpdates.studyActivitiesUpdated = false
            DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
            
        }
        else if requestName as String == WCPMethods.activity.method.methodName {
            self.removeProgressIndicator()
            self.createActivity()
        }
        else if requestName as String == WCPMethods.studyDashboard.method.methodName {
           self.sendRequestToGetResourcesInfo()
        }
        else if requestName as String == WCPMethods.resources.method.methodName {
              self.removeProgressIndicator()
        }
        else if requestName as String == ResponseMethods.processResponse.method.methodName{
            self.removeProgressIndicator()
            //self.updateRunStatusToComplete()
            self.checkForActivitiesUpdates()
        }
        else if requestName as String == WCPMethods.studyUpdates.method.methodName {
            
            Logger.sharedInstance.info("Handling response for study updates...")
            if Study.currentStudy?.version == StudyUpdates.studyVersion{
                
                self.loadActivitiesFromDatabase()
                self.removeProgressIndicator()
                if self.refreshControl != nil && (self.refreshControl?.isRefreshing)!{
                    self.refreshControl?.endRefreshing()
                }
            }
            else {
                self.handleStudyUpdatesResponse()
            }
            
        }
        else if requestName as String == WCPMethods.studyInfo.method.methodName {
            
            StudyUpdates.studyInfoUpdated = false
            DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
            
            self.checkForActivitiesUpdates()
        }
    }
    
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        if self.refreshControl != nil && (self.refreshControl?.isRefreshing)!{
            self.refreshControl?.endRefreshing()
        }
        
        if error.code == 403 { //unauthorized
            UIUtilities.showAlertMessageWithActionHandler(kErrorTitle, message: error.localizedDescription, buttonTitle: kTitleOk, viewControllerUsed: self, action: {
                self.fdaSlideMenuController()?.navigateToHomeAfterUnauthorizedAccess()
            })
        }
        else
        {
            
            
            if requestName as String == RegistrationMethods.activityState.method.methodName{
                //self.sendRequesToGetActivityList()
                if (error.code != NoNetworkErrorCode) {
                    self.loadActivitiesFromDatabase()
                }
                else {
                    
                    self.tableView?.isHidden = true
                    self.labelNoNetworkAvailable?.isHidden = false
                    
                     UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kErrorTitle, comment: "") as NSString, message: error.localizedDescription as NSString)
                }
            }
            else if requestName as String == ResponseMethods.processResponse.method.methodName {
                
                if (error.code == NoNetworkErrorCode) {
                    //Users are notified when their responses don’t get submitted due to network issues and are notified that the responses will be automatically submitted once the app has network available again.
                    //                UIUtilities.showAlertWithMessage(alertMessage: "Your responses don’t get submitted due to network issue, but we have saved it locally, we will automatically submit once the app has network available again.")
                    //
                    //                if error.code == CouldNotConnectToServerCode {
                    //                    UIUtilities.showAlertWithMessage(alertMessage: "Your responses don’t get submitted due to connectiviy with our server, but we have saved it locally, we will automatically submit once the app has network available again.")
                    //                }
                    //let data = ActivityBuilder.currentActivityBuilder.actvityResult?.getResultDictionary()
                    //DBHandler.saveResponseDataFor(activity: Study.currentActivity!, toBeSynced: true, data: data!)
                    
                }
                
            }
            else if requestName as String == RegistrationMethods.updateStudyState.method.methodName{
                
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
        
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        
        var taskResult:Any?
        
        switch reason {
            
        case ORKTaskViewControllerFinishReason.completed:
            print("completed")
            taskResult = taskViewController.result
            let ud = UserDefaults.standard
            if ud.bool(forKey: "FKC") {
                
                let runid = ud.object(forKey: "FetalKickCounterRunid") as! Int
                
                if Study.currentActivity?.currentRun.runId != runid {
                    //runid is changed
                    self.updateRunStatusForRunId(runId: runid)
                }
                else {
                    self.updateRunStatusToComplete()
                }
            }
            else {
                
                self.updateRunStatusToComplete()
            }
            
        case ORKTaskViewControllerFinishReason.failed:
            print("failed")
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.discarded:
            print("discarded")
            
             let study = Study.currentStudy
             let activity = Study.currentActivity
             activity?.currentRun.restortionData = nil
             DBHandler.updateActivityRestortionDataFor(activity:activity!, studyId: (study?.studyId)!, restortionData:nil)
            
            
            let ud = UserDefaults.standard
            ud.removeObject(forKey: "FKC")
            ud.removeObject(forKey: "FetalKickActivityId")
            ud.removeObject(forKey: "FetalKickCounterValue")
            ud.removeObject(forKey: "FetalKickStartTimeStamp")
            ud.removeObject(forKey: "FetalKickStudyId")
            ud.removeObject(forKey: "FetalKickCounterRunid")
            ud.synchronize()
            
            self.checkForActivitiesUpdates()
            
        case ORKTaskViewControllerFinishReason.saved:
            print("saved")
            taskResult = taskViewController.restorationData
            
            if taskViewController.task?.identifier == "ConsentTask"{
                
            }
            else{
                ActivityBuilder.currentActivityBuilder.activity?.restortionData = taskViewController.restorationData
            }
            
            self.checkForActivitiesUpdates()
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
                            
                            let activeTaskResultType =  ActiveStepType(rawValue:ActivityBuilder.currentActivityBuilder.activity?.activitySteps?.first?.resultType as! String)
                            
                            switch activeTaskResultType! {
                                
                            case .fetalKickCounter:
                                
                                let fetalKickResult:FetalKickCounterTaskResult? = orkStepResult?.results?.first as! FetalKickCounterTaskResult
                                
                                let study = Study.currentStudy
                                let activity = Study.currentActivity
                                
                                
                                if fetalKickResult != nil{
                                    
                                    let value = Float((fetalKickResult?.duration)!)/60
                                    let kickcount = Float((fetalKickResult?.totalKickCount)!)
                                    let dict = ActivityBuilder.currentActivityBuilder.activity?.steps?.first!
                                    let key = dict?[kActivityStepKey] as! String
                                    
                                    
                                    DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!, key: key, data:value,fkDuration:Int(kickcount), date:Date())
                                    
                                    
                                    
                                    let ud = UserDefaults.standard
                                    ud.removeObject(forKey: "FKC")
                                    ud.removeObject(forKey: "FetalKickActivityId")
                                    ud.removeObject(forKey: "FetalKickCounterValue")
                                    ud.removeObject(forKey: "FetalKickStartTimeStamp")
                                    ud.removeObject(forKey: "FetalKickStudyId")
                                    ud.removeObject(forKey: "FetalKickCounterRunid")
                                    ud.synchronize()
                                    
                                }
                                case .spatialSpanMemoryStep:
                                    let activity = Study.currentActivity
                                    
//                                    //get score
//                                    let scores = Float(0.0)
//                                    let keyScore = "score"
//                                    DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!, key: keyScore , data:Float(scores),fkDuration:Int(0), date:Date())
//
//                                    //get numberOfFailures
//                                    let numberOfFailures = Float(0.0)
//                                    let keyNumberOfFailures = "numberOfFailures"
//                                    DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!, key: keyNumberOfFailures , data:Float(numberOfFailures),fkDuration:Int(0), date:Date())
//
//
//                                    //get number of Games
//                                    let numberOfGames = Float(0.0)
//                                    let keyNumberOfGames = "numberOfGames"
//                                    DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!, key: keyNumberOfGames , data:Float(numberOfGames),fkDuration:Int(0), date:Date())
                                    
                                break
                                case .towerOfHanoi:
                                    //let study = Study.currentStudy
                                    let activity = Study.currentActivity
                                    let tohResult:ORKTowerOfHanoiResult? = orkStepResult?.results?.first as? ORKTowerOfHanoiResult
                                    let key =  ActivityBuilder.currentActivityBuilder.activity?.steps?.first![kActivityStepKey] as? String
                                    
                                    let numberOfMoves = tohResult?.moves?.count
                                    
                                    DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!, key: key! , data:Float(numberOfMoves!),fkDuration:Int(0), date:Date())
                                    
                                break
                                
                                    
                                    default:break
                                    
                                
                                
                            }
                            
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
                
                // if activity?.type != .activeTask{
                
                DBHandler.updateActivityRestortionDataFor(activity:activity!, studyId: (study?.studyId)!, restortionData: taskViewController.restorationData!)
                activity?.currentRun.restortionData = taskViewController.restorationData!
                //  }
                
                
                
                
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
                        DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!, key: (activityStepResult?.key)!, data:value,fkDuration: 0,date:Date())
                    }
                    
                }
                
                
                let ud = UserDefaults.standard
                
                
                let activityId:String? = ud.value(forKey:"FetalKickActivityId" ) as! String?
                
                //ud.set(Study.currentActivity?.actvityId, forKey: "FetalKickActivityId")
                
                if activity?.type == .activeTask
                    && ud.bool(forKey: "FKC")
                    && activityId != nil
                    && activityId == Study.currentActivity?.actvityId
                    && (stepViewController is ORKInstructionStepViewController)  {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        
                        stepViewController.goForward()
                    }
                }
                
                
                //disable back button
                if stepViewController is FetalKickCounterStepViewController{
                   stepViewController.backButtonItem = nil
                }
                
                
                
                
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

extension ActivitiesViewController:UITabBarControllerDelegate{
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 {
            //do your stuff
            self.checkForActivitiesUpdates()
        }
    }
    
    
}

//MARK:- ActivitySchedules Class
class ActivitySchedules:UIView,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var tableview:UITableView?
    @IBOutlet var buttonCancel:UIButton!
    @IBOutlet var heightLayoutConstraint:NSLayoutConstraint!
    
    var activity:Activity!
    
        
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
        formatter.dateFormat = "hh:mma, MMM dd YYYY"
        //formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
}


