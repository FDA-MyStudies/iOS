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
    @IBOutlet weak var startTitleLabel:UILabel?
    @IBOutlet weak var timerLabel:UILabel?
    @IBOutlet weak var counterTextField:UITextField?
    @IBOutlet weak var editCounterButton:UIButton?
    @IBOutlet weak var seperatorLineView:UIView?
    
    
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
        
    }
    
    override func start() {
        
        if let step = step as? FetalKickCounterStep {
            
            self.totalTime = 60 // step.counDownTimer! * 60 * 60
            
            let hours =  0 //Int(self.totalTime!) / 3600
            let minutes = 0 //Int(self.totalTime!) / 60 % 60
            let seconds =  60 // Int(self.totalTime!) % 60
            
            self.timerValue =  60 //step.counDownTimer! * 60 * 60
            
            self.timerLabel?.text = (hours < 10 ? "0\(hours):" : "\(hours):") + (minutes < 10 ? "0\(minutes):" : "\(minutes):")   + (seconds < 10 ? "0\(seconds)" : "\(seconds)")
            
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(FetalKickCounterStepViewController.setCounter), userInfo: nil, repeats: true)
    
        }
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FetalKickCounterStepViewController.handleTap(_:)))
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer)
        
        super.start()
    }
    
    
    override func finish(){
        super.finish()
    }
    
    override func stepDidFinish() {
        
    }
    
    
//Mark:Methods
    
    func setCounter() {
        if self.timerValue! < 0 {
            self.timerValue = 0
            self.timer?.invalidate()
            self.timer = nil
           
        }
        else{
            timerValue = timerValue! -  1
        }
        
        if timerValue! >= 0{
        
        let hours = Int(self.timerValue!) / 3600
        let minutes = Int(self.timerValue!) / 60 % 60
        let seconds = Int(self.timerValue!) % 60
        self.timerLabel?.text = (hours < 10 ? "0\(hours):" : "\(hours):") + (minutes < 10 ? "0\(minutes):" : "\(minutes):")   + (seconds < 10 ? "0\(seconds)" : "\(seconds)")
        }
        
    }
    
    
    func handleTap(_ sender:UITapGestureRecognizer)   {
        counterTextField?.resignFirstResponder()
    }
    
//Mark:IBActions
    
    @IBAction func editCounterButtonAction(_ sender:UIButton){
        counterTextField?.isUserInteractionEnabled = true
        counterTextField?.isHidden = false
        seperatorLineView?.isHidden =  false
        counterTextField?.becomeFirstResponder()
    }
    
    @IBAction func startButtonAction(_ sender:UIButton){
        
        if Int((self.counterTextField?.text)!)! == 0 {
            startButton?.setImage(UIImage(named: "kick_btn1.png"), for: .normal)
            startTitleLabel?.text = "TAP TO RECORD A KICK"
        }
        editCounterButton?.isHidden = false
        
         self.kickCounter = self.kickCounter! + 1
        self.counterTextField?.text =  self.kickCounter! < 10 ?  "0\(self.kickCounter!)" : "\(self.kickCounter!)"
    
    }
    
}

//Mark: GetureRecognizer delegate
extension FetalKickCounterStepViewController:UIGestureRecognizerDelegate{
    func gestureRecognizer(_: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
}



//Mark:TextField Delegates

extension FetalKickCounterStepViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField == counterTextField)
        {
            counterTextField?.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        if textField == counterTextField! && ( Utilities.isValidValue(someObject: counterTextField?.text as AnyObject?) == false || Int((counterTextField?.text)!)! <= 0) {
             counterTextField?.resignFirstResponder()
                Utilities.showAlertWithMessage(alertMessage:kAlertPleaseEnterValidValue)
        }
        else{
             self.kickCounter = Int((counterTextField?.text)!)
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == counterTextField{
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
        }
        else{
            return true
        }
    
    }
    
}

