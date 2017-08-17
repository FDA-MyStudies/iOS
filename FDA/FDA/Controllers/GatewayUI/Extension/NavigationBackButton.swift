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
        
        let customView = UIView.init(frame: CGRect.init(x: -15, y: 0, width: 46, height: 36))
        
        let backbutton:UIButton = UIButton.init(frame: customView.frame)
        
        backbutton.setImage(#imageLiteral(resourceName: "backIcon"), for: .normal)
        
        backbutton.addTarget(self, action: #selector(self.popController), for: .touchUpInside)
        
        customView.addSubview(backbutton)
           // UIBarButtonItem(image:#imageLiteral(resourceName: "backIcon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.popController))
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: customView)
    }
    
    public func addHomeButton() {
        
        let customView = UIView.init(frame: CGRect.init(x: -15, y: 0, width: 46, height: 36))
        
        /*
        let imagView = UIImageView.init(frame: CGRect.init(x: 0, y: 6, width: 20, height: 18))
        imagView.image = #imageLiteral(resourceName: "homeIcon")
        imagView.tintColor = UIColor.blue
        customView.addSubview(imagView)
        */
        
        let backbutton:UIButton = UIButton.init(frame: customView.frame)
        
        backbutton.setImage(#imageLiteral(resourceName: "homeIcon"), for: .normal)
        
        backbutton.addTarget(self, action: #selector(self.popToSpecificController), for: .touchUpInside)
        
        customView.addSubview(backbutton)
        
        // UIBarButtonItem(image:#imageLiteral(resourceName: "backIcon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.popController))
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: customView)
    }
    
    public func popToSpecificController() {
        
        var identifier:String? = ""
        
        switch self {
        case is ResourcesViewController:
            identifier = kUnwindToStudyListIdentifier
        case is ActivitiesViewController:
            identifier = kActivityUnwindToStudyListIdentifier
        default:
            break
        }
        
        if identifier != ""{
            self.performSegue(withIdentifier: identifier!, sender: self)
        }
        
        
    }
    
    
    public func popController() {
       _ = self.navigationController?.popViewController(animated: true)
    }
}
