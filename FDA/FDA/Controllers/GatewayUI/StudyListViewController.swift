//
//  StudyListViewController.swift
//  FDA
//
//  Created by Surender Rathore on 3/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StudyListViewController: UIViewController {
    
    
    @IBOutlet var tableView:UITableView?
    @IBOutlet var labelHelperText:UILabel!
    
    func loadTestData(){
        
        
        let filePath  = Bundle.main.path(forResource: "StudyList", ofType: "json")
        
        let data = NSData(contentsOfFile: filePath!)
        
        
        do {
            let response = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
            
            
            let studies = response?[kStudies] as! Array<Dictionary<String,Any>>
            var listOfStudies:Array<Study> = []
            for study in studies{
                let studyModelObj = Study(studyDetail: study)
                listOfStudies.append(studyModelObj)
            }
            
            //assgin to Gateway
            Gateway.instance.studies = listOfStudies
            
            
            
        } catch {
            print("json error: \(error.localizedDescription)")
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //self.addRightBarButton() //Phase2
        //self.addLeftBarButton()
        //self.title = NSLocalizedString("FDA LISTENS!", comment: "")
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("FDA LISTENS!", comment: "")
        titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        titleLabel.textAlignment = .left
        titleLabel.textColor = Utilities.getUIColorFromHex(0x007cba)
        titleLabel.frame = CGRect.init(x: 0, y: 0, width: 300, height: 44)
        self.navigationItem.titleView = titleLabel
        
        
        //self.loadTestData()
        
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        self.labelHelperText.isHidden = true
        self.setNavigationBarItem()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        
        //self.loadStudiesFromDatabase()
        self.sendRequestToGetStudyList()
       
        if User.currentUser.userType == .FDAUser {
            
            self.tableView?.estimatedRowHeight = 156
            self.tableView?.rowHeight = UITableViewAutomaticDimension
            self.sendRequestToGetUserPreference()
        }
        else {
            self.tableView?.estimatedRowHeight = 140
            self.tableView?.rowHeight = UITableViewAutomaticDimension
            
        }
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func loadStudiesFromDatabase(){
        
        DBHandler.loadStudyListFromDatabase { (studies) in
            if studies.count > 0 {
                Gateway.instance.studies = studies
                self.tableView?.reloadData()
            }
            else {
                self.sendRequestToGetStudyList()
            }
        }

    }
    
    //MARK:Custom Bar Buttons
    
    func addLeftBarButton(){
        
        let button = UIButton(type: .custom)
        //button.setImage(UIImage(named: "imagename"), for: .normal)
        button.setTitle("FDA LISTENS!", for: .normal)
        button.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Medium", size: 18)
        button.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(Utilities.getUIColorFromHex(0x007cba), for: .normal)
        let barItem = UIBarButtonItem(customView: button)
        
        self.navigationItem.setLeftBarButton(barItem, animated: true)
    }
    
    func addRightBarButton(){
        
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "filter_icn"), for: .normal)
        //button.setTitle("FDA LISTENS!", for: .normal)
        //button.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Medium", size: 18)
        button.frame = CGRect(x: 0, y: 0, width: 19, height: 22.5)
        //button.contentHorizontalAlignment = .left
        // button.setTitleColor(Utilities.getUIColorFromHex(0x007cba), for: .normal)
        let barItem = UIBarButtonItem(customView: button)
        
        self.navigationItem.setRightBarButton(barItem, animated: true)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func navigateToStudyHome(){
        
        let studyStoryBoard = UIStoryboard.init(name: "Study", bundle: Bundle.main)
        let studyHomeController = studyStoryBoard.instantiateViewController(withIdentifier: String(describing: StudyHomeViewController.classForCoder())) as! StudyHomeViewController
        studyHomeController.delegate = self
        self.navigationController?.pushViewController(studyHomeController, animated: true)
        
    }
    
    @IBAction func unwindToStudyList(_ segue:UIStoryboardSegue){
        //unwindStudyListSegue
    }
    func pushToStudyDashboard(){
        
         let studyStoryBoard = UIStoryboard.init(name: "Study", bundle: Bundle.main)
        
        let studyDashboard = studyStoryBoard.instantiateViewController(withIdentifier: kStudyDashboardTabbarControllerIdentifier) as! StudyDashboardTabbarViewController
      
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(studyDashboard, animated: true)
    }
    
     //MARK:Database Methods
    func checkDatabaseForStudyInfo(study:Study){
        
        DBHandler.loadStudyOverview(studyId: (study.studyId)!) { (overview) in
            if overview != nil {
                study.overview = overview
                self.navigateToStudyHome()
            }
            else {
                self.sendRequestToGetStudyInfo(study: study)
            }
        }
    }
    
    
    // MARK: - Requests
    func sendRequestToGetStudyList(){
        WCPServices().getStudyList(self)
    }
    func sendRequestToGetStudyInfo(study:Study){
        WCPServices().getStudyInformation(studyId: study.studyId, delegate: self)
    }
    func sendRequestToGetUserPreference(){
        UserServices().getUserPreference(self)
    }
    func sendRequestToUpdateBookMarkStatus(userStudyStatus:UserStudyStatus){
        UserServices().updateStudyBookmarkStatus(studyStauts: userStudyStatus, delegate: self)
    }
    
    //MARK:Responses
    func handleStudyListResponse(){
        
        if (Gateway.instance.studies?.count)! > 0{
            self.loadStudiesFromDatabase()
            self.labelHelperText.isHidden = true
        }
        else {
            self.tableView?.isHidden = true
            self.labelHelperText.isHidden = false
        }
        
    }
    
    
}
//MARK: TableView Data source
extension StudyListViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Gateway.instance.studies?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier = "studyCell"
        
        //check if current user is anonymous
        let user = User.currentUser
        if user.userType == .AnonymousUser {
            cellIdentifier = "anonymousStudyCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! StudyListCell
        
        cell.populateCellWith(study: (Gateway.instance.studies?[indexPath.row])!)
        cell.delegate = self
        
        return cell
    }
}

