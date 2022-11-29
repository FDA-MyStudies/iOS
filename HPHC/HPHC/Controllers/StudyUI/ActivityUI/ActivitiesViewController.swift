/*
 License Agreement for FDA My Studies
 Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
 hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
 limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 Software, and to permit persons to whom the Software is furnished to do so, subject to the following
 conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.
 Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
 Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
 THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
 OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import UIKit
import ResearchKit
import IQKeyboardManagerSwift

let kActivities = "activities"

let kActivityUnwindToStudyListIdentifier = "unwindeToStudyListIdentier"
let kActivityAbondonedAlertMessage1 = "You missed the previous run of this activity. Please wait till the next run becomes available."
let kActivityAbondonedAlertMessage2 = " Run timings are given on the Activities list screen."
let kActivityAbondonedAlertMessage = NSLocalizedStrings(
        "\(kActivityAbondonedAlertMessage1)\(kActivityAbondonedAlertMessage2)", comment: ""
    )

enum ActivityAvailabilityStatus:Int{
    case current
    case upcoming
    case past
}

class ActivitiesViewController : UIViewController{
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var labelNoNetworkAvailable: UILabel?
    
    var tableViewSections: Array<Dictionary<String, Any>>! = []
    var lastFetelKickIdentifer: String = ""  // TEMP
    var selectedIndexPath: IndexPath?
    var isAnchorDateSet: Bool = false
    var taskControllerPresented = false
    var refreshControl: UIRefreshControl? // To fetch the updated Activities
    
    var allActivityList: Array<Dictionary<String, Any>>! = []
    var selectedFilter: ActivityFilterType? // Holds the applied FilterTypes
    
    private var managedResult: [String: Any] = [:]
    
    let labkeyResponseFetch = ResponseDataFetch()
  
  var isActivityDismissed = false
  
  var valPipingDetailsMain: [String: [[String: String]]] = [:]
  
  var valPipingValuesMain: JSONDictionary = [:]
  
  var createActiCalled = ""
  
  var timer: Timer?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: - Viewcontroller Lifecycle
    fileprivate func presentUpdatedConsent() {
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        appDelegate.checkConsentStatus(controller: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedFilter = ActivityFilterType.all
        
        self.tableView?.estimatedRowHeight = 126
        self.tableView?.rowHeight = UITableView.automaticDimension
        
        self.tabBarController?.delegate = self
        
        if let activititesTitle = self.tabBarController?.tabBar.items {
            activititesTitle[0].title = NSLocalizedStrings("Activities", comment: "")
        }
        
        if let dashboardTitle = self.tabBarController?.tabBar.items {
            dashboardTitle[1].title = NSLocalizedStrings("Dashboard", comment: "")
        }
        if let resourcesTitle = self.tabBarController?.tabBar.items {
            resourcesTitle[2].title = NSLocalizedStrings("Resources", comment: "")
        }
        
        self.navigationItem.title = NSLocalizedStrings("STUDY ACTIVITIES", comment: "")
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: Utilities.getUIColorFromHex(0x007CBA)]
        
        self.tableView?.sectionHeaderHeight = 30
        
        self.navigationController?.navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
        
        if (Study.currentStudy?.studyId) != nil {
            if StudyUpdates.studyConsentUpdated {
                NotificationHandler.instance.activityId = ""
                presentUpdatedConsent()
            }
        }
        
        // create refresh control for pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: kPullToRefresh)
        refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView?.addSubview(refreshControl!)
        self.addProgressIndicator()
        
        if #available(iOS 15, *) {
            UITableView.appearance().sectionHeaderTopPadding = CGFloat(0)
        }
      UserDefaults.standard.set("", forKey: "createActiCalled")
      UserDefaults.standard.setValue("", forKey: "jumpActivity")
      UserDefaults.standard.setValue("", forKey: "jumpInternalLoad")
      UserDefaults.standard.synchronize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        setNavigationBarColor()
        
        if Utilities.isStandaloneApp() {
            self.setNavigationBarItem()
        } else {
            self.addHomeButton()
        }
        
        if !taskControllerPresented {
            taskControllerPresented = false
            self.checkForActivitiesUpdates()
        }
        
        if tableViewSections.count == 0 {
            self.tableView?.isHidden = true
            self.labelNoNetworkAvailable?.isHidden = false
            
        } else {
            self.tableView?.isHidden = false
            self.labelNoNetworkAvailable?.isHidden = true
        }
      
      if let activityId = UserDefaults.standard.string(forKey: "activityId") {
          let sectionCount = tableViewSections.count
          for section in 0..<sectionCount {
              let rowDetail = tableViewSections[section]
              let activities = (rowDetail["activities"] as? Array<Activity>)!
              if activities.count > 0 {
                  if let row = activities.firstIndex(where: {$0.actvityId == activityId}) {
                      let indexPath = IndexPath(row: row, section: section)
                      self.selectTableCell(indexPath: indexPath)
//                        UserDefaults.standard.setValue("TextScale", forKey: "identifier")
                      break
                  }
              }
          }
          UserDefaults.standard.setValue(nil, forKey: "activityId")
      }
        
    }
  
    // MARK: Helper Methods
    
    func getLabkeyResponse() {
        
        let ud = UserDefaults.standard
        let key = "LabKeyResponse" + (Study.currentStudy?.studyId ?? "")
        if !(ud.bool(forKey: key)){
            labkeyResponseFetch.checkUpdates()
        }
    }
    
    func checkForActivitiesUpdates(){
        
        if StudyUpdates.studyActivitiesUpdated {
            
            self.sendRequestToGetActivityStates()
            
            // Update status to false so notification can be registered again.
            Study.currentStudy?.activitiesLocalNotificationUpdated = false
            DBHandler.updateLocalNotificaitonUpdated(studyId: Study.currentStudy?.studyId ?? "", status: false)
            
        } else {
            // self.loadActivitiesFromDatabase()
            self.fetchActivityAnchorDateResponseFromLabkey()
        }
    }
    
    /**
     checkIfFetelKickCountRunning method verifies whether if FetalKick Task is Still running and calculate the time difference.
     */
    func checkIfFetelKickCountRunning(){
        
        let ud = UserDefaults.standard
        
        if ud.bool(forKey: "FKC") && ud.object(forKey: kFetalKickStartTimeStamp) != nil {
            
            // let studyId = (ud.object(forKey: kFetalkickStudyId)  as? String)!
            let activityId = (ud.object(forKey: kFetalKickActivityId)  as? String)!
            let activity  = Study.currentStudy?.activities?.filter({$0.actvityId == activityId}).last
            
            Study.updateCurrentActivity(activity: activity!)
            // check in database
            DBHandler.loadActivityMetaData(activity: activity!, completionHandler: { (found) in
                
                if found {
                    self.createActivity()
                }
                
            })
            
        } else {
            // check if user navigated from notification
            
            if NotificationHandler.instance.activityId.count > 0 {
                
                let activityId = NotificationHandler.instance.activityId
                let rowDetail = tableViewSections[0]
                let activities = (rowDetail["activities"] as? Array<Activity>)!
                
                let index = activities.firstIndex(where: {$0.actvityId == activityId})
                
                if let index = index {
                    let ip = IndexPath.init(row: index, section: 0)
                    self.selectedIndexPath = ip
                    self.tableView?.selectRow(at: ip, animated: true, scrollPosition: .middle)
                    self.tableView?.delegate?.tableView!(self.tableView!, didSelectRowAt: ip)
                } else {
                    if let studyId = NotificationHandler.instance.studyId, let activityIdRemove = NotificationHandler.instance.activityId  {
                        LocalNotification.removeLocalNotificationfor(studyId: studyId, activityid: activityIdRemove)
                        DBHandler.deleteDBLocalNotification(activityId: activityIdRemove, studyId: studyId)
                    }
                    
                }
                NotificationHandler.instance.activityId = ""
                
            }
        }
    }
    
    // MARK: - Button Actions
    
    /**
     Home Button Clicked
     @param sender    Accepts any kind of object
     */
    @IBAction func homeButtonAction(_ sender: AnyObject){
        self.performSegue(withIdentifier: kActivityUnwindToStudyListIdentifier, sender: self)
    }
    
    @IBAction func filterButtonAction(_ sender: AnyObject){
        let frame = self.view.frame
        
        if self.selectedFilter == nil {
            self.selectedFilter = ActivityFilterType.all
        }
        // create and load FilterView
        let view = ActivityFilterView.instanceFromNib(frame: frame, selectedIndex: self.selectedFilter!)
        view.delegate = self
        self.tabBarController?.view.addSubview(view)
    }
    
    // MARK: Helper Methods
    func checkForDashBoardInfo(){
        
        DBHandler.loadStatisticsForStudy(studyId: Study.currentStudy?.studyId ?? "") { (statiticsList) in
            
            if statiticsList.count != 0 {
                // Do Nothing
            } else {
                self.sendRequestToGetDashboardInfo()
            }
        }
    }
    
    @objc func refresh(sender:AnyObject) {
        WCPServices().getStudyUpdates(study: Study.currentStudy!, delegate: self)
    }
    
    /// Participant Property values received from Response Server saved in Database.
    /// Saved value will be used to compare from the values Saved on UR Server.
    /// In case DB Saved values is most recent then liftime of that activity has to be calculated again.
    /// Newly calculated then saved UR Server.
    func findActivitiesToUpdateSchedule() {
        
        let activitiesWithParticipantProperty =  Study.currentStudy?.activities.filter(
        {$0.anchorDate?.sourceType == AnchorDateSourceType.participantProperty.rawValue})
        
        for activity in activitiesWithParticipantProperty! {
            let extPPValue = activity.anchorDate?.ppMetaData?.externalPropertyValue
            let participatedActivityStatus = User.currentUser.participatedActivites.filter({$0.activityId == activity.actvityId}).last
            
            if extPPValue != participatedActivityStatus?.anchorDateVersion {
                // Anchor date is updated, should calculated life time again
            }
            
        }
        
    }
    
    // MARK: -
    
    func fetchActivityAnchorDateResponseFromLabkey() {
        
        guard let currentStudy = Study.currentStudy
            else {return}
        ActivitiesViewController.updateActivitiesAnchorDateLifeTime(for: currentStudy) { [weak self] in
            self?.loadActivitiesFromDatabase()
            self?.refreshControl?.endRefreshing()
            DispatchQueue.main.async { [weak self] in
                self?.syncParticipantPropertyValuesOnUserRegistration(for: currentStudy)
            }
        }
    }
    
    final class func updateActivitiesAnchorDateLifeTime(for study: Study, completion:(() -> Void)? = nil) {
        
        let groupQuery = DispatchGroup()
        
        groupQuery.enter()
        AnchorDateHandler(study: study).queryAnchorDateForActivityResponseActivities { (status) in
            Logger.sharedInstance.info("AD for AR Resource fetch: ", status)
            groupQuery.leave()
        }
        
        groupQuery.enter()
        AnchorDateHandler(study: study).queryParticipantPropertiesForActivities { (status) in
            Logger.sharedInstance.info("AD for PP Resource fetch: ", status)
            groupQuery.leave()
        }
        
        groupQuery.notify(queue: .main) {
            completion?()
        }
    }
    func syncParticipantPropertyValuesOnUserRegistration(for study: Study) {
        
        // Get activities from database with ParticipantProperty as anchor date.
        let activities = DBHandler.participantPropertyActivities(study.studyId)
        var activitiesToSync: [JSONDictionary] = []
        for activity in activities {
            
            var ppValue = ["activityId":activity.actvityId ?? "",
                           "activityStartDate": activity.startDate?.description ?? "",
                           "activityEndDate": activity.endDate?.description ?? "",
                           "anchorDateVersion": activity.externalPropertyValue ?? "",
                           "anchorDatecreatedDate": activity.dateOfEntryValue ?? ""] as JSONDictionary
            
            // Check activity frequency.
            var activitiesRuns = [[String:String]]()
            if activity.frequencyType == Frequency.Scheduled.rawValue {
                let runs = activity.activityRuns
                for run in runs {
                    let runDetail = ["runStartDate":run.startDate.description,
                                     "runEndDate":run.endDate.description]
                    activitiesRuns.append(runDetail)
                }
                
                ppValue["customScheduleRuns"] = activitiesRuns
            }
            
            activitiesToSync.append(ppValue)
            
        }
        
        if activitiesToSync.count > 0 {
            UserServices().updateActivityWithParticipantPropertyDetail(studyId: Study.currentStudy!.studyId,
                                                                       activities: activitiesToSync ,
                                                                       delegate: self)
        }
    }
    
    /**
     Used to load the Actif=vities data from database
     */
    func loadActivitiesFromDatabase(){
        guard let studyID = Study.currentStudy?.studyId else { return }
        if DBHandler.isActivitiesEmpty(studyID) {
            self.sendRequestToGetActivityStates()
        } else {
            
            DBHandler.loadActivityListFromDatabase(studyId: studyID) { [weak self] (activities) in
               
                if activities.count > 0 {
                    Study.currentStudy?.activities = activities
                    self?.handleActivityListResponse()
                } else {
                    self?.labelNoNetworkAvailable?.text = "Sorry, no activities available right now."
                }
                
                self?.removeProgressIndicator()
            }
        }
    }
    
    /**
     Used to create an activity using ORKTaskViewController
     */
    func createActivity(){
      addProgressIndicator3()
        // Disable Custom KeyPad with toolbars
        //        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        if Utilities.isValidObject(someObject: Study.currentActivity?.steps as AnyObject?){
            
            // Create ActivityBuilder instance
            ActivityBuilder.currentActivityBuilder = ActivityBuilder()
            ActivityBuilder.currentActivityBuilder.initWithActivity(activity: Study.currentActivity! )
        }
        
        let task: ORKTask?
        let taskViewController: ORKTaskViewController?
      
        task = ActivityBuilder.currentActivityBuilder.createTask()
        
        if task != nil {
          
          let activityCu = Study.currentActivity
          let activityStepArray = activityCu?.activitySteps
        print("activityStepArray---\(activityStepArray)")
          
          if let val = activityStepArray {
          getPipingArray(activityStepArray: val)
          }
            
            // check if restorationData is available
            if Study.currentActivity?.currentRun.restortionData != nil {
                let restoredData = Study.currentActivity?.currentRun.restortionData
                
                // let result: ORKResult?
                taskViewController = ORKTaskViewController(task: task, restorationData: restoredData, delegate: self)
            } else {
                
                taskViewController = ORKTaskViewController(task: task, taskRun: nil)
                taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            }
            
            taskViewController?.showsProgressInNavigationBar = true
            
            let kActivity = NSLocalizedStrings("Activity", comment: "")
            taskViewController?.title = kActivity
            
            // Customize appearance of TaskViewController
            UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self]).tintColor = kUIColorForSubmitButtonBackground
            
            taskViewController?.delegate = self
            UIApplication.shared.statusBarStyle = .default
            taskControllerPresented = true
            taskViewController?.navigationBar.prefersLargeTitles = false
            
            taskViewController?.modalPresentationStyle = .fullScreen
          
          let ud1 = UserDefaults.standard
                      let valJum = ud1.object(forKey: "jumpInternalLoad") as? String ?? ""

          if valJum != "jumpInternalLoad" {
            print("1jumpInternalLoad---")
            self.removeProgressIndicator3()
            present(taskViewController!, animated: true, completion: nil)
          } else {
            print("2jumpInternalLoad---")
            
//            startTimer()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
              self.removeProgressIndicator3()
              self.present(taskViewController!, animated: true, completion: nil)
            }
            
            
          }
        } else {
          self.removeProgressIndicator3()
            // Task creation failed
            UIUtilities.showAlertMessage(kTitleMessage,
                                         errorMessage: NSLocalizedStrings("Invalid Data!", comment: ""),
                                         errorAlertActionTitle: kTitleOKCapital,
                                         viewControllerUsed: self)
        }
        
    }
  
  func getPipingArray(activityStepArray: [ActivityStep]) {
    valPipingDetailsMain = [:]
    valPipingValuesMain = [:]
    createActiCalled = "true"
    
    UserDefaults.standard.set("true", forKey: "createActiCalled")
    UserDefaults.standard.synchronize()
    
    var valPipingDetails: [String: [[String: String]]] = [:]
    for activityStepArr in activityStepArray {
    let valpipingactivityid = activityStepArr.pipingactivityid ?? ""
      if valpipingactivityid != "" {
        var valPipStructure: [String: String] = [:]
        valPipStructure["pipingactivityid"] = activityStepArr.pipingactivityid
        valPipStructure["pipingSnippet"] = activityStepArr.pipingSnippet
        valPipStructure["pipingactivityVersion"] = activityStepArr.pipingactivityVersion
        valPipStructure["pipingsourceQuestionKey"] = activityStepArr.pipingsourceQuestionKey
//        valPipStructure["isPiping"] = activityStepArr.isPiping
        var valActiInmain = valPipingDetails[valpipingactivityid]
        if valActiInmain?.count ?? 0 > 0 {
         var valtempPipActiId = valActiInmain
          valtempPipActiId?.append(valPipStructure)
          valPipingDetails[valpipingactivityid] = valtempPipActiId
        } else {
          valPipingDetails[valpipingactivityid] = [valPipStructure]
        }
      }
    }
    valPipingDetailsMain = valPipingDetails
    print("valPipingDetails---\(valPipingDetails)")
    getValueForPiping()
    
//    LabKeyServices().withdrawFromStudy(studyId: (studyToWithdrawn?.studyId)!,
//                                                   participantId: (studyToWithdrawn?.participantId)!,
//                                                   deleteResponses: (studyToWithdrawn?.shouldDelete)!,
//                                                   delegate: self)
    
    
//    let participantId = Study.currentStudy?.userParticipateState.participantId ?? ""
//    guard let studyID = Study.currentStudy?.studyId else { return }
//    LabKeyServices().selectRows(studyId: "LIMITOPEN001", activityId: "imageque", stepId: "ContinuousScal", participantId: "dcb2f1938fd6b64c5e039ff476629a49", delegate: self)
    
  }
  
  func getValueForPiping() {
    print("1valvalPipingDetailsMain---\(valPipingDetailsMain)")
    let valvalPipingDetailsMain = valPipingDetailsMain
    
    if valvalPipingDetailsMain.count > 0 {
      let valKeys = valvalPipingDetailsMain.keys
      if valKeys.count > 0 {
        for valKey in valKeys {
          if let valValues1 = valvalPipingDetailsMain[valKey] {
            if valValues1.count > 0 {
              let valValues1a = valValues1[0]
              if let valValues1aActivityId = valValues1a["pipingactivityid"] {
                
                UserDefaults.standard.setValue("jumpInternalLoad", forKey: "jumpInternalLoad")
                UserDefaults.standard.synchronize()

                
                
              if valValues1.count > 1 {
                print("1valValues1---")
                querypipingresponse(activityId: valValues1aActivityId, stepId: "")
                
                
                getActivityForPiping()
              } else {
                print("2valValues1---")
                querypipingresponse(activityId: valValues1aActivityId, stepId: valValues1a["pipingsourceQuestionKey"] ?? "")
                
                getActivityForPiping()
              }
            }
              }
              
            }
          
          }
        }
      }
      
//    let participantId = Study.currentStudy?.userParticipateState.participantId ?? ""
//    guard let studyID = Study.currentStudy?.studyId else { return }
//    LabKeyServices().selectRows(studyId: "LIMITOPEN001", activityId: "imageque", stepId: "ContinuousScal", participantId: "dcb2f1938fd6b64c5e039ff476629a49", delegate: self)

  }
  
  func querypipingresponse(activityId: String, stepId: String) {
//    let activityId = Study.currentActivity
    
    let participantId = Study.currentStudy?.userParticipateState.participantId ?? ""
//    guard let studyID = Study.currentStudy?.studyId else { return }
//    LabKeyServices().selectRows(studyId: "LIMITOPEN001", activityId: "imageque", stepId: "ContinuousScal", participantId: "dcb2f1938fd6b64c5e039ff476629a49", delegate: self)
    
    guard let studyID = Study.currentStudy?.studyId else { return }
    LabKeyServices().selectRows(studyId: Study.currentStudy?.studyId ?? "", activityId: "\(activityId)", stepId: "\(stepId)", participantId: "\(participantId)", delegate: self)
  }
  
  func getActivityForPiping() {
    
    let valvalPipingDetailsMain = valPipingDetailsMain
    
    if valvalPipingDetailsMain.count > 0 {
      let valKeys = valvalPipingDetailsMain.keys
      if valKeys.count > 0 {
        for valKey in valKeys {
          if let valValues1 = valvalPipingDetailsMain[valKey] {
            if valValues1.count > 0 {
              let valValues1a = valValues1[0]
              if let valValues1aActivityId = valValues1a["pipingactivityid"],  let valpipingactivityVersion = valValues1a["pipingactivityVersion"] {
                
                UserDefaults.standard.setValue("jumpInternalLoad", forKey: "jumpInternalLoad")
            UserDefaults.standard.synchronize()
                
                
              if valValues1.count > 1 {
                
                guard let studyID = Study.currentStudy?.studyId else { return }
                WCPServices().getStudyActivityVersionMetadata(studyId: studyID,
                                                                                           activityId: valValues1aActivityId,
                                                                                           activityVersion: valpipingactivityVersion,
                                                                                           delegate: self)
                
                
//                querypipingresponse(activityId: valValues1aActivityId, stepId: "")
                
              } else {
                guard let studyID = Study.currentStudy?.studyId else { return }
                WCPServices().getStudyActivityVersionMetadata(studyId: studyID,
                                                                                           activityId: valValues1aActivityId,
                                                                                           activityVersion: valpipingactivityVersion,
                                                                                           delegate: self)
                
              }
            }
              }
              
            }
          
          }
        }
      }
      
//    let participantId = Study.currentStudy?.userParticipateState.participantId ?? ""
//    guard let studyID = Study.currentStudy?.studyId else { return }
//    LabKeyServices().selectRows(studyId: "LIMITOPEN001", activityId: "imageque", stepId: "ContinuousScal", participantId: "dcb2f1938fd6b64c5e039ff476629a49", delegate: self)

  }
   
    /**
     Used to get Activity Availability Status
     @param activity    Accepts data from Activity class
     @return ActivityAvailabilityStatus
     */
    func getActivityAvailabilityStatus(activity: Activity) -> ActivityAvailabilityStatus {
        
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
                
            } else if startDateResult == .orderedDescending {
                return .upcoming
                
            } else if endDateResult == .orderedAscending {
                return .past
            }
        } else if activity.startDate != nil {
            
            let startDateResult = (activity.startDate?.compare(todayDate))! as ComparisonResult
            
            if startDateResult == .orderedAscending{
                return .current
                
            } else if startDateResult == .orderedDescending {
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
        guard let activities = Study.currentStudy?.activities.filter({$0.startDate != nil})
          else {return}
        var bufCurrentStudyArray: [Activity] = []
        
        var currentActivities: [Activity] = []
        var upcomingActivities: [Activity] = []
        var pastActivities: [Activity] = []
        
        var isInActiveActivitiesAreAvailable: Bool! = false
        for activity in activities {
            if activity.state == "active" || activity.state == nil {
              
                let status =  self.getActivityAvailabilityStatus(activity: activity)
                switch status {
                case .current:
                    currentActivities.append(activity)
                    bufCurrentStudyArray.append(activity)
                case .upcoming:
                    upcomingActivities.append(activity)
                    bufCurrentStudyArray.append(activity)
                case .past:
                    pastActivities.append(activity)
                    bufCurrentStudyArray.append(activity)
                }
            } else {
                isInActiveActivitiesAreAvailable = true
                DBHandler.deleteDBLocalNotification(activityId: activity.actvityId!, studyId: activity.studyId!)
            }
        }
        
        if isInActiveActivitiesAreAvailable {
            LocalNotification.refreshAllLocalNotification()
        }
        
        let currentOngoingActivities = currentActivities.filter({$0.frequencyType == .Ongoing}).sorted(by: { (a1, a2) -> Bool in
            if let date1 = a1.lastModified, let date2 = a2.lastModified {
                return date1.compare(date2) == .orderedDescending
            }
            return false
        })
        
        currentActivities = currentActivities.filter({$0.frequencyType != .Ongoing}).sorted(by: {$0.startDate?.compare($1.startDate!) ==
                                                                                                .orderedAscending})
        
        upcomingActivities.sort(by: {$0.startDate?.compare($1.startDate!) == .orderedAscending})
        pastActivities.sort(by: {$0.startDate?.compare($1.startDate!) == .orderedAscending})
        
        let currentCompletedAndIncompletedActivities = currentActivities.filter { (activity) -> Bool in
            let participationStatus = activity.userParticipationStatus.status
            return participationStatus == .completed ||
                participationStatus == .abandoned ||
                participationStatus == .expired
        }.sorted { (activity1, activity2) -> Bool in
            return activity1.userParticipationStatus.status.sortIndex <
                activity2.userParticipationStatus.status.sortIndex
        }
        
        let currentYetToStartAndInProgressActivities = currentActivities.filter { (activity) -> Bool in
            let participationStatus = activity.userParticipationStatus.status
            return participationStatus == .yetToJoin ||
                participationStatus == .inProgress
        }.sorted { (activity1, activity2) -> Bool in
            return activity1.userParticipationStatus.status.sortIndex <
                activity2.userParticipationStatus.status.sortIndex
        }
        
        let allTypeCurrentActivities = currentYetToStartAndInProgressActivities +
            currentOngoingActivities +
            currentCompletedAndIncompletedActivities
        
        let currentDetails = ["title": NSLocalizedStrings("CURRENT", comment: ""), "activities": allTypeCurrentActivities] as [String : Any]
        let upcomingDetails = ["title": NSLocalizedStrings("UPCOMING", comment: ""), "activities": upcomingActivities] as [String : Any]
        let pastDetails = ["title": NSLocalizedStrings("PAST", comment: ""), "activities": pastActivities] as [String : Any]
        
        allActivityList.append(currentDetails)
        allActivityList.append(upcomingDetails)
        allActivityList.append(pastDetails)
        
        tableViewSections = allActivityList
        
        if self.selectedFilter == .tasks || self.selectedFilter == .surveys {
            
            let filterType:ActivityType! =  (selectedFilter == .surveys ? .Questionnaire : .activeTask)
            self.updateSectionArray(activityType: filterType)
        }
        self.tableView?.reloadData()
        self.tableView?.isHidden = false
        self.labelNoNetworkAvailable?.isHidden = true
        self.updateCompletionAdherence()
        
        DispatchQueue.main.async {
           if User.currentUser.settings?.localNotifications ?? false {
                if !(Study.currentStudy?.activitiesLocalNotificationUpdated)! {
                    // Register LocalNotifications
                    LocalNotification.registerAllLocalNotificationFor(activities: Study.currentStudy?.activities ?? []) {
                        (_, notificationlist) in
                        Study.currentStudy?.activitiesLocalNotificationUpdated = true
                        DBHandler.saveRegisteredLocaNotification(notificationList: notificationlist)
                        DBHandler.updateLocalNotificaitonUpdated(studyId: Study.currentStudy?.studyId ?? "",
                                                                 status: true)
                        LocalNotification.refreshAllLocalNotification()
                    }
                }
            }
        }

        self.checkIfFetelKickCountRunning()
    }
    
    /**
     Used to update Activity Run Status
     @param status    Accepts data from UserActivityStatus class and ActivityStatus enum
     */
    @discardableResult
    func updateActivityRunStatus(status: UserActivityStatus.ActivityStatus) -> Bool{
        
        let activity = Study.currentActivity!
        
        let activityStatus = User.currentUser.updateActivityStatus(studyId: activity.studyId!,
                                                                   activityId: activity.actvityId!,
                                                                   runId: String(activity.currentRunId),
                                                                   status: status)
        activityStatus.compeltedRuns = activity.compeltedRuns
        activityStatus.incompletedRuns = activity.incompletedRuns
        activityStatus.totalRuns = activity.totalRuns
        activityStatus.activityVersion = activity.version
        
        // Update participationStatus to server
        UserServices().updateUserActivityParticipatedStatus(studyId: activity.studyId!, activityStatus: activityStatus, delegate: self)
        
        // Update participationStatus to DB
        DBHandler.updateActivityParticipationStatus(activity: activity)
        
        if status == .completed && activity.frequencyType != .Ongoing {
            self.updateCompletionAdherence()
        }
        return true
    }
    
    /**
     updateCompletionAdherence, calculates the Completion & Adherence based on following criteria
     completion = ((totalCompletedRuns + totalIncompletedRuns) * 100) / (totalRuns)
     adherence =  (totalCompletedRuns*100) / (totalCompletedRuns + totalIncompletedRuns)
     
     and alerts the user about the study Completion Status
     
     */
    func updateCompletionAdherence() {
        
        var totalRuns = 0
        var totalCompletedRuns = 0
        var totalIncompletedRuns = 0
        let activities = Study.currentStudy?.activities // .filter({$0.state == "active"})
        
        // Calculate Runs
        for activity in activities! {
            if activity.frequencyType == .Ongoing {
                continue // No need to consider Ongoing activity completion.
            }
            totalRuns += activity.totalRuns
            totalIncompletedRuns += activity.incompletedRuns
            totalCompletedRuns += activity.compeltedRuns
            
        }
        
        Study.currentStudy?.totalCompleteRuns = totalCompletedRuns
        Study.currentStudy?.totalIncompleteRuns = totalIncompletedRuns
        // Calculate Completion & Adherence
        let completion = ceil( Double(self.divide(lhs: (totalCompletedRuns + totalIncompletedRuns)*100, rhs: totalRuns)) )
        let adherence = ceil(Double(self.divide(lhs: totalCompletedRuns*100, rhs: (totalCompletedRuns + totalIncompletedRuns))))
        
        let studyid = Study.currentStudy?.studyId ?? ""
        
        let status = User.currentUser.udpateCompletionAndAdherence(studyId: studyid, completion: Int(completion), adherence: Int(adherence))
        
        // Update to server
        UserServices().updateCompletionAdherence(studyStauts: status, delegate: self)
        // Update Local DB
        DBHandler.updateStudyParticipationStatus(study: Study.currentStudy!)
        
        // Compose Alert based on Completion
        let halfCompletionKey = "50pcShown"  + (Study.currentStudy?.studyId)!
        let fullCompletionKey = "100pcShown"  + (Study.currentStudy?.studyId)!
        let missedKey = "totalMissed"  + (Study.currentStudy?.studyId)!
        
        let ud = UserDefaults.standard
        if completion > 50 && completion < 100 {
            if !(ud.bool(forKey: halfCompletionKey)) {
                // UIUtilities.showAlertWithMessage(alertMessage: message)
                ud.set(true, forKey: halfCompletionKey)
            }
        }
        
        if completion == 100 {
            if !(ud.bool(forKey: fullCompletionKey)) {
                var message = ""
                if let configurationMessage = AppConfiguration.studyCompletionMessage {
                    message = configurationMessage
                } else {
                    message = kTheStudy + (Study.currentStudy?.name ?? "") + k100PercentComplete
                }
                UIUtilities.showAlertWithMessage(alertMessage: message)
                ud.set(true, forKey: fullCompletionKey)
            }
        }
        
        // Alerts User about Completion
        if ud.object(forKey: missedKey) == nil {
            ud.set(totalIncompletedRuns, forKey: missedKey)
            
        } else {
            let previousMissed = (ud.object(forKey: missedKey) as? Int)!
            ud.set(totalIncompletedRuns, forKey: missedKey)
            if previousMissed < totalIncompletedRuns {
                // show alert
                
                let message = kNoticedMissedActivity + (Study.currentStudy?.name!)! + kEncourageCompleteStudy
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
        self.updateActivityRunStatus(status: .inProgress)
    }

    /**
     Used to update Activity Status To Complete
     */
    func updateActivityStatusToComplete(){
        self.updateActivityRunStatus(status: .completed)
    }
    
    // save completed staus in database
    func updateRunStatusToComplete(){
        
        guard let currentActivity = Study.currentActivity else {return}
        currentActivity.compeltedRuns += 1
        
        if currentActivity.frequencyType != .Ongoing {
            DBHandler.updateRunToComplete(runId: currentActivity.currentRunId,
                                          activityId: currentActivity.actvityId!,
                                          studyId: currentActivity.studyId!)
            self.updateActivityStatusToComplete()
        } else {
            // Everytime user completed the ongoing run, increase it's total runs.
            currentActivity.totalRuns += 1
            if self.updateActivityRunStatus(status: .yetToJoin) {
                if let updatedRun = DBHandler.updateOngoingRunOnComplete(with: currentActivity.currentRunId,
                activityId: currentActivity.actvityId!,
                studyId: currentActivity.studyId!) {
                    currentActivity.currentRun = updatedRun
                    currentActivity.currentRunId = updatedRun.runId
                }
            }
            // Schedule another run
        }
    }
    
    /**
     Update Run Status based on Run Id
     */
    func updateRunStatusForRunId(runId:Int){
        
        let activity = Study.currentActivity!
        activity.compeltedRuns += 1
        DBHandler.updateRunToComplete(runId: runId, activityId: activity.actvityId!, studyId: activity.studyId!)
        
        // update run count information
        let incompleteRuns = activity.currentRunId - activity.compeltedRuns
        activity.incompletedRuns = (incompleteRuns < 0) ? 0 : incompleteRuns
        if activity.currentRun == nil {
            // Do Nothing
            
        } else {
            // Status is not completed
            if activity.userParticipationStatus.status != UserActivityStatus.ActivityStatus.completed {
                
                var incompleteRuns = activity.currentRunId - activity.compeltedRuns
                incompleteRuns -= 1
                activity.incompletedRuns = (incompleteRuns < 0) ? 0 : incompleteRuns
            }
            
        }
        
        let activityStatus = User.currentUser.updateActivityStatus(studyId: activity.studyId!,
                                                                   activityId: activity.actvityId!,
                                                                   runId: String(runId),
                                                                   status: .completed)
        activityStatus.compeltedRuns = activity.compeltedRuns
        activityStatus.incompletedRuns = activity.incompletedRuns
        activityStatus.totalRuns = activity.totalRuns
        activityStatus.activityVersion = activity.version
        
        // Update User Participation Status to server
        UserServices().updateUserActivityParticipatedStatus(studyId: activity.studyId!, activityStatus: activityStatus, delegate: self)
        
        // Update User Participation Status to DB
        DBHandler.updateActivityParticipationStatus(activity: activity)
        
        self.updateCompletionAdherence()
        self.tableView?.reloadData()
        
    }
    
    /**
     Handler for studyUpdateResponse
     */
    func handleStudyUpdatesResponse() {
        
        Study.currentStudy?.newVersion = StudyUpdates.studyVersion
        DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
        
        // Consent Updated
        if StudyUpdates.studyConsentUpdated {
            presentUpdatedConsent()
            
        } else if StudyUpdates.studyInfoUpdated {
            guard let studyID = Study.currentStudy?.studyId else { return }
            WCPServices().getStudyInformation(studyId: studyID, delegate: self)
            
        } else {
            self.checkForActivitiesUpdates()
        }
        
    }
    
    // MARK: Api Calls
    
    /**
     Used to send Request To Get ActivityStates
     */
    func sendRequestToGetActivityStates(){
        guard let studyID = Study.currentStudy?.studyId else { return }
        UserServices().getUserActivityState(studyId: studyID, delegate: self)
    }
    
    /**
     Used to send Request To Get ActivityList
     */
    func sendRequesToGetActivityList(){
        guard let studyID = Study.currentStudy?.studyId else {return}
        WCPServices().getStudyActivityList(studyId: studyID, delegate: self)
    }
    
    func sendRequestToGetDashboardInfo(){
        guard let studyID = Study.currentStudy?.studyId else {return}
        WCPServices().getStudyDashboardInfo(studyId: studyID, delegate: self)
    }
    func sendRequestToGetResourcesInfo(){
        guard let studyID = Study.currentStudy?.studyId else {return}
        WCPServices().getResourcesForStudy(studyId: studyID, delegate: self)
    }
    
}
// MARK: - TableView Datasource
extension ActivitiesViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewSections.count
    }
    
    private func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rowDetail = tableViewSections[section]
        let activities = (rowDetail["activities"] as? Array<Activity>)!
        if activities.count == 0 {
            return 1
        }
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        view.backgroundColor = kBackgroundTableViewColor
        
        let dayData = tableViewSections[section]
        
        let statusText = (dayData["title"] as? String)!
        
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
        let activities = (rowDetail["activities"] as? Array<Activity>)!
        
        if activities.count == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "noData", for: indexPath)
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            var cell = (tableView.dequeueReusableCell(withIdentifier: kActivitiesTableViewCell,
                                                      for: indexPath) as? ActivitiesTableViewCell)!
            cell.delegate = self
            
            // Cell Data Setup
            cell.backgroundColor = UIColor.clear
            // kActivitiesTableViewScheduledCell
            let availabilityStatus = ActivityAvailabilityStatus(rawValue: indexPath.section)
            
            let activity = activities[indexPath.row]
            
            // check for scheduled frequency
            if activity.frequencyType == .Scheduled {
                
                cell = (tableView.dequeueReusableCell(
                    withIdentifier: kActivitiesTableViewScheduledCell,
                    for: indexPath) as? ActivitiesTableViewCell)!
                cell.delegate = self
            }
            // Set Cell data
            cell.populateCellDataWithActivity(activity: activity, availablityStatus: availabilityStatus!)
            
            return cell
        }
    }
}
// MARK: - TableView Delegates
extension ActivitiesViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
      
      
//      // Comment out when done
//        let filePath  = Bundle.main.path(forResource: "iOSActivity", ofType: "json")
//        let data = NSData(contentsOfFile: filePath!)
//
//        do {
//            let res = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String, Any>
//
//            if let activites = res![kActivites]  as? Array<Dictionary<String, Any>> {
//                if Study.currentStudy != nil {
//                    for activity in activites {
//                        let participatedActivity = UserActivityStatus(detail: activity,studyId:(Study.currentStudy?.studyId)!)
//                        user.participatedActivites.append(participatedActivity)
//                    }
//                }
//            }
//        }
//        catch {
//
//        }
      
      createActiCalled = ""
      UserDefaults.standard.set("", forKey: "createActiCalled")
      UserDefaults.standard.synchronize()
      
        let availabilityStatus = ActivityAvailabilityStatus(rawValue: indexPath.section)!
        
        switch availabilityStatus {
        case .current:
            
            let rowDetail = tableViewSections[indexPath.section]
            let activities = (rowDetail["activities"] as? Array<Activity>)!
            
            let activity = activities[indexPath.row]
            // Check for activity run status & if run is available
            if activity.currentRun != nil {
                if activity.userParticipationStatus != nil {
                    let activityRunParticipationStatus = activity.userParticipationStatus
                    if activityRunParticipationStatus?.status == .yetToJoin
                        || activityRunParticipationStatus?.status == .inProgress {
                        
                        Study.updateCurrentActivity(activity: activities[indexPath.row])
                        
                        // Following to be commented
                        // self.createActivity()
                        Logger.sharedInstance.info("Activity Fetching from db")
                        // check in database
                        DBHandler.loadActivityMetaData(
                            activity: activities[indexPath.row],
                            completionHandler: { (_) in
                                
//                            if found {
//
//                                self.createActivity()
//                            } else {
                          //  if NetworkManager.isNetworkAvailable() {
                                if let studyID = Study.currentStudy?.studyId,
                                    let activityID = Study.currentActivity?.actvityId,
                                    let version = Study.currentActivity?.version {
                                  print("1getStudyActivityMetadata---")
                                    WCPServices().getStudyActivityMetadata(studyId: studyID,
                                                                           activityId: activityID,
                                                                           activityVersion: version,
                                                                           delegate: self)
//                                } else if found{
//                                    self.createActivity()
//                                }
                                    ///  }
                            }
                        })
                        
                        self.updateActivityStatusToInProgress()
                        self.selectedIndexPath = indexPath
                        
                    } else {
                        
                    }
                }
                
            } else if activity.userParticipationStatus?.status == .abandoned {
                
                UIUtilities.showAlertWithMessage(alertMessage: kActivityAbondonedAlertMessage)
            }
            
        case .upcoming, .past: break
            
        }
      
      selectTableCell(indexPath: indexPath)
    }
  
  private func selectTableCell(indexPath: IndexPath) {
      let availabilityStatus = ActivityAvailabilityStatus(rawValue: indexPath.section)!
      
      switch availabilityStatus {
      case .current:
          
          let rowDetail = tableViewSections[indexPath.section]
          let activities = (rowDetail["activities"] as? Array<Activity>)!
          
          let activity = activities[indexPath.row]
          // Check for activity run status & if run is available
          if activity.currentRun != nil {
              if activity.userParticipationStatus != nil {
                  let activityRunParticipationStatus = activity.userParticipationStatus
                  if activityRunParticipationStatus?.status == .yetToJoin
                      || activityRunParticipationStatus?.status == .inProgress {
                      
                      Study.updateCurrentActivity(activity: activities[indexPath.row])
                      
                      // Following to be commented
                      // self.createActivity()
                      Logger.sharedInstance.info("Activity Fetching from db")
                      // check in database
                      DBHandler.loadActivityMetaData(
                          activity: activities[indexPath.row],
                          completionHandler: { (_) in
                              
                              //                            if found {
                              //
                              //                                self.createActivity()
                              //                            } else {
                              //  if NetworkManager.isNetworkAvailable() {
                              if let studyID = Study.currentStudy?.studyId,
                                 let activityID = Study.currentActivity?.actvityId,
                                 let version = Study.currentActivity?.version {
                                print("2getStudyActivityMetadata---")
//                                  WCPServices().getStudyActivityMetadata(studyId: studyID,
//                                                                         activityId: activityID,
//                                                                         activityVersion: version,
//                                                                         delegate: self)
                                  //                                } else if found{
                                  //                                    self.createActivity()
                                  //                                }
                                  ///  }
                              }
                          })
                      
                      self.updateActivityStatusToInProgress()
                      self.selectedIndexPath = indexPath
                      
                  } else {
                      
                  }
              }
              
          } else if activity.userParticipationStatus?.status == .abandoned {
              
              UIUtilities.showAlertWithMessage(alertMessage: kActivityAbondonedAlertMessage)
          }
          
      case .upcoming, .past: break
          
      }
  }
  
  private func selectACTIOTHERTableCell(indexPathMain: IndexPath, actiActivityId: String) {
      let availabilityStatus = ActivityAvailabilityStatus(rawValue: indexPathMain.section)!
      
      switch availabilityStatus {
      case .current:
          
          let rowDetail = tableViewSections[indexPathMain.section]
          let activities = (rowDetail["activities"] as? Array<Activity>)!
//        if activities.count > 0 {
          if let row = activities.firstIndex(where: {$0.actvityId == actiActivityId}) {
            let indexPath = IndexPath(row: row, section: indexPathMain.section)
          let activity = activities[indexPath.row]
        print("1jumpactivity---\(activity.actvityId)")
          // Check for activity run status & if run is available
          if activity.currentRun != nil {
              if activity.userParticipationStatus != nil {
                  let activityRunParticipationStatus = activity.userParticipationStatus
                  if activityRunParticipationStatus?.status == .yetToJoin
                      || activityRunParticipationStatus?.status == .inProgress {
                      
                      Study.updateCurrentActivity(activity: activities[indexPath.row])
                    print("2jumpactivity---\(activities[indexPath.row].actvityId)")
                      // Following to be commented
                      // self.createActivity()
                      Logger.sharedInstance.info("Activity Fetching from db")
                      // check in database
                      DBHandler.loadActivityMetaData(
                          activity: activities[indexPath.row],
                          completionHandler: { (_) in
                              
                              //                            if found {
                              //
                              //                                self.createActivity()
                              //                            } else {
                              //  if NetworkManager.isNetworkAvailable() {
                              if let studyID = Study.currentStudy?.studyId,
                                 let activityID = Study.currentActivity?.actvityId,
                                 let version = Study.currentActivity?.version {
                                print("2getStudyActivityMetadata---")
                                UserDefaults.standard.set("", forKey: "createActiCalled")
                                UserDefaults.standard.synchronize()
                                self.createActiCalled = ""
                                print("3jumpactivity---\(activityID)")
                                  WCPServices().getStudyActivityMetadata(studyId: studyID,
                                                                         activityId: activityID,
                                                                         activityVersion: version,
                                                                         delegate: self)
                                  //                                } else if found{
                                  //                                    self.createActivity()
                                  //                                }
                                  ///  }
                              }
                          })
                      
                      self.updateActivityStatusToInProgress()
                      self.selectedIndexPath = indexPath
                      
                  } else {
                      
                  }
              }
              
          } else if activity.userParticipationStatus?.status == .abandoned {
              
              UIUtilities.showAlertWithMessage(alertMessage: kActivityAbondonedAlertMessage)
          }
          }
      case .upcoming, .past: break
          
      }
  }
  
}

