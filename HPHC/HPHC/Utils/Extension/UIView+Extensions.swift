//
//  UIView+Extensions.swift
//  HPHC
//
//  Created by Tushar Katyal on 11/05/20.
//  Copyright © 2020 BTC. All rights reserved.
//

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
