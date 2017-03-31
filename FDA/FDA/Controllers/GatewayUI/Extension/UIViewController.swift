//
//  UIViewControllerExtension.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setNavigationBarItem() {
        self.addLeftBarButtonWithImage(UIImage(named: "menu_icn")!)
        //self.addRightBarButtonWithImage(UIImage(named: "")!)
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
        self.slideMenuController()?.addLeftGestures()
        self.slideMenuController()?.addRightGestures()
    }
    
    func removeNavigationBarItem() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
    }
    
    func showAlert(title:String,message:String){
        
          let alert = UIAlertController(title:title,message:message,preferredStyle: UIAlertControllerStyle.alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         
          self.present(alert, animated: true, completion: nil)
    }
    
    func addProgressIndicator(){
        
        var view = self.view.viewWithTag(5000)
        if view == nil {
            view = UINib(nibName: "ProgressView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
            view?.frame = UIScreen.main.bounds
            view?.tag = 5000
            self.view.addSubview(view!)
            view?.alpha = 0
            UIView.animate(withDuration: 0.3) {
                view?.alpha = 1
            }
        }
        
        
    }
    
    func removeProgressIndicator(){
        
        let view = self.view.viewWithTag(5000) //as UIView
        UIView.animate(withDuration: 0.2, animations: {
            view?.alpha = 0
        }) { (completed) in
            view?.removeFromSuperview()
        }
    }
}
