//
//  ResourcesViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/24/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit


let kConsentPdfKey = "consent"

let kUnwindToStudyListIdentifier = "unwindeToStudyListResourcesIdentifier"

class ResourcesViewController : UIViewController{
    
    var tableViewRowDetails : [AnyObject]? = []
    
    @IBOutlet var tableView : UITableView?
    var resourceLink:String?
    var fileType:String?
    var navigateToStudyOverview:Bool? = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //load plist info
        //let plistPath = Bundle.main.path(forResource: "ResourcesUI", ofType: ".plist", inDirectory:nil)
        //tableViewRowDetails = NSMutableArray(contentsOfFile: plistPath!) as [AnyObject]?
        
        //if (Study.currentStudy?.studySettings.rejoinStudyAfterWithdrawn)! == false {
        //    tableViewRowDetails?.removeLast()
        //}
        
        self.navigationItem.title = NSLocalizedString("Resources", comment: "")
        //Next Phase
        //WCPServices().getResourcesForStudy(studyId:(Study.currentStudy?.studyId)!, delegate: self)
        
        
        if StudyUpdates.studyConsentUpdated {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
             appDelegate.checkConsentStatus(controller: self)
        }
        
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addHomeButton()
         UIApplication.shared.statusBarStyle = .default
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.tabBarController?.tabBar.isHidden = false
        
        if Study.currentStudy?.withdrawalConfigration?.message == nil && ( Study.currentStudy?.withdrawalConfigration?.type == nil || Study.currentStudy?.withdrawalConfigration?.type == .notAvailable ){
            WCPServices().getStudyInformation(studyId: (Study.currentStudy?.studyId)!, delegate: self)
        }
        
        self.checkForResourceUpdate()
        
