//
//  EligibilityStepViewController.swift
//  FDA
//
//  Created by Arun Kumar on 3/21/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import ResearchKit
import IQKeyboardManagerSwift

let kStudyWithStudyId = "Study with StudyId"
let kTitleOK = "OK"

class EligibilityStep: ORKStep {
    var type:String?
    
    func showsProgress() -> Bool {
        return false
    }
}


class EligibilityStepViewController: ORKStepViewController {
    
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var buttonSubmit:UIButton?
    @IBOutlet weak var labelDescription:UILabel?
    var descriptionText:String?
    
    var taskResult:EligibilityTokenTaskResult = EligibilityTokenTaskResult(identifier: kFetalKickCounterStepDefaultIdentifier)
    
    //MARK: ORKStepViewController Intitialization Methods
    
    override init(step: ORKStep?) {
        super.init(step: step)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonSubmit?.layer.borderColor =   kUicolorForButtonBackground
        
        if (self.descriptionText?.characters.count)! > 0{
            labelDescription?.text = self.descriptionText
        }
        
        if let step = step as? EligibilityStep {
            step.type = "token"
        }
        
        IQKeyboardManager.sharedManager().enable = true
    }
    
    //MARK: Methods and Button Actions
    
    func showAlert(message:String){
        let alert = UIAlertController(title:kErrorTitle as String,message:message as String,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:NSLocalizedString(kTitleOK, comment: ""), style: .default, handler: nil))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonActionSubmit(sender: UIButton?) {
        
        self.view.endEditing(true)
        let token = tokenTextField.text
        
        if (token?.isEmpty) == false {
            
            LabKeyServices().verifyEnrollmentToken(studyId: (Study.currentStudy?.studyId)!, token: token!, delegate: self)
        }else {
            self.showAlert(title: kTitleMessage, message:kMessageValidToken )
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: TextField Delegates
extension EligibilityStepViewController:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == " "{
            return false
            
        }else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
}

//MARK: Webservice Delegates
extension EligibilityStepViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.addProgressIndicator()
        
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        
        if (tokenTextField.text?.isEmpty) == false {
            self.taskResult.enrollmentToken = tokenTextField.text!
            
        }else {
            self.taskResult.enrollmentToken = ""
        }
        
        
        self.goForward()
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        
        self.removeProgressIndicator()
        if error.localizedDescription.localizedCaseInsensitiveContains(tokenTextField.text!){
            
            self.showAlert(message: kMessageInvalidTokenOrIfStudyDoesNotExist) //kMessageForInvalidToken
            
        }else {
            if error.localizedDescription.localizedCaseInsensitiveContains(kStudyWithStudyId) {
                
                self.showAlert(message:kMessageInvalidTokenOrIfStudyDoesNotExist) //kMessageForMissingStudyId
                
            }else {
                self.showAlert(message:error.localizedDescription)
            }
            
        }
    }
}

//MARK: ORKResult overriding

open class EligibilityTokenTaskResult: ORKResult {
    open var enrollmentToken:String = ""
    
    
    override open var description: String {
        get {
            return "enrollmentToken:\(enrollmentToken)"
        }
    }
    
    override open var debugDescription: String {
        get {
            return "enrollmentToken:\(enrollmentToken)"
        }
    }
}

