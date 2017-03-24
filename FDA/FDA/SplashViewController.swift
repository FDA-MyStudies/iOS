//
//  SplashViewController.swift
//  FDA
//
//  Created by Surender Rathore on 3/7/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        DBHandler().initilizeCurrentUser()
        //TEMP : Need to get form Realm
        //let ud = UserDefaults.standard
        if User.currentUser.authToken != nil {
           
//            DBHandler().initilizeCurrentUser()
//            User.currentUser.authToken = ud.object(forKey: kUserAuthToken) as! String!
//            User.currentUser.userId = ud.object(forKey:kUserId) as! String!
//            User.currentUser.userType = UserType.FDAUser
            self.navigateToGatewayDashboard()
        }
        else {
            self.navigateToHomeController()
        }
        
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigateToHomeController(){
        
        let loginStoryboard = UIStoryboard.init(name: "Login", bundle:Bundle.main)
        let homeViewController = loginStoryboard.instantiateViewController(withIdentifier:"HomeViewController")
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    func navigateToGatewayDashboard(){
        
        self.createMenuView()
    }
    

    func createMenuView() {
        
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
        
        let fda = storyboard.instantiateViewController(withIdentifier: "FDASlideMenuViewController") as! FDASlideMenuViewController
        fda.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.pushViewController(fda, animated: true)
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
