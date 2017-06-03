//
//  FetalKickCounterStepViewController.swift
//  FDA
//
//  Created by Arun Kumar on 2/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import ResearchKit
import IQKeyboardManagerSwift
import IQKeyboardManagerSwift

let kFetalKickCounterStepDefaultIdentifier = "defaultIdentifier"

class FetalKickCounterStepViewController:  ORKStepViewController {
    
    //ORKStepViewController ORKActiveStepViewController
    
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    
    @IBOutlet weak var startButton:UIButton?   // button to start task as well as increment the counter
    @IBOutlet weak var startTitleLabel:UILabel? // displays the title
    @IBOutlet weak var timerLabel:UILabel?      //  displays the current timer Value
    @IBOutlet weak var counterTextField:UITextField? // displays current kick counts
    @IBOutlet weak var editCounterButton:UIButton?  // used to edit the counter value
    @IBOutlet weak var seperatorLineView:UIView? // separator line
    
    
    var kickCounter:Int? = 0        // counter
    var timer:Timer? = Timer()      //  timer for the task
    var timerValue:Int? = 0         // TimerValue
    
    var totalTime:Int? = 0          // Total duration
    
    var taskResult:FetalKickCounterTaskResult = FetalKickCounterTaskResult(identifier: kFetalKickCounterStepDefaultIdentifier)
  
    
    //Mark: ORKStepViewController overriden methods
    
    
    override init(step: ORKStep?) {
        super.init(step: step)
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        
        notificationCenter.addObserver(self, selector: #selector(appBecameActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        
        
        if let step = step as? FetalKickCounterStep {
            
            let ud = UserDefaults.standard
            //ud.set(true, forKey: "FKC")
            
            //ud.set(Study.currentActivity?.actvityId, forKey: "FetalKickActivityId")
            //ud.set(Study.currentStudy?.studyId, forKey: "FetalKickStudyId")
            let activityId = ud.value(forKey:"FetalKickActivityId" ) as! String?
            var differenceInSec = 0
            var autoStartTimer = false
            if  ud.bool(forKey: "FKC")
                && activityId != nil
                && activityId == Study.currentActivity?.actvityId
                 {
                    
                let previousTimerStartDate = ud.object(forKey: "FetalKickStartTimeStamp") as! Date
                let currentDate = Date()
                differenceInSec = Int(currentDate.timeIntervalSince(previousTimerStartDate))
                autoStartTimer = true
                    
                    
                    
                    
            }
        
            if differenceInSec > step.counDownTimer!{
                //task is completed
                
                let previousKicks:Int? = ud.value(forKey:"FetalKickCounterValue" ) as? Int
                
                self.kickCounter = (previousKicks == nil ? 0 : previousKicks!)
                
                self.taskResult.totalKickCount = self.kickCounter!
                
                self.goForward()
            }
            else {
                if differenceInSec >= 0 && differenceInSec < step.counDownTimer!{
                    self.totalTime =   step.counDownTimer! - differenceInSec
                }
                
                print("difference \(differenceInSec)")
                // self.totalTime =    step.counDownTimer!
                
                let hours =  Int(self.totalTime!) / 3600
                let minutes = Int(self.totalTime!) / 60 % 60
                let seconds =  Int(self.totalTime!) % 60
                
                self.timerValue =  self.totalTime    // step.counDownTimer!
                
                self.timerLabel?.text = (hours < 10 ? "0\(hours):" : "\(hours):") + (minutes < 10 ? "0\(minutes):" : "\(minutes):")   + (seconds < 10 ? "0\(seconds)" : "\(seconds)")
                self.taskResult.duration = self.totalTime!
                
                
                if autoStartTimer{
                    
                    let previousKicks:Int? = ud.value(forKey:"FetalKickCounterValue" ) as? Int
                    
                    self.kickCounter = (previousKicks == nil ? 0 : previousKicks!)
                    
                    self.setCounter()
                    
                    self.startButtonAction(UIButton())
                    
                    
                    
                }
                
            }
            
            backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                
            })
            
            
            
            
            // enables the IQKeyboardManager
            IQKeyboardManager.sharedManager().enable = true
            
            // adding guesture to view to support outside tap
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FetalKickCounterStepViewController.handleTap(_:)))
            gestureRecognizer.delegate = self
            self.view.addGestureRecognizer(gestureRecognizer)
            }
            
            
            
          
        
        
       // backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
       //     UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
       // })
    
        
    }
    
    
    override func hasNextStep() -> Bool {
        super.hasNextStep()
        return true
    }
    
    override func goForward(){
        
        super.goForward()
        
    }
    
    override var result: ORKStepResult? {
        
        let orkResult = super.result
        orkResult?.results = [self.taskResult]
        return orkResult
        
    }
    
    
    //Mark:Utility Methods
    
    /*
     updates the timer value
     */
    
    func setCounterValue(){
        
            if self.kickCounter! < 10{
                counterTextField?.text = "00" + "\(self.kickCounter!)"
            }
            else if self.kickCounter! >= 10 && self.kickCounter! < 100{
                counterTextField?.text = "0" + "\(self.kickCounter!)"
            }
            else {
                counterTextField?.text = "\(self.kickCounter!)"
            }
            
        

    }
    
    
    func setCounter() {
        
        
        DispatchQueue.global(qos: .background).async {
            if self.timerValue! < 0 {
                self.timerValue = 0
                self.timer?.invalidate()
                self.timer = nil
                
                // self.result = ORKStepResult.init(stepIdentifier: (step?.identifier)!, results: [taskResult])
                
                DispatchQueue.main.async{
                    
                    self.perform(#selector(self.goForward))
                }
                
            }
            else{
                self.timerValue = self.timerValue! -  1
            }
            
            if self.timerValue! >= 0{
                
                
                DispatchQueue.main.async{
                    
                    let hours = Int(self.timerValue!) / 3600
                    let minutes = Int(self.timerValue!) / 60 % 60
                    let seconds = Int(self.timerValue!) % 60

                    
                    
                   self.timerLabel?.text = (hours < 10 ? "0\(hours):" : "\(hours):") + (minutes < 10 ? "0\(minutes):" : "\(minutes):")   + (seconds < 10 ? "0\(seconds)" : "\(seconds)")
                    
                    
                     self.taskResult.totalKickCount = self.kickCounter!
                }
                
               
                
            }
        }
        
    }
    
    /*
     handleTap method detects the tap gesture event
     @param  sender is tapguesture instance
     */
    func handleTap(_ sender:UITapGestureRecognizer)   {
        counterTextField?.resignFirstResponder()
    }
    
    func appMovedToBackground() {
        
        print("App moved to background!")
        
        let ud = UserDefaults.standard
        if ud.object(forKey: "FetalKickStartTimeStamp") != nil{
            
            ud.set(true, forKey: "FKC")
            
            ud.set(Study.currentActivity?.actvityId, forKey: "FetalKickActivityId")
            ud.set(Study.currentStudy?.studyId, forKey: "FetalKickStudyId")
            
            ud.set(self.kickCounter, forKey: "FetalKickCounterValue")
            
            //check if runid is saved
            if ud.object(forKey: "FetalKickCounterRunid") == nil {
                ud.set(Study.currentActivity?.currentRun.runId, forKey: "FetalKickCounterRunid")
            }
            
            
            ud.synchronize()
        }
        
    }
    
    
    func appBecameActive() {
        print("App moved to forground!")
        
        let ud = UserDefaults.standard
        ud.set(false, forKey: "FKC")
        
        ud.synchronize()
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
            
            if self.timer == nil {
                // first time
                
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(FetalKickCounterStepViewController.setCounter), userInfo: nil, repeats: true)
                
                //save start time stamp
                let ud = UserDefaults.standard
                if ud.object(forKey: "FetalKickStartTimeStamp") == nil {
                    ud.set(Date(),forKey:"FetalKickStartTimeStamp")
                }
                ud.synchronize()
                
                RunLoop.main.add(self.timer!, forMode: .commonModes)
                
                // start button image and start title changed
                startButton?.setImage(UIImage(named: "kick_btn1.png"), for: .normal)
                startTitleLabel?.text = NSLocalizedString("TAP TO RECORD A KICK", comment:"")
            }
            else{
                self.kickCounter = self.kickCounter! + 1
            }
            
        }
        else{
            if self.kickCounter! < 999 {
               self.kickCounter = self.kickCounter! + 1
            }
        }
        editCounterButton?.isHidden = false
        
        
        
        
        self.counterTextField?.text =  self.kickCounter! < 10 ?  ("0\(self.kickCounter!)" == "00" ? "000" : "00\(self.kickCounter!)") : (self.kickCounter! > 100 ? "\(self.kickCounter!)" : "0\(self.kickCounter!)" )
        
    }
    
}

