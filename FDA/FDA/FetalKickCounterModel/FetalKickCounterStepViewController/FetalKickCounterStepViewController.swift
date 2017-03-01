//
//  FetalKickCounterStepViewController.swift
//  FDA
//
//  Created by Arun Kumar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit

class FetalKickCounterStepViewController:  ORKActiveStepViewController {
    
    //ORKStepViewController
    
    @IBOutlet weak var startButton:UIButton?
    @IBOutlet weak var timerLabel:UILabel?
    @IBOutlet weak var counterLabel:UILabel?
    
    var kickCounter:Int? = 0
    var timer:Timer? = Timer()
     var timerValue:Int? = 0
    
    var totalTime:Int? = 0
    
    override init(step: ORKStep?) {
        super.init(step: step)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    
    
    
    
    func applicationWillResignActive(notification:NSNotification)  {
        
        if(super.suspendIfInactive){
            super.suspend()
        }
        
    }
    func applicationDidBecomeActive(notification:NSNotification)  {
        
        if(super.suspendIfInactive){
            super.resume()
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewDidLoad() {
        //let container:UIView? = Bundle.main.loadNibNamed("fetalKick", owner: self, options:nil)?[0] as? UIView
        
        //let container:UIView?  =  UINib(nibName: "fetalKick", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        
        // let container:UIView? = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        //container?.backgroundColor = UIColor.cyan

        //self.customView?.addSubview(container!)

    }
    
     override func start() {
       
        
        if let step = step as? FetalKickCounterStep {
            
            self.totalTime = step.counDownTimer! * 60 * 60
            
            let hours = Int(self.totalTime!) / 3600
            let minutes = Int(self.totalTime!) / 60 % 60
            let seconds = Int(self.totalTime!) % 60
    
            self.timerValue = step.counDownTimer! * 60 * 60
            
            self.timerLabel?.text = (hours < 10 ? "0\(hours):" : "\(hours):") + (minutes < 10 ? "0\(minutes):" : "\(minutes):")   + (seconds < 10 ? "0\(seconds)" : "\(seconds)")
            
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(FetalKickCounterStepViewController.setCounter), userInfo: nil, repeats: true)
            
            
                   }
    }
    
    
    override func finish(){
        
    }
    
     override func stepDidFinish() {
       
        
    }
    
    func setCounter() {
        if self.timerValue! < 0 {
            self.timerValue = 0
            self.timer?.invalidate()
            self.timer = nil
        }
        else{
            timerValue = timerValue! -  1
        }
        
        let hours = Int(self.timerValue!) / 3600
        let minutes = Int(self.timerValue!) / 60 % 60
        let seconds = Int(self.timerValue!) % 60
        self.timerLabel?.text = (hours < 10 ? "0\(hours):" : "\(hours):") + (minutes < 10 ? "0\(minutes):" : "\(minutes):")   + (seconds < 10 ? "0\(seconds)" : "\(seconds)")
    
    }
    
    @IBAction func startButtonAction(_ sender:UIButton){
        
        self.kickCounter = self.kickCounter! + 1
        self.counterLabel?.text =  self.kickCounter! < 10 ?  "0\(self.kickCounter!)" : "\(self.kickCounter!)"
        
        
    }
    
    
}
