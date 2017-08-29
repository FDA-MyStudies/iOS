//
//  StudyListViewController.swift
//  FDA
//
//  Created by Surender Rathore on 3/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

let kHelperTextForFilteredStudiesNotFound = "Sorry, no Studies found. Please try different Filter Options"
let kHelperTextForSearchedStudiesNotFound = "Sorry, no Studies found. Please check the spelling or try a different search."

let kHelperTextForOffline = "Sorry, no studies available right now. Please remain signed in to get notified when there are new studies available."

class StudyListViewController: UIViewController {
    
    @IBOutlet var tableView:UITableView?
    @IBOutlet var labelHelperText:UILabel!
    
    var refreshControl:UIRefreshControl?
    
    var studyListRequestFailed = false
    var searchView:SearchBarView?
    
    var isComingFromFilterScreen : Bool = false
    var studiesList:Array<Study> = []
    
    var previousStudyList:Array<Study> = []
    
    //MARK:- Viewcontroller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //self.addRightBarButton() //Phase2
        //self.addLeftBarButton()
        //self.title = NSLocalizedString("FDA LISTENS!", comment: "")
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("FDA My Studies", comment: "")
        titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        titleLabel.textAlignment = .left
        titleLabel.textColor = Utilities.getUIColorFromHex(0x007cba)
        titleLabel.frame = CGRect.init(x: 0, y: 0, width: 300, height: 44)
        
        self.navigationItem.titleView = titleLabel
        
        //self.loadTestData()
        //get Profile data to check for passcode
        //Condition missing
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //        appDelegate.askForNotification()
        
        if User.currentUser.userType == .FDAUser && User.currentUser.settings?.localNotifications == true{
            appDelegate.checkForAppReopenNotification()
        }
        
        isComingFromFilterScreen = false
        
