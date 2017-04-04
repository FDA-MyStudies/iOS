//
//  ContactUsViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/22/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class ContactUsViewController : UIViewController{
    
    var tableViewRowDetails : NSMutableArray?
    
    @IBOutlet var buttonSubmit : UIButton?
    @IBOutlet var tableView : UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Used to set border color for bottom view
        buttonSubmit?.layer.borderColor = kUicolorForButtonBackground
        
        //Automatically takes care  of text field become first responder and scroll of tableview
        IQKeyboardManager.sharedManager().enable = true
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "ContactUs", ofType: ".plist", inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
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
extension ContactUsViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kContactUsTableViewCellIdentifier, for: indexPath) as! ContactUsTableViewCell
        
        cell.textFieldValue?.tag = indexPath.row
        
        var keyBoardType : UIKeyboardType? =  UIKeyboardType.default
        let textFieldTag = ContactTextFieldTags(rawValue:indexPath.row)!
        
        //Cell ContactTextField data setup
        switch  textFieldTag {
        case .FirstName , .Subject:
            keyBoardType = .default
        case .Email :
            keyBoardType = .emailAddress
        }
        
        //Cell Data Setup
        cell.populateCellData(data: tableViewData,keyboardType: keyBoardType)
        
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

//MARK: TableView Delegates
extension ContactUsViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}