//MARK:- TableView Delegates
extension StudyListViewController :  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let study = Gateway.instance.studies?[indexPath.row]
        Study.updateCurrentStudy(study: study!)
        
        
        if User.currentUser.userType == UserType.FDAUser {
            
            if Study.currentStudy?.status == .Active{
                
                let userStudyStatus =  (Study.currentStudy?.userParticipateState.status)!
                
                if userStudyStatus == .completed || userStudyStatus == .inProgress || userStudyStatus == .yetToJoin {
                    //self.pushToStudyDashboard()
                    WCPServices().getStudyUpdates(study: study!, delegate: self)
                }
                else {
                    
                    self.checkDatabaseForStudyInfo(study: study!)
                    //self.sendRequestToGetStudyInfo(study: study!)
                }
                
                
            }
            else {
                
                self.checkDatabaseForStudyInfo(study: study!)
                //self.sendRequestToGetStudyInfo(study: study!)
            }
        }
        else {
            self.checkDatabaseForStudyInfo(study: study!)
        }
      
        
        
        
       
        
        
    }
}

//MARK: StudyListDelegates
extension StudyListViewController : StudyListDelegates {
    
    func studyBookmarked(_ cell: StudyListCell, bookmarked: Bool, forStudy study: Study) {
        
        let user = User.currentUser
        var userStudyStatus:UserStudyStatus!
        if bookmarked {
            userStudyStatus =  user.bookmarkStudy(studyId: study.studyId!)
        }
        else {
            userStudyStatus =  user.removeBookbarkStudy(studyId: study.studyId!)
        }
        
        self.sendRequestToUpdateBookMarkStatus(userStudyStatus: userStudyStatus)
    }
}


extension StudyListViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) : \(response)")
        
        self.removeProgressIndicator()
        
        if requestName as String == WCPMethods.studyList.rawValue{
            self.handleStudyListResponse()
        }
        else if(requestName as String == WCPMethods.studyInfo.rawValue){
            self.navigateToStudyHome()
        }
        else if (requestName as String == RegistrationMethods.userPreferences.description){
            //self.sendRequestToGetStudyList()
            self.tableView?.reloadData()
        }
        else if (requestName as String == WCPMethods.studyUpdates.rawValue){
        }
        
        
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        
        if error.code == 401 { //unauthorized
            UIUtilities.showAlertMessageWithActionHandler(kErrorTitle, message: error.localizedDescription, buttonTitle: kTitleOk, viewControllerUsed: self, action: {
                self.fdaSlideMenuController()?.navigateToHomeAfterUnauthorizedAccess()
            })
        }
        else {
            
            UIUtilities.showAlertWithTitleAndMessage(title:NSLocalizedString(kErrorTitle, comment: "") as NSString, message: error.localizedDescription as NSString)
        }
    }
}

extension StudyListViewController:StudyHomeViewDontrollerDelegate{
    func studyHomeJoinStudy() {
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.removeProgressIndicator()
            
            // your code here
            let leftController = self.slideMenuController()?.leftViewController as! LeftMenuViewController
            leftController.changeViewController(.reachOut_signIn)
        }
        
        
    }
}
