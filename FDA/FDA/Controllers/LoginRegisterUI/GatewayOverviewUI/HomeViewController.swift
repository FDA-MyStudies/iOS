//
//  LoginViewController.swift
//  FDA
//
//  Created by Ravishankar on 3/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit
import SlideMenuControllerSwift

class HomeViewController : UIViewController{
    
    @IBOutlet weak var container : UIView!
    @IBOutlet var pageControlView : UIPageControl?
    @IBOutlet var buttonLink : UIButton!
    @IBOutlet var buttonSignin : UIButton!
    @IBOutlet var buttonRegister : UIButton!
    
    
//    var pageViewController: PageViewController? {
//        didSet {
//            pageViewController?.pageViewDelegate = self
//            //pageViewController?.overview = Gateway.instance.overview!
//        }
//    }
    
    override func loadView() {
        
        super.loadView()
        self.loadTestData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
       // self.loadTestData()
        self.automaticallyAdjustsScrollViewInsets = false
        //Added to change next screen
        pageControlView?.addTarget(self, action:#selector(HomeViewController.didChangePageControlValue), for: .valueChanged)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //hide navigationbar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func loadTestData(){
//        let filePath  = Bundle.main.path(forResource: "GatewayOverview", ofType: "json")
//        let data = NSData(contentsOfFile: filePath!)

        //load plist info
        let plistPath = Bundle.main.path(forResource: "GatewayOverview", ofType: ".plist", inDirectory:nil)
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
            overview.type = .gateway
            overview.sections = listOfOverviews
            
            //assgin to Gateway
            Gateway.instance.overview = overview
            
            
        } catch {
            print("json error: \(error.localizedDescription)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageViewController = segue.destination as? PageViewController {
            pageViewController.pageViewDelegate = self
            pageViewController.overview = Gateway.instance.overview!
        }
        
        if let signInController = segue.destination as? SignInViewController {
            signInController.viewLoadFrom = .gatewayOverview
          
        }
        
        if let signUpController = segue.destination as? SignUpViewController {
            signUpController.viewLoadFrom = .gatewayOverview
            
        }
        
        
    }
    
    //Fired when the user taps on the pageControl to change its current page (Commented as this is not working)
    func didChangePageControlValue() {
        //pageViewController?.scrollToViewController(index: (pageControlView?.currentPage)!)
    }
   
    @IBAction func linkButtonAction(_ sender: Any) {
       
        let loginStoryboard = UIStoryboard.init(name: "Main", bundle:Bundle.main)
        let webViewController = loginStoryboard.instantiateViewController(withIdentifier:"WebViewController") as! UINavigationController
        let webView = webViewController.viewControllers[0] as! WebViewController
        webView.requestLink = "http://www.fda.gov"
        self.navigationController?.present(webViewController, animated: true, completion: nil)
    }
    
    @IBAction func unwindForLogout(_ segue:UIStoryboardSegue){
        
        //self.view.alpha = 0
        
       
       
    }
    @IBAction func unwindForRegister(_ segue:UIStoryboardSegue){
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            // your code here
            self.buttonRegister.sendActions(for: .touchUpInside)
        }
    }
    @IBAction func unwindForSignIn(_ segue:UIStoryboardSegue){
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            // your code here
            self.buttonSignin.sendActions(for: .touchUpInside)
        }
    }
}

//MARK: Page Control Delegates for handling Counts
extension HomeViewController: PageViewControllerDelegate {
    
    func pageViewController(pageViewController: PageViewController, didUpdatePageCount count: Int){
        pageControlView?.numberOfPages = count
    }
    
    func pageViewController(pageViewController: PageViewController, didUpdatePageIndex index: Int) {
        pageControlView?.currentPage = index
    }
    
}
