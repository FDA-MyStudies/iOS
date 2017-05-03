//
//  ReachoutOptionsViewController.swift
//  FDA
//
//  Created by Surender Rathore on 4/5/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class ReachoutOptionsViewController: UIViewController {

    @IBOutlet var tableView:UITableView?
    
    
//MARK:- Viewcontroller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title =  NSLocalizedString("REACH OUT", comment: "")
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBarItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//MARK:- TableView Data source
extension ReachoutOptionsViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reachoutCell", for: indexPath) as! ReachoutOptionCell
        
        
        switch indexPath.row {
        case 0:
            cell.labelTitle?.text = NSLocalizedString("Leave Anonymous Feedback", comment: "")
        case 1:
            cell.labelTitle?.text = NSLocalizedString("Need Help? Contact Us", comment: "")
        default:
            cell.labelTitle?.text = NSLocalizedString("Need Help? Contact Us", comment: "")
        }
        
        
        return cell
    }
}

//MARK:- TableView Delegates
extension ReachoutOptionsViewController :  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        switch indexPath.row {
        case 1:
            self.performSegue(withIdentifier: "contactusSegue", sender: self)
        case 0:
            self.performSegue(withIdentifier: "feedbackSegue", sender: self)
        default:
            debugPrint("default")
        }
    }
}



