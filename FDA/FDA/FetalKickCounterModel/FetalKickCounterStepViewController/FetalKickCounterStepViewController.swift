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

let kFetalKickCounterStepDefaultIdentifier = "defaultIdentifier"

class FetalKickCounterStepViewController:  ORKStepViewController {
    
    //ORKStepViewController ORKActiveStepViewController
    
    
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
    
     var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let step = step as? FetalKickCounterStep {
            
        
            self.totalTime =  step.counDownTimer! * 60
            
            let hours =  Int(self.totalTime!) / 3600
            let minutes = Int(self.totalTime!) / 60 % 60
            let seconds =  Int(self.totalTime!) % 60
            
            self.timerValue =  step.counDownTimer! * 60
            
            self.timerLabel?.text = (hours < 10 ? "0\(hours):" : "\(hours):") + (minutes < 10 ? "0\(minutes):" : "\(minutes):")   + (seconds < 10 ? "0\(seconds)" : "\(seconds)")
            self.taskResult.duration = self.totalTime!
            
           
            
            
        }
        
        // enables the IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        
        // adding guesture to view to support outside tap
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FetalKickCounterStepViewController.handleTap(_:)))
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer)
        
        
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
        
        
        self.counterTextField?.text =  self.kickCounter! < 10 ?  "0\(self.kickCounter!)" : "\(self.kickCounter!)"
        
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
               textField.text = "00"
                self.kickCounter = 00
            }
            
            
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        if textField == counterTextField! && ( Utilities.isValidValue(someObject: counterTextField?.text as AnyObject?) == false || Int((counterTextField?.text)!)! <= 0) {
            counterTextField?.resignFirstResponder()
            if textField.text?.characters.count == 0 || (Int((counterTextField?.text)!) != nil) {
                textField.text = "00"
                self.kickCounter = 00
            }
           
            
            //Utilities.showAlertWithMessage(alertMessage:kAlertPleaseEnterValidValue)
        }
        else{
            self.kickCounter = Int((counterTextField?.text)!)
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