        IQKeyboardManager.sharedManager().enable = true
        
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView?.addSubview(refreshControl!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if isComingFromFilterScreen {
            isComingFromFilterScreen = false
            return
        }
        
        self.addRightNavigationItem()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        Study.currentStudy = nil
        
        let ud = UserDefaults.standard
        
        
        var ispasscodePending:Bool? = false
        
        if (ud.value(forKey: kPasscodeIsPending) != nil){
            ispasscodePending = ud.value(forKey: kPasscodeIsPending) as! Bool?
        }
        
        if ispasscodePending == true{
            if User.currentUser.userType == .FDAUser {
                self.tableView?.isHidden = true
                UserServices().getUserProfile(self as NMWebServiceDelegate)
            }
        }
        
        self.labelHelperText.isHidden = true
        self.setNavigationBarItem()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        
        if User.currentUser.userType == .FDAUser {
            
            self.tableView?.estimatedRowHeight = 145
            self.tableView?.rowHeight = UITableViewAutomaticDimension
            
            if (self.fdaSlideMenuController()?.isLeftOpen())!{
                
            }else {
                
                
                self.sendRequestToGetUserPreference()
                
                
            }
            
            //  self.sendRequestToGetStudyList()
        }
        else {
            self.tableView?.estimatedRowHeight = 140
            self.tableView?.rowHeight = UITableViewAutomaticDimension
            self.sendRequestToGetStudyList()
        }
        
        //self.loadStudiesFromDatabase()
        
        UIApplication.shared.statusBarStyle = .default
        
        
        if ud.value(forKey: kNotificationRegistrationIsPending) != nil && ud.bool(forKey: kNotificationRegistrationIsPending) == true{
            appdelegate.askForNotification()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func  addRightNavigationItem(){
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 4, width: 110, height: 40))
        //view.backgroundColor = UIColor.red
        
        
        // Notification Button
        let button = UIButton.init(type: .custom)
        
        button.setImage(#imageLiteral(resourceName: "notification_grey"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(self.buttonActionNotification(_:)), for: UIControlEvents.touchUpInside)
        button.frame = CGRect.init(x: 80, y: 4, width: 30, height: 30)
        view.addSubview(button)
        button.isExclusiveTouch = true
        
        // notification Indicator
        let label = UILabel.init(frame:CGRect.init(x: 100, y: 4, width: 10, height: 10) )
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.white
        
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = kUIColorForSubmitButtonBackground
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.text = ""
        view.addSubview(label)
        
        
        
        //  filter Button
        let filterButton = UIButton.init(type: .custom)
        filterButton.setImage(#imageLiteral(resourceName: "filterIcon"), for: UIControlState.normal)
        filterButton.addTarget(self, action:#selector(self.filterAction(_:)), for: UIControlEvents.touchUpInside)
        filterButton.frame = CGRect.init(x: 40, y: 4, width: 30, height: 30)
        view.addSubview(filterButton)
        filterButton.isExclusiveTouch = true
        
        
        //  filter Button
        let SearchButton = UIButton.init(type: .custom)
        SearchButton.setImage(#imageLiteral(resourceName: "search_small"), for: UIControlState.normal)
        SearchButton.addTarget(self, action:#selector(self.searchButtonAction(_:)), for: UIControlEvents.touchUpInside)
        SearchButton.frame = CGRect.init(x: 0, y: 4, width: 30, height: 30)
        view.addSubview(SearchButton)
        SearchButton.isExclusiveTouch = true
        
        
        
        let barButton = UIBarButtonItem.init(customView: view)
        
        
        // let filterButton1 = UIBarButtonItem(image: UIImage(named: "filterIcon"), style: .plain, target: self, action: #selector(self.filterAction(_:)))//action:#selector(Class.MethodName) for swift 3
        
        ///// Added filterBarButton
        //let filterBarButton = UIBarButtonItem.init(customView: view)
        
        
        //let buttonSearch = UIBarButtonItem(image: UIImage(named: "search_big"), style: .plain, target: self, action: #selector(self.searchButtonAction(_:)))//action:#selector(Class.MethodName) for swift 3
        
        
        //Changes from rightBarButtonItem to rightBarButtonItems(to support multiple Bar button item)
        self.navigationItem.rightBarButtonItems = [barButton ]
        
        let ud = UserDefaults.standard
        
        let showNotification = ud.bool(forKey: kShowNotification)
        
        if showNotification{
            label.isHidden = false
        }else{
            label.isHidden = true
        }
    }
    
    
    //MARK:-
    
    func checkIfNotificationEnabled(){
        
        var notificationEnabledFromAppSettings = false
        
        
        //app settings
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        if notificationType == [] {
            print("notifications are NOT enabled")
        } else {
            print("notifications are enabled")
            notificationEnabledFromAppSettings = true
        }
        
        
        if ((User.currentUser.settings?.remoteNotifications)!
            && (User.currentUser.settings?.localNotifications)!
            && notificationEnabledFromAppSettings) {
            //don't do anything
        }
        else {
            
            let ud = UserDefaults.standard
            let previousDate = ud.object(forKey: "NotificationRemainder") as? Date
            let todayDate = Date()
            var daysLastSeen = 0
            if previousDate != nil {
                daysLastSeen = Schedule().getNumberOfDaysBetween(startDate: previousDate!, endDate: todayDate)
            }
            
            
            if (previousDate == nil || daysLastSeen >= 7 ) {
                
                UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString("FDA My Studies", comment: "") as NSString, message: NSLocalizedString(kMessageAppNotificationOffRemainder, comment: "") as NSString)
                
                ud.set(Date(), forKey: "NotificationRemainder")
                ud.synchronize()
            }
        }
        
    }
    
    /**
     
     Used to load the test data from Studylist of type json
     
     */
    func loadTestData(){
        
        let filePath  = Bundle.main.path(forResource: "StudyList", ofType: "json")
        let data = NSData(contentsOfFile: filePath!)
        
        do {
            let response = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
            
            let studies = response?[kStudies] as! Array<Dictionary<String,Any>>
            var listOfStudies:Array<Study> = []
            for study in studies{
                let studyModelObj = Study(studyDetail: study)
                listOfStudies.append(studyModelObj)
            }
            
            //assgin to Gateway
            Gateway.instance.studies = listOfStudies
            
        } catch {
            print("json error: \(error.localizedDescription)")
        }
    }
    
    
    func checkIfFetelKickCountRunning(){
        
        let ud = UserDefaults.standard
        
        
        if (ud.bool(forKey: "FKC") && ud.object(forKey: "FetalKickStartTimeStamp") != nil) {
            
            let studyId = ud.object(forKey: "FetalKickStudyId")  as! String
            let study  = Gateway.instance.studies?.filter({$0.studyId == studyId}).last
            
            
            if (study?.userParticipateState.status == .inProgress && study?.status == .Active){
                
                Study.updateCurrentStudy(study: study!)
                self.pushToStudyDashboard(animated: false)
            }
        }
        else {
            //self.checkIfNotificationEnabled()
            if NotificationHandler.instance.studyId.characters.count > 0 {
                
               
                
                let studyId = NotificationHandler.instance.studyId
                
                let study = Gateway.instance.studies?.filter({$0.studyId == studyId}).first
                Study.updateCurrentStudy(study: study!)
                
                NotificationHandler.instance.studyId = ""
                
                self.performTaskBasedOnStudyStatus()
                
                
            }
        }
        
    }
    
    
    //MARK:- Helper Methods
    
    /**
     
     Navigate to notification screen
     
     */
    func navigateToNotifications(){
        
        let gatewayStoryBoard = UIStoryboard.init(name: kStoryboardIdentifierGateway, bundle: Bundle.main)
        let notificationController = gatewayStoryBoard.instantiateViewController(withIdentifier:"NotificationViewControllerIdentifier") as! NotificationViewController
        
        self.navigationController?.pushViewController(notificationController, animated: true)
        
    }
    
    
    /**
     
     Navigate to StudyHomeViewController screen
     
     */
    func navigateToStudyHome(){
        
        let studyStoryBoard = UIStoryboard.init(name: kStudyStoryboard, bundle: Bundle.main)
        let studyHomeController = studyStoryBoard.instantiateViewController(withIdentifier: String(describing: StudyHomeViewController.classForCoder())) as! StudyHomeViewController
        studyHomeController.delegate = self
        self.navigationController?.pushViewController(studyHomeController, animated: true)
    }
    
    
    /**
     
     Navigate the screen to Study Dashboard tabbar viewcontroller screen
     
     */
    func pushToStudyDashboard(animated:Bool = true){
        
        let studyStoryBoard = UIStoryboard.init(name: kStudyStoryboard, bundle: Bundle.main)
        
        let studyDashboard = studyStoryBoard.instantiateViewController(withIdentifier: kStudyDashboardTabbarControllerIdentifier) as! StudyDashboardTabbarViewController
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(studyDashboard, animated: animated)
    }
    
    
    /**
     
     Method to display taskViewController for passcode setup if
     passcode setup is enabled,called only once after signin.
     
     */
    func setPassCode() {
        //Remove Passcode if already exist
        
        ORKPasscodeViewController.removePasscodeFromKeychain()
        
        let passcodeStep = ORKPasscodeStep(identifier: kPasscodeStepIdentifier)
        passcodeStep.passcodeType = .type4Digit
        
        //passcodeStep.text = kPasscodeSetUpText
        
        let task = ORKOrderedTask(identifier: kPasscodeTaskIdentifier, steps: [passcodeStep])
        let taskViewController = ORKTaskViewController.init(task: task, taskRun: nil)
        taskViewController.delegate = self
        
        taskViewController.isNavigationBarHidden = true
        
        
        self.navigationController?.present(taskViewController, animated: false, completion: {
            self.tableView?.isHidden = false
        })
        
    }
    
    
    /**
     
     Load the study data from Database
     
     */
    func loadStudiesFromDatabase(){
        
        
        Logger.sharedInstance.info("Fetching Studies From DB")
        DBHandler.loadStudyListFromDatabase { (studies) in
            if studies.count > 0 {
                self.tableView?.isHidden = false
                //                let  sortedstudies =  studies.sorted(by: { (study1:Study, study2:Study) -> Bool in
                //
                //                   return (study1.userParticipateState.status.sortIndex < study2.userParticipateState.status.sortIndex)
                //                })
                Logger.sharedInstance.info("Sorting Studies")
                let  sortedstudies2 =  studies.sorted(by: { (study1:Study, study2:Study) -> Bool in
                    
                    if study1.status == study2.status {
                        return (study1.userParticipateState.status.sortIndex < study2.userParticipateState.status.sortIndex)
                    }
                    return (study1.status.sortIndex < study2.status.sortIndex)
                })
                
                self.studiesList = sortedstudies2
                self.tableView?.reloadData()
                Logger.sharedInstance.info("Studies displayed to user")
                
                self.previousStudyList = sortedstudies2
                
                if StudyFilterHandler.instance.previousAppliedFilters.count > 0 {
                    let previousCollectionData = StudyFilterHandler.instance.previousAppliedFilters
                    
                    if User.currentUser.userType == .FDAUser{
                        
                        self.appliedFilter(studyStatus: previousCollectionData.first!, pariticipationsStatus: previousCollectionData[2], categories:previousCollectionData[3], searchText: "", bookmarked:(previousCollectionData[1].count > 0 ? true : false))
                    }
                    else{
                        self.appliedFilter(studyStatus: previousCollectionData.first!, pariticipationsStatus: [], categories:previousCollectionData[1], searchText: "", bookmarked:false)
                    }
                    
                    
                    
                }
                
                self.checkIfFetelKickCountRunning()
                
            }
            else {
                if !self.studyListRequestFailed {
                    
                    self.labelHelperText.isHidden = true
                    self.tableView?.isHidden = false
                    self.studyListRequestFailed = false
                    
                    self.sendRequestToGetStudyList()
                }
                else {
                    self.tableView?.isHidden = true
                    self.labelHelperText.isHidden = false
                    self.labelHelperText.text = kHelperTextForOffline
                    
                }
                
                
                
            }
        }
    }
    
    func getSortedStudies(studies:Array<Study>) -> Array<Study>{
        
        let  sortedstudies2 =  studies.sorted(by: { (study1:Study, study2:Study) -> Bool in
            
            if study1.status == study2.status {
                return (study1.userParticipateState.status.sortIndex < study2.userParticipateState.status.sortIndex)
            }
            return (study1.status.sortIndex < study2.status.sortIndex)
        })
        return sortedstudies2
    }
    
    
    //MARK:- Button Actions
    
    /**
     
     Navigate to notification screen on button clicked
     
     @param sender    accepts UIBarButtonItem in sender
     
     */
    @IBAction func buttonActionNotification(_ sender:UIBarButtonItem){
        self.navigateToNotifications()
    }
    
    
    func refresh(sender:AnyObject) {
        self.sendRequestToGetStudyList()
    }
    
    
    /**
     
     Navigate to StudyFilter screen on button clicked
     
     @param sender    accepts UIBarButtonItem in sender
     
     */
    @IBAction func filterAction(_ sender:UIBarButtonItem){
        
        isComingFromFilterScreen = true
        self.performSegue(withIdentifier: filterListSegue, sender: nil)
    }
    
    
    @IBAction func searchButtonAction(_ sender:UIBarButtonItem){
        
        
        self.searchView = SearchBarView.instanceFromNib(frame:CGRect.init(x: 0, y: -200, width: self.view.frame.size.width, height: 64.0), detail: nil);
        
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: UIViewAnimationOptions.preferredFramesPerSecond60,
                       animations: { () -> Void in
                        
                        self.searchView?.frame = CGRect(x:0 , y:0 , width:self.view.frame.size.width , height: 64.0)
                        
                        //self.navigationController?.navigationBar.isHidden = true
                        
                        self.searchView?.textFieldSearch?.becomeFirstResponder()
                        self.searchView?.delegate = self
                        
                        self.slideMenuController()?.leftPanGesture?.isEnabled = false
                        
                        self.navigationController?.view.addSubview(self.searchView!)
                        
                        if StudyFilterHandler.instance.searchText.characters.count > 0 {
                            self.searchView?.textFieldSearch?.text = StudyFilterHandler.instance.searchText
                        }
                        
        }, completion: { (finished) -> Void in
            
        })
    }
    
    
    //MARK:- Custom Bar Buttons
    
    /**
     
     Used to add left bar button item
     
     */
    func addLeftBarButton(){
        
        let button = UIButton(type: .custom)
        //button.setImage(UIImage(named: "imagename"), for: .normal)
        button.setTitle("FDA LISTENS!", for: .normal)
        button.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Medium", size: 18)
        button.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(Utilities.getUIColorFromHex(0x007cba), for: .normal)
        
        let barItem = UIBarButtonItem(customView: button)
        
        self.navigationItem.setLeftBarButton(barItem, animated: true)
    }
    
    
    /**
     
     Used to add right bar button item
     
     */
    func addRightBarButton(){
        
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "filter_icn"), for: .normal)
        //button.setTitle("FDA LISTENS!", for: .normal)
        //button.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Medium", size: 18)
        button.frame = CGRect(x: 0, y: 0, width: 19, height: 22.5)
        //button.contentHorizontalAlignment = .left
        // button.setTitleColor(Utilities.getUIColorFromHex(0x007cba), for: .normal)
        let barItem = UIBarButtonItem(customView: button)
        
        self.navigationItem.setRightBarButton(barItem, animated: true)
    }
    
    
    //MARK:- Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == filterListSegue{
            let filterVc = segue.destination as! StudyFilterViewController
            if StudyFilterHandler.instance.previousAppliedFilters.count > 0 {
                filterVc.previousCollectionData = StudyFilterHandler.instance.previousAppliedFilters
            }
            
            filterVc.delegate = self
        }
    }
    
    
    @IBAction func unwindToStudyList(_ segue:UIStoryboardSegue){
        //unwindStudyListSegue
    }
    
    
    //MARK:- Database Methods
    func checkDatabaseForStudyInfo(study:Study){
        
        DBHandler.loadStudyOverview(studyId: (study.studyId)!) { (overview) in
            if overview != nil {
                study.overview = overview
                //
                self.navigateBasedOnUserStatus()
            }
            else {
                self.sendRequestToGetStudyInfo(study: study)
            }
        }
    }
    
    
    //MARK:- Webservice Requests
    
    /**
     
     Send the webservice request to get Study List
     
     */
    func sendRequestToGetStudyList(){
        WCPServices().getStudyList(self)
    }
    
    
    /**
     
     Send the webservice request to get Study Info
     
     @param study    Access the data from the study class
     
     */
    func sendRequestToGetStudyInfo(study:Study){
        WCPServices().getStudyInformation(studyId: study.studyId, delegate: self)
    }
    
    
    /**
     
     Send the webservice request to get UserPreferences
     
     */
    func sendRequestToGetUserPreference(){
        UserServices().getStudyStates(self)
    }
    
    
    /**
     
     Send the webservice request to Update BookMarkStatus
     
     @param userStudyStatus    Access the data from UserStudyStatus
     
     */
    func sendRequestToUpdateBookMarkStatus(userStudyStatus:UserStudyStatus){
        UserServices().updateStudyBookmarkStatus(studyStauts: userStudyStatus, delegate: self)
    }
    
    
    //MARK:- Webservice Responses
    
    /**
     
     Handle the Study list webservice response
     
     */
    func handleStudyListResponse(){
        
        Logger.sharedInstance.info("Study Response Handler")
        
        if (Gateway.instance.studies?.count)! > 0{
            self.loadStudiesFromDatabase()
            //self.labelHelperText.isHidden = true
            //self.tableView?.isHidden = false
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            if appDelegate.notificationDetails != nil && User.currentUser.userType == .FDAUser{
                appDelegate.handleLocalAndRemoteNotification(userInfoDetails:appDelegate.notificationDetails! )
            }
            
            
            
        }
        else {
            self.tableView?.isHidden = true
            self.labelHelperText.isHidden = false
        }
    }
    
    
    /**
     
     save information for study which feilds need to be updated
     
     */
    func handleStudyUpdatedInformation(){
        
        let currentStudy = Study.currentStudy
        if currentStudy?.userParticipateState.status == UserStudyStatus.StudyStatus.yetToJoin {
            
            StudyUpdates.studyConsentUpdated = false
            StudyUpdates.studyActivitiesUpdated = false
            StudyUpdates.studyResourcesUpdated = false
            
            currentStudy?.version = StudyUpdates.studyVersion
            currentStudy?.newVersion = StudyUpdates.studyVersion
        }
        
        DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
        
        if StudyUpdates.studyInfoUpdated {
            self.sendRequestToGetStudyInfo(study: Study.currentStudy!)
        }
        else {
            
            self.removeProgressIndicator()
            self.navigateBasedOnUserStatus()
        }
        
        
        
        
    }
    
    
    func navigateBasedOnUserStatus(){
        
        if User.currentUser.userType == UserType.FDAUser {
            
            if Study.currentStudy?.status == .Active{
                
                let userStudyStatus =  (Study.currentStudy?.userParticipateState.status)!
                
                if userStudyStatus == .completed || userStudyStatus == .inProgress  //|| userStudyStatus == .yetToJoin
                {
                    self.pushToStudyDashboard()
                }
                else {
                    //self.checkDatabaseForStudyInfo(study: Study.currentStudy!)
                    self.navigateToStudyHome()
                }
            }
            else {
                //self.checkDatabaseForStudyInfo(study: Study.currentStudy!)
                self.navigateToStudyHome()
            }
        }
        else {
            //self.checkDatabaseForStudyInfo(study: Study.currentStudy!)
            self.navigateToStudyHome()
        }
    }
    
    func performTaskBasedOnStudyStatus(){
        
        let study = Study.currentStudy
        
        if User.currentUser.userType == UserType.FDAUser {
            
            if Study.currentStudy?.status == .Active{
                
                let userStudyStatus =  (Study.currentStudy?.userParticipateState.status)!
                
                if userStudyStatus == .completed || userStudyStatus == .inProgress
                    //|| userStudyStatus == .yetToJoin
                {
                    
                    //self.pushToStudyDashboard()
                    // check if study version is udpated
                    if(study?.version != study?.newVersion){
                        WCPServices().getStudyUpdates(study: study!, delegate: self)
                    }
                    else{
                        
                        DBHandler.loadStudyDetailsToUpdate(studyId: (study?.studyId)!, completionHandler: { (success) in
                            //self.pushToStudyDashboard()
                            self.checkDatabaseForStudyInfo(study: study!)
                        })
                    }
                }
                else {
                    
                    self.checkForStudyUpdate(study: study)
                }
            }
            else  if Study.currentStudy?.status == .Paused{
                let userStudyStatus =  (Study.currentStudy?.userParticipateState.status)!
                
                if userStudyStatus == .completed || userStudyStatus == .inProgress {
                    
                    UIUtilities.showAlertWithTitleAndMessage(title: "", message: NSLocalizedString(kMessageForStudyPausedAfterJoiningState, comment: "") as NSString)
                }
                else {
                    self.checkForStudyUpdate(study: study)
                }
            }
            else {
                
                self.checkForStudyUpdate(study: study)
            }
        }
        else {
            
            self.checkForStudyUpdate(study: study)
            
        }
    }
    
    func checkForStudyUpdate(study:Study?){
        
        if(study?.version != study?.newVersion){
            WCPServices().getStudyUpdates(study: study!, delegate: self)
        }
        else {
            self.checkDatabaseForStudyInfo(study: study!)
        }
    }
    
}