        self.checkForInfoUpdate()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
               
    }
    
    func checkForResourceUpdate(){
        
        if StudyUpdates.studyResourcesUpdated {
            WCPServices().getResourcesForStudy(studyId:(Study.currentStudy?.studyId)!, delegate: self)
        }
        else {
            self.loadResourceFromDatabase()
        }
    }
    
    func checkForInfoUpdate(){
        
        if StudyUpdates.studyInfoUpdated {
             WCPServices().getStudyInformation(studyId: (Study.currentStudy?.studyId)!, delegate: self)
        }
    }
    
    
    func loadResourceFromDatabase(){
        DBHandler.loadResourcesForStudy(studyId: (Study.currentStudy?.studyId)!) { (resources) in
            if resources.count != 0 {
                 Study.currentStudy?.resources = resources
                 self.handleResourcesReponse()
            }
            else {
                 WCPServices().getResourcesForStudy(studyId:(Study.currentStudy?.studyId)!, delegate: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ResourceDetailViewControllerIdentifier"{
            
            let resourceDetail = segue.destination as! ResourcesDetailViewController
            resourceDetail.resource = sender as! Resource
            if self.resourceLink != nil{
                resourceDetail.requestLink = self.resourceLink!
            }
            if self.fileType != nil {
                resourceDetail.type = self.fileType!
            }
            resourceDetail.hidesBottomBarWhenPushed = true
            
        }
        else if segue.identifier == "ResourceDetailViewSegueIdentifier"{
            
            let resourceDetail = segue.destination as! ResourcesDetailViewControllerCopy
            resourceDetail.resource = sender as! Resource
            if self.resourceLink != nil{
                resourceDetail.requestLink = self.resourceLink!
            }
            if self.fileType != nil {
                resourceDetail.type = self.fileType!
            }
            resourceDetail.hidesBottomBarWhenPushed = true
            
        }
    }
    
    
    @IBAction func homeButtonAction(_ sender: AnyObject){
        self.navigationController?.navigationBar.isHidden = false
        self.performSegue(withIdentifier: kUnwindToStudyListIdentifier, sender: self)
        
    }
    
    func addDefaultList(){
        
        //add default List
        let plistPath = Bundle.main.path(forResource: "ResourcesUI", ofType: ".plist", inDirectory:nil)
        
        let array = NSMutableArray(contentsOfFile: plistPath!) as [AnyObject]?
        
        for title in array!{
            tableViewRowDetails?.append(title)
        }
        
    }
    
    func appendLeaveStudy(){
        
        //append Leave Study row
        //if (Study.currentStudy?.studySettings.rejoinStudyAfterWithdrawn)! != false {
            tableViewRowDetails?.append("Leave Study" as AnyObject)
        //}
    }
    
    func handleResourcesReponse(){
        
        tableViewRowDetails = []
        
        self.addDefaultList()
        
        let todayDate = Date()
        
        //Add resources list
        for  resource in (Study.currentStudy?.resources)!{
            
            if resource.povAvailable{
                //check for startDate and endDate
                if resource.startDate != nil && resource.endDate != nil {
                    
                    let start = resource.startDate?.startOfDay
                    let end = resource.endDate?.endOfDay
                    
                    let startDateResult = (start?.compare(todayDate))! as ComparisonResult
                    let endDateResult = (end?.compare(todayDate))! as ComparisonResult
                    
                    
                    if ((startDateResult == .orderedAscending || startDateResult == .orderedSame) && (endDateResult == .orderedDescending || endDateResult == .orderedSame)){
                        print("current")
                        
                        tableViewRowDetails?.append(resource)
                        
                        
                        
                        
                    }
                } //check for anchorDate
                else if resource.anchorDateStartDays != nil && resource.anchorDateEndDays != nil {
                    
                    let anchorDateObject = Study.currentStudy?.anchorDate
                    if(anchorDateObject != nil && (anchorDateObject?.isAnchorDateAvailable())!) {
                        
                        
                        
                        let anchorDate = Study.currentStudy?.anchorDate?.date?.startOfDay
                        
                        if anchorDate != nil {
                            
                            //also anchor date condition
                            let startDateInterval = TimeInterval(60*60*24*(resource.anchorDateStartDays)!)
                            let endDateInterval = TimeInterval(60*60*24*(resource.anchorDateEndDays)!)
                            
                            let startAnchorDate = anchorDate?.addingTimeInterval(startDateInterval)
                            var endAnchorDate = anchorDate?.addingTimeInterval(endDateInterval)
                            
                            endAnchorDate = endAnchorDate?.endOfDay
                            let startDateResult = (startAnchorDate?.compare(todayDate))! as ComparisonResult
                            let endDateResult = (endAnchorDate?.compare(todayDate))! as ComparisonResult
                            
                            if ((startDateResult == .orderedAscending || startDateResult == .orderedSame) && (endDateResult == .orderedDescending || endDateResult == .orderedSame)){
                                
                                tableViewRowDetails?.append(resource)
                            }
                                //                        else if startDateResult == .orderedDescending {
                                //                            print("upcoming")
                                //                            return .upcoming
                                //                        }
                                //                        else if endDateResult == .orderedAscending {
                                //                            print("past")
                                //                            return .past
                                //                        }
                            else if startDateResult == .orderedDescending {
                                //upcoming
                                let notfiId = resource.resourcesId! + (Study.currentStudy?.studyId)!
                                DBHandler.isNotificationSetFor(notification: notfiId
                                    , completionHandler: { (found) in
                                        if !found {
                                            
                                            let notification = AppLocalNotification()
                                            notification.id = resource.resourcesId! + (Study.currentStudy?.studyId)!
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
                    else {
                        tableViewRowDetails?.append(resource)
                    }
                    
                    
                }
                else {
                    tableViewRowDetails?.append(resource)
                }
            }
            else {
                 tableViewRowDetails?.append(resource)
            }
            
        }
        
        self.appendLeaveStudy()
        
        
        tableView?.isHidden =  false
        tableView?.reloadData()
        
        
        StudyUpdates.studyResourcesUpdated = false
        DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
    }
    
    func navigateToStudyHome(){
        
        let studyStoryBoard = UIStoryboard.init(name: "Study", bundle: Bundle.main)
        let studyHomeController = studyStoryBoard.instantiateViewController(withIdentifier: String(describing: StudyHomeViewController.classForCoder())) as! StudyHomeViewController
        studyHomeController.hideViewConsentAfterJoining = true
        
        studyHomeController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(studyHomeController, animated: true)
        
    }
    
    
    func navigateToWebView(link:String?,htmlText:String?,pdfData:Data?){
        
        let loginStoryboard = UIStoryboard.init(name: "Main", bundle:Bundle.main)
        let webViewController = loginStoryboard.instantiateViewController(withIdentifier:"WebViewController") as! UINavigationController
        let webView = webViewController.viewControllers[0] as! WebViewController
        webView.isEmailAvailable = true
        
        if pdfData != nil {
            webView.pdfData = pdfData
        }
        
        self.navigationController?.present(webViewController, animated: true, completion: nil)
    }
    
    
    
    func checkDatabaseForStudyInfo(study:Study){
        
        DBHandler.loadStudyOverview(studyId: (study.studyId)!) { (overview) in
            if overview != nil {
                study.overview = overview
                self.navigateToStudyHome()
            }
            else {
                
                self.navigateToStudyOverview = true
                self.sendRequestToGetStudyInfo(study: study)
            }
        }
    }
    func sendRequestToGetStudyInfo(study:Study){
        
        
        
        WCPServices().getStudyInformation(studyId: study.studyId, delegate: self)
    }
    
    func pushToResourceDetails(){
        
        let path = AKUtility.baseFilePath + "/Study"
        let consentPath = Study.currentStudy?.signedConsentFilePath
        
        let fullPath = path + "/" + consentPath!
        
        let pdfData = FileDownloadManager.decrytFile(pathURL:URL.init(string: fullPath))
        
        
        if pdfData != nil {
            self.navigateToWebView(link: "", htmlText: "",pdfData:pdfData)
        }
    }
    
    
    func saveConsentPdfToLocal(base64dataString:String){
        
        let consentData = NSData(base64Encoded: base64dataString, options: .ignoreUnknownCharacters)
        
        var fullPath:String!
        let path =  AKUtility.baseFilePath + "/Study"
        let fileName:String = "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + ".pdf"
        
        fullPath = path + "/" + fileName
        
        if !FileManager.default.fileExists(atPath: path) {
            try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        
        do {
            
            if FileManager.default.fileExists(atPath: fullPath){
                
                try FileManager.default.removeItem(atPath: fullPath)
                
            }
            FileManager.default.createFile(atPath:fullPath , contents: consentData as Data?, attributes: [:])
            
            let defaultPath = fullPath
            
            fullPath = "file://" + "\(fullPath!)"
            
            try consentData?.write(to:  URL(string:fullPath!)!)
            
            FileDownloadManager.encyptFile(pathURL: URL(string:defaultPath!)!)
            
            Study.currentStudy?.signedConsentFilePath = fileName
            DBHandler.saveConsentInformation(study: Study.currentStudy!)
            
            self.pushToResourceDetails()
            
            
        } catch let error as NSError {
            print("error writing to url \(fullPath)")
            print(error.localizedDescription)
        }

    }
    
    func withdrawalFromStudy(deleteResponse:Bool)  {
        //TBD: uncomment following for UAT
        let participantId = Study.currentStudy?.userParticipateState.participantId
         LabKeyServices().withdrawFromStudy(studyId: (Study.currentStudy?.studyId)!, participantId: participantId!, deleteResponses: deleteResponse, delegate: self)
        
        //UserServices().withdrawFromStudy(studyId: (Study.currentStudy?.studyId)!, shouldDeleteData: deleteResponse, delegate: self)
    }
    
    
}


//MARK: TableView Data source
extension ResourcesViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return tableViewRowDetails!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let resource = (tableViewRowDetails?[indexPath.row])!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kResourcesTableViewCell, for: indexPath) as! ResourcesTableViewCell
        
        //Cell Data Setup
        
        if (resource as? Resource) != nil {
            // resources cell
            
            if Utilities.isValidValue(someObject: (resource as? Resource)?.title as AnyObject) {
                cell.populateCellData(data: ((resource as? Resource)?.title)!)
            }
            else{
                cell.labelTitle?.text = ""
            }
            
            
        }
        else{
            // default cells
            
            cell.populateCellData(data:resource as! String)
        }
        
       
        
        //cell.accessoryType = .disclosureIndicator
        
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

//MARK: TableView Delegates
extension ResourcesViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let resource = (tableViewRowDetails?[indexPath.row])!
        
        if (resource as? Resource) != nil {
            
            resourceLink = (resource as? Resource)?.file?.getFileLink()
            fileType = (resource as? Resource)?.file?.getMIMEType()
            self.performSegue(withIdentifier:"ResourceDetailViewSegueIdentifier" , sender: resource)
        }
        else{
            if resource as! String == "Leave Study" {
                
                //Incomplete web config
                
                // iF WEBCONFIG == ask_user
                
                var withdrawalMessage = Study.currentStudy?.withdrawalConfigration?.message
                
                var withdrawalType = Study.currentStudy?.withdrawalConfigration?.type
                
                if withdrawalMessage == nil {
                    withdrawalMessage = "Are you sure you want to leave Study ?"
                }
                
                if withdrawalType == nil {
                    withdrawalType = .notAvailable
                }
                
                
                UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString("Leave Study?", comment: ""), errorMessage: NSLocalizedString(withdrawalMessage!, comment: ""), errorAlertActionTitle: NSLocalizedString("Proceed", comment: ""),
                                                                     errorAlertActionTitle2: NSLocalizedString("Cancel", comment: ""), viewControllerUsed: self,
                                                                     action1: {
                                                                        
                                                                        
                                                                        switch withdrawalType! as StudyWithdrawalConfigrationType {
                                                                            
                                                                        case .askUser :
                                                                            
                                                                            UIUtilities.showAlertMessageWithThreeActionsAndHandler(kImportantNoteMessage, errorMessage: "You are choosing to leave the study. Please choose if the data you provided for the study so far, can be retained and used for research purposes OR if it should be deleted.", errorAlertActionTitle: "Retain my data", errorAlertActionTitle2: "Delete my data", errorAlertActionTitle3: "Cancel", viewControllerUsed: self, action1: {
                                                                                // Retain Action
                                                                                
                                                                                self.withdrawalFromStudy(deleteResponse: false)
                                                                                
                                                                               
                                                                                
                                                                            }, action2: {
                                                                                
                                                                                // Delete action
                                                                                
                                                                                self.withdrawalFromStudy(deleteResponse: true)
                                                                                
                                                                            }, action3: {
                                                                                // Cancel Action
                                                                            })
                                                                            
                                                                            
                                                                        case .deleteData:
                                                                            
                                                                            UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString("You are choosing to leave the study. Data that you have provided for the study so far, will be deleted from our databases. Tap OK to confirm that you wish to leave the study or Cancel to abstain from doing so.", comment: ""), errorMessage: NSLocalizedString("", comment: ""), errorAlertActionTitle: NSLocalizedString("OK", comment: ""),
                                                                                                                                 errorAlertActionTitle2: NSLocalizedString("Cancel", comment: ""), viewControllerUsed: self,
                                                                                                                                 action1: {
                                                                                                                                     self.withdrawalFromStudy(deleteResponse: true)
                                                                            },
                                                                                                                                 action2: {
                                                                                                                                    
                                                                            })
                                                                        
                                                                        case .noAction :
                                                                            
                                                                            UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString("You are choosing to leave the study. Data that you have provided for the study so far, will be retained in our databases for research purposes. Tap OK to confirm that you wish to leave the study or Cancel to abstain from doing so.", comment: ""), errorMessage: NSLocalizedString("", comment: ""), errorAlertActionTitle: NSLocalizedString("OK", comment: ""),
                                                                                                                                 errorAlertActionTitle2: NSLocalizedString("Cancel", comment: ""), viewControllerUsed: self,
                                                                                                                                 action1: {
                                                                                                                                    self.withdrawalFromStudy(deleteResponse: false)
                                                                            },
                                                                                                                                 action2: {
                                                                                                                                    
                                                                            })
                                                                            
                                                                            default : break
                                                                        }
                                                                       

                },
                                                                     action2: {
                                                                        
                })

               // else if no_action
                
                
                // else if delete_data
                
            }
            else if  resource as! String == "About the Study"{
                
                self.checkDatabaseForStudyInfo(study: Study.currentStudy!)
                
            }
            else if  resource as! String == "Consent PDF"{
                
                //PENDING
                
                if  Study.currentStudy?.signedConsentFilePath != nil {
                
                    self.pushToResourceDetails()
                }
                else{
                    
                    UserServices().getConsentPDFForStudy(studyId: (Study.currentStudy?.studyId)!, delegate: self)
                    
                }
            }
                
            else{
                
            }
        }
        
    }
    
}


extension ResourcesViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) response : \(response)" )
        
        
        
        if requestName as String == WCPMethods.resources.method.methodName {
            
            self.removeProgressIndicator()
            self.handleResourcesReponse()
            
            
        }
        else if requestName as String == ResponseMethods.withdrawFromStudy.method.methodName {
            
             //self.addProgressIndicator()
            UserServices().withdrawFromStudy(studyId: (Study.currentStudy?.studyId)!, shouldDeleteData: false, delegate: self)
        }
        else if requestName as String == RegistrationMethods.withdraw.method.methodName{
            
            
            DBHandler.deleteStudyData(studyId:(Study.currentStudy?.studyId)!)
            
            self.removeProgressIndicator()
            self.navigationController?.navigationBar.isHidden = false
            self.performSegue(withIdentifier: "unwindeToStudyListResourcesIdentifier", sender: self)

            
            
          //  let currentUserStudyStatus =  User.currentUser.updateStudyStatus(studyId:(Study.currentStudy?.studyId)!  , status: .withdrawn)
            
          //  UserServices().updateUserParticipatedStatus(studyStauts: currentUserStudyStatus, delegate: self)
           // self.addProgressIndicator()
        }
        else  if requestName as String == RegistrationMethods.updatePreferences.method.methodName{
           // self.navigationController?.navigationBar.isHidden = false
           // self.performSegue(withIdentifier: "unwindeToStudyListResourcesIdentifier", sender: self)
            self.removeProgressIndicator()
        }
        else if(requestName as String == WCPMethods.studyInfo.rawValue){
            
            self.removeProgressIndicator()
            StudyUpdates.studyInfoUpdated = false
            DBHandler.updateMetaDataToUpdateForStudy(study: Study.currentStudy!, updateDetails: nil)
            
            if self.navigateToStudyOverview == true{
                // this means that about the study has been tapped and get study info has been called
                self.navigateToStudyOverview = false
                self.tabBarController?.tabBar.isHidden = true
                
                self.navigateToStudyHome()
            }
            
            
        }
        else if requestName as String == RegistrationMethods.consentPDF.method.methodName{
            
            self.removeProgressIndicator()
            let consentDict:Dictionary<String,Any> = (response as! Dictionary<String,Any>)[kConsentPdfKey] as! Dictionary<String, Any>
            
            if Utilities.isValidObject(someObject:consentDict as AnyObject? ){
                
                if Utilities.isValidValue(someObject: consentDict[kConsentVersion] as AnyObject?){
                    Study.currentStudy?.signedConsentVersion = consentDict[kConsentVersion] as? String
                }
                else{
                     Study.currentStudy?.signedConsentVersion = "No_Version"
                }
                
                /* supposed that mime type of consent remains pdf
                if Utilities.isValidValue(someObject: consentDict[kFileMIMEType] as AnyObject?){
                    Study.currentStudy?.signedConsentVersion = consentDict[kConsentVersion] as? String
                }
 */
                
                if Utilities.isValidValue(someObject: consentDict[kConsentPdfContent] as AnyObject?){
                    self.saveConsentPdfToLocal(base64dataString: consentDict[kConsentPdfContent] as! String )
                }
                
                
            }
            
            
        }
        else if(requestName as String == WCPMethods.studyInfo.rawValue){
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
            
            if requestName as String == WCPMethods.resources.method.methodName {
                
                tableViewRowDetails = []
                self.addDefaultList()
                self.appendLeaveStudy()
                self.tableView?.isHidden = false
                self.tableView?.reloadData()
                
                
            }
            else {
                 UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kErrorTitle, comment: "") as NSString, message: error.localizedDescription as NSString)
            }
        }
    }
}


public extension String {
    /// Decodes string with html encoding.
    var htmlDecoded: String {
        guard let encodedData = self.data(using: .utf8) else { return self }
        
        let attributedOptions: [String : Any] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue]
        
        do {
            let attributedString = try NSAttributedString(data: encodedData,
                                                          options: attributedOptions,
                                                          documentAttributes: nil)
            return attributedString.string
        } catch {
            print("Error: \(error)")
            return ""
        }
    }
}

