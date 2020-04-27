//
//  TwoButtonStepViewController.swift
//  HPHC
//
//  Created by Tushar Katyal on 27/01/20.
//  Copyright © 2020 BTC. All rights reserved.
//

import UIKit
import ResearchKit

var twoButtonStepViewControllerResultDefaultIdentifier = "twoDefaultIdentifier"

class TwoButtonStepViewController: ORKStepViewController {
    
    
    var taskResult : TwoButtonStepViewControllerResult = TwoButtonStepViewControllerResult(identifier: twoButtonStepViewControllerResultDefaultIdentifier)
    
    //MARK: Overridden Methods
    
    override init(step: ORKStep?) {
        super.init(step: step)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func goForward() {
        super.goForward()
    }
    
    override func hasNextStep() -> Bool {
        super.hasNextStep()
    }
    
    override var result: ORKStepResult? {
        let orkResult = super.result
        orkResult?.results = [self.taskResult]
        return orkResult
    }
    
    override func viewDidLoad() {
        print("TwoButtonStepViewController---ViewDidLoad")
    }
    
    //MARK: Actions
    @IBAction func actionBtnYes (_ sender : UIButton) {
        taskResult.buttonResult = "YES"
        
        self.perform(#selector(self.goForward))
        
    }
    
    @IBAction func actionBtnNo (_ sender : UIButton) {
        taskResult.buttonResult = "NO"
        
        self.perform(#selector(self.goForward))
    }
    
}


class TwoButtonStepViewControllerResult: ORKResult {
    open var buttonResult : String = "NO"
    
    
    override open var description: String {
        get {
            return buttonResult
        }
    }
    
    override open var debugDescription: String {
        get {
            return buttonResult
        }
    }
    
    
}

class TwoButtonStepViewControllerStep: ORKQuestionStep {
    var stepButtonResult : String?
}


class TwoButtonStepViewControllerTask {

    class func getTask() -> ORKOrderedTask {
        var steps : [ORKStep]?
        
        let step1 = TwoButtonStepViewControllerStep(identifier: twoButtonStepViewControllerResultDefaultIdentifier)
        
        steps?.append(step1)
        
        return ORKOrderedTask(identifier: "twoButtonStepViewControllerResultDefaultIdentifierTask", steps: steps)
    }
    
    class func getStep() -> ORKStep {
        let step1 = TwoButtonStepViewControllerStep(identifier: twoButtonStepViewControllerResultDefaultIdentifier)
        
        return step1
    }

}