//MARK:- Applied filter delegate
extension StudyListViewController : StudyFilterDelegates{
    
    //Based on applied filter call WS
    func appliedFilter(studyStatus: Array<String>, pariticipationsStatus: Array<String>, categories: Array<String>, searchText: String, bookmarked: Bool) {
        
        
        
        var previousCollectionData:Array<Array<String>> = []
        
        previousCollectionData.append(studyStatus)
        
        if User.currentUser.userType == .FDAUser{
            previousCollectionData.append((bookmarked == true ? ["Bookmarked"]:[]))
            previousCollectionData.append(pariticipationsStatus)
        }
        
        
        previousCollectionData.append(categories.count == 0 ? [] : categories)
        
        StudyFilterHandler.instance.previousAppliedFilters = previousCollectionData
        
        StudyFilterHandler.instance.searchText = ""
        
        //filter by study category
        var categoryFilteredStudies:Array<Study>! = []
        if categories.count > 0 {
            categoryFilteredStudies =  Gateway.instance.studies?.filter({categories.contains($0.category!)})
        }
        
        //filter by study status
        var statusFilteredStudies:Array<Study>! = []
        if studyStatus.count > 0 {
            statusFilteredStudies =  Gateway.instance.studies?.filter({studyStatus.contains($0.status.rawValue)})
        }
        
        //filter by study status
        var pariticipationsStatusFilteredStudies:Array<Study>! = []
        if pariticipationsStatus.count > 0 {
            pariticipationsStatusFilteredStudies =  Gateway.instance.studies?.filter({pariticipationsStatus.contains($0.userParticipateState.status.description)})
        }
        
        //filter by bookmark
        var bookmarkedStudies:Array<Study>! = []
        
        if bookmarked{
            
            bookmarkedStudies = Gateway.instance.studies?.filter({$0.userParticipateState.bookmarked == bookmarked})
        }
        
        //filter by searched Text
        var searchTextFilteredStudies:Array<Study>! = []
        if searchText.characters.count > 0 {
            searchTextFilteredStudies = Gateway.instance.studies?.filter({
                ($0.name?.containsIgnoringCase(searchText))! || ($0.category?.containsIgnoringCase(searchText))! || ($0.description?.containsIgnoringCase(searchText))! || ($0.sponserName?.containsIgnoringCase(searchText))!
                
            })
        }
        
        /* Union
        let setStudyStatus = Set<Study>(statusFilteredStudies)
        let setpariticipationsStatus = Set<Study>(pariticipationsStatusFilteredStudies)
        var studiesSet = setStudyStatus.union(setpariticipationsStatus)
        
        let setCategories  = Set<Study>(categoryFilteredStudies)
        studiesSet = studiesSet.union(setCategories)
        
        let setSearchedTextStudies = Set<Study>(searchTextFilteredStudies)
        studiesSet = studiesSet.union(setSearchedTextStudies)
        
        
        let setBookmarkedStudies = Set<Study>(bookmarkedStudies)
        studiesSet = studiesSet.union(setBookmarkedStudies)
        */
        
        // Intersection
        let setStudyStatus = Set<Study>(statusFilteredStudies)
        
        let setpariticipationsStatus = Set<Study>(pariticipationsStatusFilteredStudies)
        
         var statusFilteredSet = Set<Study>()
        
         var allFilteredSet = Set<Study>()
        
         // (setStudyStatus) ^ (setpariticipationsStatus)
        
        if setStudyStatus.count > 0 && setpariticipationsStatus.count > 0{
            statusFilteredSet = setStudyStatus.intersection(setpariticipationsStatus)
        }
        else{
            if setStudyStatus.count > 0 {
               statusFilteredSet = setStudyStatus
            }
            else if setpariticipationsStatus.count > 0{
                statusFilteredSet = setpariticipationsStatus
            }
        }

         var bookMarkAndCategorySet = Set<Study>()
        
        let setCategories  = Set<Study>(categoryFilteredStudies)
        
        let setBookmarkedStudies = Set<Study>(bookmarkedStudies)
       
        
        // (setCategories) ^ (setBookmarkedStudies)
        if setCategories.count > 0 && setBookmarkedStudies.count > 0{
            bookMarkAndCategorySet = setCategories.intersection(setBookmarkedStudies)
        }
        else{
            if setCategories.count > 0 {
                bookMarkAndCategorySet = setCategories
            }
            else if setBookmarkedStudies.count > 0{
                bookMarkAndCategorySet = setBookmarkedStudies
            }
        }
        
        // (statusFilteredSet) ^ (bookMarkAndCategorySet)
        
        
        if statusFilteredSet.count > 0 && bookMarkAndCategorySet.count > 0{
            allFilteredSet = statusFilteredSet.intersection(bookMarkAndCategorySet)
        }
        else{
            
            if (statusFilteredSet.count > 0 && (bookmarked == true || categories.count > 0)) ||  (bookMarkAndCategorySet.count > 0 && (pariticipationsStatus.count > 0 || studyStatus.count > 0)){
                 allFilteredSet = bookMarkAndCategorySet.intersection(statusFilteredSet)
            }
            else{
                allFilteredSet = statusFilteredSet.union(bookMarkAndCategorySet)
            
            }

        }

        // (studystatus ^ participantstatus ^ bookmarked ^ category) ^ (searchTextResult)
        let setSearchedTextStudies = Set<Study>(searchTextFilteredStudies)
        
        if allFilteredSet.count > 0 && setSearchedTextStudies.count > 0{
            allFilteredSet = allFilteredSet.intersection(setSearchedTextStudies)
        }
        else{
             if setSearchedTextStudies.count > 0{
                allFilteredSet = setSearchedTextStudies
            }
        }
        
        
        
        

        //--
        let allStudiesArray:Array<Study> = Array(allFilteredSet)
        
        if searchText.characters.count == 0 && bookmarked == false && studyStatus.count == 0 &&
            pariticipationsStatus.count == 0 && categories.count == 0 {
            
            self.studiesList = Gateway.instance.studies!
        }
        else{
            self.studiesList = self.getSortedStudies(studies: allStudiesArray)
        }
        
        
        
        self.previousStudyList = self.studiesList
        
        self.tableView?.reloadData()
        
        if self.studiesList.count == 0 {
            self.tableView?.isHidden = true
            self.labelHelperText.isHidden = false
            
            if searchText == ""{
                self.labelHelperText.text = kHelperTextForFilteredStudiesNotFound
            }
            else{
                self.labelHelperText.text = kHelperTextForSearchedStudiesNotFound
            }
        }
        else{
            self.tableView?.isHidden = false
            self.labelHelperText.isHidden = true
        }
    }
    
