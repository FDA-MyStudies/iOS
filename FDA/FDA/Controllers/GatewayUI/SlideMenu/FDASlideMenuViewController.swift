//
//  FDASlideMenuViewController.swift
//  FDA
//
//  Created by Surender Rathore on 3/8/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift


open class FDASlideMenuViewController: SlideMenuController {
    
    
    override open func awakeFromNib() {
        
       
        SlideMenuOptions.leftViewWidth = 300
        let storyboard = UIStoryboard(name: "Gateway", bundle: nil)
        //kStreamerDashBoard
        let controller = storyboard.instantiateViewController(withIdentifier: "StudyListViewController")
        self.mainViewController = controller
        
        
        
        
         let controller2 = storyboard.instantiateViewController(withIdentifier: "LeftMenuViewController")
        self.leftViewController = controller2
         super.awakeFromNib()
         //
       
    }
//
    
    override open func isTagetViewController() -> Bool {
        if let vc = UIApplication.topViewController() {
            if vc is StudyListViewController ||
                vc is NotificationViewController ||
                vc is ResourcesListViewController ||
                vc is ProfileViewController {
                return true
            }
        }
        return false
    }
    
    
    override open func track(_ trackAction: TrackAction) {
        switch trackAction {
        case .leftTapOpen:
            print("TrackAction: left tap open.")
        case .leftTapClose:
            print("TrackAction: left tap close.")
        case .leftFlickOpen:
            print("TrackAction: left flick open.")
        case .leftFlickClose:
            print("TrackAction: left flick close.")
        case .rightTapOpen:
            print("TrackAction: right tap open.")
        case .rightTapClose:
            print("TrackAction: right tap close.")
        case .rightFlickOpen:
            print("TrackAction: right flick open.")
        case .rightFlickClose:
            print("TrackAction: right flick close.")
        }
    }
    
//    override open func viewDidLoad() {
//        super.viewDidLoad()
//        SlideMenuOptions.leftViewWidth = 300
//    }
    func navigateToHomeAfterSingout(){
        
        self.leftViewController?.view.isHidden = true
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func navigateToHomeControllerForSignin(){
        
        self.performSegue(withIdentifier: "unwindToHomeSignin", sender: self)
        
    }
    func navigateToHomeControllerForRegister(){
        
        self.performSegue(withIdentifier: "unwindToHomeRegister", sender: self)
        
    }
}

extension UIViewController {
    
    public func fdaSlideMenuController() -> FDASlideMenuViewController? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if viewController is FDASlideMenuViewController {
                return viewController as? FDASlideMenuViewController
            }
            viewController = viewController?.parent
        }
        return nil;
    }
}
