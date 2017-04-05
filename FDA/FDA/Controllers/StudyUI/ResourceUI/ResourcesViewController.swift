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
    
    var tableViewRowDetails : NSMutableArray?
    
    @IBOutlet var tableView : UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "Resources", ofType: ".plist", inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
        self.navigationItem.title = NSLocalizedString("Resources", comment: "")
        
        WCPServices().getResourcesForStudy(studyId: (Study.currentStudy?.studyId)!, delegate: self)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @IBAction func homeButtonAction(_ sender: AnyObject){
        
        
    }
}


//MARK: TableView Data source
extension ResourcesViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDetails!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! String
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kResourcesTableViewCell, for: indexPath) as! ResourcesTableViewCell
        
        //Cell Data Setup
        cell.populateCellData(data: tableViewData)
        //cell.accessoryType = .disclosureIndicator
        
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

//MARK: TableView Delegates
extension ResourcesViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


extension ResourcesViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        //self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        //self.removeProgressIndicator()
        
        if requestName as String == WCPMethods.resources.method.methodName {
            
        }
        
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        //self.removeProgressIndicator()
        
        
        
    }
}