    func didCancelFilter(_ cancel: Bool) {
        
        //self.studiesList = Gateway.instance.studies!
        //self.tableView?.reloadData()
    }
    
    
}


//MARK:- TableView Data source
extension StudyListViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studiesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier = "studyCell"
        
        //check if current user is anonymous
        let user = User.currentUser
        if user.userType == .AnonymousUser {
            cellIdentifier = "anonymousStudyCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! StudyListCell
        
        
        cell.populateCellWith(study: (self.studiesList[indexPath.row]))
        cell.delegate = self
        
        return cell
    }
}


//MARK:- TableView Delegates
extension StudyListViewController :  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        if searchView != nil {
            searchView?.removeFromSuperview()
            self.slideMenuController()?.leftPanGesture?.isEnabled = true
        }
        
        let study = self.studiesList[indexPath.row]
        Study.updateCurrentStudy(study: study)
        
        self.performTaskBasedOnStudyStatus()
        
        /*
        if User.currentUser.userType == UserType.FDAUser {
            
            if Study.currentStudy?.status == .Active{
                
                let userStudyStatus =  (Study.currentStudy?.userParticipateState.status)!
                
                if userStudyStatus == .completed || userStudyStatus == .inProgress
                    //|| userStudyStatus == .yetToJoin
                {
                    
                    //self.pushToStudyDashboard()
                    // check if study version is udpated
                    if(study.version != study.newVersion){
                        WCPServices().getStudyUpdates(study: study, delegate: self)
                    }
                    else{
                        
                        DBHandler.loadStudyDetailsToUpdate(studyId: (study.studyId)!, completionHandler: { (success) in
                            self.pushToStudyDashboard()
                        })
                    }
                }
                else {
                    
                    if(study.version != study.newVersion){
                        WCPServices().getStudyUpdates(study: study, delegate: self)
                    }
                    else {
                        self.checkDatabaseForStudyInfo(study: study)
                    }
                    
                    //self.sendRequestToGetStudyInfo(study: study!)
                }
            }
            else  if Study.currentStudy?.status == .Paused{
                let userStudyStatus =  (Study.currentStudy?.userParticipateState.status)!
                
                if userStudyStatus == .completed || userStudyStatus == .inProgress {
                    
                    UIUtilities.showAlertWithTitleAndMessage(title: "", message: NSLocalizedString(kMessageForStudyPausedAfterJoiningState, comment: "") as NSString)
                }
                else {
                    if(study.version != study.newVersion){
                        WCPServices().getStudyUpdates(study: study, delegate: self)
                    }
                    else {
                        self.checkDatabaseForStudyInfo(study: study)
                    }
                }
            }
            else {
                
                if(study.version != study.newVersion){
                    WCPServices().getStudyUpdates(study: study, delegate: self)
                }
                else {
                    self.checkDatabaseForStudyInfo(study: study)
                }
                //self.sendRequestToGetStudyInfo(study: study!)
            }
        }
        else {
            if(study.version != study.newVersion){
                WCPServices().getStudyUpdates(study: study, delegate: self)
            }
            else {
                self.checkDatabaseForStudyInfo(study: study)
            }
        }
 */
    }
 
}

