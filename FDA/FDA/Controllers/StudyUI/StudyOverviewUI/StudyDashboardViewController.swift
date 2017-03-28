//
//  StudyDashboardViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/27/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class StudyDashboardViewController : UIViewController{
    
    var tableViewRowDetails = NSMutableArray()
    var todayActivitiesArray = NSMutableArray()
    var statisticsArray = NSMutableArray()
    
    @IBOutlet var tableView : UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "StudyDashboard", ofType: ".plist", inDirectory:nil)
        let tableViewRowDetailsdat = NSMutableArray.init(contentsOfFile: plistPath!)
        
        let tableviewdata = tableViewRowDetailsdat?[0] as! NSDictionary
        
        tableViewRowDetails = tableviewdata["studyActivity"] as! NSMutableArray
        todayActivitiesArray = tableviewdata["todaysActivity"] as! NSMutableArray
        statisticsArray = tableviewdata["statistics"] as! NSMutableArray
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
}

//MARK: TableView Data source
extension StudyDashboardViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1//tableViewRowDetails.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewRowDetails.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //Used for the last cell Height (trends cell)
        if indexPath.section == tableViewRowDetails.count{
            return 55
        }
        
        let data = self.tableViewRowDetails[indexPath.section] as! NSDictionary
        
        var heightValue : CGFloat = 0
        if data["isTableViewCell"] as! String == "YES" {
            
            //Used for Table view Height in a cell
            switch indexPath.section {
            case 0:
                heightValue = 55
            case 1:
                heightValue = 160
            case 2:
                heightValue = 70
            default:
                return 0
            }
            
        }else{
            //Used for Collection View Height in a cell
            if data["isStudy"] as! String == "YES" {
                heightValue = 130
            }else{
                heightValue = 150
            }
        }
        
        return heightValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell?
        
        //Used to display the last cell trends
        if indexPath.section == tableViewRowDetails.count{
            
            cell = tableView.dequeueReusableCell(withIdentifier: kTrendTableViewCell, for: indexPath) as! StudyDashboardTableViewCell
            return cell!
        }
        
        let tableViewData = tableViewRowDetails.object(at: indexPath.section) as! NSDictionary
        
        if tableViewData["isTableViewCell"] as! String == "YES" {
            
            //Used for Table view Cell
            switch indexPath.section {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: kWelcomeTableViewCell, for: indexPath) as! StudyDashboardTableViewCell
                (cell as! StudyDashboardTableViewCell).displayFirstCelldata(data: tableViewData)
                
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: kStudyActivityTableViewCell, for: indexPath) as! StudyDashboardTableViewCell
                (cell as! StudyDashboardTableViewCell).displaySecondCelldata(data: tableViewData)
                
            case 2:
                cell = tableView.dequeueReusableCell(withIdentifier: kPercentageTableViewCell, for: indexPath) as! StudyDashboardTableViewCell
                (cell as! StudyDashboardTableViewCell).displayThirdCellData(data: tableViewData)
                
            default:
                return cell!
            }
            
        }else{
            
            //Used for Collection View cell
            if tableViewData["isStudy"] as! String == "YES"{
                
                cell = tableView.dequeueReusableCell(withIdentifier: kActivityTableViewCell, for: indexPath) as! StudyDashboardActivityTableViewCell
                (cell as! StudyDashboardActivityTableViewCell).activityArrayData = todayActivitiesArray
                (cell as! StudyDashboardActivityTableViewCell).activityCollectionView?.reloadData()
            }
            
           else if tableViewData["isStudy"] as! String == "NO"{
                
                cell = tableView.dequeueReusableCell(withIdentifier: kStatisticsTableViewCell, for: indexPath) as! StudyDashboardStatisticsTableViewCell
                (cell as! StudyDashboardStatisticsTableViewCell).statisticsArrayData = statisticsArray
                (cell as! StudyDashboardStatisticsTableViewCell).statisticsCollectionView?.reloadData()
            }
        }
        
        return cell!
    }
}

//MARK: TableView Delegates
extension StudyDashboardViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        
    }
}


