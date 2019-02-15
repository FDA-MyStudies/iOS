//
//  StandaloneStudy.swift
//  FDA
//
//  Created by Surender Rathore on 12/21/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StandaloneStudy: NSObject {
    
    
    
    func createStudyForStandalone() {
        
        WCPServices().getStudyList(self)
        
//        let studyDetail = ["category":"Drug Safety",
//                           "logo":"https://hphci-fdama-st-wcp-01.labkey.com/fdaResources/studylogo/STUDY_HT_06072017020809.jpeg?v=1513764405945",
//                           "settings" :             [
//                            "enrolling" : true,
//                            "platform" : "all",
//                            "rejoin" : false
//            ],
//                           "sponsorName" : " FDA",
//                           "status" : "Active",
//                           "studyId" : "TESTSTUDY01",
//                           "studyVersion" : "48.2",
//                           "tagline" : "A study on exposures exposures during Human Eye.",
//                           "title" : "Human Eye"] as [String : Any]
//
//        let study = Study.init(studyDetail: studyDetail)
//        Study.updateCurrentStudy(study: study)
//
//        let studylist:Array<Study> = [study]
//        Gateway.instance.studies = studylist
//
//        Logger.sharedInstance.info("Studies Saving in DB")
//        //save in database
//        DBHandler().saveStudies(studies: studylist)
//
//        self.fetchStudyDashboardInfo()
    }
    
    func setupStandaloneStudy() {
        //self.getStudyStates()
        self.createStudyForStandalone()
    }
    
    func getStudyStates() {
        UserServices().getStudyStates(self)
    }
    
    func getStudyDashboardInfo() {
        WCPServices().getStudyInformation(studyId: (Study.currentStudy?.studyId)!, delegate: self)
    }
    
    func fetchStudyDashboardInfo() {
        
    
        DBHandler.loadStudyOverview(studyId: (Study.currentStudy?.studyId)!) { (overview) in
            if overview != nil {
                Study.currentStudy?.overview = overview
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "StudySetupCompleted"), object: nil)
                self.getStudyUpdates()
            }
            else {
                self.getStudyDashboardInfo()
            }
        }
    }
    func getStudyUpdates(){
        
        let study = Study.currentStudy
        DBHandler.loadStudyDetailsToUpdate(studyId: (study?.studyId)!, completionHandler: { (success) in
          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "StudySetupCompleted"), object: nil)
            //self.pushToStudyDashboard()
            //self.removeProgressIndicator()
            //self.checkDatabaseForStudyInfo(study: study!)
        })
    }
    func handleStudyListResponse(){
        
        Logger.sharedInstance.info("Study Response Handler")
        
        if (Gateway.instance.studies?.count)! > 0{
            DBHandler.loadStudyListFromDatabase { (studies) in
                if studies.count > 0 {
                    Logger.sharedInstance.info(studies)
                    
                    let study = studies.filter({$0.studyId == "PreganancyStudy"})
                    
                    Study.updateCurrentStudy(study:study.last!)
                    self.getStudyDashboardInfo()
                }
                else {
                    // no study found send controler back from here
                }
            }
          
        }
       
    }
}

//MARK:- Webservices Delegates
extension StandaloneStudy:NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname START : \(requestName)")
        
        //let appdelegate = UIApplication.shared.delegate as! AppDelegate
        //appdelegate.window?.addProgressIndicatorOnWindowFromTop()
        
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname FINISH: \(requestName) : \(response)")
        
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        if(requestName as String == WCPMethods.studyList.rawValue){
            self.handleStudyListResponse()
        }
        
        if(requestName as String == WCPMethods.studyInfo.rawValue){
        
            self.fetchStudyDashboardInfo()
        }
        else if (requestName as String == RegistrationMethods.studyState.description){
        
            self.createStudyForStandalone()
        }
        
        
        
    }
    
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname Failed: \(requestName)")
        
        //--
        //self.removeProgressIndicator()
        //--
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        appdelegate.window?.removeProgressIndicatorFromWindow()
        
        if error.code == 403 { //unauthorized
//            UIUtilities.showAlertMessageWithActionHandler(kErrorTitle, message: error.localizedDescription, buttonTitle: kTitleOk, viewControllerUsed: self, action: {
//                self.fdaSlideMenuController()?.navigateToHomeAfterUnauthorizedAccess()
//            })
        }
        else {
            
            UIUtilities.showAlertWithMessage(alertMessage: error.localizedDescription)
//            UIUtilities.showAlertMessageWithActionHandler(kErrorTitle, message: error.localizedDescription, buttonTitle: kTitleOk, viewControllerUsed: self, action: {
//                self.fdaSlideMenuController()?.navigateToHomeAfterUnauthorizedAccess()
//            })

         
        }
    }
}
