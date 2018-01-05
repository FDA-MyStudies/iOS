//
//  ConfirmationViewController.swift
//  FDA
//
//  Created by Arun Kumar on 3/8/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

let kConfirmationSegueIdentifier = "confirmationSegue"
let kHeaderDescription = "You have chosen to delete your FDA My Studies Account. This will result in automatic withdrawal from all studies.\nBelow is a list of studies that you are a part of and information on how your response data will be handled with each after you withdraw. Please review and confirm."

let kConfirmWithdrawlSelectOptionsAlert = "Please select an option between Delete Data or Retain Data for all studies."
let kResponseDataDeletedText = "Response data will be deleted"
let kResponseDataRetainedText = "Response data will be retained"

let kConfirmationCellType = "type"
let kConfirmationCellTypeOptional = "Optional"
let kConfrimationOptionalCellIdentifier = "ConfirmationOptionalCell"
let kConfrimationCellIdentifier = "ConfirmationCell"
let kConfirmationTitle = "title"
let kConfirmationPlaceholder = "placeHolder"
let kConfirmationPlist = "Confirmation"
let kConfirmationNavigationTitle = "DELETE ACCOUNT"
let kPlistFileType = ".plist"



class StudyToDelete{
    
    var studyId:String!
    var shouldDelete:Bool?
    var participantId:String!
    
    init() {
        
    }
}
class ConfirmationViewController: UIViewController {
    
    var tableViewRowDetails : NSMutableArray?
    
    @IBOutlet var tableViewConfirmation : UITableView?
    @IBOutlet var tableViewHeaderViewConfirmation : UIView?
    @IBOutlet var tableViewFooterViewConfirmation : UIView?
    @IBOutlet var buttonDeleteAccount:UIButton?
    @IBOutlet var buttonDoNotDeleteAccount:UIButton?
    @IBOutlet var LabelHeaderDescription:UILabel?
    var studiesToDisplay:Array<Study>! = []
    var joinedStudies:Array<Study>! = []
    var studyWithoutWCData:Study?
    var studiesToWithdrawn:Array<StudyToDelete>! = []
    