//MARK:- StudyList Delegates
extension StudyListViewController : StudyListDelegates {
    
    func studyBookmarked(_ cell: StudyListCell, bookmarked: Bool, forStudy study: Study) {
        
        let user = User.currentUser
        var userStudyStatus:UserStudyStatus!
        if bookmarked {
            userStudyStatus =  user.bookmarkStudy(studyId: study.studyId!)
        }
        else {
            userStudyStatus =  user.removeBookbarkStudy(studyId: study.studyId!)
        }
        
        self.sendRequestToUpdateBookMarkStatus(userStudyStatus: userStudyStatus)
    }
}

//MARK:SearchBarDelegate
extension StudyListViewController : searchBarDelegate {
    func didTapOnCancel() {
        
        self.slideMenuController()?.leftPanGesture?.isEnabled = true
        //self.navigationController?.navigationBar.isHidden = false
        
        
        if self.studiesList.count == 0 {
            self.studiesList = self.previousStudyList
        }
        
        
        self.tableView?.reloadData()
        //self.search(text: "")
    }
    func search(text: String) {
        
        //filter by searched Text
        var searchTextFilteredStudies:Array<Study>! = []
        if text.characters.count > 0 {
            searchTextFilteredStudies = self.studiesList.filter({
                ($0.name?.containsIgnoringCase(text))! || ($0.category?.containsIgnoringCase(text))! || ($0.description?.containsIgnoringCase(text))! || ($0.sponserName?.containsIgnoringCase(text))!
                
            })
            
            StudyFilterHandler.instance.searchText = text
            
            self.previousStudyList = self.studiesList
            self.studiesList = self.getSortedStudies(studies: searchTextFilteredStudies)
            
            if self.studiesList.count == 0 {
                self.labelHelperText.text = kHelperTextForSearchedStudiesNotFound
                self.tableView?.isHidden = true
                self.labelHelperText.isHidden = false
            }
            
            
        }else{
            StudyFilterHandler.instance.searchText = ""
            
        }
        
        
        self.tableView?.reloadData()
        
        if self.studiesList.count > 0{
            if searchView != nil {
                searchView?.removeFromSuperview()
                self.slideMenuController()?.leftPanGesture?.isEnabled = true
            }
        }
        
        
    }
}


