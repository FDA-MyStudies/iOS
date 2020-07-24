/*
 License Agreement for FDA My Studies
Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.
Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import ResearchKit
import IQKeyboardManagerSwift

class LARConsentStep: ORKStep {
//    var type: String?
    
    func showsProgress() -> Bool {
        return false
    }
}

class LARConsentStepViewController: ORKStepViewController {
    
    @IBOutlet weak var buttonSubmit: UIButton?
    @IBOutlet weak var buttonCancel: UIButton?
    @IBOutlet weak var buttonBack: UIButton?
    @IBOutlet weak var buttonMyself: UIButton?
    @IBOutlet weak var buttonOnBehalf: UIButton?
    @IBOutlet weak var labelMyself: UILabel?
    @IBOutlet weak var labelOnBehalf: UILabel?
    
    var hasOnBehalfSelected: Bool = true
    var taskResult: LARTokenTaskResult = LARTokenTaskResult(identifier: kFetalKickCounterStepDefaultIdentifier)
    
    let kLARConsentParticipantViewController = "LARConsentParticipantViewController"
    
    // MARK: ORKStepViewController Intitialization Methods
    
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
        
        self.taskViewController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
        buttonSubmit?.layer.borderColor = kUicolorForButtonBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
//        let footerView = ORKNavigationContainerView()
//        footerView.translatesAutoresizingMaskIntoConstraints = false
//        footerView.neverHasContinueButton = true
////        footerView.cancelButtonItem = self.cancelButtonItem
//        footerView.skipEnabled = false
//        self.view.addSubview(footerView)
        
//        NSLayoutConstraint.activate([
//            footerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
//            footerView.heightAnchor.constraint(equalToConstant: 100),
//            footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
//            footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
//            ])
        
        self.navigationController?.isToolbarHidden = true
    }
    
    // MARK: Methods and Button Actions
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: kErrorTitle as String,message: message as String,preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(kTitleOK, comment: ""), style: .default, handler: nil))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonActionMyself(sender: UIButton?) {
        labelMyself?.textColor = Utilities.getUIColorFromHex(0x007cba)
        labelOnBehalf?.textColor = .black
        hasOnBehalfSelected = false
    }
    
    @IBAction func buttonActionOnBehalf(sender: UIButton?) {
        labelMyself?.textColor = .black
        labelOnBehalf?.textColor = Utilities.getUIColorFromHex(0x007cba)
        hasOnBehalfSelected = true
    }
    
    @IBAction func buttonActionCancel(sender: UIButton?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonActionSubmit(sender: UIButton?) {
        
        self.view.endEditing(true)
        if !hasOnBehalfSelected {
            self.goForward()
//           let _ = self.taskViewController?.delegate?.taskViewController?(self.taskViewController!, shouldPresent: ORKStep(identifier: "sharing MobileTesting"))
        } else {
            self.goForward()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: ORKResult overriding

open class LARTokenTaskResult: ORKResult {
    open var enrollmentToken: String = ""
    
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

