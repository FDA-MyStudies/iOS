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
import Foundation

enum TextFieldTags: Int {
   // case FirstNameTag = 0
   // case LastName
    case EmailId = 0
    case Password
    case ConfirmPassword
}

class SignUpTableViewCell: UITableViewCell {
    
    @IBOutlet var labelType: UILabel?
    @IBOutlet var textFieldValue: UITextField?
    @IBOutlet var buttonChangePassword: UIButton? // this button will be extensively used for profile screen
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    /**
     
     Populate cell data coming in dictionary
     
     @param data    Access the data from Dictionary
     @param securedText     condition used to give TextField secured or not
     @param keyboardType    allows which kind of keyboard to use
     
     */
    func populateCellData(data: NSDictionary , securedText: Bool, keyboardType: UIKeyboardType?){
        
        textFieldValue?.isSecureTextEntry = false
      textFieldValue?.textContentType = UITextContentType(rawValue: "")
      if securedText == true {
        if #available(iOS 12.0, *) {
          textFieldValue?.autocorrectionType = .no
        } else {
          textFieldValue?.autocorrectionType = .no
        }
      }
        

        
        labelType?.text = NSLocalizedStrings((data["helpText"] as? String)!, comment: "")
        textFieldValue?.placeholder = NSLocalizedStrings((data["placeHolder"] as? String)!, comment: "")
        
        if keyboardType == nil {
            textFieldValue?.keyboardType = .emailAddress
        } else {
            textFieldValue?.keyboardType = keyboardType!
        }
    }
    
    
    /**
     
     Set cell data from User Object (for Profile Class)
     
     @param tag    is the cell index
     
     */
    func setCellData(tag: TextFieldTags)  {
        let user = User.currentUser
        switch tag {
            
        case .EmailId:
            if Utilities.isValidValue(someObject: user.emailId as AnyObject?) {
                self.textFieldValue?.text =  user.emailId
            } else {
                self.textFieldValue?.text = ""
            }
            
        case .Password:
            if Utilities.isValidValue(someObject: user.password as AnyObject?) {
                self.textFieldValue?.text =  user.password
            } else {
                self.textFieldValue?.text = ""
            }
            
        default: break
            
        }
    }    
}