// MARK: - ActivitiesCell Delegate
extension ActivitiesViewController: ActivitiesCellDelegate{
    
    func activityCell(cell: ActivitiesTableViewCell, activity: Activity) {
        
        let frame = self.view.frame
        // frame.size.height += 114
        
        let view = ActivitySchedules.instanceFromNib(frame: frame, activity: activity)
        self.tabBarController?.view.addSubview(view)
        
    }
}

// MARK: - ActivityFilterDelegate
extension ActivitiesViewController: ActivityFilterViewDelegate{
    func setSelectedFilter(selectedIndex: ActivityFilterType) {
        
        // current filter is not same as existing filter
        if self.selectedFilter != selectedIndex {
            
            // currently filter type is all so no need to fetch all activities
            if self.selectedFilter == .all{
                
                let filterType: ActivityType! =  (selectedIndex == .surveys ? .Questionnaire : .activeTask)
                self.updateSectionArray(activityType: filterType)
                
            } else {// existing filterType is either Task or Surveys
                
                // load all the sections from scratch
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
        } else {
            // current and newly selected filter types are same
        }
    }
    
    func updateSectionArray(activityType: ActivityType)  {
        
        var updatedSectionArray: Array<Dictionary<String, Any>>! = []
        for section in tableViewSections {
            let activities = (section[kActivities] as? Array<Activity>)!
            var sectionDict: Dictionary<String, Any>! = section
            sectionDict[kActivities] = activities.filter({$0.type == activityType
            })
            
            updatedSectionArray.append(sectionDict)
        }
        tableViewSections = []
        tableViewSections = updatedSectionArray
    }
    
}
// MARK: - Webservice Delegates
extension ActivitiesViewController: NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info(" START requestname : \(requestName)")
        
