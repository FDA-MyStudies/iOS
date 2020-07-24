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

class LARConsentParticipantStep: ORKStep {
//    var type: String?
    
    func showsProgress() -> Bool {
        return false
    }
}

class LARConsentParticipantViewController: ORKStepViewController {
    
    @IBOutlet weak var relationshipTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var buttonSubmit: UIButton?
    @IBOutlet weak var buttonCancel: UIButton?
    @IBOutlet weak var buttonBack: UIButton?
    
    var nextButtonHasToEnable = false
    
    // MARK: ORKStepViewController Intitialization Methods
    
    override init(step: ORKStep?) {
        super.init(step: step)
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("92---")
        super.init(coder: aDecoder)
//        self.goForward()
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
        
        goForward()
        print("93---")
        
        self.taskViewController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
        buttonSubmit?.layer.borderColor =   kUicolorForButtonBackground
    }

    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        print("94---")
//        self.goForward()
            self.navigationController?.isToolbarHidden = true
        }
    
    // MARK: Methods and Button Actions
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: kErrorTitle as String,message: message as String,preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(kTitleOK, comment: ""), style: .default, handler: nil))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonActionCancel(sender: UIButton?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonActionSubmit(sender: UIButton?) {
        let valErrorMessage = errorMessage()
        if valErrorMessage.isEmpty {
            showAlert(title: kTitleError, message: valErrorMessage )
        }
        else {
            self.view.endEditing(true)
            self.goForward()
        }
    }
    
    func errorMessage() -> String {
        if relationshipTextField.text?.isEmpty ?? true {
            return kMessageRelationship
        } else if relationshipTextField.text?.isEmpty ?? true {
            return kMessageFirstNameBlank
        } else if relationshipTextField.text?.isEmpty ?? true {
            return kMessageLastNameBlank
        }
        
        return ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: TextField Delegates
extension LARConsentParticipantViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {}
    
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

open class LARConsentParticipantResult: ORKResult {
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
