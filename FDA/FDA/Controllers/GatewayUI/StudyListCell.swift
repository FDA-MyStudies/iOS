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

    /**
     
     Used to change the cell background color
     
     @param selected    checks if particular cell is selected
     @param animated    used to animate the cell

     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = studyStatusIndicator?.backgroundColor
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if(selected) {
            studyStatusIndicator?.backgroundColor = color
        }
    }
    
    
    /**
     
     Used to set the cell state ie Highlighted
     
     @param highlighted    should cell be highlightened
     @param animated    used to animate the cell

     */
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = studyStatusIndicator?.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        if(highlighted) {
            studyStatusIndicator?.backgroundColor = color
        }
    }
    
    
    /**
     
     Used to populate the cell data
     
     @param study    access the data from Study class

     */
    func populateCellWith(study:Study){
        selectedStudy = study
        labelStudyTitle?.text = study.name
        
        labelStudyShortDescription?.text = study.description
        if study.sponserName != nil {
            labelStudySponserName?.text =  study.sponserName!
        }
        
        labelStudyCategoryType?.text =  study.category!.uppercased()
        
        progressBarCompletion?.layer.cornerRadius = 2
        progressBarCompletion?.layer.masksToBounds = true
        
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
    
    
    /**
     
     Used to set the Study State
     
     @param study    Access the data from Study Class

     */
    func setStudyStatus(study:Study){
        
        labelStudyStatus?.text = study.status.rawValue.uppercased()
        
        switch study.status {
        case .Active:
            studyStatusIndicator?.backgroundColor = Utilities.getUIColorFromHex(0x4caf50) //green
        case .Upcoming:
            studyStatusIndicator?.backgroundColor = Utilities.getUIColorFromHex(0x007cba)  //app color
        case .Closed:
            studyStatusIndicator?.backgroundColor = Utilities.getUIColorFromHex(0xFF0000)  //red color
        case .Paused:
            studyStatusIndicator?.backgroundColor = Utilities.getUIColorFromHex(0xf5af37)  //orange color
        }
    }
    
    
    /**
     
     Used to set UserStatus ForStudy
     
     @param study    Access the data from Study Class
     
     */
    func setUserStatusForStudy(study:Study){
        let currentUser = User.currentUser
        if let userStudyStatus = currentUser.participatedStudies.filter({$0.studyId == study.studyId}).first {
            
            //assign to study
            study.userParticipateState = userStudyStatus
            
            //user study status
            labelStudyUserStatus?.text = userStudyStatus.status.description
            
            //update completion %
            self.labelCompletionValue?.text = String(userStudyStatus.completion) + "%"
            self.labelAdherenceValue?.text = String(userStudyStatus.adherence)  + "%"
            self.progressBarCompletion?.progress = Float(userStudyStatus.completion)/100
            self.progressBarAdherence?.progress = Float(userStudyStatus.adherence)/100
            
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
    
    
//MARK:- Button Actions
    
    /**
     
     Button bookmark clicked and delegate it back to Study home and 
     Study list View controller
     
     @param sender    Accepts UIButton object
     
     */
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
