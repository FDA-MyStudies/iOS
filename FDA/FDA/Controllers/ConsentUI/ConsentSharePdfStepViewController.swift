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
let kMainTitle = "Thanks for providing consent for this Study"
let kSubTitle = "You can now start participating in the Study"


/* Consent Completion Step
 @mainTitle: title displayed in Consent Completion UI
 @subTitle: subTitle displayed in Consent Completion UI
 */
class ConsentCompletionStep: ORKStep {
    var mainTitle:String?
    var subTitle:String?
    
    /*
     showsProgress: Displays the step numbers in navigation bar
     */
    func showsProgress() -> Bool {
        return false
    }
    
}

class ConsentSharePdfStepViewController: ORKStepViewController {
    
    @IBOutlet weak var buttonViewPdf:UIButton? // button to Push to PdfViewer
    
    @IBOutlet weak var buttonNext:UIButton? // button to take to next step
    var consentDocument:ORKConsentDocument?
    
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
        
        self.addProgressIndicator()
        
        //Generating consentDocumentPdf
        self.consentDocument?.makePDF(completionHandler: { data,error in
            NSLog("data: \(String(describing: data))    \n  error: \(String(describing: error))")
            
            self.taskResult.pdfData = data!
            
            self.taskResult.didTapOnViewPdf = true
            
            //Saving ConsentPdfData
            ConsentBuilder.currentConsent?.consentResult?.consentPdfData = Data()
            ConsentBuilder.currentConsent?.consentResult?.consentPdfData = data
            
            
            self.removeProgressIndicator()
            //Navigate to next step
            self.goForward()
            
        })
    }
    
    //MARK:View controller delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let step = step as? ConsentCompletionStep {
            step.mainTitle = kMainTitle
            step.subTitle =  kSubTitle
        }
        
        buttonViewPdf?.layer.borderColor =   kUicolorForButtonBackground
        
        buttonNext?.layer.borderColor =   kUicolorForButtonBackground
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


//Overrriding the ORKTaskResult to get customized results
open class ConsentCompletionTaskResult: ORKResult {
    
    open var didTapOnViewPdf:Bool = false
    
    open var pdfData:Data = Data()
    
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


