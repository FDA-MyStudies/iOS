//
//  NavigationBackButton.swift
//  FDA
//
//  Created by Surender Rathore on 3/8/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

extension UIViewController{
    
    public func addBackBarButton() {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image:#imageLiteral(resourceName: "backIcon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.popController))
        navigationItem.leftBarButtonItem = leftButton
        
        
    }
    
    
    public func popController() {
       _ = self.navigationController?.popViewController(animated: true)
    }
}
