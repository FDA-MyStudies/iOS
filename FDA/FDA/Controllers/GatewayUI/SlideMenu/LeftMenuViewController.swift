//
//  LeftMenuViewController.swift
//  FDA
//
//  Created by Surender Rathore on 3/8/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift


let kLeftMenuSubtitle = "subTitle"
let kLeftMenuTitle = "menuTitle"
let kLeftMenuIconName = "iconName"


let kLeftMenuCellTitleHome = "Home"
let kLeftMenuCellTitleResources = "Resources"
let kLeftMenuCellTitleProfile = "Profile"
let kLeftMenuCellTitleSignIn = "Sign In"
let kLeftMenuCellTitleNewUser = "New User?"
let kLeftMenuCellSubTitleValue = "Sign up"

enum LeftMenu: Int {
    case studyList = 0
    case resources
    case profile_signin
    case signup
}




protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class LeftMenuViewController : UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tableFooterView: UIView!
    
    
    @IBOutlet weak var buttonSignOut: UIButton?
    var menus = [ ["menuTitle":"Home",
                   "iconName":"home_menu1"],
                  
                  ["menuTitle":"Resources",
                   "iconName":"resources_menu1"],
                  ]
    var studyListViewController: UINavigationController!
    var notificationController: UIViewController!
    var resourcesViewController: UIViewController!
    var profileviewController: UIViewController!
    var nonMenuViewController: UIViewController!
    
    var signInViewController:UINavigationController!
    var signUpViewController:UINavigationController!
    
    //var imageHeaderView: ImageHeaderView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.createLeftmenuItems()
        
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
        
        
        
        self.studyListViewController = storyboard.instantiateViewController(withIdentifier: String(describing: StudyListViewController.classForCoder())) as! UINavigationController
        
        
        self.notificationController = storyboard.instantiateViewController(withIdentifier:  String(describing: NotificationViewController.classForCoder())) as! UINavigationController
        
        
        self.profileviewController = storyboard.instantiateViewController(withIdentifier:  String(describing: ProfileViewController.classForCoder())) as! UINavigationController
        
        
        
        self.labelVersion.text = "v" + "\(Utilities.getAppVersion())"
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.setInitialData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func createControllersForAnonymousUser(){
        
        let loginStoryBoard = UIStoryboard(name: "Login", bundle: nil)
        let signInController = loginStoryBoard.instantiateViewController(withIdentifier:  String(describing: SignInViewController.classForCoder())) as! SignInViewController
        self.signInViewController = UINavigationController(rootViewController: signInController)
        
        
        let signUpController = loginStoryBoard.instantiateViewController(withIdentifier:  String(describing: SignUpViewController.classForCoder())) as! SignUpViewController
        self.signUpViewController = UINavigationController(rootViewController: signUpController)
    }
    
    func createLeftmenuItems(){
        
        self.createControllersForAnonymousUser()
        
        let user = User.currentUser
        
        menus = [ ["menuTitle":"Home",
                   "iconName":"home_menu1"],
                  
                  ["menuTitle":"Resources",
                   "iconName":"resources_menu1"],
        ]
        
        if user.userType == .FDAUser {
            menus.append(["menuTitle":"Profile",
                          "iconName":"profile_menu1"])
           
            self.buttonSignOut?.isHidden = false
        }
        else{
            menus.append(["menuTitle":"Sign In",
                          "iconName":"signin_menu1"])
            
            menus.append(["menuTitle":"New User?",
                          "iconName":"newuser_menu1",
                          "subTitle":"Sign up"])
             self.buttonSignOut?.isHidden = true
        }
        
        // Setting proportion height of the header and footer view
       // let height = UIScreen.main.bounds.size.height  * (220.0 / 667.0) //calculate new height
        
        var height:CGFloat? = 0.0
        height =  (UIScreen.main.bounds.size.height -  CGFloat(menus.count * 78))/2
        
        self.tableHeaderView.frame.size = CGSize(width: self.tableHeaderView!.frame.size.width, height: height!)
        self.tableFooterView.frame.size = CGSize(width: self.tableFooterView!.frame.size.width, height: height!)
        self.tableView.frame.size = CGSize(width:self.tableView.frame.width, height:UIScreen.main.bounds.size.height  )
        
        self.tableView.reloadData()
        
    }
    
    func setInitialData()  {
        
        let user = User.currentUser
        if user.userType == .FDAUser {
            menus.append(["menuTitle":"Profile",
                          "iconName":"profile_menu1"])
            self.tableView.tableFooterView?.isHidden = false
        }
        else{
            menus.append(["menuTitle":"Sign In",
                          "iconName":"signin_menu1"])
            
            menus.append(["menuTitle":"New User?",
                          "iconName":"newuser_menu1",
                          "subTitle":"Sign up"])
            self.tableView.tableFooterView?.isHidden = true
        }
        
        
        // Setting proportion height of the header and footer view
        let height = UIScreen.main.bounds.size.height  * (220.0 / 667.0) //calculate new height
        self.tableView.tableHeaderView?.frame.size = CGSize(width: self.tableView.tableHeaderView!.frame.size.width, height: height)
        self.tableView.tableFooterView?.frame.size = CGSize(width: self.tableView.tableFooterView!.frame.size.width, height: height)
        self.tableView.frame.size = CGSize(width:self.tableView.frame.width, height:UIScreen.main.bounds.size.height)
        
        self.tableView.reloadData()
        
    }
    
    
    
    func changeViewController(_ menu: LeftMenu) {
        switch menu {
        case .studyList:
            self.slideMenuController()?.changeMainViewController(self.studyListViewController, close: true)
        case .resources: break
        //self.slideMenuController()?.changeMainViewController(self.javaViewController, close: true)
        case .profile_signin:
            
            if User.currentUser.userType == .FDAUser {
                self.slideMenuController()?.changeMainViewController(self.profileviewController, close: true)
                
            }
            else{
                // go to signin screen
                //fdaSlideMenuController()?.navigateToHomeControllerForSignin()
                self.slideMenuController()?.changeMainViewController(self.signInViewController, close: true)
            }
            
        case .signup:
            self.slideMenuController()?.changeMainViewController(self.signUpViewController, close: true)
            
            
        }
    }
    
    
    @IBAction func buttonActionSignOut(_ sender: UIButton) {
        
        
        UIUtilities.showAlertMessageWithTwoActionsAndHandler(NSLocalizedString("Signout", comment: ""), errorMessage: NSLocalizedString("Are you sure you want to signout ?", comment: ""), errorAlertActionTitle: NSLocalizedString("Yes", comment: ""),
                                                             errorAlertActionTitle2: NSLocalizedString("Cancel", comment: ""), viewControllerUsed: self,
                                                             action1: {
                                                                
                                                                
                                                                self.sendRequestToSignOut()
                                                                
                                                                
        },
                                                             action2: {
                                                                
        })
        
    }
    func sendRequestToSignOut() {
        UserServices().logoutUser(self as NMWebServiceDelegate)
    }
    
    func signout(){
        debugPrint("singout")
        self.changeViewController(.studyList)
        self.createLeftmenuItems()
        //_ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    
}

extension LeftMenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let menu = LeftMenu(rawValue: indexPath.row) {
            switch menu {
            case .studyList, .resources, .profile_signin, .signup:
                return 78
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if let menu = LeftMenu(rawValue: indexPath.row) {
            self.changeViewController(menu)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView == scrollView {
            
        }
    }
}

extension LeftMenuViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict:Dictionary<String,Any>? = menus[indexPath.row]
        
        if dict?["subTitle"] != nil {
            var cell : LeftMenuCell?
            
            cell = tableView.dequeueReusableCell(withIdentifier:"cell" , for: indexPath) as? LeftMenuCell
            
            cell?.populateCellData(data: menus[indexPath.row])
            
            return cell!
        }
        else{
            var cell : LeftMenuResourceTableViewCell?
            
            cell = tableView.dequeueReusableCell(withIdentifier:"LeftMenuResourceCell" , for: indexPath) as? LeftMenuResourceTableViewCell
            
            cell?.populateCellData(data: menus[indexPath.row])
            
            return cell!
        }
        
        
    }
    
    
}


//MARK:UserService Response handler

extension LeftMenuViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        if requestName as String ==  RegistrationMethods.logout.description {
            
            self.signout()
        }
        
        self.removeProgressIndicator()
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
