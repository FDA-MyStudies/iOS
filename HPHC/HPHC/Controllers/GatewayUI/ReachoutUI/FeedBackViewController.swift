/*
 License Agreement for FDA My Studies
Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.
Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import UIKit
import IQKeyboardManagerSwift

struct FeedbackDetail {
    
    static var feedback: String = ""
    static var subject: String = ""
    
    init(){
        FeedbackDetail.feedback = ""
        FeedbackDetail.subject = ""
    }
}

class FeedBackViewController: UIViewController{
    
    @IBOutlet var buttonSubmit: UIButton?
    @IBOutlet var tableView: UITableView?
    var feedbackText: String = ""
    let kLeaveFeedbackTitle = NSLocalizedStrings("LEAVE US YOUR FEEDBACK", comment: "")
    let kEnterFeedback = NSLocalizedStrings("Enter your feedback here", comment: "")
    
// MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title =  kLeaveFeedbackTitle
        
        // Used to set border color for bottom view
        buttonSubmit?.layer.borderColor = kUicolorForButtonBackground
        
        // Automatically takes care  of text field become first responder and scroll of tableview
        // IQKeyboardManager.sharedManager().enable = true

        self.tableView?.estimatedRowHeight = 123
        self.tableView?.rowHeight = UITableView.automaticDimension
        
        self.addBackBarButton()
        
        _ = FeedbackDetail.init()
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
    
// MARK: - Button Actions
    
    /**
     
     Validations after clicking on submit button
     If all the validations satisfy send user feedback request
     
     @param sender  accepts any object
     
     */
    @IBAction func buttonSubmitAciton(_ sender: UIButton){
        
        if FeedbackDetail.subject.isEmpty && FeedbackDetail.feedback.isEmpty {
            UIUtilities.showAlertWithMessage(alertMessage: kMessageAllFieldsAreEmpty)
        } else if FeedbackDetail.subject.isEmpty {
            UIUtilities.showAlertWithMessage(alertMessage: kMessageMessageBlankCheck)
        } else if FeedbackDetail.feedback.isEmpty {
            UIUtilities.showAlertWithMessage(alertMessage: NSLocalizedStrings("Please provide your feedback", comment: ""))
        } else {
            UserServices().sendUserFeedback(delegate: self)
        }
    }
}

// MARK: - TableView Datasource
extension FeedBackViewController: UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        
        var cell: UITableViewCell?
        
        if indexPath.row == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: kFeedbackTableViewCellIdentifier1,
                                                 for: indexPath) as! FeedBackTableViewCell
           
        } else if indexPath.row == 1{
           let cell = tableView.dequeueReusableCell(withIdentifier: kContactUsTableViewCellIdentifier,
                                                    for: indexPath) as! ContactUsTableViewCell
            cell.textFieldValue?.tag = indexPath.row
            
//            var keyBoardType : UIKeyboardType? =  UIKeyboardType.default
//           
//            cell.textFieldValue?.keyboardType = keyBoardType
//            cell.placeholderText
//            
//            // Cell Data Setup
//            // cell.populateCellData(data: tableViewData,keyboardType: keyBoardType)
            return cell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "textviewCell", for: indexPath) as! TextviewCell
          
          let cell = tableView.dequeueReusableCell(withIdentifier: "textviewCell", for: indexPath) as! TextviewCell
          
          if cell.textView?.tag == 100 {
            cell.textView?.text = kEnterFeedback
            cell.textView?.textColor = UIColor.lightGray
            cell.textView?.tag = 100
          }
          return cell
        
        }
        
        return cell!
    }
}

// MARK: - TableView Delegates
extension FeedBackViewController : UITableViewDelegate{

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITextview Delegate
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
        
        if textView.tag == 101 && textView.text.count == 0 {
            textView.text = kEnterFeedback
            textView.textColor = UIColor.lightGray
            textView.tag = 100
        } else {
            // self.feedbackText = textView.text!
            FeedbackDetail.feedback = textView.text!
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
                
        if textView.tag == 100 {
            textView.text = ""
            textView.textColor = UIColor.black
            textView.tag = 101
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if var text = textField.text, range.location == text.count, string == " " {
                let noBreakSpace: Character = "\u{00a0}"
                text.append(noBreakSpace)
                textField.text = text
                return false
            }
            return true
    }
}

// MARK: - Textfield Delegate
extension FeedBackViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
   
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textField.text =  textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        FeedbackDetail.subject = textField.text!
    }
}

// MARK: - Webservice Delegates
extension FeedBackViewController: NMWebServiceDelegate {
    
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        UIUtilities.showAlertMessageWithActionHandler("",
                                                      message: kMessageFeedbackSubmittedSuccessfuly,
                                                      buttonTitle: kTitleOk,
                                                      viewControllerUsed: self) {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        
        self.removeProgressIndicator()
        Logger.sharedInstance.info("requestname : \(requestName)")
        let errorMsg = base64DecodeError(error.localizedDescription)
        UIUtilities.showAlertWithTitleAndMessage(title: kTitleError as NSString, message: errorMsg as NSString)
    }
}
