//
//  StudyOverviewViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/1/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class StudyOverviewPageViewController : UIPageViewController{
    
//MARK:- Viewcontroller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
//MARK:-
    
    /**
     
     This method is used to instantiate view controllers for Pagination 
     
     */
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newColoredViewController(ViewController: "First"),
                self.newColoredViewController(ViewController: "Second")]
    }()
    
    
    /** 
     
     This method is used to show which Viewcontroller needs to be loaded 
     in Pagination 
     
     @param Viewcontroller  used to track which kind of viewcontroller
                            should be loaded
     @return UIViewController
     
     */
    private func newColoredViewController(ViewController: String) -> UIViewController {
        return UIStoryboard(name: kLoginStoryboardIdentifier, bundle: nil) .
            instantiateViewController(withIdentifier: "\(ViewController)OverviewViewController")
    }
}


//MARK:- Page View Controller delegates
extension StudyOverviewPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}
