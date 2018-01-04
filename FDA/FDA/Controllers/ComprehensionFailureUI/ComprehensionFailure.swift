//
//  ComprehensionFailure.swift
//  FDA
//
//  Created by Arun Kumar on 25/07/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation

let kComprehensionFailureViewIdentifier = "ComprehensionFailure"

protocol ComprehensionFailureDelegate {
    func didTapOnRetry();
    func didTapOnCancel();
}
class ComprehensionFailure: UIView {
    
    @IBOutlet weak var buttonCancel:UIButton!
    @IBOutlet weak var buttonRetry:UIButton!
    @IBOutlet weak var labelDescription:UILabel!
    
    var delegate:ComprehensionFailureDelegate?
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
       
        //sets border color for bottom view
        buttonRetry?.layer.borderColor =   kUicolorForButtonBackground
    }
    class func instanceFromNib(frame:CGRect,detail:Dictionary<String,Any>?) -> ComprehensionFailure {
        
        let view = UINib(nibName: kComprehensionFailureViewIdentifier, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ComprehensionFailure
        view.frame = frame
        view.buttonRetry?.layer.borderColor =   kUicolorForButtonBackground
        
        view.layoutIfNeeded()
        return view
        
    }
    
    //MARK: Button Actions
    @IBAction func buttonCancelAction() {
        self.isHidden =  true
        self.removeFromSuperview()
        self.delegate?.didTapOnCancel()
    }
    @IBAction func buttonRetryAction() {
       
      self.delegate?.didTapOnRetry()
      self.isHidden =  true
      self.removeFromSuperview()
    }
}