//MARK:- Webservices Delegates
extension StudyListViewController:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        //Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.addProgressIndicator()
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        //Logger.sharedInstance.info("requestname : \(requestName) : \(response)")
        
        if requestName as String == WCPMethods.studyList.rawValue{
            let responseDict = response as! NSDictionary
            
            
            if self.refreshControl != nil && (self.refreshControl?.isRefreshing)!{
                self.refreshControl?.endRefreshing()
            }
            
            self.handleStudyListResponse()
            self.removeProgressIndicator()
        }
        else if(requestName as String == WCPMethods.studyInfo.rawValue){
            self.removeProgressIndicator()
            //self.navigateToStudyHome()
            self.navigateBasedOnUserStatus()
        }
        else if (requestName as String == RegistrationMethods.studyState.description){
            self.sendRequestToGetStudyList()
        }
        else if (requestName as String == WCPMethods.studyUpdates.rawValue){
            
            self.handleStudyUpdatedInformation()
            //self.removeProgressIndicator()
        }
        else if requestName as String ==  RegistrationMethods.userProfile.description {
            self.removeProgressIndicator()
            if User.currentUser.settings?.passcode == true {
                self.setPassCode()
                
            }
            else {
                UserDefaults.standard.set(false, forKey: kPasscodeIsPending)
                UserDefaults.standard.synchronize()
            }
        }
        else if (requestName as String == RegistrationMethods.updateStudyState.description){
            self.removeProgressIndicator()
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
        else {
            
            if (requestName as String == RegistrationMethods.studyState.description){
                self.sendRequestToGetStudyList()
            }
            else if requestName as String == WCPMethods.studyList.rawValue{
                studyListRequestFailed = true
                self.loadStudiesFromDatabase()
                
            }
            else {
                UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kErrorTitle, comment: "") as NSString, message: error.localizedDescription as NSString)
            }
            
            
        }
    }
}


//MARK:- StudyHomeViewDontroller Delegate
extension StudyListViewController:StudyHomeViewDontrollerDelegate{
    func studyHomeJoinStudy() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.removeProgressIndicator()
            // your code here
            let leftController = self.slideMenuController()?.leftViewController as! LeftMenuViewController
            leftController.changeViewController(.reachOut_signIn)
        }
    }
}


//MARK:- ORKTaskViewController Delegate
extension StudyListViewController:ORKTaskViewControllerDelegate{
    
    func taskViewControllerSupportsSaveAndRestore(_ taskViewController: ORKTaskViewController) -> Bool {
        return true
    }
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        var taskResult:Any?
        switch reason {
            
        case ORKTaskViewControllerFinishReason.completed:
            print("completed")
            taskResult = taskViewController.result
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: kPasscodeIsPending)
            ud.synchronize()
            
        case ORKTaskViewControllerFinishReason.failed:
            print("failed")
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.discarded:
            print("discarded")
            
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.saved:
            print("saved")
            taskResult = taskViewController.restorationData
            
        }
        
        self.perform(#selector(dismisscontroller), with: self, afterDelay: 1.0)
        
        
    }
    
    func dismisscontroller(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        
    }
}