        if (requestName as String == RegistrationMethods.updateStudyState.method.methodName) ||
            (requestName as String == RegistrationMethods.updateActivityState.method.methodName) ||
            (requestName as String == WCPMethods.studyDashboard.method.methodName) ||
            (requestName as String == WCPMethods.resources.method.methodName){
        } else {
            self.addProgressIndicator()
        }
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) Response : \(String(describing:response))")
        
        if requestName as String == RegistrationMethods.activityState.method.methodName {
            self.sendRequesToGetActivityList()
        } else if requestName as String == WCPMethods.activityList.method.methodName {
            
            StudyUpdates.studyActivitiesUpdated = false
            // Update StudymetaData for Study
            DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
            // findActivitiesToUpdateSchedule()
            self.fetchActivityAnchorDateResponseFromLabkey()
            // get DashboardInfo
            self.sendRequestToGetDashboardInfo()
            
        } else if requestName as String == WCPMethods.activity.method.methodName {
            self.removeProgressIndicator()
          
          if createActiCalled != "true" {
            print("1createActiCalled---")
            UserDefaults.standard.set("true", forKey: "createActiCalled")
            UserDefaults.standard.synchronize()
            
            self.createActivity()
            
            
//            let ud1 = UserDefaults.standard
//            let valJum = ud1.object(forKey: "jumpInternalLoad") as? String ?? ""
//            if valJum != "jumpInternalLoad" {
//              print("1jumpInternalLoad---")
//            self.createActivity()
//            } else {
//              print("2jumpInternalLoad---")
//
//              addProgressIndicator3()
////              DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
////                self.createActivity()
////                UserDefaults.standard.setValue("", forKey: "jumpInternalLoad")
////            UserDefaults.standard.synchronize()
////              }
//            }
          } else {
            print("2createActiCalled---")
            if let valresponse: Dictionary<String, Any> = response as? Dictionary<String, Any> {

            setActivityMetaData(activityDict: valresponse[kActivity] as! Dictionary<String, Any>)
            }
          }
            
        } else if requestName as String == WCPMethods.studyDashboard.method.methodName {
            self.sendRequestToGetResourcesInfo()
            self.getLabkeyResponse()
            
        } else if requestName as String == WCPMethods.resources.method.methodName {
            DispatchQueue.main.async {
                if let study = Study.currentStudy {
                    ResourcesViewController.updateResourcesAnchorDateLifeTime(for: study)
                }
            }
        } else if requestName as String == ResponseMethods.processResponse.method.methodName {
            self.removeProgressIndicator()
            // self.updateRunStatusToComplete()
            self.checkForActivitiesUpdates()
            
        } else if requestName as String == WCPMethods.studyUpdates.method.methodName {
            
            Logger.sharedInstance.info("Handling response for study updates...")
            self.removeProgressIndicator()
            self.handleStudyUpdatesResponse()
            if Study.currentStudy?.version == StudyUpdates.studyVersion {
                
                self.checkForActivitiesUpdates()
            } else {
                
                self.handleStudyUpdatesResponse()
            }
            
        } else if requestName as String == WCPMethods.studyInfo.method.methodName {
            
            StudyUpdates.studyInfoUpdated = false
            DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
            
            self.checkForActivitiesUpdates()
        } else if requestName as String == "BTC/\(Study.currentStudy?.studyId ?? "")/mobileappstudy-selectRows.api" {
          print("selectRows---\(response)")
          
          guard let rows = response?["rows"] as? [JSONDictionary] ,
                let rowDetail = rows.last
               else { return }
          
          let resultA = valPipingValuesMain.merging(rowDetail, uniquingKeysWith: { (first, _) in first })
          
          valPipingValuesMain = resultA
          valPipingValuesMain.removeValue(forKey: "Key")
          valPipingValuesMain.removeValue(forKey: "ParticipantId")
//          valPipingValuesMain["valuePicker"] = "3"
          
          print("resultA---\(resultA)---\(valPipingValuesMain)")
      }
    }
    
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        if self.refreshControl != nil && (self.refreshControl?.isRefreshing)! {
            self.refreshControl?.endRefreshing()
        }
        if error.code == 403 { // unauthorized
            // let errorMsg = base64DecodeError(error.localizedDescription)
            UIUtilities.showAlertMessageWithActionHandler(kErrorTitle,
                                                          message: error.localizedDescription,
                                                          buttonTitle: kTitleOk,
                                                          viewControllerUsed: self,
                                                          action: {
                self.fdaSlideMenuController()?.navigateToHomeAfterUnauthorizedAccess()
            })
        } else if requestName as String == RegistrationMethods.activityState.method.methodName {
            // self.sendRequesToGetActivityList()
            if error.code != NoNetworkErrorCode {
                self.loadActivitiesFromDatabase()
            } else {
                self.tableView?.isHidden = true
                self.labelNoNetworkAvailable?.isHidden = false
            }
        } else {
            let errorMsg = base64DecodeError(error.localizedDescription)
            // let errorMsg = base64DecodeError(error.localizedDescription)
            UIUtilities.showAlertWithTitleAndMessage(
                title: NSLocalizedStrings(kErrorTitle, comment: "") as NSString,
                message: errorMsg as NSString)
        }
    }
  
  func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 5.0,
                                 target: self,
                                 selector: #selector(eventWith(timer:)),
                                 userInfo: [ "foo" : "bar" ],
                                 repeats: false)
  }
  
  @objc func eventWith(timer: Timer!) {
//    let info = timer.userInfo as Any
//    print(info)
    timer.invalidate()
    UserDefaults.standard.setValue("", forKey: "jumpInternalLoad")
UserDefaults.standard.synchronize()
    removeProgressIndicator3()
  }
}

