//
//  NotificationViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/1/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit




class NotificationViewController : UIViewController{
    
    @IBOutlet var tableView : UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString(kNotificationsTitleText, comment: "")
        
        WCPServices().getNotification(skip: 1, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
}

//MARK: TableView Datasource
extension NotificationViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Gateway.instance.notification?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : NotificationTableViewCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier:kNotificationTableViewCellIdentifier , for: indexPath) as? NotificationTableViewCell
        
        cell?.populateCellWith(appNotification: (Gateway.instance.notification?[indexPath.row])!)
        cell?.backgroundColor = UIColor.clear
        return cell!
    }
    
    func pushToStudyDashboard(type:AppNotification.NotificationSubType?){
        
        let viewController:StudyDashboardTabbarViewController?
          let storyboard = UIStoryboard(name: "Study", bundle: nil)
        if type != nil {
        
           self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            viewController = storyboard.instantiateViewController(withIdentifier: kStudyDashboardTabbarControllerIdentifier) as? StudyDashboardTabbarViewController
            
        switch type! as  AppNotification.NotificationSubType{
        case .Study:
            
            viewController?.selectedIndex = 0
             self.navigationController?.pushViewController(viewController!, animated: true)
        case .Resource:
            
             viewController?.selectedIndex = 2
             self.navigationController?.pushViewController(viewController!, animated: true)
        case .Activity:
            
             viewController?.selectedIndex = 1
             self.navigationController?.pushViewController(viewController!, animated: true)
        default: break
            
        }
        }
    }
    
    
    
}

//MARK: TableView Delegates
extension NotificationViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let appNotif = (Gateway.instance.notification?[indexPath.row])!
        
        if Utilities.isValidValue(someObject: appNotif.studyId as AnyObject?) {
            
            if Gateway.instance.studies!.contains(where: { $0.studyId == appNotif.studyId }){
                
              let index =  Gateway.instance.studies?.index(where: { $0.studyId == appNotif.studyId })
                
                Study.updateCurrentStudy(study:(Gateway.instance.studies?[index!])! )
                
                  self.pushToStudyDashboard(type:appNotif.subType )
            }
            
        }
    
    }
}



extension NotificationViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) Response : \(response)")
        
        self.removeProgressIndicator()
        
        if requestName as String == WCPMethods.notifications.method.methodName {
            
           self.tableView?.reloadData()
            
            self.tableView?.isHidden = false
        }
       
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
    }
}


