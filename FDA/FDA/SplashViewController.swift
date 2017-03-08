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
        
        let loginStoryboard = UIStoryboard.init(name: "Login", bundle:Bundle.main)
        let homeViewController = loginStoryboard.instantiateViewController(withIdentifier:"HomeViewController")
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
