//
//  ActivitiesViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class ActivitiesViewController : UIViewController{
    
    var tableViewRowDetails : NSMutableArray?
    
    @IBOutlet var tableView : UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "Activities", ofType: ".plist", inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
        self.navigationItem.title = NSLocalizedString("STUDY ACTIVITIES", comment: "")
        self.tableView?.sectionHeaderHeight = 30
        
        if (Study.currentStudy?.studyId) != nil {
            WCPServices().getStudyActivityList(studyId: (Study.currentStudy?.studyId)!, delegate: self)
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         UIApplication.shared.statusBarStyle = .default
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    
    
    
    @IBAction func homeButtonAction(_ sender: AnyObject){
        //_ = self.navigationController?.popToRootViewController(animated: true)
        
       
        
        self.performSegue(withIdentifier: "unwindeToStudyListIdentier", sender: self)
        
        
    }
    
    @IBAction func filterButtonAction(_ sender: AnyObject){
        
        
    }
}

//MARK: TableView Data source
extension ActivitiesViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (tableViewRowDetails?.count)!
    }
    
    private func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionHeader = tableViewRowDetails?[section] as! NSDictionary
        let sectionHeaderData = sectionHeader["items"] as! NSArray
        return sectionHeaderData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        view.backgroundColor = kBackgroundTableViewColor
        
        let dayData = tableViewRowDetails?[section] as! NSDictionary
        
        let statusText = dayData["status"] as! String
        
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
        
        let tableViewData = tableViewRowDetails?.object(at: indexPath.section) as! NSDictionary
        let projectInfo = tableViewData["items"] as! NSArray
        let project = projectInfo[indexPath.row] as! NSMutableDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kActivitiesTableViewCell, for: indexPath) as! ActivitiesTableViewCell
        
        //Cell Data Setup
        cell.populateCellData(data: project)
        
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

//MARK: TableView Delegates
extension ActivitiesViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ActivitiesViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        //self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        //self.removeProgressIndicator()
        
        if requestName as String == WCPMethods.activityList.method.methodName {
            
        }
        
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        //self.removeProgressIndicator()
        
        
        
    }
}



