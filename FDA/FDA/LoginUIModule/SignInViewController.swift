//
//  SignInViewController.swift
//  FDA
//
//  Created by Ravishankar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class SignInViewController : UIViewController{
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var buttonSignIn : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonSignIn?.layer.borderColor = UIColor.init(colorLiteralRed: 0/255.0, green: 124/255.0, blue: 186/255.0, alpha: 1.0).cgColor
        self.title = "SIGN IN"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    //MARK: Signin Button Action and validation checks
    @IBAction func signInButtonAction(_ sender: Any) {
        
        
        
        
        
    }
    
}

//MARK: TableView Data source
extension SignInViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell", for: indexPath) as! SignInTableViewCell
     
        cell?.backgroundColor = UIColor.clear
        return cell!
    }
}

//MARK: TableView Delegates
extension SignInViewController :  UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}



