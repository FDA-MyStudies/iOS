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
    @IBOutlet var tableViewFooterView : UIView?
    @IBOutlet var buttonSubmit : UIButton?
    
    @IBOutlet var buttonAgree : UIButton?
    @IBOutlet var labelTermsAndConditions : FRHyperLabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to set border color for bottom view
        buttonSubmit?.layer.borderColor = UIColor.init(colorLiteralRed: 73/255.0, green: 182/255.0, blue: 229/255.0, alpha: 1.0).cgColor
        
        self.agreeToTermsAndConditions()
        self.title = "SIGN UP"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }


    func agreeToTermsAndConditions(){
        
        labelTermsAndConditions?.numberOfLines = 0;
        
        //Step 1: Define a normal attributed string for non-link texts
        let string = "I Agree to the Terms and Privacy Policy"
        
        let attributes = [NSForegroundColorAttributeName: UIColor.black,
                          NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)]
        
        labelTermsAndConditions?.attributedText = NSAttributedString(string: string, attributes: attributes)
        
        //Step 2: Define a selection handler block
        let handler = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            
            if substring == "Terms"{
                //self.performSegue(withIdentifier: "TermsOfUse", sender: nil)
                
            }
            else if substring == "Privacy Policy" {
                //self.performSegue(withIdentifier: "TermsOfUse", sender: nil)
            }
        }
        
        //Step 3: Add link substrings
        labelTermsAndConditions?.setLinksForSubstrings(["Privacy Policy", "Terms"], withLinkHandler: handler)
        
    }
}

//MARK: TableView Delegates
extension SignUpViewController : UITableViewDataSource , UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
//        if indexPath.row == 5 {
//            
//            cell = tableView.dequeueReusableCell(withIdentifier: "TouchIdAccessCell", for: indexPath) as! SignUpTableViewCell
//            
//        }else if indexPath.row == 6 {
//            
//            cell = tableView.dequeueReusableCell(withIdentifier: "TermsAndPrivacyCell", for: indexPath) as! SignUpTableViewCell
//            (cell as! SignUpTableViewCell).agreeToTermsAndConditions()
//            
//        }else{
        
            cell = tableView.dequeueReusableCell(withIdentifier: "CommonDetailsCell", for: indexPath) as! SignUpTableViewCell
            
//        }
        
        cell?.backgroundColor = UIColor.clear
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return tableViewFooterView
//    }
    
}
