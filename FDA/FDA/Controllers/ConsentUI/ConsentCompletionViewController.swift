//
//  ConsentCompletionViewController.swift
//  FDA
//
//  Created by Arun Kumar on 4/4/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import ResearchKit

class ConsentCompletionStep: ORKStep {
    var mainTitle:String?
    var subTitle:String?
}

class ConsentCompletionViewController: ORKStepViewController {

    @IBOutlet weak var buttonViewPdf:UIButton?
    
    @IBOutlet weak var buttonNext:UIButton?
    
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
    
    
//MARK:Button Actions
    
    @IBAction func buttonActionNext(sender: UIButton?) {
        self.goForward()
    }
    
    @IBAction func buttonActionViewPdf(sender: UIButton?) {
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