    //MARK:- View Controller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load plist info
        let plistPath = Bundle.main.path(forResource: kConfirmationPlist, ofType:kPlistFileType , inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
        // setting the headerdescription
        self.LabelHeaderDescription?.text = kHeaderDescription
        
        // setting border color for footer buttons
        self.buttonDeleteAccount?.layer.borderColor = kUicolorForButtonBackground
        self.buttonDoNotDeleteAccount?.layer.borderColor = kUicolorForButtonBackground
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.title = NSLocalizedString(kConfirmationNavigationTitle, comment: "")
        
        self.checkWithdrawlConfigurationForNextSuty()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addBackBarButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Helper Methods
    func checkWithdrawlConfigurationForNextSuty() {
        
        if joinedStudies.count != 0 {
            
            let study = joinedStudies.first
            
            if study?.withdrawalConfigration?.type == StudyWithdrawalConfigrationType.notAvailable {
                
                Study.updateCurrentStudy(study: study!)
                self.sendRequestToGetInfoForStudy(study: study!)
                
            }else {
                studiesToDisplay.append(study!)
                joinedStudies.removeFirst()
                
                let studiesIds = studiesToDisplay.map({$0.studyId!})
                print("studies to display \(studiesIds)")
                
                self.checkWithdrawlConfigurationForNextSuty()
            }
        }else {
            
            self.removeProgressIndicator()
            self.createListOfStudiesToDelete()
        }
    }
    
    func createListOfStudiesToDelete() {
        
        for study in studiesToDisplay {
            var withdrawnStudy = StudyToDelete()
            withdrawnStudy.studyId = study.studyId
            withdrawnStudy.participantId = study.userParticipateState.participantId
            
            if study.withdrawalConfigration?.type == StudyWithdrawalConfigrationType.deleteData {
                withdrawnStudy.shouldDelete = true
                
            }else if study.withdrawalConfigration?.type == StudyWithdrawalConfigrationType.noAction {
                withdrawnStudy.shouldDelete = false
            }
            
            studiesToWithdrawn.append(withdrawnStudy)
        }
    }
    
    //MARK:- Webservice Response Handlers
    func sendRequestToGetInfoForStudy(study:Study) {
        WCPServices().getStudyInformation(studyId: study.studyId, delegate: self)
    }
    
    //MARK:- Webservice Response Handlers
    
    /**
     Handle delete account webservice response
     */
    func handleDeleteAccountResponse() {
       
        let leftController = slideMenuController()?.leftViewController as! LeftMenuViewController
        leftController.changeViewController(.studyList)
        leftController.createLeftmenuItems()
        
    }
    
    func handleStudyInformationResonse() {
        
        studiesToDisplay.append(Study.currentStudy!)
        joinedStudies.removeFirst()
        
        self.checkWithdrawlConfigurationForNextSuty()
        self.tableViewConfirmation?.reloadData()
    }
    
    func handleWithdrawnFromStudyResponse() {
        
        studiesToWithdrawn.removeFirst()
        self.withdrawnFromNextStudy()
    }
    
    //MARK:- Button Actions
    
    /**
     Delete account button clicked
     @param sender  Accepts UIButton object
     */
    @IBAction func deleteAccountAction(_ sender:UIButton){
        
        var found:Bool = false
        for withdrawnStudy in studiesToWithdrawn {
            if withdrawnStudy.shouldDelete == nil {
                
                UIUtilities.showAlertWithMessage(alertMessage: NSLocalizedString(kConfirmWithdrawlSelectOptionsAlert, comment: ""))
                found = true
                break;
            }
        }
        if !found {
            self.withdrawnFromNextStudy()
        }
    }
    
    func withdrawnFromNextStudy(){
        
        if studiesToWithdrawn.count != 0 {
            
            let studyToWithdrawn = studiesToWithdrawn.first
            LabKeyServices().withdrawFromStudy(studyId: (studyToWithdrawn?.studyId)!, participantId: (studyToWithdrawn?.participantId)!, deleteResponses: (studyToWithdrawn?.shouldDelete)!, delegate: self)
        }else {
            //call for delete account
            
            let studiesIds = studiesToDisplay.map({$0.studyId!})
            UserServices().deActivateAccount(listOfStudyIds: studiesIds, delegate: self)
        }
    }
    
    /**
     Donot Delete button action
     @param sender  Accepts UIButton object
     */
    @IBAction func doNotDeleteAccountAction(_ sender:UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}


//MARK:- TableView Data source
extension ConfirmationViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studiesToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let study = studiesToDisplay[indexPath.row]
        if study.withdrawalConfigration?.type == StudyWithdrawalConfigrationType.askUser {
            
            let  cell = tableView.dequeueReusableCell(withIdentifier: kConfrimationOptionalCellIdentifier, for: indexPath) as! ConfirmationOptionalTableViewCell
            cell.delegate = self
            cell.study = study
            
            cell.labelTitle?.text = study.name 
            
            return cell
            
        }else {
            // for ConfirmationTableViewCell data
            let cell = tableView.dequeueReusableCell(withIdentifier: kConfrimationCellIdentifier, for: indexPath) as! ConfirmationTableViewCell
            cell.labelTitle?.text = study.name
            
            if study.withdrawalConfigration?.type == StudyWithdrawalConfigrationType.deleteData {
                cell.labelTitleDescription?.text = NSLocalizedString(kResponseDataDeletedText, comment: "")
            }else {
                cell.labelTitleDescription?.text = NSLocalizedString(kResponseDataRetainedText, comment: "")
            }
            return cell
        }
    }
}

//MARK:- TableView Delegates
extension ConfirmationViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //print(indexPath.row)
    }
}

extension ConfirmationViewController : ConfirmationOptionalDelegate{
    
    func confirmationCell(cell: ConfirmationOptionalTableViewCell, forStudy study: Study, deleteData: Bool) {
        
        if var withdrawnStudy = self.studiesToWithdrawn.filter({$0.studyId == study.studyId}).last {
            withdrawnStudy.shouldDelete = deleteData
        }
    }
}

//MARK:- UserService Response handler
extension ConfirmationViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        if requestName as String ==  RegistrationMethods.deactivate.description {
            self.removeProgressIndicator()
            self.handleDeleteAccountResponse()
            
        }else if(requestName as String == WCPMethods.studyInfo.rawValue) {
            self.handleStudyInformationResonse()
            
        }else if(requestName as String == ResponseMethods.withdrawFromStudy.description) {
            self.handleWithdrawnFromStudyResponse()
        }
    }
    
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        if error.code == 403 { //unauthorized
            self.removeProgressIndicator()
            UIUtilities.showAlertMessageWithActionHandler(kErrorTitle, message: error.localizedDescription, buttonTitle: kTitleOk, viewControllerUsed: self, action: {
                self.fdaSlideMenuController()?.navigateToHomeAfterUnauthorizedAccess()
            })
            
        }else {
            if(requestName as String == WCPMethods.studyInfo.rawValue) {
                self.removeProgressIndicator()
                
            }else if requestName as String == ResponseMethods.withdrawFromStudy.description {
                if error.localizedDescription.localizedCaseInsensitiveContains("Invalid ParticipantId.") {
                    
                    self.handleWithdrawnFromStudyResponse()
                    
                }else {
                    self.removeProgressIndicator()
                }
            }else {
                self.removeProgressIndicator()
                UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kErrorTitle, comment: "") as NSString, message: error.localizedDescription as NSString)
            }
        }
    }
}



