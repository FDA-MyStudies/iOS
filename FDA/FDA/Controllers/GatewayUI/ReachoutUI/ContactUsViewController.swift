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


struct ContactUsFeilds {
    
    static var firstName:String = ""
    static var email:String = ""
    static var subject:String = ""
    static var message:String = ""
    
}

class ContactUsViewController : UIViewController{
    
    var tableViewRowDetails : NSMutableArray?
    
    @IBOutlet var buttonSubmit : UIButton?
    @IBOutlet var tableView : UITableView?
    @IBOutlet var tableViewFooter : UIView?
    @IBOutlet var feedbackTextView : UITextView?
    var previousContentHeight:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title =  NSLocalizedString("CONTACT US", comment: "")
        
        //Used to set border color for bottom view
        buttonSubmit?.layer.borderColor = kUicolorForButtonBackground
        
        //Automatically takes care  of text field become first responder and scroll of tableview
        IQKeyboardManager.sharedManager().enable = true
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "ContactUs", ofType: ".plist", inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
        self.addBackBarButton()
        
        self.tableView?.estimatedRowHeight = 62
        self.tableView?.rowHeight = UITableViewAutomaticDimension
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
        print("\(ContactUsFeilds.firstName)")
    }
}

//MARK: TableView Data source
extension ContactUsViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = UITableViewCell()
        if indexPath.row == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "textviewCell", for: indexPath) as! TextviewCell
            return cell
        }
        else {
            
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
                cell.textFieldValue?.text = User.currentUser.emailId!
                keyBoardType = .emailAddress
            }
            
            //Cell Data Setup
            cell.populateCellData(data: tableViewData,keyboardType: keyBoardType)
            
            cell.backgroundColor = UIColor.clear
            return cell
        }
        
        return cell
    }
   
}

//MARK: TableView Delegates
extension ContactUsViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ContactUsViewController: UITextViewDelegate {

    
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
            textView.text = "Enter your message here"
            textView.textColor = UIColor.lightGray
            textView.tag = 100
        }
        else {
            ContactUsFeilds.message = textView.text!
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

//MARK: Textfield Delegate
extension ContactUsViewController : UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let tag:ContactTextFieldTags = ContactTextFieldTags(rawValue: textField.tag)!
        let finalString = textField.text! + string
      
        
        if string == " " {
            return false
        }
        
        if  tag == .Email {
            if string == " " || finalString.characters.count > 255{
                return false
            }
            else{
                return true
            }
        }
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text!)
        
        textField.text =  textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let tag:ContactTextFieldTags = ContactTextFieldTags(rawValue: textField.tag)!
        
        switch tag {
           
        case .Email:
            ContactUsFeilds.email = textField.text!
            break
            
        case .FirstName:
            ContactUsFeilds.firstName = textField.text!
            break
            
        case .Subject:
            ContactUsFeilds.subject = textField.text!
            break
            
        default:
            print("No Matching data Found")
            break
        }
    }
}


class TextviewCell:UITableViewCell{
    
    @IBOutlet var labelTitle: UILabel?
    @IBOutlet var textView : UITextView?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
}


