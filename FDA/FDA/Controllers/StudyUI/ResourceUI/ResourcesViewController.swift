//
//  ResourcesViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/24/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class ResourcesViewController : UIViewController{
    
    var tableViewRowDetails : [AnyObject]? = []
    
    @IBOutlet var tableView : UITableView?
    var resourceLink:String?
    var fileType:String?
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
        WCPServices().getResourcesForStudy(studyId: "STDPD", delegate: self)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         UIApplication.shared.statusBarStyle = .default
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
               
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
    }
    
    
    @IBAction func homeButtonAction(_ sender: AnyObject){
        self.navigationController?.navigationBar.isHidden = false
        self.performSegue(withIdentifier: "unwindeToStudyListResourcesIdentifier", sender: self)
        
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
        if (Study.currentStudy?.studySettings.rejoinStudyAfterWithdrawn)! != false {
            tableViewRowDetails?.append("Leave Study" as AnyObject)
        }
    }
    
    func handleResourcesReponse(){
        
        self.addDefaultList()
        
        //Add resources list
        for  resource in (Study.currentStudy?.resources)!{
            tableViewRowDetails?.append(resource)
        }
        
        self.appendLeaveStudy()
        
       
        tableView?.isHidden =  false
        tableView?.reloadData()
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
            self.performSegue(withIdentifier:"ResourceDetailViewControllerIdentifier" , sender: resource)
        }
        else{
            if resource as! String == "Leave Study" {
                
                //Incomplete web config
                
                // iF WEBCONFIG == ask_user
                
                UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString("Leave Study", comment: ""), errorMessage: NSLocalizedString("Are you sure you want to leave Study ?", comment: ""), errorAlertActionTitle: NSLocalizedString("Leave Study", comment: ""),
                                                                     errorAlertActionTitle2: NSLocalizedString("Cancel", comment: ""), viewControllerUsed: self,
                                                                     action1: {
                                                                        
                                                                        LabKeyServices().withdrawFromStudy(studyId: (Study.currentStudy?.studyId)!, participantId: User.currentUser.userId, deleteResponses: false, delegate: self)
                                                                        
                                                                       
                },
                                                                     action2: {
                                                                        
                })

               // else if no_action
                
                
                // else if delete_data
                
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
        
        self.removeProgressIndicator()
        
        if requestName as String == WCPMethods.resources.method.methodName {
            
            self.handleResourcesReponse()
            
            
        }
        else if requestName as String == ResponseMethods.withdrawFromStudy.method.methodName {
            
             self.addProgressIndicator()
            UserServices().withdrawFromStudy(studyId: (Study.currentStudy?.studyId)!, shouldDeleteData: false, delegate: self)
        }
        else if requestName as String == RegistrationMethods.withdraw.method.methodName{
            
            
            self.navigationController?.navigationBar.isHidden = false
            self.performSegue(withIdentifier: "unwindeToStudyListResourcesIdentifier", sender: self)

            
            
          //  let currentUserStudyStatus =  User.currentUser.updateStudyStatus(studyId:(Study.currentStudy?.studyId)!  , status: .withdrawn)
            
          //  UserServices().updateUserParticipatedStatus(studyStauts: currentUserStudyStatus, delegate: self)
           // self.addProgressIndicator()
        }
        else  if requestName as String == RegistrationMethods.updatePreferences.method.methodName{
           // self.navigationController?.navigationBar.isHidden = false
           // self.performSegue(withIdentifier: "unwindeToStudyListResourcesIdentifier", sender: self)
        }
        
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        
        
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

