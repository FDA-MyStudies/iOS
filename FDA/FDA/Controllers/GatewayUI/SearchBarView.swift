//
//  SearchBarView.swift
//  FDA
//
//  Created by Arun Kumar on 07/08/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation


protocol searchBarDelegate {
    func didTapOnCancel()
    func  search(text:String)
}


class SearchBarView: UIView {
    
    @IBOutlet weak var textFieldSearch:UITextField?
    @IBOutlet weak var buttonCancel:UIButton?
    @IBOutlet weak var viewBackground:UIView?
    var delegate: searchBarDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
        
    }
    class func instanceFromNib(frame:CGRect,detail:Dictionary<String,Any>?) -> SearchBarView {
        
        let view = UINib(nibName: "SearchBarView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SearchBarView
        view.frame = frame
        view.layoutIfNeeded()
        
        
        
        view.viewBackground?.layer.cornerRadius = 2.0
        view.viewBackground?.clipsToBounds = true
        
        
        
        return view
        
    }
    
    @IBAction func buttonCancelAction(){
       self.delegate?.didTapOnCancel()
        
        self.removeFromSuperview()
    }
    
}

extension SearchBarView : UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.tag)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let finalString = textField.text! + string
        
        
        if textField == textFieldSearch{
            if finalString.characters.count > 64 {
                return false
            }
            else{
                if (range.location == textField.text?.characters.count && string == " ") {
                    
                    textField.text = textField.text?.appending("\u{00a0}")
                    return false
                }
                return true
            }
        }
        else{
            
            if (range.location == textField.text?.characters.count && string == " ") {
                
                textField.text = textField.text?.appending("\u{00a0}")
                return false
            }
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text!)
        textField.text =  textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        textField.resignFirstResponder()
        
        if textField.text != nil && (textField.text?.characters.count)! > 0 {
            self.delegate?.search(text: textField.text!)
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
