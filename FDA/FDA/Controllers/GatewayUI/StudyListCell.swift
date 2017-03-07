//
//  StudyListCell.swift
//  FDA
//
//  Created by Surender Rathore on 3/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

protocol StudyListDelegates {
    func studyBookmark(_ cell:StudyListCell,didTapped button:UIButton,forStudy study:Study)
}

class StudyListCell: UITableViewCell {

    @IBOutlet var labelStudyUserStatus:UILabel?
    @IBOutlet var labelStudyTitle:UILabel?
    @IBOutlet var labelStudyShortDescription:UILabel?
    @IBOutlet var labelStudySponserName:UILabel?
    @IBOutlet var labelStudyCategoryType:UILabel?
    @IBOutlet var labelCompletionValue:UILabel?
    @IBOutlet var labelAdherenceValue:UILabel?
    @IBOutlet var labelStudyStatus:UILabel?
    
    @IBOutlet var buttonBookmark:UIButton?
    
    @IBOutlet var progressBarCompletion:UIProgressView?
    @IBOutlet var progressBarAdherence:UIProgressView?
    
    @IBOutlet var studyLogoImage:UIImageView?
    @IBOutlet var studyUserStatusIcon:UIImageView?
    
    @IBOutlet var studyStatusIndicator:UIView?
    
    var selectedStudy:Study!
    var delegate:StudyListDelegates? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func populateCellWith(study:Study){
        
        selectedStudy = study
        
        labelStudyTitle?.text = study.name
        labelStudyShortDescription?.text = study.description
        labelStudySponserName?.text = study.sponserName
        labelStudyCategoryType?.text = study.category
        studyLogoImage?.image = #imageLiteral(resourceName: "welcomeBg")
        
        self.setStudyStatus(study: study)
        
        if User.currentUser.userType == .AnonymousUser {
            
        }
        else {
            //self.setUserStatusForStudy(study: study)
        }
    }
    
    func setStudyStatus(study:Study){
        
        labelStudyStatus?.text = study.status.rawValue.uppercased()
        
        switch study.status {
        case .active:
            studyStatusIndicator?.backgroundColor = Utilities.getUIColorFromHex(0x4caf50) //green
        case .upcoming:
            studyStatusIndicator?.backgroundColor = Utilities.getUIColorFromHex(0x007cba)  //app color
        case .closed:
            studyStatusIndicator?.backgroundColor = Utilities.getUIColorFromHex(0xFF0000)  //red color
            
        }
    }
    
    func setUserStatusForStudy(study:Study){
        
        let currentUser = User.currentUser
        let userStudyStatus = currentUser.participatedStudies[0]
        
        //user study status
        labelStudyUserStatus?.text = userStudyStatus.status.description
        
        switch userStudyStatus.status {
        case .inProgress:
            studyUserStatusIcon?.image = #imageLiteral(resourceName: "in_progress_icn")
        case .yetToJoin:
            studyUserStatusIcon?.image = #imageLiteral(resourceName: "yet_to_join_icn")
         case .notEligible:
            studyUserStatusIcon?.image = #imageLiteral(resourceName: "not_eligible_icn")
        case .withdrawn:
            studyUserStatusIcon?.image = #imageLiteral(resourceName: "not_eligible_icn")
        case .completed:
            studyUserStatusIcon?.image = #imageLiteral(resourceName: "completed_icn")

        }
        
        //bookMarkStatus
        buttonBookmark?.isSelected = userStudyStatus.bookmarked
        
        
    }
    
     //MARK:Button Actions
    @IBAction func buttonBookmardAction(_ sender:UIButton){
        
        if sender.isSelected {
            sender.isSelected = false
        }
        else {
            sender.isSelected = true
        }
        
        delegate?.studyBookmark(self, didTapped:sender, forStudy:selectedStudy)
    }
}
