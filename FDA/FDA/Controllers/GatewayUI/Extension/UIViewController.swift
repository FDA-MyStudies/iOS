//
//  UIViewControllerExtension.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import UIKit
import QuickLook

extension UIViewController {
    
    
    
    func topMostViewController() -> UIViewController {
        
            if self.presentedViewController == nil {
                return self
            }
            if let navigation = self.presentedViewController as? UINavigationController {
                return navigation.visibleViewController!.topMostViewController()
            }
            if let tab = self.presentedViewController as? UITabBarController {
                if let selectedTab = tab.selectedViewController {
                    return selectedTab.topMostViewController()
                }
                return tab.topMostViewController()
            }
            return self.presentedViewController!.topMostViewController()
    }
    
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
        
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationItem.backBarButtonItem?.isEnabled = false
        slideMenuController()?.removeLeftGestures()
        slideMenuController()?.view.isUserInteractionEnabled = false
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        
        
       
        
        var view = self.view.viewWithTag(5000)
        if view == nil {
            
           
            
            
            
           view = UINib(nibName: "NewProgressView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
            
            
            let url = Bundle.main.url(forResource: "fda_preload@2x", withExtension: "gif")!
            let data = try! Data(contentsOf: url)
            let webView =  view?.subviews.first as! UIWebView
            
            
            webView.load(data, mimeType: "image/gif", textEncodingName: "UTF-8", baseURL: NSURL() as URL)
            webView.scalesPageToFit = true
            webView.contentMode = UIViewContentMode.scaleAspectFit
            
            
            
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
        
        
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationItem.backBarButtonItem?.isEnabled = true
        
         self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        let view = self.view.viewWithTag(5000) //as UIView
        
        slideMenuController()?.view.isUserInteractionEnabled = true
        slideMenuController()?.addLeftGestures()
        
        UIView.animate(withDuration: 0.2, animations: {
            view?.alpha = 0
        }) { (completed) in
            view?.removeFromSuperview()
        }
    }
}
