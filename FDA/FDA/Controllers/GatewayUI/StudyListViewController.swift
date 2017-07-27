//
//  StudyListViewController.swift
//  FDA
//
//  Created by Surender Rathore on 3/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StudyListViewController: UIViewController {
    
    @IBOutlet var tableView:UITableView?
    @IBOutlet var labelHelperText:UILabel!
    var studyListRequestFailed = false
    
    
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
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
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
                
            }
            else {
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
        
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        
        let button = UIButton.init(type: .custom)
        
        button.setImage(#imageLiteral(resourceName: "notification_active"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(self.buttonActionNotification(_:)), for: UIControlEvents.touchUpInside)
        button.frame = CGRect.init(x: 15, y: 0, width: 30, height: 30)
        view.addSubview(button)
        
        button.isExclusiveTouch = true
        
        let label = UILabel.init(frame:CGRect.init(x: 30, y: 0, width: 10, height: 10) )
        
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.white
        
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = kUIColorForSubmitButtonBackground
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.text = ""
        view.addSubview(label)
        
        let barButton = UIBarButtonItem.init(customView: view)
        self.navigationItem.rightBarButtonItem = barButton
        
        let ud = UserDefaults.standard
        
        let showNotification = ud.bool(forKey: kShowNotification)
        
        if showNotification{
            label.isHidden = false
        }
        else{
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
            
            var ud = UserDefaults.standard
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
        
        
        
        DBHandler.loadStudyListFromDatabase { (studies) in
            if studies.count > 0 {
                self.tableView?.isHidden = false
                //                let  sortedstudies =  studies.sorted(by: { (study1:Study, study2:Study) -> Bool in
                //
                //                   return (study1.userParticipateState.status.sortIndex < study2.userParticipateState.status.sortIndex)
                //                })
                
                let  sortedstudies2 =  studies.sorted(by: { (study1:Study, study2:Study) -> Bool in
                    
                    if study1.status == study2.status {
                        return (study1.userParticipateState.status.sortIndex < study2.userParticipateState.status.sortIndex)
                    }
                    
                    // print("1id : \(study1.studyId) , 2id : \(study2.studyId)")
                    return (study1.status.sortIndex < study2.status.sortIndex)
                })
                
                Gateway.instance.studies = sortedstudies2
                self.tableView?.reloadData()
                
                
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
                    
                    
                }
                
                
                
            }
        }
    }
    
    
    //MARK:- Button Actions
    
    /**
     
     Navigate to notification screen button clicked
     
     @param sender    accepts UIBarButtonItem in sender
     
     */
    @IBAction func buttonActionNotification(_ sender:UIBarButtonItem){
        self.navigateToNotifications()
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
    }
    
    
    @IBAction func unwindToStudyList(_ segue:UIStoryboardSegue){
        //unwindStudyListSegue
    }
    
    
    //MARK:- Database Methods
    func checkDatabaseForStudyInfo(study:Study){
        
        DBHandler.loadStudyOverview(studyId: (study.studyId)!) { (overview) in
            if overview != nil {
                study.overview = overview
                self.navigateToStudyHome()
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
        
        
        
        if (Gateway.instance.studies?.count)! > 0{
            self.loadStudiesFromDatabase()
            self.labelHelperText.isHidden = true
            self.tableView?.isHidden = false
            
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
                    self.checkDatabaseForStudyInfo(study: Study.currentStudy!)
                }
            }
            else {
                self.checkDatabaseForStudyInfo(study: Study.currentStudy!)
            }
        }
        else {
            self.checkDatabaseForStudyInfo(study: Study.currentStudy!)
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
                            self.pushToStudyDashboard()
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


//MARK:- TableView Data source
extension StudyListViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Gateway.instance.studies?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier = "studyCell"
        
        //check if current user is anonymous
        let user = User.currentUser
        if user.userType == .AnonymousUser {
            cellIdentifier = "anonymousStudyCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! StudyListCell
        
        cell.populateCellWith(study: (Gateway.instance.studies?[indexPath.row])!)
        cell.delegate = self
        
        return cell
    }
}


//MARK:- TableView Delegates
extension StudyListViewController :  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let study = Gateway.instance.studies?[indexPath.row]
        Study.updateCurrentStudy(study: study!)
        
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
                    if(study?.version != study?.newVersion){
                        WCPServices().getStudyUpdates(study: study!, delegate: self)
                    }
                    else{
                        
                        DBHandler.loadStudyDetailsToUpdate(studyId: (study?.studyId)!, completionHandler: { (success) in
                            self.pushToStudyDashboard()
                        })
                    }
                }
                else {
                    
                    if(study?.version != study?.newVersion){
                        WCPServices().getStudyUpdates(study: study!, delegate: self)
                    }
                    else {
                        self.checkDatabaseForStudyInfo(study: study!)
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
                    if(study?.version != study?.newVersion){
                        WCPServices().getStudyUpdates(study: study!, delegate: self)
                    }
                    else {
                        self.checkDatabaseForStudyInfo(study: study!)
                    }
                }
            }
            else {
                
                if(study?.version != study?.newVersion){
                    WCPServices().getStudyUpdates(study: study!, delegate: self)
                }
                else {
                    self.checkDatabaseForStudyInfo(study: study!)
                }
                //self.sendRequestToGetStudyInfo(study: study!)
            }
        }
        else {
            if(study?.version != study?.newVersion){
                WCPServices().getStudyUpdates(study: study!, delegate: self)
            }
            else {
                self.checkDatabaseForStudyInfo(study: study!)
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


//MARK:- Webservices Delegates
extension StudyListViewController:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.addProgressIndicator()
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) : \(response)")
        
        if requestName as String == WCPMethods.studyList.rawValue{
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