// MARK: - ORKTaskViewController Delegate
extension ActivitiesViewController: ORKTaskViewControllerDelegate{
    
    func taskViewControllerSupportsSaveAndRestore(_ taskViewController: ORKTaskViewController) -> Bool {
        return true
    }
  
  func jumpActi(activityId: String) {
    addProgressIndicator2()
        let sectionCount = tableViewSections.count
        for section in 0..<sectionCount {
            let rowDetail = tableViewSections[section]
            let activities = (rowDetail["activities"] as? Array<Activity>)!
            if activities.count > 0 {
                if let row = activities.firstIndex(where: {$0.actvityId == activityId}) {
                    let indexPath = IndexPath(row: row, section: section)
                  
                  
                  
                  
                      let availabilityStatus = ActivityAvailabilityStatus(rawValue: indexPath.section)!
                      
                      switch availabilityStatus {
                      case .current:
                        
                        let activityVal = activities[indexPath.row]
                        let valStatus = activityVal.userParticipationStatus.status
                        if valStatus == .completed ||
                            valStatus == .abandoned ||
                            valStatus == .expired {
                          UIUtilities.showAlertMessageWithActionHandler(kErrorTitle,
                                                                        message: "Current activity/survey is completed. Kindly standby for the next activity/survey",
                                                                        buttonTitle: "Ok",
                                                                        viewControllerUsed: self,
                                                                        action: {
                            self.removeProgressIndicator2()
        //                    self.selectTableCell(indexPath: indexPath)
  //                          self.selectACTIOTHERTableCell(indexPath: indexPath)
                          })
                        } else {

                        
                        
                        
                        UIUtilities.showAlertMessageWithActionHandler(kErrorTitle,
                                                                      message: "You will be navigated to a different activity/survey as this activity/survey is completed",
                                                                      buttonTitle: "Ok",
                                                                      viewControllerUsed: self,
                                                                      action: {
                          self.removeProgressIndicator2()
      //                    self.selectTableCell(indexPath: indexPath)
                          self.selectACTIOTHERTableCell(indexPathMain: indexPath, actiActivityId: activityId)
                        })
                        }
                      case .upcoming, .past:
                        UIUtilities.showAlertMessageWithActionHandler(kErrorTitle,
                                                                      message: "Current activity/survey is completed. Kindly standby for the next activity/survey",
                                                                      buttonTitle: "Ok",
                                                                      viewControllerUsed: self,
                                                                      action: {
                          self.removeProgressIndicator2()
      //                    self.selectTableCell(indexPath: indexPath)
//                          self.selectACTIOTHERTableCell(indexPath: indexPath)
                        })
                      }
                  
                  
                  
                  
                    
                    break
                }
            }
        }
        UserDefaults.standard.setValue("", forKey: "jumpActivity")
    UserDefaults.standard.synchronize()
    
  }
  
  func jumpToActivity(identifier: String, indexPath: IndexPath) {
    let availabilityStatus = ActivityAvailabilityStatus(rawValue: indexPath.section)!
    
    switch availabilityStatus {
    case .current:
        
        let rowDetail = tableViewSections[indexPath.section]
        let activities = (rowDetail["activities"] as? Array<Activity>)!
        
        let activity = activities[indexPath.row]
        // Check for activity run status & if run is available
        if activity.currentRun != nil {
            if activity.userParticipationStatus != nil {
                let activityRunParticipationStatus = activity.userParticipationStatus
                if activityRunParticipationStatus?.status == .yetToJoin
                    || activityRunParticipationStatus?.status == .inProgress {
                    
                    Study.updateCurrentActivity(activity: activities[indexPath.row])
                    
                    // Following to be commented
                    // self.createActivity()
                    Logger.sharedInstance.info("Activity Fetching from db")
                    // check in database
                    DBHandler.loadActivityMetaData(
                        activity: activities[indexPath.row],
                        completionHandler: { (_) in
                            
//                            if found {
//
//                                self.createActivity()
//                            } else {
                      //  if NetworkManager.isNetworkAvailable() {
                            if let studyID = Study.currentStudy?.studyId,
                                let activityID = Study.currentActivity?.actvityId,
                                let version = Study.currentActivity?.version {
                                WCPServices().getStudyActivityMetadata(studyId: studyID,
                                                                       activityId: activityID,
                                                                       activityVersion: version,
                                                                       delegate: self)
//                                } else if found{
//                                    self.createActivity()
//                                }
                                ///  }
                        }
                    })
                    
                    self.updateActivityStatusToInProgress()
                    self.selectedIndexPath = indexPath
                    
                } else {
                    
                }
            }
            
        } else if activity.userParticipationStatus?.status == .abandoned {
            
            UIUtilities.showAlertWithMessage(alertMessage: kActivityAbondonedAlertMessage)
        }
        
    case .upcoming, .past: break
        
      
      
    }
  
  selectTableCell(indexPath: indexPath)
}
    
    /// This method will update the result for other choices for each step
    fileprivate func updateResultForChoiceQuestions(_ taskViewController: ORKTaskViewController) {
        if let results = taskViewController.result.results as? [ORKStepResult]{
            
            for result in results {
                if let choiceResult = result.results?.first as? ORKChoiceQuestionResult, let answers = choiceResult.answer as? [Any] {
                    var selectedChoices: [Any] = []
                    
                    var otherChoiceDict = answers.filter({$0 as? JSONDictionary != nil}).first as? JSONDictionary
                    let otherValueKey = "otherValue"
                    if let otherValue = otherChoiceDict?[otherValueKey] as? String {
                        otherChoiceDict?.removeValue(forKey: otherValueKey)
                        answers.forEach { (value) in
                            if let value = value as? String {
                                if value != otherValue {
                                    selectedChoices.append(value)
                                }
                            } else {
                                selectedChoices.append(otherChoiceDict!)
                            }
                        }
                        choiceResult.answer = selectedChoices
                    }
                    
                }
            }
        }
    }
    
