//
//  FeedBackViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/22/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class FeedBackViewController : UIViewController{
    
    @IBOutlet var buttonSubmit : UIButton?
    @IBOutlet var tableView : UITableView?
    var feedbackText:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title =  NSLocalizedString("FEEDBACK", comment: "")
        
        //Used to set border color for bottom view
        buttonSubmit?.layer.borderColor = kUicolorForButtonBackground
        
        //Automatically takes care  of text field become first responder and scroll of tableview
        IQKeyboardManager.sharedManager().enable = true

        
        self.tableView?.estimatedRowHeight = 123
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        
        self.addBackBarButton()
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
    
    @IBAction func buttonSubmitAciton(_ sender:UIButton){
        //print("\(ContactUsFeilds.firstName)")
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

extension FeedBackViewController: UITextViewDelegate {
    
    
    func textViewDidChange(_ textView: UITextView) {
        let currentOffset = tableView?.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView?.beginUpdates()
        tableView?.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView?.setContentOffset(currentOffset!, animated: false)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
        if textView.tag == 101 && textView.text.characters.count == 0 {
            textView.text = "Enter your feedback here"
            textView.textColor = UIColor.lightGray
            textView.tag = 100
        }
        else {
            self.feedbackText = textView.text!
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
        
        if textView.tag == 100 {
            textView.text = ""
            textView.textColor = UIColor.black
            textView.tag = 101
        }
    }
}




