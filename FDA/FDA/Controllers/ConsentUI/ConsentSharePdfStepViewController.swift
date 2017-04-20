//
//  ConsentCompletionViewController.swift
//  FDA
//
//  Created by Arun Kumar on 4/4/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import ResearchKit

let kConsentCompletionResultIdentifier = "ConsentCompletion"

class ConsentCompletionStep: ORKStep {
    var mainTitle:String?
    var subTitle:String?
}

class ConsentCompletionViewController: ORKStepViewController {

    @IBOutlet weak var buttonViewPdf:UIButton?
    
    @IBOutlet weak var buttonNext:UIButton?
    
    
    var taskResult:ConsentCompletionTaskResult = ConsentCompletionTaskResult(identifier: kConsentCompletionResultIdentifier)
    
    
//MARK:ORKstepView Controller Init methods
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
    
    
//MARK:Button Actions
    
    @IBAction func buttonActionNext(sender: UIButton?) {
         self.taskResult.didTapOnViewPdf = false
        self.goForward()
    }
    
    @IBAction func buttonActionViewPdf(sender: UIButton?) {
        
        self.taskResult.didTapOnViewPdf = true
        self.goForward()
    }
    
//MARK:View controller delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let step = step as? ConsentCompletionStep {
            step.mainTitle = "Thanks for providing consent for this Study"
            step.subTitle =  "You can now start participating in the Study"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



open class ConsentCompletionTaskResult: ORKResult {
    
    open var didTapOnViewPdf:Bool = false
    
    
    override open var description: String {
        get {
            return "didTapOnViewPdf:\(didTapOnViewPdf)"
        }
    }
    
    override open var debugDescription: String {
        get {
            return "didTapOnViewPdf:\(didTapOnViewPdf)"
        }
    }
}