    public func taskViewController(_ taskViewController: ORKTaskViewController,
                                   didFinishWith reason: ORKTaskViewControllerFinishReason,
                                   error: Error?) {
        print("taskViewControllertaskViewController---")
      
      
      
      
        // Enable Custom Keypad with toolbar
        // IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        self.managedResult.removeAll()
        
        updateResultForChoiceQuestions(taskViewController)
        
        // var taskResult: Any?
        
        switch reason {
            
        case ORKTaskViewControllerFinishReason.completed: break
            
            // taskResult = taskViewController.result
            //            let ud = UserDefaults.standard
            //            if ud.bool(forKey: "FKC") {
            //
            //                let runid = (ud.object(forKey: "FetalKickCounterRunid") as? Int)!
            //
            //                if Study.currentActivity?.currentRun.runId != runid {
            //                    // runid is changed
            //                    self.updateRunStatusForRunId(runId: runid)
            //                } else {
            //                    self.updateRunStatusToComplete()
            //                }
            //            } else {
            //
            //                self.updateRunStatusToComplete()
            //            }
            
        case ORKTaskViewControllerFinishReason.failed: break
          UserDefaults.standard.setValue("", forKey: "jumpActivity")
      UserDefaults.standard.synchronize()
            // taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.discarded:
          UserDefaults.standard.setValue("", forKey: "jumpActivity")
      UserDefaults.standard.synchronize()
            let study = Study.currentStudy
            let activity = Study.currentActivity
            activity?.currentRun.restortionData = nil
            DBHandler.updateActivityRestortionDataFor(activity: activity!, studyId: (study?.studyId)!, restortionData:nil)
            
            let ud = UserDefaults.standard
            ud.removeObject(forKey: "FKC")
            ud.removeObject(forKey: kFetalKickActivityId)
            ud.removeObject(forKey: kFetalKickCounterValue)
            ud.removeObject(forKey: kFetalKickStartTimeStamp)
            ud.removeObject(forKey: kFetalkickStudyId)
            ud.removeObject(forKey: kFetalKickCounterRunId)
            ud.synchronize()
            
            self.checkForActivitiesUpdates()
            
        case ORKTaskViewControllerFinishReason.saved:
          UserDefaults.standard.setValue("", forKey: "jumpActivity")
      UserDefaults.standard.synchronize()
            // taskResult = taskViewController.restorationData
            
            if taskViewController.task?.identifier == "ConsentTask" {
                // Do Nothing
            } else {
                ActivityBuilder.currentActivityBuilder.activity?.restortionData = taskViewController.restorationData
              
              let study = Study.currentStudy
              guard let activity = Study.currentActivity else { return }
              
              if activity.type != .activeTask {
                guard let studyId = study?.studyId else { return }
                // Update RestortionData for Activity in DB
                DBHandler.updateActivityRestortionDataFor(
                  activity: activity,
                  studyId: studyId,
                  restortionData: taskViewController.restorationData!
                )
                activity.currentRun.restortionData = taskViewController.restorationData!
              }
              
            }
            
            self.checkForActivitiesUpdates()
            
        @unknown default:
            break
        }
        
        let activityId = Study.currentActivity?.actvityId
        let studyId = Study.currentStudy?.studyId
        var response:[String:Any]?
        
        if  taskViewController.task?.identifier == "ConsentTask" {
            consentbuilder?.consentResult?.initWithORKTaskResult(taskResult:taskViewController.result )
        } else {
            
            if reason == ORKTaskViewControllerFinishReason.completed {
                
                ActivityBuilder.currentActivityBuilder.actvityResult?.initWithORKTaskResult(taskResult: taskViewController.result)
                
                response = ActivityBuilder.currentActivityBuilder.actvityResult?.getResultDictionary()
                
                Study.currentActivity?.userStatus = .completed
                
                if ActivityBuilder.currentActivityBuilder.actvityResult?.type == ActivityType.activeTask {
                    
                    if  (taskViewController.result.results?.count)! > 0 {
                        
                        let orkStepResult:ORKStepResult? = (taskViewController.result.results?[1] as? ORKStepResult)!
                        
                        if (orkStepResult?.results?.count)! > 0 {
                            
                            let activeTaskResultType =  ActiveStepType(rawValue:
                                                        (ActivityBuilder.currentActivityBuilder.activity?.activitySteps?.first?.resultType
                                                                            as? String)!)
                            
                            switch activeTaskResultType! {
                                
                            case .fetalKickCounter:
                                
                                let fetalKickResult:FetalKickCounterTaskResult? = orkStepResult?.results?.first as?
                                    FetalKickCounterTaskResult
                                
                                // let study = Study.currentStudy
                                let activity = Study.currentActivity
                                
                                // Create the stats for FetalKick
                                if fetalKickResult != nil {
                                    
                                    let value = Float((fetalKickResult?.duration)!)/60
                                    let kickcount = Float((fetalKickResult?.totalKickCount)!)
                                    let dict = ActivityBuilder.currentActivityBuilder.activity?.steps?.first!
                                    let key =   (dict?[kActivityStepKey] as? String)!
                                    
                                    // Save Stats to DB
                                    DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!,
                                                                    key: key,
                                                                    data: value,
                                                                    fkDuration: Int(kickcount),
                                                                    date: Date())
                                    
                                    let ud = UserDefaults.standard
                                    ud.removeObject(forKey: "FKC")
                                    ud.removeObject(forKey: kFetalKickActivityId)
                                    ud.removeObject(forKey: kFetalKickCounterValue)
                                    ud.removeObject(forKey: kFetalKickStartTimeStamp)
                                    ud.removeObject(forKey: kFetalkickStudyId)
                                    ud.removeObject(forKey: kFetalKickCounterRunId)
                                    ud.synchronize()
                                    
                                }
                            case .spatialSpanMemoryStep:
                                let activity = Study.currentActivity
                                
                                // Create stats for SpatialSpanMemoryStep
                                let spatialSpanResult: ORKSpatialSpanMemoryResult? =
                                orkStepResult?.results?.first as? ORKSpatialSpanMemoryResult
                                
                                // get score
                                let scores = Float((spatialSpanResult?.score)!)
                                let keyScore = "Score"
                                // Save Stats to DB
                                DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!,
                                                                key: keyScore ,
                                                                data: Float(scores),
                                                                fkDuration: Int(0),
                                                                date: Date())
                                
                                // get numberOfFailures
                                let numberOfFailures = Float((spatialSpanResult?.numberOfFailures)!)
                                let keyNumberOfFailures = "NumberofFailures"
                                // Save Stats to DB
                                DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!,
                                                                key: keyNumberOfFailures ,
                                                                data: Float(numberOfFailures),
                                                                fkDuration: Int(0),
                                                                date: Date())
                                
                                // get number of Games
                                let numberOfGames = Float((spatialSpanResult?.numberOfGames)!)
                                let keyNumberOfGames = "NumberofGames"
                                // Save Stats to DB
                                DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!,
                                                                key: keyNumberOfGames ,
                                                                data: Float(numberOfGames),
                                                                fkDuration: Int(0),
                                                                date: Date())
                                
                            case .towerOfHanoi:
                                
                                // Create Stats for TowersOfHonoi
                                let activity = Study.currentActivity
                                let tohResult: ORKTowerOfHanoiResult? = orkStepResult?.results?.first as? ORKTowerOfHanoiResult
                                let key =  ActivityBuilder.currentActivityBuilder.activity?.steps?.first![kActivityStepKey] as? String
                                
                                let numberOfMoves = tohResult?.moves?.count
                                
                                // Save Stats to DB
                                DBHandler.saveStatisticsDataFor(activityId: (activity?.actvityId)!,
                                                                key: key! ,
                                                                data: Float(numberOfMoves!),
                                                                fkDuration: Int(0),
                                                                date: Date())
                                
                            default:break
                            }
                        }
                    }
                }
                // send response to labkey
                LabKeyServices().processResponse(responseData:response!, delegate: self)
              
              let ud = UserDefaults.standard
              if ud.bool(forKey: "FKC") {
                let runid = (ud.object(forKey: "FetalKickCounterRunid") as? Int)!
                
                if Study.currentActivity?.currentRun.runId != runid {
                  // runid is changed
                  self.updateRunStatusForRunId(runId: runid)
                } else {
                  self.updateRunStatusToComplete()
                }
              } else {
                self.updateRunStatusToComplete()
              }
            }
        }
      
      taskViewController.dismiss(animated: true, completion: {
        
        if reason == ORKTaskViewControllerFinishReason.completed {
          
          let lifeTimeUpdated = DBHandler.updateTargetActivityAnchorDateDetail(studyId: studyId ?? "",
                                                                               activityId: activityId ?? "",
                                                                               response: response ?? [String:Any]())
          if lifeTimeUpdated {
            self.loadActivitiesFromDatabase()
          } else {
            self.tableView?.reloadData()
          }
        } else {
          self.tableView?.reloadData()
        }
        
      })
      
      
      let ud1 = UserDefaults.standard
      
      let valJum = ud1.object(forKey: "jumpActivity") as? String ?? ""
      if valJum != "" {
        print("valJum---\(valJum)")
        jumpActi(activityId: valJum)
      }
      
      
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController,
                            stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        
        if (taskViewController.result.results?.count)! > 1 {
            
          if activityBuilder?.actvityResult?.result?.count
            == taskViewController.result.results?
            .count
          {
            activityBuilder?.actvityResult?.result?.removeLast()
          } else {

            let study = Study.currentStudy
            guard let activity = Study.currentActivity else { return }

            if activity.type != .activeTask {

              // Update RestortionData for Activity in DB
              
              DBHandler.updateActivityRestortionDataFor(
                activity: activity,
                studyId: (study?.studyId)!,
                restortionData: taskViewController.restorationData!
              )
              activity.currentRun.restortionData = taskViewController.restorationData!
            }

            let orkStepResult: ORKStepResult? =
              taskViewController.result.results?[
                (taskViewController.result.results?.count)! - 2
              ] as! ORKStepResult?
            let activityStepResult: ActivityStepResult? = ActivityStepResult()
            if (activity.activitySteps?.count)! > 0 {

              let activityStepArray = activity.activitySteps?.filter({
                $0.key == orkStepResult?.identifier
              })
              if (activityStepArray?.count)! > 0 {
                activityStepResult?.step = activityStepArray?.first
              }
            }
            activityStepResult?.initWithORKStepResult(
              stepResult: orkStepResult! as ORKStepResult,
              activityType: (ActivityBuilder.currentActivityBuilder.actvityResult?.type)!
            )

            /// check for anchor date.
            if study?.anchorDate != nil
              && study?.anchorDate?.anchorDateActivityId
                == activity
                .actvityId
            {

              if (study?.anchorDate?.anchorDateQuestionKey)! == (activityStepResult?.key)! {
                if let value1 = activityStepResult?.value as? String {
                  isAnchorDateSet = true
                  study?.anchorDate?.setAnchorDateFromQuestion(date: value1)
                        }
                    }
                }
                
                // save data for stats
                if ActivityBuilder.currentActivityBuilder.actvityResult?.type == .Questionnaire {
                    
                    if let value1 = activityStepResult?.value as? NSNumber {
                        let value = value1.floatValue
                        DBHandler.saveStatisticsDataFor(activityId: (activity.actvityId)!,
                                                        key: (activityStepResult?.key)!,
                                                        data: value,
                                                        fkDuration: 0,
                                                        date: Date())
                    }
                }
                
                let ud = UserDefaults.standard
                
                let activityId:String? = ud.value(forKey:"FetalKickActivityId" ) as! String?
                // go forward if fetal kick task is running
                if activity.type == .activeTask
                    && ud.bool(forKey: "FKC")
                    && activityId != nil
                    && activityId == Study.currentActivity?.actvityId
                    && (stepViewController is ORKInstructionStepViewController)  {
                    
//                    DispatchQueue.main.asyncAfter(deadline: .now()) {
//                        stepViewController.goForward()
//                    }
                }
                
                // disable back button
                if stepViewController is FetalKickCounterStepViewController{
                    stepViewController.backButtonItem = nil
                }
            }
        }
    }
  
  func setResultValue(stepResult: ORKStepResult, activityType: ActivityType) -> String {
      var valAnswer = ""
      if (stepResult.results?.count)! > 0 {
          
          if  activityType == .Questionnaire {
              // for question Step
//            if stepResult.results?.count == 1 && self.type != .form {
            if stepResult.results?.count == 1 { // && activityType != .form {
              print("1questionstepResult---\(stepResult.results?.first as? ORKQuestionResult?)")
                  if let questionstepResult: ORKQuestionResult? = stepResult.results?.first as? ORKQuestionResult? {
                    print("2questionstepResult---\(questionstepResult)")
                     let val = self.setValue(questionstepResult:questionstepResult! )
                      return val
                  }
              }
//            else {
//                  // for form step result
//
//                  self.value  = [ActivityStepResult]()
//                  var formResultArray:[Any] = [Any]()
//                  var i: Int! = 0
//                  var j: Int! = 0
//                  var isAddMore: Bool? =  false
//
//                  if (stepResult.results?.count)! > (self.step as? ActivityFormStep)!.itemsArray.count {
//                      isAddMore = true
//                  }
//                  var localArray: [Dictionary<String, Any>] = [Dictionary<String, Any>]()
//
//                  for result in stepResult.results! {
//
//                      let activityStepResult: ActivityStepResult? = ActivityStepResult()
//                      activityStepResult?.startTime = self.startTime
//                      activityStepResult?.endTime = self.endTime
//                      activityStepResult?.skipped = self.skipped
//
//                      let activityStep = ActivityStep()
//                      activityStepResult?.step = activityStep
//
//                      j = (i == 0 ? 0 : i % (self.step as? ActivityFormStep)!.itemsArray.count)
//
//                      // Checking if formStep is RepeatableFormStep
//                      if isAddMore! {
//                          if j  == 0 {
//                              localArray.removeAll()
//                              localArray = [Dictionary<String, Any>]()
//                          }
//
//                          let stepDict = (((self.step as? ActivityFormStep)!.itemsArray) as [Dictionary<String, Any>])[j]
//
//                           activityStepResult?.key = stepDict["key"] as! String?
//
//                      } else {
//                           activityStepResult?.key = result.identifier
//                      }
//                      let itemDict = (self.step as? ActivityFormStep)!.itemsArray[j] as Dictionary<String, Any>
//                      activityStepResult?.step?.resultType = (itemDict["resultType"] as? String)!
//                      if (result as? ORKQuestionResult) != nil {
//
//                          let questionResult: ORKQuestionResult? = (result as? ORKQuestionResult)
//
//                          if  Utilities.isValidValue(someObject: (activityStepResult?.step?.resultType as? String as AnyObject)) {
//                              self.subTypeForForm = activityStepResult?.step?.resultType as? String
//
//                          } else {
//                              self.subTypeForForm = ""
//                          }
//
//                          self.setValue(questionstepResult: questionResult!)
//
//                          activityStepResult?.value = self.value
//                          localArray.append((activityStepResult?.getActivityStepResultDict()!)!)
//
//                          // checking if more steps added in RepeatableFormStep
//                          if isAddMore! {
//                              if j + 1 == (self.step as? ActivityFormStep)!.itemsArray.count {
//                                  if localArray.count > 0 {
//                                      formResultArray.append(localArray)
//                                  }
//                              }
//                          }
//                      }
//                      i += 1
//                  }
//
//                  if isAddMore! {
//                      self.value = formResultArray
//
//                  } else {
//                      if localArray.count > 0 {
//                          formResultArray.append(localArray)
//                      }
//                      self.value = formResultArray
//                  }
//              }
              
          }
        
      }
    return ""
  }
  
  func getresultType (identifier: String) -> String {
    let activity = Study.currentActivity
    let activityStepArray = activity?.activitySteps?.filter({$0.key == identifier
    })
      
      if (activityStepArray?.count)! > 0 {
          let step1 = activityStepArray?.first
        print("step1?.resultType---\(step1?.resultType)")
        let val1 = step1?.resultType as? String ?? ""
        
       return val1
      }
    return ""
  }
  
  func getTextValueFromValue(identifier: String, valFinalRes: String) -> String {
    let activity = Study.currentActivity
    let activityStepArray = activity?.activitySteps?.filter({$0.key == identifier
    })
      
      if (activityStepArray?.count)! > 0 {
          let step1 = activityStepArray?.first
        print("step1?.resultType---\(step1?.resultType)")
        let val1 = step1?.resultType as? String ?? ""
        
        //        var style = ""
//                var style = ((step1 as? ActivityQuestionStep)?.formatDict?["textChoices"] as? [String: String])!
                
//                let activityStep: ActivityStep?

        let valFormat = (step1 as? ActivityQuestionStep)?.formatDict
        
        if  Utilities.isValidObject(someObject: valFormat?[kStepQuestionTextChoiceTextChoices] as AnyObject?)
            && Utilities.isValidValue(someObject: valFormat?[kStepQuestionTextChoiceSelectionStyle] as AnyObject?) {
            
//            let textChoiceDict = valFormat?[kStepQuestionTextChoiceTextChoices] as? [Any] ?? []
          let textChoiceDict = valFormat?[kStepQuestionTextChoiceTextChoices] as? [JSONDictionary] ?? []
         
            
            for dict in textChoiceDict {
              let text = dict[kORKTextChoiceText] as? String ?? ""
              let value = dict[kORKTextChoiceValue] as? String ?? ""
              
              if valFinalRes == value {
                print("valuevaluevalue---\(value)---\(text)")
                return text
              }
            }
          
        }
        
        
       return valFinalRes
      }
    return valFinalRes
  }
  
  func getScaleValueFromValue(identifier: String, valFinalRes: String) -> String {
    let activity = Study.currentActivity
    let activityStepArray = activity?.activitySteps?.filter({$0.key == identifier
    })
      
      if (activityStepArray?.count)! > 0 {
          let step1 = activityStepArray?.first
        print("step1?.resultType---\(step1?.resultType)")
        let val1 = step1?.resultType as? String ?? ""
        
        //        var style = ""
//                var style = ((step1 as? ActivityQuestionStep)?.formatDict?["textChoices"] as? [String: String])!
                
//                let activityStep: ActivityStep?

        let valFormat = (step1 as? ActivityQuestionStep)?.formatDict
        
        if  Utilities.isValidObject(someObject: valFormat?[kStepQuestionTextChoiceTextChoices] as AnyObject?) {
            
//            let textChoiceDict = valFormat?[kStepQuestionTextChoiceTextChoices] as? [Any] ?? []
          let textChoiceDict = valFormat?[kStepQuestionTextChoiceTextChoices] as? [JSONDictionary] ?? []
         
            
            for dict in textChoiceDict {
              let text = dict[kORKTextChoiceText] as? String ?? ""
              let value = dict[kORKTextChoiceValue] as? String ?? ""
              
              if valFinalRes == value {
                print("valuevaluevalue---\(value)---\(text)")
                return text
              }
            }
          
        }
        
        
       return valFinalRes
      }
    return valFinalRes
  }
  
  func getPickerValueFromValue(identifier: String, valFinalRes: String) -> String {
    let activity = Study.currentActivity
    let activityStepArray = activity?.activitySteps?.filter({$0.key == identifier
    })
      
      if (activityStepArray?.count)! > 0 {
          let step1 = activityStepArray?.first
        print("step1?.resultType---\(step1?.resultType)")
        let val1 = step1?.resultType as? String ?? ""
        
        //        var style = ""
//                var style = ((step1 as? ActivityQuestionStep)?.formatDict?["textChoices"] as? [String: String])!
                
//                let activityStep: ActivityStep?

        let valFormat = (step1 as? ActivityQuestionStep)?.formatDict
        
        if  Utilities.isValidObject(someObject: valFormat?[kStepQuestionTextChoiceTextChoices] as AnyObject?) {
            
//            let textChoiceDict = valFormat?[kStepQuestionTextChoiceTextChoices] as? [Any] ?? []
          let textChoiceDict = valFormat?[kStepQuestionTextChoiceTextChoices] as? [JSONDictionary] ?? []
         
            
            for dict in textChoiceDict {
              let text = dict[kORKTextChoiceText] as? String ?? ""
              let value = dict[kORKTextChoiceValue] as? String ?? ""
              
              if valFinalRes == value {
                print("valuevaluevalue---\(value)---\(text)")
                return text
              }
            }
          
        }
        
        
       return valFinalRes
      }
    return valFinalRes
  }
  
  func getTextChoicesSingleSelection(dataArray: [Any]) -> ([ORKTextChoice]?, OtherChoice?) {
    print("1getTextChoicesSingleSelection---")
    var textChoiceArray: [ORKTextChoice] = []
    var otherChoice: OtherChoice?
    
    if let dictArr = dataArray as? [JSONDictionary] {
      
      for dict in dictArr {
        
        let text = dict[kORKTextChoiceText] as? String ?? ""
        let value = dict[kORKTextChoiceValue] as? String ?? ""
        let detail = dict[kORKTextChoiceDetailText] as? String ?? ""
        let isExclusive = true
        
        if let otherDict = dict[kORKOTherChoice] as? JSONDictionary {
          
          let placeholder = otherDict["placeholder"] as? String ?? "enter here"
          let isMandatory = otherDict["isMandatory"] as? Bool ?? false
          let textFieldReq = otherDict["textfieldReq"] as? Bool ?? false
          
//          otherChoice = OtherChoice(
//            isShowOtherCell: true,
//            isShowOtherField: textFieldReq,
//            otherTitle: text,
//            placeholder: placeholder,
//            isMandatory: isMandatory,
//            isExclusive: isExclusive,
//            detailText: detail,
//            value: value
//          )
          // No need to add other text choice
          continue
        }
        
//        let choice = ORKTextChoice(
//          text: text,
//          detailText: detail,
//          value: value as NSCoding & NSCopying & NSObjectProtocol,
//          exclusive: isExclusive
//        )
//
//        textChoiceArray.append(choice)
        
      }
      
    } else if let titleArr = dataArray as? [String] {
      
      for (i, title) in titleArr.enumerated() {
        
        let choice = ORKTextChoice(
          text: title,
          value: i as NSCoding & NSCopying & NSObjectProtocol
        )
        
//        if self.textScaleDefaultValue?.isEmpty == false && self.textScaleDefaultValue != "" {
//          if title == self.textScaleDefaultValue {
//            self.textScaleDefaultIndex = i
//          }
//        }
//        textChoiceArray.append(choice)
      }
      
    }
    if textChoiceArray.isEmpty {
      return (nil, nil)
    } else {
      return (textChoiceArray, otherChoice)
    }
    
  }
  
  func getTextChoices(dataArray: [Any]) -> ([ORKTextChoice]?, OtherChoice?) {
      
      var textChoiceArray: [ORKTextChoice] = []
      var otherChoice: OtherChoice?
      
      if let dictArr = dataArray as? [JSONDictionary] {
          
          for dict in dictArr {
              
              let text = dict[kORKTextChoiceText] as? String ?? ""
              let value = dict[kORKTextChoiceValue] as? String ?? ""
              let detail = dict[kORKTextChoiceDetailText] as? String ?? ""
              let isExclusive = dict[kORKTextChoiceExclusive] as? Bool ?? false
              
              if let otherDict = dict[kORKOTherChoice] as? JSONDictionary {
                  
                  let placeholder = otherDict["placeholder"] as? String ?? kEnterHere
                  let isMandatory = otherDict["isMandatory"] as? Bool ?? false
                  let textFieldReq = otherDict["textfieldReq"] as? Bool ?? false
      
//                    otherChoice = OtherChoice(isShowOtherCell: true,
//                                              isShowOtherField: textFieldReq,
//                                              otherTitle: text,
//                                              placeholder: placeholder,
//                                              isMandatory: isMandatory,
//                                              isExclusive: isExclusive,
//                                              detailText: detail,
//                                              value: value)
//
//                    continue // No need to add other text choice
              }
              
//                let choice = ORKTextChoice(text: text ,
//                                           detailText: detail,
//                                           value: value as NSCoding & NSCopying & NSObjectProtocol,
//                                           exclusive: isExclusive)
//
//                textChoiceArray.append(choice)
              
          }
          
      } else if let titleArr = dataArray as? [String] {
          
          for (i, title) in titleArr.enumerated() {
              
              let choice = ORKTextChoice(text: title, value: i as NSCoding & NSCopying & NSObjectProtocol)
              
//                if self.textScaleDefaultValue?.isEmpty == false && self.textScaleDefaultValue != "" {
//                    if title == self.textScaleDefaultValue {
//                        self.textScaleDefaultIndex = i
//                    }
//                }
//                textChoiceArray.append(choice)
          }
          
      } else {
          Logger.sharedInstance.debug("dataArray has Invalid data: null for Text Choice ")
      }
      
        if textChoiceArray.isEmpty {
            return (nil, nil)
        } else {
            return (textChoiceArray, otherChoice)
        }
      
  }
  
  func setValue(questionstepResult: ORKQuestionResult) -> String {
      switch questionstepResult.questionType.rawValue {

      case  ORKQuestionType.scale.rawValue : // scale and continuos scale

          if (questionstepResult as? ORKScaleQuestionResult) != nil {
              let stepTypeResult = (questionstepResult as? ORKScaleQuestionResult)!
            print("1res---\(stepTypeResult.answer)---\(stepTypeResult.scaleAnswer)")
            if stepTypeResult.scaleAnswer != nil {
            return "\(stepTypeResult.scaleAnswer!)"
            }
             } else {
              let stepTypeResult = (questionstepResult as? ORKChoiceQuestionResult)!
//               print("2res---\(stepTypeResult.answer)---\(stepTypeResult.choiceAnswers)")
               if (stepTypeResult.choiceAnswers?.count) ?? 0 > 0 {
//                   self.value = stepTypeResult.choiceAnswers?.first
                 print("3res---\(stepTypeResult.choiceAnswers?.first)")
                 
//                 getActualAnswer(choiceSelected: "\(stepTypeResult.choiceAnswers!.first!)", identifierOfRes: <#T##String#>)
                 if stepTypeResult.choiceAnswers != nil {
                   
                   let val = getScaleValueFromValue(identifier: stepTypeResult.identifier, valFinalRes: "\(stepTypeResult.choiceAnswers!.first!)")
                   
                 return "\(val)" //check
                 }
               }
               
          }

      case ORKQuestionType.singleChoice.rawValue: // textchoice + value picker + imageChoice

          let stepTypeResult = (questionstepResult as? ORKChoiceQuestionResult)!
//          var resultType: String? = (self.step?.resultType as? String)!
        var resultType: String = getresultType(identifier: questionstepResult.identifier) //(self.step?.resultType as? String)!
        print("1resultTyperesultTyperesultType---\(resultType)")
          if Utilities.isValidObject(someObject: stepTypeResult.choiceAnswers as AnyObject?) {
            if (stepTypeResult.choiceAnswers?.count) ?? 0 > 0 {

                  if resultType ==  QuestionStepType.imageChoice.rawValue {

                      // for image choice and valuepicker

                      let resultValue: String! = "\(stepTypeResult.choiceAnswers!.first!)"

//                      self.value = (resultValue == nil ? "" : resultValue)
                    print("478res---\((resultValue == nil ? "" : resultValue))")
                    
                    return "\(resultValue == nil ? "" : resultValue ?? "")"
                  } else if resultType == QuestionStepType.valuePicker.rawValue {
                    
                    // for image choice and valuepicker

                    let resultValue: String! = "\(stepTypeResult.choiceAnswers!.first!)"

//                      self.value = (resultValue == nil ? "" : resultValue)
                  print("478res---\((resultValue == nil ? "" : resultValue))")
                    
                    
                    
                    let val = getPickerValueFromValue(identifier: stepTypeResult.identifier, valFinalRes: "\(stepTypeResult.choiceAnswers!.first!)")
                    
                  return "\(val)" //check
                    
                    
                  
                  return "\(resultValue == nil ? "" : resultValue ?? "")"
                } else {
                      // for text choice
                      var resultValue: [Any] = []
                      let selectedValue = stepTypeResult.choiceAnswers?.first

                      if let stringValue = selectedValue as? String {
                          resultValue.append(stringValue)
                      } else if let otherDict = selectedValue as? [String:Any] {
                        
                        let valOtherText = otherDict["text"]
//                          resultValue.append(otherDict)
                        
                        
                        let valOthertextString = otherDict["text"] as? String ?? ""
                        
                        if valOthertextString == "" {
                        
                        let valFinalText = getOtherTextValue(identifier: questionstepResult.identifier, valueStr: "\(valOtherText ?? "")")
                          resultValue.append(valFinalText)
                        } else {
                        resultValue.append(valOthertextString)
                        }
                      } else {
                          resultValue.append(selectedValue as Any)
                      }
                    print("5res---\(resultValue)")
                    let valFinalRes = resultValue.first as? String ?? ""
                    
                    
                    let val = getTextValueFromValue(identifier: stepTypeResult.identifier, valFinalRes: valFinalRes)
                    
//                    return "\(valFinalRes)" //check
                    return "\(val)" //check

//                      self.value = resultValue
                  }

              }
          }
//      case ORKQuestionType.multipleChoice.rawValue: // textchoice + imageChoice
//
//          let stepTypeResult = (questionstepResult as? ORKChoiceQuestionResult)!
//
//          if let answers = stepTypeResult.choiceAnswers {
//
//              var resultArray: [Any] = []
//
//              for value in answers {
//
//                  if let stringValue = value as? String {
//                      resultArray.append(stringValue)
//                  } else if let otherDict = value as? [String:Any] {
//                      resultArray.append(otherDict)
//                  } else {
//                      resultArray.append(value)
//                  }
//
//              }
//              self.value = resultArray
//
//          } else {
//              // self.value = []
//              self.skipped = true
//          }
//
//          /*
//          if Utilities.isValidObject(someObject: stepTypeResult.choiceAnswers as AnyObject?) {
//              if (stepTypeResult.choiceAnswers?.count)! > 1 {
//
//
//
//              } else {
//
//                  let resultValue: String! = "\(stepTypeResult.choiceAnswers!.first!)"
//                  let resultArray: Array<String>? = ["\(resultValue == nil ? "" : resultValue!)"]
//                  self.value = resultArray
//              }
//
//          } else {
//              self.value = []
//          }
//           */
        
      case ORKQuestionType.boolean.rawValue:

          let stepTypeResult = (questionstepResult as? ORKBooleanQuestionResult)!

//          if Utilities.isValidValue(someObject: stepTypeResult.booleanAnswer as AnyObject?) {
              let value = stepTypeResult.booleanAnswer ?? false == 1 ? "True" : "False"
            return value
        
//
//      case ORKQuestionType.boolean.rawValue:
//
//          let stepTypeResult = (questionstepResult as? ORKBooleanQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.booleanAnswer as AnyObject?) {
//              self.value =  stepTypeResult.booleanAnswer! == 1 ? true : false
//
//          } else {
//              // self.value = false
//              self.skipped = true
//          }
//
        
      case ORKQuestionType.integer.rawValue: // numeric type
          let stepTypeResult = (questionstepResult as? ORKNumericQuestionResult)!
      if let val = stepTypeResult.numericAnswer {
            let value = Double(truncating:stepTypeResult.numericAnswer!)
            return "\(value)"
      }
        
//      case ORKQuestionType.integer.rawValue: // numeric type
//          let stepTypeResult = (questionstepResult as? ORKNumericQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.numericAnswer as AnyObject?) {
//              self.value =  Double(truncating:stepTypeResult.numericAnswer!)
//
//          } else {
//              // self.value = 0.0
//              self.skipped = true
//          }
//
        
      case ORKQuestionType.decimal.rawValue: // numeric type
          let stepTypeResult = (questionstepResult as? ORKNumericQuestionResult)!
      if let val = stepTypeResult.numericAnswer {
            let value = Double(truncating:stepTypeResult.numericAnswer!)
            return "\(value)"
      }
        
//      case ORKQuestionType.decimal.rawValue: // numeric type
//          let stepTypeResult = (questionstepResult as? ORKNumericQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.numericAnswer as AnyObject?) {
//              self.value = Double(truncating:stepTypeResult.numericAnswer!)
//
//          } else {
//              // self.value = 0.0
//              self.skipped = true
//          }
//
//      case  ORKQuestionType.timeOfDay.rawValue:
//          let stepTypeResult = (questionstepResult as? ORKTimeOfDayQuestionResult)!
//
//          if stepTypeResult.dateComponentsAnswer != nil {
//
//              let hour: Int? = (stepTypeResult.dateComponentsAnswer?.hour == nil ? 0 : stepTypeResult.dateComponentsAnswer?.hour)
//              let minute: Int? = (stepTypeResult.dateComponentsAnswer?.minute == nil ? 0 : stepTypeResult.dateComponentsAnswer?.minute)
//              let seconds: Int? = (stepTypeResult.dateComponentsAnswer?.second == nil ? 0 : stepTypeResult.dateComponentsAnswer?.second)
//
//              self.value = (( hour! < 10 ? ("0" + "\(hour!)") : "\(hour!)") + ":" + ( minute! < 10 ? ("0" + "\(minute!)") : "\(minute!)") + ":" + ( seconds! < 10 ? ("0" + "\(seconds!)") : "\(seconds!)"))
//
//          } else {
//              // self.value = "00:00:00"
//              self.skipped = true
//          }
//
//      case ORKQuestionType.date.rawValue:
//          let stepTypeResult = (questionstepResult as? ORKDateQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.dateAnswer as AnyObject?) {
//              self.value =  Utilities.getStringFromDate(date: stepTypeResult.dateAnswer!)
//          } else {
//              // self.value = "0000-00-00'T'00:00:00"
//              self.skipped = true
//          }
//      case ORKQuestionType.dateAndTime.rawValue:
//          let stepTypeResult = (questionstepResult as? ORKDateQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.dateAnswer as AnyObject?) {
//              self.value =  Utilities.getStringFromDate(date: stepTypeResult.dateAnswer! )
//
//          } else {
//              // self.value = "0000-00-00'T'00:00:00"
//              self.skipped = true
//          }
        
      case ORKQuestionType.text.rawValue: // text + email

          let stepTypeResult = (questionstepResult as? ORKTextQuestionResult)!

        if let value = (stepTypeResult.answer as? String) {
            return "\(value)"
        }
        
//      case ORKQuestionType.text.rawValue: // text + email
//
//          let stepTypeResult = (questionstepResult as? ORKTextQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.answer as AnyObject?) {
//              self.value = (stepTypeResult.answer as? String)!
//
//          } else {
//              // self.value = ""
//              self.skipped = true
//          }
//
//      case ORKQuestionType.timeInterval.rawValue:
//
//          let stepTypeResult = (questionstepResult as? ORKTimeIntervalQuestionResult)!
//
//          if Utilities.isValidValue(someObject: stepTypeResult.intervalAnswer as AnyObject?) {
//              self.value = Double(truncating:stepTypeResult.intervalAnswer!)/3600
//
//          } else {
//              // self.value = 0.0
//              self.skipped = true
//          }
//
      case ORKQuestionType.height.rawValue:

          let stepTypeResult = (questionstepResult as? ORKNumericQuestionResult)!
            let value = Double(truncating:stepTypeResult.numericAnswer!)
            return "\(value)"
//
//      case ORKQuestionType.location.rawValue:
//          let stepTypeResult = (questionstepResult as? ORKLocationQuestionResult)!
//          /*
//          if stepTypeResult.locationAnswer != nil && CLLocationCoordinate2DIsValid((stepTypeResult.locationAnswer?.coordinate)!) {
//
//              let lat = stepTypeResult.locationAnswer?.coordinate.latitude
//              let long = stepTypeResult.locationAnswer?.coordinate.longitude
//
//              self.value = "\(lat!)" + "," + "\(long!)"
//
//          } else {
//              self.value = "0.0,0.0"
//          }*/
//          if let locationAnswer = stepTypeResult.locationAnswer {
//              if CLLocationCoordinate2DIsValid(locationAnswer.coordinate) {
//                  let lat = locationAnswer.coordinate.latitude
//                  let long = locationAnswer.coordinate.longitude
//                  self.value = "\(lat)" + "," + "\(long)"
//              } else {
//                  self.value = "0.0,0.0"
//              }
//          } else {
//              self.skipped = true
//          }
      default:break
      }
    return ""
  }
  
  func getOtherTextValue(identifier: String, valueStr: String) -> String {
    let activityCu = Study.currentActivity
    var valPiping = false
    var pipingSnippet = ""
    var pipingsourceQuestionKey = ""
    var pipingactivityid = ""
    
    let valMandatory = false
    
    if (activityCu?.activitySteps?.count )! > 0 {
        
        let activityStepArray = activityCu?.activitySteps?.filter({$0.key == identifier
        })
        if (activityStepArray?.count)! > 0 {
          valPiping = activityStepArray?.last?.isPiping ?? false
          pipingSnippet = activityStepArray?.last?.pipingSnippet ?? ""
          pipingsourceQuestionKey = activityStepArray?.last?.pipingsourceQuestionKey ?? ""
          pipingactivityid = activityStepArray?.last?.pipingactivityid ?? ""
          
          
          
          
          let step1 = activityStepArray?.first
          let valFormat = (step1 as? ActivityQuestionStep)?.formatDict
          
          if  Utilities.isValidObject(someObject: valFormat?[kStepQuestionTextChoiceTextChoices] as AnyObject?)
              && Utilities.isValidValue(someObject: valFormat?[kStepQuestionTextChoiceSelectionStyle] as AnyObject?) {
              
  //            let textChoiceDict = valFormat?[kStepQuestionTextChoiceTextChoices] as? [Any] ?? []
            let textChoiceDict = valFormat?[kStepQuestionTextChoiceTextChoices] as? [JSONDictionary] ?? []
           
              
              for dict in textChoiceDict {
                let text = dict[kORKTextChoiceText] as? String ?? ""
                let value = dict[kORKTextChoiceValue] as? String ?? ""
                
                let other = dict["other"] as? [String: Any] ?? [:]
                
                if other.count > 0 {
                  print("valuevaluevalue---\(value)---\(text)")
                  
                  let valMandatory = other["isMandatory"] as? Bool ?? false
                  
                  if !valMandatory {
                    let valOthertext = dict["text"] as? String ?? valueStr
                    return valOthertext
                  }
//                  return text
                }
              }
            
          }
          
          
        }
    }
    
    return valueStr
  }
  
  func getActualAnswer(choiceSelected : String, identifierOfRes: String) {
    let activityCu = Study.currentActivity
//    let activityself  =

    if (activityCu?.activitySteps?.count )! > 0 {
              
              let activityStepArray = activityCu?.activitySteps?.filter({$0.key == identifierOfRes
              })
//              if (activityStepArray?.count)! > 0 {
//                var formatDict: Dictionary<String, Any>?
//                if Utilities.isValidObject(someObject: stepDict[kStepQuestionFormat] as AnyObject ) {
//                    self.formatDict = (stepDict[kStepQuestionFormat] as? Dictionary)!
//                }
//
//
//
//
//                valPiping = activityStepArray?.last?.isPiping ?? false
//                pipingSnippet = activityStepArray?.last?.pipingSnippet ?? ""
//                pipingsourceQuestionKey = activityStepArray?.last?.pipingsourceQuestionKey ?? ""
//              }
          }
    
    
  }
    
  //rinuthaa
  @objc func dismisscontroller() {
      dismiss(animated: true, completion: nil)
  }
  //rinuthab
  
    // MARK: - StepViewController Delegate
    public func stepViewController(_ stepViewController: ORKStepViewController,
                                   didFinishWith direction: ORKStepViewControllerNavigationDirection){
        
    }
    
    public func stepViewControllerResultDidChange(_ stepViewController: ORKStepViewController){
        
    }
    
    public func stepViewControllerDidFail(_ stepViewController: ORKStepViewController, withError error: Error?){
        
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
//      taskViewController.currentStepViewController
      
        if let result = taskViewController.result.stepResult(forStepIdentifier: step.identifier) {
            self.managedResult[step.identifier] = result
        }
//      step.title = "GGG"
//      step.text = "GGG"
//      step
      
//      //rinuthaa
//      //Perform dismiss task here :
//           if let result = taskViewController.result.stepResult(forStepIdentifier: "textscale") {
//
//               self.isActivityDismissed = true
//               self.managedResult["textscale"] = result
//               self.updateActivityStatusToComplete()
//
//   //            if isActivityDismissed {
//   ////                self.addProgressIndicator()
//   //
//   //            }
//
//               UserDefaults.standard.setValue("Responce_Types", forKey: "activityId")
//
//               UserDefaults.standard.setValue("textscale", forKey: "identifier")
//
//               //dismiss
//               perform(#selector(dismisscontroller), with: self, afterDelay: 1.5)
//
//           }
//
//           //Going to next activity's particular step
//           if isActivityDismissed {
//               print("Came to next activity")
//           }
//      //rinuthab
      
      
      
     
      let activityCu = Study.currentActivity
      var valPiping = false
      var pipingSnippet = ""
      var pipingsourceQuestionKey = ""
      var pipingactivityid = ""
      if (activityCu?.activitySteps?.count )! > 0 {
          
          let activityStepArray = activityCu?.activitySteps?.filter({$0.key == step.identifier
          })
          if (activityStepArray?.count)! > 0 {
            valPiping = activityStepArray?.last?.isPiping ?? false
            pipingSnippet = activityStepArray?.last?.pipingSnippet ?? ""
            pipingsourceQuestionKey = activityStepArray?.last?.pipingsourceQuestionKey ?? ""
            pipingactivityid = activityStepArray?.last?.pipingactivityid ?? ""
          }
      }
      print("valPiping---\(valPiping)---\(pipingSnippet)---\(pipingsourceQuestionKey)---\(step.identifier)---\(pipingactivityid)")
      if let step1 = step as? ORKQuestionStep {
        
//        if valPiping, pipingSnippet != "",  pipingsourceQuestionKey != "" {
        
        
        //other ActivityPiping
        if pipingSnippet != "", pipingactivityid != "", pipingsourceQuestionKey != "" {// same to Instructio-
          
          let valName = "\(valPipingValuesMain[pipingsourceQuestionKey] ?? "")"
          
          var orignalVal1 = step1.question ?? ""
          let activityStepArray = activityCu?.activitySteps?.filter({$0.key == step.identifier })
          // replaced originalVal with this ---> activityStepArray?.last?.title
          if valName != "", valName != "<null>" {
          let changedText2 = activityStepArray?.last?.title?.replacingOccurrences(of: pipingSnippet, with: valName)
          print("1orignalVal---\(orignalVal1)----\(changedText2)")
          
          
          
          let changedText = orignalVal1.replacingOccurrences(of: pipingSnippet, with: valName)
          print("2orignalVal---\(orignalVal1)")
          step1.question = changedText2// "GGG2"
          if !(step1.question != nil && step1.question != "") {
            
          }
          }
        }
        
        
          
         else if let result = taskViewController.result.stepResult(forStepIdentifier: pipingsourceQuestionKey) {
            
           let valName = self.setResultValue(stepResult: result, activityType: .Questionnaire )
            
                      print("SORTED STEP RESULT -- \(result)")
                      print("SORTED STEP RESULT ANSWER -- \((result as? ORKScaleQuestionResult)?.answer)")
            var orignalVal = step1.question ?? ""
            if valName != "", pipingSnippet != "", valName != "<null>" {
              let activityStepArray = activityCu?.activitySteps?.filter({$0.key == step.identifier })
              // replaced originalVal with this ---> activityStepArray?.last?.title
              let changedText2 = activityStepArray?.last?.title?.replacingOccurrences(of: pipingSnippet, with: valName)
              print("1orignalVal---\(orignalVal)----\(changedText2)")
              
              
              
              let changedText = orignalVal.replacingOccurrences(of: pipingSnippet, with: valName)
              print("2orignalVal---\(orignalVal)")
              step1.question = changedText2// "GGG2"
              if !(step1.question != nil && step1.question != "") {
                
              }
            }
           
           else if (valName == "" || valName == "<null>"), pipingSnippet != "" {//Skipped sce
             let activityStepArray = activityCu?.activitySteps?.filter({$0.key == step.identifier })
             // replaced originalVal with this ---> activityStepArray?.last?.title
             let changedText2 = activityStepArray?.last?.title
             print("1orignalVal---\(orignalVal)----\(changedText2)")
             step1.question = changedText2// "GGG2"
           }
           
      
           
           
           
                    }
          
          
//        step1.question = "GGG2"
//        }
        print("step1.question---\(step1.question)")
//        taskViewController.currentStepViewController = step1
//        step = step1
        
        
        
      } else if let step1 = step as? ORKInstructionStep {
        
        
        //other ActivityPiping
        if pipingSnippet != "", pipingactivityid != "", pipingsourceQuestionKey != "" {// same to Instructio-
          
          let valName = "\(valPipingValuesMain[pipingsourceQuestionKey] ?? "")"
          
          var orignalVal = step1.title ?? ""
          if valName != "", pipingSnippet != "", valName != "<null>" {
            let activityStepArray = activityCu?.activitySteps?.filter({$0.key == step.identifier })
            // replaced originalVal with this ---> activityStepArray?.last?.title
            let changedText2 = activityStepArray?.last?.title?.replacingOccurrences(of: pipingSnippet, with: valName)
            print("1orignalVal---\(orignalVal)----\(changedText2)")
            
            
            
            let changedText = orignalVal.replacingOccurrences(of: pipingSnippet, with: valName)
            print("2orignalVal---\(orignalVal)")
            step1.title = changedText2// "GGG2"
            if !(step1.title != nil && step1.title != "") {
              
            }
          }
        }
        
        
        
        
       else if let result = taskViewController.result.stepResult(forStepIdentifier: pipingsourceQuestionKey) {
          
          let valName = self.setResultValue(stepResult: result, activityType: .Questionnaire )
          
          print("SORTED STEP RESULT -- \(result)")
          print("SORTED STEP RESULT ANSWER -- \((result as? ORKScaleQuestionResult)?.answer)")
          var orignalVal = step1.title ?? ""
          if valName != "", pipingSnippet != "", valName != "<null>" {
            let activityStepArray = activityCu?.activitySteps?.filter({$0.key == step.identifier })
            // replaced originalVal with this ---> activityStepArray?.last?.title
            let changedText2 = activityStepArray?.last?.title?.replacingOccurrences(of: pipingSnippet, with: valName)
            print("1orignalVal---\(orignalVal)----\(changedText2)")
            
            
            
            let changedText = orignalVal.replacingOccurrences(of: pipingSnippet, with: valName)
            print("2orignalVal---\(orignalVal)")
            step1.title = changedText2// "GGG2"
            if !(step1.title != nil && step1.title != "") {
              
            }
          }
        }
        
        
        //        step1.question = "GGG2"
        //        }
        print("step1.question---\(step1.text)")
        //        taskViewController.currentStepViewController = step1
        //        step = step1
        
        
        
      }
        if let step = step as? QuestionStep, step.answerFormat?.isKind(of: ORKTextChoiceAnswerFormat.self) ?? false {
          
          let valStep = step
          if valStep.isOptional {
            UserDefaults.standard.set("true", forKey: "isOptionalTextChoice")
            UserDefaults.standard.synchronize()
          } else {
            UserDefaults.standard.set("false", forKey: "isOptionalTextChoice")
            UserDefaults.standard.synchronize()
          }
          
          if let result = taskViewController.result.stepResult(forStepIdentifier: step.identifier) {
            self.managedResult[step.identifier] = result
          }
          
            var textChoiceQuestionController :TextChoiceQuestionController
            
            var result = taskViewController.result.result(forIdentifier: step.identifier)
            result = ( result == nil ) ? self.managedResult[step.identifier] as? ORKStepResult : result
            
            if let result = result  {
                textChoiceQuestionController = TextChoiceQuestionController(step: step, result: result)
            } else {
                textChoiceQuestionController = TextChoiceQuestionController(step: step)
            }
                     
            return textChoiceQuestionController
        }
      
      UserDefaults.standard.set("", forKey: "isOptionalTextChoice")
      UserDefaults.standard.synchronize()
      if let step = step as? CustomInstructionStep {
        return CustomInstructionStepViewController(step: step)
      }

      let storyboard = UIStoryboard.init(name: "FetalKickCounter", bundle: nil)
        
      if step is FetalKickCounterStep {
        
        let ttController =
        (storyboard.instantiateViewController(
          withIdentifier: "FetalKickCounterStepViewController"
        )
         as? FetalKickCounterStepViewController)!
        ttController.step = step
        return ttController
      } else if step is FetalKickIntroStep {
        
        let ttController =
        (storyboard.instantiateViewController(
          withIdentifier: "FetalKickIntroStepViewControllerIdentifier"
        )
         as? FetalKickIntroStepViewController)!
        ttController.step = step
        return ttController
      } else {
        return nil
      }
      
    }
    
  func taskViewController(_ taskViewController: ORKTaskViewController, didChange result: ORKTaskResult) {
    
    // Saving the TextChoiceQuestionController result to publish it later.
    if taskViewController.currentStepViewController?.isKind(
      of: TextChoiceQuestionController.self
    )
        ?? false
    {
      if let result = result.stepResult(
        forStepIdentifier: taskViewController.currentStepViewController?.step?.identifier
        ?? ""
      ) {
        self.managedResult[result.identifier] = result
      }
    }
  }
  
  func taskViewController(_ taskViewController: ORKTaskViewController, shouldPresent step: ORKStep) -> Bool {
    return true
  }
  
}

