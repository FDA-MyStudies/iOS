//
//  ConfirmationViewController.swift
//  FDA
//
//  Created by Arun Kumar on 3/8/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit


let kConfirmationSegueIdentifier = "confirmationSegue"
let kHeaderDescription = "You have chosen to delete your FDA app account. This will result in automatic withdrawl from all Studies.\n Below is a list of studies that you are a part of and information on how your response data will be handled with each after you withdraw.Please review and confirm."

let kConfirmationCellType = "type"
let kConfirmationCellTypeOptional = "Optional"

let kConfrimationOptionalCellIdentifier = "ConfirmationOptionalCell"
let kConfrimationCellIdentifier = "ConfirmationCell"

let kConfirmationTitle = "title"
let kConfirmationPlaceholder = "placeHolder"

let kConfirmationPlist = "Confirmation"

let kConfirmationNavigationTitle = "DELETE ACCOUNT"

let kPlistFileType = ".plist"




class ConfirmationViewController: UIViewController {
    
    var tableViewRowDetails : NSMutableArray?
    
    
    @IBOutlet var tableViewConfirmation : UITableView?
    @IBOutlet var tableViewHeaderViewConfirmation : UIView?
    @IBOutlet var tableViewFooterViewConfirmation : UIView?
    @IBOutlet var buttonDeleteAccount:UIButton?
    @IBOutlet var buttonDoNotDeleteAccount:UIButton?
    @IBOutlet var LabelHeaderDescription:UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Load plist info
        let plistPath = Bundle.main.path(forResource: kConfirmationPlist, ofType:kPlistFileType , inDirectory:nil)
        tableViewRowDetails = NSMutableArray.init(contentsOfFile: plistPath!)
        
        // setting the headerdescription
        self.LabelHeaderDescription?.text = kHeaderDescription
        
        // setting border color for footer buttons
        self.buttonDeleteAccount?.layer.borderColor = kUicolorForButtonBackground
        self.buttonDoNotDeleteAccount?.layer.borderColor = kUicolorForButtonBackground
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.title = NSLocalizedString(kConfirmationNavigationTitle, comment: "")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addBackBarButton()
    }
    
    //MARK:IBActions
    
    @IBAction func deleteAccountAction(_ sender:UIButton){
     UserServices().deleteAccount(self as NMWebServiceDelegate)
    }
    @IBAction func doNotDeleteAccountAction(_ sender:UIButton){
         _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleDeleteAccountResponse(){
        fdaSlideMenuController()?.navigateToHomeAfterSingout()
    }
    
    
}

//MARK: TableView Data source
extension ConfirmationViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        
        if tableViewData[kConfirmationCellType] as! String ==  kConfirmationCellTypeOptional{
            // for ConfirmationCellTypeOptional
            
            let  cell = tableView.dequeueReusableCell(withIdentifier: kConfrimationOptionalCellIdentifier, for: indexPath) as! ConfirmationOptionalTableViewCell
            
            
            cell.setDefaultDeleteAction(defaultValue:tableViewData[kConfirmationPlaceholder] as! String)
            
            
            cell.labelTitle?.text = tableViewData[kConfirmationTitle] as? String
            
            return cell
        }
        else{
            // for ConfirmationTableViewCell data
            
            let cell = tableView.dequeueReusableCell(withIdentifier: kConfrimationCellIdentifier, for: indexPath) as! ConfirmationTableViewCell
            
            
            cell.labelTitle?.text = tableViewData[kConfirmationTitle] as? String
            
            cell.labelTitleDescription?.text = tableViewData[kConfirmationPlaceholder] as? String
            
            
            return cell
        }
        
        
        
        
    }
}

//MARK: TableView Delegates
extension ConfirmationViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //print(indexPath.row)
    }
}

//MARK:UserService Response handler

extension ConfirmationViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
         self.removeProgressIndicator()
        if requestName as String ==  RegistrationMethods.deleteAccount.description {
            
             self.handleDeleteAccountResponse()
        }
        
       
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString("Error", comment: "") as NSString, message: error.localizedDescription as NSString)
        
        
        
    }
}


