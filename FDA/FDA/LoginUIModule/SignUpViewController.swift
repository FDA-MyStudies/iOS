//
//  SIGNUPVIEWCONTROLLER.swift
//  FDA
//
//  Created by Ravishankar on 2/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController : UIViewController{
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var buttonSubmit : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonSubmit?.layer.borderColor = UIColor.init(colorLiteralRed: 73/255.0, green: 182/255.0, blue: 229/255.0, alpha: 1.0).cgColor
    }

}

//MARK: TableView Delegates
extension SignUpViewController : UITableViewDataSource , UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        if indexPath.row == 5 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "TouchIdAccessCell", for: indexPath) as! SignUpTableViewCell
            
        }else if indexPath.row == 6 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "TermsAndPrivacyCell", for: indexPath) as! SignUpTableViewCell
            
        }else{
        
            cell = tableView.dequeueReusableCell(withIdentifier: "CommonDetailsCell", for: indexPath) as! SignUpTableViewCell
        }
        
        cell?.backgroundColor = UIColor.clear
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