class FetalKickCounterStepType : ORKActiveStep {
    static func stepViewControllerClass() -> FetalKickCounterStepViewController.Type {
        return FetalKickCounterStepViewController.self
    }
}


/*
 FetalKickCounterTaskResult holds the tak result
 @param totalKickCount contains the Kick count
 @param duration is the task duration
 */

open class FetalKickCounterTaskResult: ORKResult {
    
    open var totalKickCount:Int = 0
    open var duration:Int = 0
    
    override open var description: String {
        get {
            return "hitCount:\(totalKickCount), duration:\(duration)"
        }
    }
    
    override open var debugDescription: String {
        get {
            return "hitCount:\(totalKickCount), duration:\(duration)"
        }
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
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if (textField == counterTextField)
        {
            if (textField.text?.characters.count)! > 0 {
                if Int(textField.text!)! == 0 {
                    textField.text = ""
                }
            }
        }
    }
    
        
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField == counterTextField)
        {
            counterTextField?.resignFirstResponder()
            
            if textField.text?.characters.count == 0 {
               textField.text = "000"
                self.kickCounter = 000
            }
            
            
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        if textField == counterTextField! && ( Utilities.isValidValue(someObject: counterTextField?.text as AnyObject?) == false || Int((counterTextField?.text)!)! <= 0) {
            counterTextField?.resignFirstResponder()
            if textField.text?.characters.count == 0 || (Int((counterTextField?.text)!) != nil) {
                textField.text = "000"
                self.kickCounter = 000
            }
            
            
            //Utilities.showAlertWithMessage(alertMessage:kAlertPleaseEnterValidValue)
        }
        else{
            self.kickCounter = Int((counterTextField?.text)!)
            
            if textField.text?.characters.count == 2{
                counterTextField?.text = "0" + textField.text!
                self.kickCounter  = (Int((counterTextField?.text)!))
            }
            else if (textField.text?.characters.count)! > 3{
                let finalValue = (Int((counterTextField?.text)!))
                
                if finalValue! < 10{
                    counterTextField?.text = "00" + "\(finalValue!)"
                }
                else if finalValue! >= 10 && finalValue! < 100{
                     counterTextField?.text = "0" + "\(finalValue!)"
                }
                else {
                     counterTextField?.text = "\(finalValue!)"
                }
                
            }
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let finalString = textField.text! + string
        
        if textField == counterTextField && finalString.characters.count > 0{
            
            if Int(finalString)! <= 999{
                
                return true
            }
            else{
                return false
            }
        }
        else {
            return true
        }
        
    }
}

