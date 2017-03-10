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
    case profile
    case signUp
    case notification
}




protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class LeftMenuViewController : UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var tableView: UITableView!
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
    
    var signInViewController:UIViewController!
     var signUpViewController:UIViewController!
    
    //var imageHeaderView: ImageHeaderView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.setInitialData()
        
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
         let loginStoryBoard = UIStoryboard(name: "Login", bundle: nil)
        
        
        self.studyListViewController = storyboard.instantiateViewController(withIdentifier: String(describing: StudyListViewController.classForCoder())) as! UINavigationController
        
        
        self.notificationController = storyboard.instantiateViewController(withIdentifier:  String(describing: NotificationViewController.classForCoder())) as! UINavigationController
        
        
        self.profileviewController = storyboard.instantiateViewController(withIdentifier:  String(describing: ProfileViewController.classForCoder())) as! UINavigationController
        
        
        //self.signInViewController = loginStoryBoard.instantiateViewController(withIdentifier:  String(describing: SignInViewController.classForCoder())) as! UINavigationController
        
        //self.signUpViewController = loginStoryBoard.instantiateViewController(withIdentifier:  String(describing: SignUpViewController.classForCoder())) as! UINavigationController

        
        
        
//        let goViewController = storyboard.instantiateViewController(withIdentifier: "GoViewController") as! ResourcesListViewController
//        self.goViewController = UINavigationController(rootViewController: goViewController)
        
//        let nonMenuController = storyboard.instantiateViewController(withIdentifier: "NonMenuController") as! ProfileViewController
//        nonMenuController.delegate = self
//        self.nonMenuViewController = UINavigationController(rootViewController: nonMenuController)
        
       // self.tableView.registerCellClass(BaseTableViewCell.self)
        
       // self.imageHeaderView = ImageHeaderView.loadNib()
       // self.view.addSubview(self.imageHeaderView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.imageHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 160)
//        self.view.layoutIfNeeded()
//    }
    
    
    func setInitialData()  {
        
        if user.userType == .FDAUser {
            menus.append(["menuTitle":"Profile",
                          "iconName":"profile_menu1"])
        }
        else{
            menus.append(["menuTitle":"Sign In",
                          "iconName":"signin_menu1"])
            
            menus.append(["menuTitle":"New User?",
                          "iconName":"newuser_menu1",
                          "subTitle":"Sign up"])
        }
        
        
    }
    
    
    
    func changeViewController(_ menu: LeftMenu) {
        switch menu {
        case .studyList:
            self.slideMenuController()?.changeMainViewController(self.studyListViewController, close: true)
        case .notification:
            self.slideMenuController()?.changeMainViewController(self.notificationController, close: true)
        case .resources: break
            //self.slideMenuController()?.changeMainViewController(self.javaViewController, close: true)
        case .profile:
            
            if user.userType == .FDAUser {
                 self.slideMenuController()?.changeMainViewController(self.profileviewController, close: true)
            }
            else{
                break
                 self.slideMenuController()?.changeMainViewController( self.signInViewController, close: true)
            }
           
        case .signUp:break
            self.slideMenuController()?.changeMainViewController(self.signUpViewController, close: true)
            
            
        }
    }
    
    
    func signout(){
        debugPrint("singout")
       _ = self.navigationController?.popToRootViewController(animated: true)
    }
}

extension LeftMenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let menu = LeftMenu(rawValue: indexPath.row) {
            switch menu {
            case .studyList, .notification, .resources, .profile, .signUp:
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