extension ActivitiesViewController:UITabBarControllerDelegate{
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
                
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 {
            // do your stuff
            // self.checkForActivitiesUpdates()
        }
    }
  
  
  func setActivityMetaData(activityDict: Dictionary<String, Any>) {
      
      if Utilities.isValidObject(someObject: activityDict as AnyObject?) {
          
          if Utilities.isValidValue(someObject: activityDict[kActivityType] as AnyObject ) {
//              self.type? =  ActivityType(rawValue: (activityDict[kActivityType] as? String)!)!
             
          }
        
//        let valActivityResp = response[kActivity] as! Dictionary<String, Any>
        
         let valActivityData = self.setInfo(infoDict: (activityDict[kActivityInfoMetaData] as? Dictionary<String, Any>)!)
          
//          if Utilities.isValidObject(someObject: activityDict[kActivitySteps] as AnyObject?) {
        
        
//               self.setStepArray(stepArray: (activityDict[kActivitySteps] as? Array)! )
              
        
        
        let valactivity1 = activityDict["steps"] as? Array<Dictionary<String, Any>>
//        let valactivity2 = valactivity1["steps"] as? Array)!
        
        self.setStepArray(stepArray: (valactivity1)!, valActivityData: valActivityData )
        
        
//          } else {
//
//          }
      } else {
          
      }
  }
  
