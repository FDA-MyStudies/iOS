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

class ConsentSharePdfStepViewController: ORKStepViewController {

    @IBOutlet weak var buttonViewPdf:UIButton?
    
    @IBOutlet weak var buttonNext:UIButton?
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
      
        
        self.consentDocument?.makePDF(completionHandler: { data,error in
            NSLog("data: \(data)    \n  error: \(error)")
            
            self.taskResult.pdfData = data!
            
            self.taskResult.didTapOnViewPdf = true
            
            let dir = FileManager.getStorageDirectory(type: .study)
            
            let fullPath = "file://" + dir + "/" + "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + ".pdf"
            
            do {
                
                if FileManager.default.fileExists(atPath: fullPath){
                    
                    try FileManager.default.removeItem(atPath: fullPath)
                    
                }
                FileManager.default.createFile(atPath:fullPath , contents: data, attributes: [:])
                
                
                try data?.write(to:  URL(string:fullPath)!)
                
                //try data?.write(to: URL(string:fullPath)! , options: .atomicWrite)
                
                // writing to disk
                
            } catch let error as NSError {
                print("error writing to url \(fullPath)")
                print(error.localizedDescription)
            }

            self.removeProgressIndicator()
            
            self.goForward()
            
        })
    }
    
//MARK:View controller delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let step = step as? ConsentCompletionStep {
            step.mainTitle = "Thanks for providing consent for this Study"
            step.subTitle =  "You can now start participating in the Study"
        }
        
         buttonViewPdf?.layer.borderColor =   kUicolorForButtonBackground
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



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


