//
//  FeedBackViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/22/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class FeedBackViewController : UIViewController{
    
    @IBOutlet var buttonSubmit : UIButton?
    @IBOutlet var tableView : UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Used to set border color for bottom view
        buttonSubmit?.layer.borderColor = kUicolorForButtonBackground
        
        //self.tableView?.estimatedRowHeight = 123
        //self.tableView?.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}

//MARK: TableView Data source
extension FeedBackViewController: UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        
        var cell : UITableViewCell?
        
        if indexPath.row == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: kFeedbackTableViewCellIdentifier1, for: indexPath) as! FeedBackTableViewCell
            //(cell as! FeedBackTableViewCell).displayTableData(data: data , collectionArraydata: upcomingEventsArray)
        
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: kFeedbackTableViewCellIdentifier2, for: indexPath) as! FeedBackTableViewCell
        
        }
        
        return cell!
    }
}

//MARK: TableView Delegates
extension FeedBackViewController : UITableViewDelegate{

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}





