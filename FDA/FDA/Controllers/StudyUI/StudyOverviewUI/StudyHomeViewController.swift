//
//  StudyHomeViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/9/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit

class StudyHomeViewController : UIViewController{
    
    @IBOutlet weak var container : UIView!
    @IBOutlet var pageControlView : UIPageControl?
    @IBOutlet var buttonBack : UIButton!
    @IBOutlet var buttonStar : UIButton!

    var pageViewController: PageViewController? {
        didSet {
            pageViewController?.pageViewDelegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.loadTestData()
        
        //Added to change next screen
        pageControlView?.addTarget(self, action:#selector(StudyHomeViewController.didChangePageControlValue), for: .valueChanged)
        
        
        // pageViewController?.overview = Gateway.instance.overview
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //hide navigationbar
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func loadTestData(){
        //        let filePath  = Bundle.main.path(forResource: "GatewayOverview", ofType: "json")
        //        let data = NSData(contentsOfFile: filePath!)
        
        //load plist info
        let plistPath = Bundle.main.path(forResource: "StudyOverview", ofType: ".plist", inDirectory:nil)
        let arrayContent = NSMutableArray.init(contentsOfFile: plistPath!)
        
        do {
            //let response = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
            
            
            //let overviewList = response[kOverViewInfo] as! Array<Dictionary<String,Any>>
            var listOfOverviews:Array<OverviewSection> = []
            for overview in arrayContent!{
                let overviewObj = OverviewSection(detail: overview as! Dictionary<String, Any>)
                listOfOverviews.append(overviewObj)
            }
            
            //create new Overview object
            let overview = Overview()
            overview.type = .study
            overview.sections = listOfOverviews
            
            //assgin to Gateway
            Gateway.instance.overview = overview
            
            
        } catch {
            print("json error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
    
    
    }
    
    @IBAction func starButtonAction(_ sender: Any) {
        if (sender as! UIButton).isSelected{
            (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
            
        }else{
            (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageViewController = segue.destination as? PageViewController {
            pageViewController.pageViewDelegate = self
        }
    }
    
    //Fired when the user taps on the pageControl to change its current page (Commented as this is not working)
    func didChangePageControlValue() {
        pageViewController?.scrollToViewController(index: (pageControlView?.currentPage)!)
    }
}

//MARK: Page Control Delegates for handling Counts
extension StudyHomeViewController: PageViewControllerDelegate {
    
    func pageViewController(pageViewController: PageViewController, didUpdatePageCount count: Int){
        pageControlView?.numberOfPages = count
    }
    
    func pageViewController(pageViewController: PageViewController, didUpdatePageIndex index: Int) {
        pageControlView?.currentPage = index
    }
    
}
