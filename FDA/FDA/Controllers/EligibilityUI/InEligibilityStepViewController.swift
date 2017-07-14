//
//  InEligibilityStepViewController.swift
//  FDA
//
//  Created by Arun Kumar on 7/13/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import ResearchKit


class InEligibilityStep: ORKStep {
   
    func showsProgress() -> Bool {
        return false
    }
}

//let kStudyWithStudyId = "Study with StudyId"

class InEligibilityStepViewController: ORKStepViewController {
    
    
    @IBOutlet weak var buttonDone:UIButton?
    @IBOutlet weak var labelDescription:UILabel?
    var descriptionText:String?
    
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonDone?.layer.borderColor =   kUicolorForButtonBackground
        
        if let step = step as? EligibilityStep {
            
        }
        
    }
    
    //MARK: Methods and Button Actions
    
    func showAlert(message:String){
        let alert = UIAlertController(title:kErrorTitle as String,message:message as String,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:NSLocalizedString(kTitleOK, comment: ""), style: .default, handler: nil))
        
        
        self.navigationController?.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func buttonActionDone(sender: UIButton?) {
        
       self.goForward()
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


