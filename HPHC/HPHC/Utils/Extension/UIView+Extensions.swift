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

import Foundation

extension UIView {

}

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: backgroundColor!), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: tintColor!), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }

    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}

private var kAssociationKeyMaxLength: Int = 0

extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }
    
    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }
        
        let selection = selectedTextRange
        
        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        
        selectedTextRange = selection
    }
}

@IBDesignable
class TapAndCopyLabel: UILabel {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    //1.Adding UILongPressGestureRecognizer by which copy popup will Appears
    let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
    self.addGestureRecognizer(gestureRecognizer)
    self.isUserInteractionEnabled = true
  }
  
  // MARK: - UIGestureRecognizer
  @objc func handleLongPressGesture(_ recognizer: UIGestureRecognizer) {
    guard recognizer.state == .recognized else { return }
    
    if let recognizerView = recognizer.view,
       let recognizerSuperView = recognizerView.superview, recognizerView.becomeFirstResponder()
    {
      let menuController = UIMenuController.shared
      menuController.setTargetRect(recognizerView.frame, in: recognizerSuperView)
      menuController.setMenuVisible(true, animated:true)
    }
  }
  //2.Returns a Boolean value indicating whether this object can become the first responder
  override var canBecomeFirstResponder: Bool {
    return true
  }
  //3. Enabling copy action
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return (action == #selector(UIResponderStandardEditActions.copy(_:)))
    
  }
  // MARK: - UIResponderStandardEditActions
  override func copy(_ sender: Any?) {
    //4.copy current Text to the paste board
    UIPasteboard.general.string = text
  }
}

public extension UITextField {
  
  @IBInspectable var localizedText: String? {
    get {
      return placeholder
    }
    set (key) {
      placeholder = NSLocalizedStrings(key ?? "", comment: "")
    }
  }
  
}

public extension UITextField {
  
  @IBInspectable var localizedTextFieldtxt: String? {
    get {
      return text
    }
    set (key) {
      text = NSLocalizedStrings(key ?? "", comment: "")
    }
  }
  
}

public extension UILabel {
  
  @IBInspectable var localizedText: String? {
    get {
      return text
    }
    set {
      text = NSLocalizedStrings(newValue ?? "", comment: "")
    }
  }
  
}

public extension UIButton {
  
  @IBInspectable var localizedText: String? {
    get {
      return title(for: .normal)
    }
    set (key) {
      setTitle(NSLocalizedStrings(key ?? "", comment: ""), for: .normal)
    }
  }
  
}
