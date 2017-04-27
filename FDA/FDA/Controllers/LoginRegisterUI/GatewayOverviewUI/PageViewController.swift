//
//  PageViewController.swift
//  FDA
//
//  Created by Ravishankar on 2/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

protocol PageViewControllerDelegate: class {
    
    //Parameter count: the total number of pages.
    func pageViewController(pageViewController: PageViewController,
                            didUpdatePageCount count: Int)
    
    //Parameter index: the index of the currently visible page.
    func pageViewController(pageViewController: PageViewController,
                            didUpdatePageIndex index: Int)
    
}

class PageViewController : UIPageViewController{
    
    weak var pageViewDelegate: PageViewControllerDelegate?
    
    var overview : Overview!
    var currentIndex = 0
    
//MARK:View Controller Delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.automaticallyAdjustsScrollViewInsets = false;
        dataSource = self
        delegate =  self
        
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }
        
        print("\(orderedViewControllers)")
        
        pageViewDelegate?.pageViewController(pageViewController: self, didUpdatePageCount: orderedViewControllers.count)
        
        let scrollView = self.view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView
        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.loadTestData()
        
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
  //MARK:Scroll Delegates
    
    /*
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController){
            scrollToViewController(viewController: nextViewController)
        }
    }
    
    /*
    Scrolls to the given 'viewController' page.
    */
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
                            self.notifyTutorialDelegateOfNewIndex(prevViewController: nil)
        })
    }
    
    /*
    Used to Notify that the current page index was updated.
    */
    func notifyTutorialDelegateOfNewIndex(prevViewController: UIViewController?) {
//        if let firstViewController = viewControllers?.first,
//            let index = orderedViewControllers.index(of: firstViewController) {
//            pageViewDelegate?.pageViewController(pageViewController: self, didUpdatePageIndex: index)
//        }
        
        
        var index = 0
        
        if  (prevViewController != nil) {
            index = orderedViewControllers.index(of: prevViewController!)!
        }
        else {
        
            let viewController = self.viewControllers?.last
            
            switch viewController {
            case is FirstGatewayOverviewViewController:
                index = (viewController as! FirstGatewayOverviewViewController).pageIndex
            case is SecondGatewayOverviewViewController:
                index = (viewController as! SecondGatewayOverviewViewController).pageIndex
            case is StudyOverviewViewControllerFirst:
                index = (viewController as! StudyOverviewViewControllerFirst).pageIndex
            case is StudyOverviewViewControllerSecond:
                index = (viewController as! StudyOverviewViewControllerSecond).pageIndex
            default:
                index = 0
            }
        
        }
        
        pageViewDelegate?.pageViewController(pageViewController: self, didUpdatePageIndex: index)

    }
    
    /*
    Scrolls to the view controller at the given index.
    */
    func scrollToViewController(index newIndex: Int) {
        
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        
        return self.getOverviewViewControllers()
    }()
    
    private func getOverviewViewControllers() -> [UIViewController] {
        
        var controllers:Array<UIViewController> = []
        var storyboard = UIStoryboard.init(name: "Login", bundle: Bundle.main)
        
        if overview.type == .study {
            storyboard = UIStoryboard.init(name: "Study", bundle: Bundle.main)
            
            //get first overview controller
            let firstController = storyboard.instantiateViewController(withIdentifier: "FirstViewController") as! StudyOverviewViewControllerFirst
            firstController.pageIndex = 0
            firstController.overViewWebsiteLink = overview.websiteLink
            firstController.overviewSectionDetail = overview.sections[0]
            controllers.append(firstController)
            if overview.sections.count >= 2 {
                let sections = overview.sections.count
                for section in 1...(sections-1) {
                    
                    let restControllers = storyboard.instantiateViewController(withIdentifier: "SecondViewController") as! StudyOverviewViewControllerSecond
                    restControllers.overviewSectionDetail = overview.sections[section]
                     restControllers.overViewWebsiteLink = overview.websiteLink
                    restControllers.pageIndex = section
                    controllers.append(restControllers)
                }
            }
            
        }
        else {
            //get first overview controller
            let firstController = storyboard.instantiateViewController(withIdentifier: "FirstViewController") as! FirstGatewayOverviewViewController
            firstController.overviewSectionDetail = overview.sections[0]
            firstController.pageIndex = 0
            controllers.append(firstController)
            
            let sections = overview.sections.count
            for section in 1...(sections-1) {
                
                let restControllers = storyboard.instantiateViewController(withIdentifier: "SecondViewController") as! SecondGatewayOverviewViewController
                restControllers.overviewSectionDetail = overview.sections[section]
                restControllers.pageIndex = section
                controllers.append(restControllers)
            }
        }
        
        return controllers
    }
}

//MARK: UIPageViewController DataSource
extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        //print("pageViewController viewControllerAfter")
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        currentIndex = viewControllerIndex
        let nextIndex = viewControllerIndex + 1
        
        guard orderedViewControllers.count > nextIndex else {
            return nil
        }
        
        //currentIndex = nextIndex
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        //print("pageViewController viewControllerBefore")
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        currentIndex = viewControllerIndex
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
   
}

//MARK: UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
      //  print("transition \(finished) \(previousViewControllers)")

        if completed {
            //print("transitionCompleted \(previousViewControllers)")
            
            self.notifyTutorialDelegateOfNewIndex(prevViewController: nil)
        }
        else {
            self.notifyTutorialDelegateOfNewIndex(prevViewController: previousViewControllers.last!)
        }
        
    }
}
extension PageViewController: UIScrollViewDelegate{
   
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
       print(currentIndex)
        
        pageViewDelegate?.pageViewController(pageViewController: self, didUpdatePageIndex: currentIndex)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(currentIndex)
        //pageViewDelegate?.pageViewController(pageViewController: self, didUpdatePageIndex: currentIndex)
    }
}