//  func createTask(varActivityType: ActivityType?) -> ORKTask? {
//
//      if  (varActivityType) != nil {
//
//          var orkStepArray: [ORKStep]?
//
//          orkStepArray = Array<ORKStep>()
//
//          var activityStepArray: [ActivityStep]? = Array<ActivityStep>()
//
//        switch (varActivityType!) as ActivityType {
//
//          // MARK: Questionnaire
//          case .Questionnaire:
//
//              // creating step array
//
//              for stepDict in (activity?.steps!)! {
//
//                  if Utilities.isValidObject(someObject: stepDict as AnyObject?) {
//
//                      if Utilities.isValidValue(someObject: stepDict[kActivityStepType] as AnyObject ) {
//
//                          switch ActivityStepType(rawValue:(stepDict[kActivityStepType] as? String)!)! as  ActivityStepType {
//
//                          case .instruction:
//
//                              let instructionStep: ActivityInstructionStep? = ActivityInstructionStep()
//                            instructionStep?.initWithDict(stepDict: stepDict, allSteps: (activity?.steps!)!)
//                              orkStepArray?.append((instructionStep?.getInstructionStep())!)
//                              activityStepArray?.append(instructionStep!)
//
//                          case .question:
//
//                              let questionStep: ActivityQuestionStep? = ActivityQuestionStep()
//                            questionStep?.initWithDict(stepDict: stepDict, allSteps: (activity?.steps!)!)
//
//                              if let step = (questionStep?.getQuestionStep()) {
//
//                                  orkStepArray?.append(step)
//                                  activityStepArray?.append(questionStep!)
//                              }
//                          case .form:
//
//                              let formStep: ActivityFormStep? = ActivityFormStep()
//                            formStep?.initWithDict(stepDict: stepDict, allSteps: (activity?.steps!)!)
//                              orkStepArray?.append((formStep?.getFormStep())!)
//                              activityStepArray?.append(formStep!)
//
//                          default: break
//                          }
//                      }
//                  } else {
//                      Logger.sharedInstance.debug("Activity:stepDict is null:\(stepDict)")
//                      break
//                  }
//              }
//
//              if (orkStepArray?.count)! > 0 {
//
//                  self.activity?.setORKSteps(orkStepArray: orkStepArray!)
//                  self.activity?.setActivityStepArray(stepArray: activityStepArray!)
//
//                  // addding completion step
//                  let completionStep = ORKCompletionStep(identifier: kCompletionStep)
//                  let kActivityCompleted = NSLocalizedStrings("Activity Completed", comment: "")
//                  let msg = "Tap Done to submit responses. Responses cannot be modified after submission"
//                  let kTapDoneSubmit = NSLocalizedStrings(msg, comment: "")
//                  completionStep.title = kActivityCompleted
//                  completionStep.image = #imageLiteral(resourceName: "successBlueBig")
//                  completionStep.detailText = kTapDoneSubmit
//                completionStep.steppreisHidden = "false"
//                  orkStepArray?.append(completionStep)
//
//                  // Creating ordered or navigable task
//                  if (orkStepArray?.count)! > 0 {
//
//                      task =  ORKOrderedTask(identifier: (activity?.actvityId!)!, steps: orkStepArray)
//
//                      if self.activity?.branching == true { // For Branching/Navigable Task
//                          task =  ORKNavigableOrderedTask(identifier: (activity?.actvityId)!, steps: orkStepArray)
//
//                      } else { // For OrderedTask
//                          task =  ORKOrderedTask(identifier: (activity?.actvityId)!, steps: orkStepArray)
//                      }
//                  }
//                  var i: Int? = 0
//
//                  if self.activity?.branching == true {
//
//                      for step in orkStepArray! {
//                          // Setting ActivityStep
//                          if step.isKind(of: ORKQuestionStep.self) ||
//                              step is RepeatableFormStep ||
//                              step is ORKFormStep ||
//                              (step.isKind(of: ORKInstructionStep.self) &&
//                                  step.isKind(of: ORKCompletionStep.self) == false) {
//
//                              let activityStep: ActivityStep?
//
//                              if step.isKind(of: ORKQuestionStep.self) ||
//                                  (step.isKind(of: ORKInstructionStep.self) == false &&
//                                   step.isKind(of: ORKCompletionStep.self) == false) {
//                                  activityStep = activityStepArray?[(i!)] as?  ActivityQuestionStep
//
//                              } else if step.isKind(of: ORKFormStep.self) || step.isKind(of: RepeatableFormStep.self) {
//                                  activityStep = activityStepArray?[(i!)] as?  ActivityFormStep
//
//                              } else {
//                                  activityStep = activityStepArray?[(i!)] as?  ActivityInstructionStep
//                              }
//
//                              if activityStep?.destinations != nil && (activityStep?.destinations?.count)! > 0 {
//
//                                  var defaultStepIdentifier: String = ""
//
//                                  // Setting Next Step as Default destination
//                                  if i! + 1 < (activityStepArray?.count)! {
//                                      defaultStepIdentifier = (activityStepArray?[(i!+1)].key)!
//
//                                  } else { // Setting Completion Step as Default destination
//                                      defaultStepIdentifier = kCompletionStep
//                                  }
//
//                                  var defaultStepExist: Bool? = false
//                                  let resultSelector: ORKResultSelector?
//                                  var predicateRule: ORKPredicateStepNavigationRule?
//
//                                  // Creating Result Selector
//                                  resultSelector =  ORKResultSelector(stepIdentifier: step.identifier, resultIdentifier: step.identifier)
//                                  let questionStep: ORKStep?
//
//                                  // Intializing Question Step
//                                  if step.isKind(of: ORKQuestionStep.self) {
//                                      questionStep = (step as? ORKQuestionStep)!
//
//                                  } else if step is RepeatableFormStep {
//                                      questionStep = (step as? RepeatableFormStep)!
//
//                                  } else if step is ORKFormStep {
//                                      questionStep = (step as? ORKFormStep)!
//
//                                  } else {
//                                      questionStep = (step as? ORKInstructionStep)!
//                                  }
//
//                                  // choicearray and destination array will hold predicates & their respective destination
//                                  var choicePredicate: [NSPredicate] = [NSPredicate]()
//                                  var destination: Array<String>? = Array<String>()
//
//                                  for dict in (activityStep?.destinations)! {
//
//                                      var predicateQuestionChoiceA: NSPredicate = NSPredicate()
//
//                                      // Condition is not nil
//                                      if Utilities.isValidValue(someObject: dict[kCondtion] as AnyObject) {
//
//                                          switch (questionStep as? ORKQuestionStep)!.answerFormat {
//
//                                          case is ORKTextChoiceAnswerFormat,
//                                               is ORKTextScaleAnswerFormat,
//                                               is ORKImageChoiceAnswerFormat,
//                                               is ORKValuePickerAnswerFormat:
//
//                                              predicateQuestionChoiceA = ORKResultPredicate.predicateForChoiceQuestionResult(
//                                                  with: resultSelector!,
//                                                  expectedAnswerValue: dict[kCondtion] as! NSCoding & NSCopying & NSObjectProtocol)
//
//                                              choicePredicate.append(predicateQuestionChoiceA)
//
//                                              if dict[kCondtion] != nil &&
//                                                  dict[kDestination] != nil &&
//                                                  (dict[kDestination] as? String)! == "" {
//                                                  // this means c = value & d = ""
//                                                  destination?.append( kCompletionStep )
//
//                                              } else {
//                                                  // this means c = value && d =  value
//                                                  destination?.append( (dict[kDestination]! as? String)!)
//                                              }
//
//                                          case is ORKNumericAnswerFormat ,
//                                               is ORKScaleAnswerFormat,
//                                               is ORKTimeIntervalAnswerFormat,
//                                               is ORKHeightAnswerFormat,
//                                               is ORKContinuousScaleAnswerFormat,
//                                               is ORKHealthKitQuantityTypeAnswerFormat:
//
//                                              if let operatorValue = dict[kOperator] as? String, operatorValue != "" {
//
//                                                  let condition: String = (dict[kCondtion] as? String)!
//                                                  let conditionValue = condition.components(separatedBy: CharacterSet(charactersIn: ","))
//
//                                                  var lhs: Double? = 0.0
//                                                  var rhs: Double? = 0.0
//
//                                                  lhs = Double(conditionValue.first!)
//                                                  if conditionValue.count == 2 { // multiple conditions exists
//                                                      rhs = Double(conditionValue.last!)
//                                                  }
//                                                  let operatorType:OperatorType = OperatorType(rawValue: operatorValue)!
//
//                                                  switch (questionStep as? ORKQuestionStep)!.answerFormat {
//                                                  case is ORKNumericAnswerFormat,
//                                                       is ORKHeightAnswerFormat,
//                                                       is ORKHealthKitQuantityTypeAnswerFormat: // Height & Numeric Question
//
//                                                      var minimumValue = (activityStep
//                                                                          as? ActivityQuestionStep)!.formatDict![kMinimumValue]
//                                                      as? Float
//
//                                                      var style = ""
//
//                                                      if (questionStep as? ORKQuestionStep)!.answerFormat! is ORKHeightAnswerFormat {
//                                                          minimumValue = 0
//                                                      } else {
//                                                          style = ((activityStep
//                                                                    as? ActivityQuestionStep)?.formatDict?[kStepQuestionNumericStyle]
//                                                                   as? String)!
//                                                      }
//
//                                                      predicateQuestionChoiceA = self.getPredicateForNumeric(
//                                                          resultSelector: resultSelector!,
//                                                          lhs: lhs!,
//                                                          minimumValue: minimumValue!,
//                                                          operatorType: operatorType,
//                                                          answerFormat: (questionStep as? ORKQuestionStep)!.answerFormat!,
//                                                          style: style)
//
//                                                  case is ORKTimeIntervalAnswerFormat: // TimeInterval
//
//                                                      predicateQuestionChoiceA = self.getPredicateForTimeInterval(
//                                                          resultSelector: resultSelector!,
//                                                          lhs: lhs!,
//                                                          minimumValue: 0.0,
//                                                          operatorType: operatorType)
//
//                                                  case is ORKScaleAnswerFormat, is ORKContinuousScaleAnswerFormat: // Scale & Continuos Scale
//
//                                                      let minimumValue = (activityStep
//                                                                          as? ActivityQuestionStep)!.formatDict![kMinimumValue] as? Float
//
//                                                      predicateQuestionChoiceA = self.getPredicateForScale(resultSelector: resultSelector!,
//                                                                                       lhs: lhs!, minimumValue: minimumValue!,
//                                                                                       operatorType: operatorType,
//                                                                                       rhs: rhs!,
//                                                                                       resultType: ((questionStep as?
//                                                                                                      ORKQuestionStep)!.answerFormat)!,
//                                                                                       activityStep:activityStep!)
//
//                                                  case .none: break
//
//                                                  case .some(_): break
//
//                                                  }
//                                                  choicePredicate.append(predicateQuestionChoiceA)
//
//                                                  if dict[kCondtion] != nil &&
//                                                      dict[kDestination] != nil &&
//                                                      (dict[kDestination] as? String)! == "" {
//                                                      // this means c = value & d = ""
//                                                      destination?.append( kCompletionStep )
//
//                                                  } else {
//                                                      // this means c = value && d =  value
//                                                      destination?.append( (dict[kDestination]! as? String)!)
//                                                  }
//                                              } else {
//                                              }
//
//                                          case is ORKBooleanAnswerFormat :
//
//                                              var boolValue: Bool? = false
//
//                                              if (dict[kCondtion] as? String)!.caseInsensitiveCompare("true") ==  ComparisonResult.orderedSame {
//                                                  boolValue = true
//
//                                              } else {
//                                                  if (dict[kCondtion] as? String)!.caseInsensitiveCompare("false")==ComparisonResult.orderedSame {
//                                                      boolValue = false
//
//                                                  } else if (dict[kCondtion] as? String)! == "" {
//                                                      boolValue = nil
//                                                      if Utilities.isValidValue(someObject: dict[kDestination] as AnyObject? ) {
//
//                                                          defaultStepIdentifier = (dict[kDestination]! as? String)!
//                                                      }
//                                                  }
//                                              }
//
//                                              if  boolValue != nil {
//
//                                                  predicateQuestionChoiceA =
//                                                      ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector!,
//                                                                                                      expectedAnswer: boolValue!)
//                                              }
//                                              choicePredicate.append(predicateQuestionChoiceA)
//
//                                              if dict[kCondtion] != nil &&
//                                                  dict[kDestination] != nil &&
//                                                  (dict[kDestination] as? String)! == "" {
//                                                  // this means c = value & d = ""
//                                                  destination?.append( kCompletionStep )
//
//                                              } else {
//                                                  // this means c = value && d =  value
//                                                  destination?.append( (dict[kDestination]! as? String)!)
//                                              }
//                                          default: break
//                                          }
//                                      } else {
//                                          // it means condition is empty
//                                          if dict[kCondtion] != nil && (dict[kCondtion] as? String)! == "" {
//
//                                              defaultStepExist = true
//                                              if Utilities.isValidValue(someObject: dict[kDestination] as AnyObject? ) {
//                                                  // means we ahave valid destination
//                                                  defaultStepIdentifier = (dict[kDestination]! as? String)!
//
//                                              } else {
//                                                  // invalid destination i.e condition = "" && destination = ""
//                                                  defaultStepIdentifier = kCompletionStep
//                                              }
//                                          }
//                                      }
//                                  }
//                                  if choicePredicate.count == 0 {
//
//                                      // if condition is empty
//
//                                      if (destination?.count)! > 0 {
//
//                                          // if destination is not empty but condition is empty
//
//                                          for destinationId in destination! {
//
//                                              if destinationId.count != 0 {
//
//                                                  let  directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: destinationId)
//
//                                                  (task as? ORKNavigableOrderedTask)!.setNavigationRule(directRule,
//                                                                                                        forTriggerStepIdentifier: step.identifier)
//                                              }
//                                          }
//                                      } else {
//                                          // if both destination and condition are empty
//                                          let  directRule: ORKDirectStepNavigationRule!
//
//                                          if defaultStepExist == false {
//                                              directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: kCompletionStep)
//                                          } else {
//                                              directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: defaultStepIdentifier)
//                                          }
//
//                                          (task as? ORKNavigableOrderedTask)!.setNavigationRule(directRule!,
//                                                                                                forTriggerStepIdentifier:step.identifier)
//                                      }
//                                  } else {
//
//                                      predicateRule = ORKPredicateStepNavigationRule(resultPredicates: choicePredicate,
//                                                                                     destinationStepIdentifiers: destination!,
//                                                                                     defaultStepIdentifier: defaultStepIdentifier,
//                                                                                     validateArrays: true)
//
//                                      (task as? ORKNavigableOrderedTask)!.setNavigationRule(predicateRule!,
//                                                                                            forTriggerStepIdentifier:step.identifier)
//                                  }
//                              } else {
//                                  // destination array is empty - Do Nothing
//                              }
//                          } else {
//                              // this is not question step
//                          }
//                          i = i! + 1
//                      }
//                  }
//                  if task != nil {
//
//                      if (self.activity?.branching)! {
//                          return (task as? ORKNavigableOrderedTask)!
//                      } else {
//                          return (task as? ORKOrderedTask)!
//                      }
//                  } else {
//                      return nil
//                  }
//              }
//          // MARK: Active Task
//          case .activeTask:
//
//              for stepDict in (activity?.steps!)! {
//
//                  if Utilities.isValidObject(someObject: stepDict as AnyObject?) {
//
//                      if Utilities.isValidValue(someObject: stepDict[kActivityStepType] as AnyObject ) {
//
//                          switch ActivityStepType(rawValue: (stepDict[kActivityStepType] as? String)!)! as  ActivityStepType {
//
//                          case .instruction:
//
//                              let instructionStep:ActivityInstructionStep? = ActivityInstructionStep()
//                            instructionStep?.initWithDict(stepDict: stepDict, allSteps: (activity?.steps!)!)
//                              orkStepArray?.append((instructionStep?.getInstructionStep())!)
//
//                          case .question:
//
//                              let questionStep:ActivityQuestionStep? = ActivityQuestionStep()
//                            questionStep?.initWithDict(stepDict: stepDict, allSteps: (activity?.steps!)!)
//                              orkStepArray?.append((questionStep?.getQuestionStep())!)
//
//                          case .active, .taskSpatialSpanMemory, .taskTowerOfHanoi:
//
//                              var localTask: ORKOrderedTask?
//
//                              let activeStep:ActivityActiveStep? = ActivityActiveStep()
//                            activeStep?.initWithDict(stepDict: stepDict, allSteps: (activity?.steps!)!)
//                              localTask = activeStep?.getActiveTask() as! ORKOrderedTask?
//                              activityStepArray?.append(activeStep!)
//
//                              if (localTask?.steps) != nil && ((localTask?.steps)?.count)! > 0 {
//
//                                  for step  in (localTask?.steps)! {
//                                      orkStepArray?.append(step)
//                                  }
//                              }
//                          default: break
//                          }
//                      }
//
//                  } else {
//                      Logger.sharedInstance.debug("Activity:stepDict is null:\(stepDict)")
//                      break
//                  }
//              }
//
//              if (orkStepArray?.count)! > 0 {
//
//                  if (activityStepArray?.count)! > 0 {
//
//                      self.activity?.setActivityStepArray(stepArray: activityStepArray!)
//                  }
//                  self.activity?.setORKSteps(orkStepArray: orkStepArray!)
//
//                  if (orkStepArray?.count)! > 0 {
//                      task =  ORKOrderedTask(identifier: (activity?.actvityId!)!, steps: orkStepArray)
//                  }
//                  return task!
//
//              } else {
//                  return nil
//              }
//          }
//      } else {
//          Logger.sharedInstance.debug("activity is null")
//      }
//      return nil
//      // self.actvityResult?.setActivity(activity: self.activity!)
//  }
  
  func setInfo(infoDict: Dictionary<String, Any>) -> [String] {
      var version = ""
    var activityId = ""
    
      if Utilities.isValidObject(someObject: infoDict as AnyObject?) {
       
//          if Utilities.isValidValue(someObject: infoDict["name"] as AnyObject ) {
//              self.shortName =   infoDict["name"] as? String
//          }
          
          if Utilities.isValidValue(someObject: infoDict["version"] as AnyObject ) {
            version =  infoDict["version"] as? String ?? ""
          }
        if Utilities.isValidValue(someObject: infoDict["activityId"] as AnyObject ) {
          activityId =  infoDict["activityId"] as? String ?? ""
        }
//          if Utilities.isValidValue(someObject: infoDict[kActivityStartTime] as AnyObject ) {
//              // self.startDate =  Utilities.getDateFromString(dateString: (infoDict[kActivityStartTime] as! String?)!)
//          }
//          if Utilities.isValidValue(someObject: infoDict[kActivityEndTime] as AnyObject ) {
//              // self.endDate =   Utilities.getDateFromString(dateString: (infoDict[kActivityEndTime] as! String?)!)
//          }
//          if let lastModified = infoDict[kActivityLastModified] as? String {
//              self.lastModified =  Utilities.getDateFromString(dateString: lastModified)
//          }
        //  self.activityLang = getLanguageLocale()
      }
//    else {
//          Logger.sharedInstance.debug("infoDict is null:\(infoDict)")
//      }
    
    return [activityId, version]
  }
  
  func setStepArray(stepArray: Array<Dictionary<String, Any>>, valActivityData: [String]) {
     
      if Utilities.isValidObject(someObject: stepArray as AnyObject?){
//          self.steps? = stepArray
        
        for stepArr in stepArray {
          let valKey = stepArr["key"] as? String ?? ""
          if valKey != "" {
            let valresultType = stepArr["resultType"] as? String ?? ""
            if valresultType == QuestionStepType.valuePicker.rawValue {
              
              //              let stepArr1 = stepArr as? Dictionary<String, Any>
                            let valformatDict = stepArr["format"] as? [String: Any] ?? [:]
                            let valTextChoices = valformatDict["textChoices"] as? [[String: Any]] ?? []
                            
                            let valRes = valPipingValuesMain[valKey] as? String ?? ""
                            if valRes != "" {
                              
                              for valTextChoices1 in valTextChoices {
                                let valValue = valTextChoices1["value"] as? String ?? ""
                                if valValue == valRes {
                                  let valText = valTextChoices1["text"] as? String ?? ""
                                  print("valText---\(valText)---\(valRes)")
                                  valPipingValuesMain[valKey] = valText
                                  
                                }
                              }
                              
                              
                            }
                            
            } else if valresultType == QuestionStepType.textChoice.rawValue {
              
              //              let stepArr1 = stepArr as? Dictionary<String, Any>
              let valformatDict = stepArr["format"] as? [String: Any] ?? [:]
              let valTextChoices = valformatDict["textChoices"] as? [[String: Any]] ?? []
              
              let valRes = valPipingValuesMain[valKey] as? String ?? ""
              if valRes != "" {
                
                for valTextChoices1 in valTextChoices {
                  let valValue = valTextChoices1["value"] as? String ?? ""
                  if valValue == valRes {
                    let valText = valTextChoices1["text"] as? String ?? ""
                    print("valText---\(valText)---\(valRes)")
                    valPipingValuesMain[valKey] = valText
                    
                  }
                }
                
                
              } else {
                guard let studyID = Study.currentStudy?.studyId else { return }
                
               let valValues1aActivityId1 = valActivityData[0]
                var valValues1aActivityId2 = valActivityData[0]
                let valpipingactivityVersion = valActivityData[1]
                
                if let valValues1 = valPipingDetailsMain[valValues1aActivityId1] {
                  if valValues1.count > 0 {
                    let valValues1a = valValues1[0]
                    if let valValues1aActivityId = valValues1a["pipingsourceQuestionKey"] {
                      valValues1aActivityId2 = valValues1aActivityId2 + valValues1aActivityId
                    }
                  }
                }
                
                if valValues1aActivityId2 != valValues1aActivityId1, valValues1aActivityId2 != "" {
                  if let valValues1 = valPipingDetailsMain[valValues1aActivityId1] {
                  if valValues1.count > 0 {
                    let valValues1a = valValues1[0]
                    if let valValues1aActivityId = valValues1a["pipingsourceQuestionKey"] {
                      querypipingresponse(activityId: valValues1aActivityId2, stepId: valValues1aActivityId)
                    }
                  }
                    
                }
                  
                  
                  
//                WCPServices().getStudyActivityVersionMetadata(studyId: studyID,
//                                                                                           activityId: valValues1aActivityId2,
//                                                                                           activityVersion: valpipingactivityVersion,
//                                                                                           delegate: self)
                }
                
              }
              
            } else if valresultType == QuestionStepType.textscale.rawValue {
              
//              let stepArr1 = stepArr as? Dictionary<String, Any>
              let valformatDict = stepArr["format"] as? [String: Any] ?? [:]
              let valTextChoices = valformatDict["textChoices"] as? [[String: Any]] ?? []
              
              let valRes = valPipingValuesMain[valKey] as? String ?? ""
              if valRes != "" {
                
                for valTextChoices1 in valTextChoices {
                  let valValue = valTextChoices1["value"] as? String ?? ""
                  if valValue == valRes {
                    let valText = valTextChoices1["text"] as? String ?? ""
                    print("valText---\(valText)---\(valRes)")
                    valPipingValuesMain[valKey] = valText
                    
                  }
                }
                
                
              }
              
            }
            
          }
        }
        
      } else {
          Logger.sharedInstance.debug("stepArray is null:\(stepArray)")
      }
  }
  
}

