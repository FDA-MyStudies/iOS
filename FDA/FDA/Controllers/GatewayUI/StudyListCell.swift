//
//  StudyListCell.swift
//  FDA
//
//  Created by Surender Rathore on 3/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import SDWebImage

protocol StudyListDelegates {
    func studyBookmarked(_ cell:StudyListCell, bookmarked:Bool,forStudy study:Study)
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
       
        let color = studyStatusIndicator?.backgroundColor
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if(selected) {
            
            studyStatusIndicator?.backgroundColor = color
        }
    }
    
   override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = studyStatusIndicator?.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        if(highlighted) {
            
            studyStatusIndicator?.backgroundColor = color
        }

    }
    

    
    func populateCellWith(study:Study){
        
        selectedStudy = study
        
        labelStudyTitle?.text = study.name
        labelStudyShortDescription?.text = study.description
        
       
        
        if study.sponserName != nil {
            labelStudySponserName?.text =  study.category! + "  |  " + study.sponserName!
        }
        else {
            labelStudySponserName?.text =  study.category!
        }
        
        let attributedString =  labelStudySponserName?.attributedText?.mutableCopy() as! NSMutableAttributedString
        
        let foundRange = attributedString.mutableString.range(of:study.category!)
        attributedString.addAttributes([NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 12)!], range: foundRange)
        labelStudySponserName?.attributedText = attributedString
        
        
        
        studyLogoImage?.image = #imageLiteral(resourceName: "placeholder")
        
        //study status
        self.setStudyStatus(study: study)
        
        if User.currentUser.userType == .AnonymousUser {
            // do nothing
        }
        else {
            
            //set participatedStudies
            self.setUserStatusForStudy(study: study)
            
           
        }
        
        //logo
        if study.logoURL != nil {
            
            let url = URL.init(string: study.logoURL!)
            studyLogoImage?.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
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
        case .paused:
            studyStatusIndicator?.backgroundColor = Utilities.getUIColorFromHex(0xFF0000)  //red color
        }
    }
    
    func setUserStatusForStudy(study:Study){
        
        let currentUser = User.currentUser
        
        
        if let userStudyStatus = currentUser.participatedStudies.filter({$0.studyId == study.studyId}).first {
            
            //assign to study
            study.userParticipateState = userStudyStatus
            
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
        else {
            study.userParticipateState = UserStudyStatus()
            labelStudyUserStatus?.text = UserStudyStatus.StudyStatus.yetToJoin.description
            studyUserStatusIcon?.image = #imageLiteral(resourceName: "yet_to_join_icn")
            buttonBookmark?.isSelected = false
        }
        
        
        
        
    }
    
     //MARK:Button Actions
    @IBAction func buttonBookmardAction(_ sender:UIButton){
        
        if sender.isSelected {
            sender.isSelected = false
        }
        else {
            sender.isSelected = true
        }
        
        delegate?.studyBookmarked(self, bookmarked: sender.isSelected, forStudy: self.selectedStudy)
    }
}
