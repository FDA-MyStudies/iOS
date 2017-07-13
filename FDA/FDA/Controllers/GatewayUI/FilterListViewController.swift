//
//  FilterListViewController.swift
//  FDA
//
//  Created by Ravishankar on 7/11/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit


//Used to apply filter based on Apply and Cancel actions
protocol StudyFilterDelegates {
    
    func appliedFilter(studyArray : Array<String>, statusArray : Array<String>, categoriesArray : Array<String>)
    
    func cancelFilter(studyArray : Array<String>, statusArray : Array<String>, categoriesArray : Array<String>)
}

class StudyFilterViewController: UIViewController {

    @IBOutlet weak var cancelButton : UIButton?
    @IBOutlet weak var applyButton : UIButton?
    
    var delegate : StudyFilterDelegates?
    
    var studiesString = ""
    var categoriesString = ""
    var participationStatus = ""
    
    
    //MARK:- Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applyButton?.layer.borderColor = kUicolorForButtonBackground
        cancelButton?.layer.borderColor = kUicolorForCancelBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
    }
    
    
    //MARK:- Button Actions
    
    /**
     
     Navigate to Studylist screen on Apply button clicked
     
     @param sender    accepts Anyobject in sender
     
     */
    @IBAction func applyButtonAction(_ sender: AnyObject){
        delegate?.appliedFilter(studyArray: [""], statusArray: [""], categoriesArray: [""])
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    /**
     
     Navigate to Studylist screen on Cancel button clicked
     
     @param sender    accepts Anyobject in sender
     
     */
    @IBAction func cancelButtonAction(_ sender: AnyObject){
        delegate?.cancelFilter(studyArray: [""], statusArray: [""], categoriesArray: [""])
        self.dismiss(animated: true, completion: nil)

    
    }
}