// MARK: - ActivitySchedules Class
class ActivitySchedules: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView?
    @IBOutlet var buttonCancel: UIButton!
    @IBOutlet var heightLayoutConstraint: NSLayoutConstraint!
    
    var activity:Activity!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // fatalError("init(coder:) has not been implemented")
    }
    
    class func instanceFromNib(frame:CGRect, activity:Activity) -> ActivitySchedules {
        let view = (UINib(nibName: "ActivitySchedules", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? ActivitySchedules)!
        view.frame = frame
        view.activity = activity
        view.tableview?.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.tableview?.delegate = view
        view.tableview?.dataSource = view
        let height = (activity.activityRuns.count*44) + 104
        let maxViewHeight = Int(UIScreen.main.bounds.size.height - 67)
        view.heightLayoutConstraint.constant = CGFloat((height > maxViewHeight) ? maxViewHeight: height)
        view.layoutIfNeeded()
        
        return view
    }
    
    // MARK: - Button Action
    @IBAction func buttonCancelClicked(_:UIButton) {
        self.removeFromSuperview()
    }
    
    // MARK: Tableview Delegates
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
            
        } else if activityRun.runId < self.activity.currentRunId {
            cell.textLabel?.textColor = UIColor.gray
        }
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma, MMM dd YYYY"
        formatter.locale = Locale(identifier: getLanguageLocale())
        // formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
}

class ResponseDataFetch: NMWebServiceDelegate {
    
    var dataSourceKeysForLabkey: Array<Dictionary<String, String>> = []
    
    static let labkeyDateFormatter: DateFormatter = {
        // 2017/06/13 18:12:13
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.init(identifier: "America/New_York")
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: getLanguageLocale())
        return formatter
    }()
    
    public static let localDateFormatter: DateFormatter = {
        // 2017/06/13 18:12:13
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        formatter.locale = Locale(identifier: getLanguageLocale())
        return formatter
    }()
    
    init() {
        
    }
    
    // MARK: Helper Methods
    func checkUpdates() {
        if StudyUpdates.studyActivitiesUpdated {
            self.sendRequestToGetDashboardInfo()
            
        } else {
            
            // Load Stats List from DB
            DBHandler.loadStatisticsForStudy(studyId: Study.currentStudy?.studyId ?? "") { (statiticsList) in
                
                if statiticsList.count != 0 {
                    StudyDashboard.instance.statistics = statiticsList
                    self.getDataKeysForCurrentStudy()
                    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
                    appDelegate.addAndRemoveProgress(add: true)
                    
                } else {
                    // Fetch DashboardInfo
                    self.sendRequestToGetDashboardInfo()
                }
            }
        }
    }
    
    func sendRequestToGetDashboardInfo(){
        guard let studyID = Study.currentStudy?.studyId else { return }
        WCPServices().getStudyDashboardInfo(studyId: studyID, delegate: self)
    }
    
    func handleExecuteSQLResponse(){
        
        if !self.dataSourceKeysForLabkey.isEmpty {
            self.dataSourceKeysForLabkey.removeFirst()
        }
        self.sendRequestToGetDashboardResponse()
    }
    
    func getDataKeysForCurrentStudy(){
        
        DBHandler.getDataSourceKeyForActivity(studyId: Study.currentStudy?.studyId ?? "") { (activityKeys) in
            
            if activityKeys.count > 0 {
                self.dataSourceKeysForLabkey = activityKeys
                            
                // GetDashboardResponse from server
                self.sendRequestToGetDashboardResponse()
            }
        }
        
    }
    
    func sendRequestToGetDashboardResponse() {
        
        if self.dataSourceKeysForLabkey.count != 0 {
            let details = self.dataSourceKeysForLabkey.first
            let activityId = details?["activityId"]
            var tableName = activityId
            let activity = Study.currentStudy?.activities.filter({$0.actvityId == activityId}).first
            var keys = details?["keys"]
            if activity?.type == ActivityType.activeTask {
                if activity?.taskSubType == "fetalKickCounter" {
                    //                keys = "\"count\",duration,FetalKickId"
                    //                tableName = activityId!+activityId!
                    
                    keys = "\"count\",duration"
                    tableName = activityId!+activityId!
                } else if activity?.taskSubType == "towerOfHanoi" {
                    keys = "numberOfMoves"
                    tableName = activityId!+activityId!
                } else if activity?.taskSubType == "spatialSpanMemory" {
                    keys = "NumberofGames,Score,NumberofFailures"
                    tableName = activityId!+activityId!
                }
            }
            let participantId = Study.currentStudy?.userParticipateState.participantId
            // Get Survey Response from Server
            LabKeyServices().getParticipantResponse(tableName: tableName!,
                                                    activityId: activityId!,
                                                    keys: keys!,
                                                    participantId: participantId!,
                                                    delegate: self)
        } else {
            
            // save response in database
            
            let responses = StudyDashboard.instance.dashboardResponse
            for  response in responses{
                
                let activityId = response.activityId
                let activity = Study.currentStudy?.activities.filter({$0.actvityId == activityId}).first
                var key = response.key
                if activity?.type == ActivityType.activeTask {
                    
                    if activity?.taskSubType == "fetalKickCounter" || activity?.taskSubType == "towerOfHanoi" {
                        key = activityId!
                    }
                    
                }
                
                let values = response.values
                for value in values {
                    let responseValue = (value["value"] as? Float)!
                    let count = (value["count"] as? Float)!
                    // SetData Format
                    let date = ResponseDataFetch.labkeyDateFormatter.date(from: (value["date"] as? String)!)
                    let localDateAsString = ResponseDataFetch.localDateFormatter.string(from: date!)
                    
                    let localDate = ResponseDataFetch.localDateFormatter.date(from: localDateAsString)
                    // Save Stats to DB
                    DBHandler.saveStatisticsDataFor(activityId: activityId!,
                                                    key: key!,
                                                    data: responseValue,
                                                    fkDuration: Int(count),
                                                    date: localDate!)
                }
                
            }
            let key = "LabKeyResponse" + (Study.currentStudy?.studyId ?? "")
            UserDefaults.standard.set(true, forKey: key)
            
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            appDelegate.addAndRemoveProgress(add: false)
            
        }
    }
    
    // MARK: Webservice Delegates
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info(" START requestname : \(requestName)")
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) Response : \(String(describing:response) )")
        
        if requestName as String == WCPMethods.studyDashboard.method.methodName {
            self.getDataKeysForCurrentStudy()
            
        } else if requestName as String == ResponseMethods.executeSQL.description {
            self.handleExecuteSQLResponse()
        }
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("failed requestname : \(requestName)")
        if requestName as String == ResponseMethods.executeSQL.description {
            self.handleExecuteSQLResponse()
        } else {
            // Do Nothing
        }
    }
}
