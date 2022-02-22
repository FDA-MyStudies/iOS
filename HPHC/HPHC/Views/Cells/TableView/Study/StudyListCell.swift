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

// import SDWebImage
import UIKit
import SDWebImage

protocol StudyListDelegates {
    func studyBookmarked(_ cell: StudyListCell, bookmarked: Bool,forStudy study: Study)
}

class StudyListCell: UITableViewCell {

    @IBOutlet var labelStudyUserStatus: UILabel?
    @IBOutlet var labelStudyTitle: UILabel?
    @IBOutlet var labelStudyShortDescription: UILabel?
    @IBOutlet var labelStudySponserName: UILabel?
    @IBOutlet var labelStudyCategoryType: UILabel?
    @IBOutlet var labelCompletionValue: UILabel?
    @IBOutlet var labelAdherenceValue: UILabel?
    @IBOutlet var labelStudyStatus: UILabel?
    @IBOutlet var labelStudylanguage: UILabel?
    @IBOutlet var buttonBookmark: UIButton?
    @IBOutlet var progressBarCompletion: UIProgressView?
    @IBOutlet var progressBarAdherence: UIProgressView?
    @IBOutlet var studyLogoImage: UIImageView?
    @IBOutlet var studyUserStatusIcon: UIImageView?
    @IBOutlet var studyStatusIndicator: UIView?
    @IBOutlet var categoryBG: UIView?
    
    var selectedStudy: Study!
    var delegate: StudyListDelegates? = nil
    
    /// Cell cleanup.
    override func prepareForReuse() {
        super.prepareForReuse()
          studyLogoImage?.image = UIImage(named: "placeholder")
    }
    
    /// Used to change the cell background color.
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = studyStatusIndicator?.backgroundColor
        let color2 = categoryBG?.backgroundColor
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if(selected) {
            studyStatusIndicator?.backgroundColor = color
            categoryBG?.backgroundColor = color2
        }
    }
    
    
    /**
     
     Used to set the cell state ie Highlighted
     
     @param highlighted    should cell be highlightened
     @param animated    used to animate the cell

     */
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = studyStatusIndicator?.backgroundColor
        let color2 = categoryBG?.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        if(highlighted) {
            studyStatusIndicator?.backgroundColor = color
            categoryBG?.backgroundColor = color2
        }
    }
    
    
    /**
     
     Used to populate the cell data
     @param study    access the data from Study class
     */
    func populateCellWith(study: Study){
        selectedStudy = study
        // logo
        updateStudyImage(study)
           
        labelStudyTitle?.text = study.name
        
        labelStudyShortDescription?.text = study.description
        if study.sponserName != nil {
            labelStudySponserName?.text =  study.sponserName!
        }
        
        labelStudyCategoryType?.text =  categoryReCorrection(study.category!).uppercased()
        
        progressBarCompletion?.layer.cornerRadius = 2
        progressBarCompletion?.layer.masksToBounds = true
        
        let attributedString =  labelStudySponserName?.attributedText?.mutableCopy() as! NSMutableAttributedString
        
        let foundRange = attributedString.mutableString.range(of: study.category!)
        attributedString.addAttributes([NSAttributedString.Key.font:UIFont(name: "HelveticaNeue-Bold", size: 12)!], range: foundRange)
        labelStudySponserName?.attributedText = attributedString
        
        //study status
        self.setStudyStatus(study: study)
      
        //study status
        self.setStudyLanguage(study: study)
        
        
        if User.currentUser.userType == .AnonymousUser {
            // do nothing
        }
        else {
            //set participatedStudies
            self.setUserStatusForStudy(study: study)
        }
    }
  
    //Category correction for Spanish Language
    func categoryReCorrection(_ category: String) -> String {
      switch category {
      case "1Biologics Safety":
        return "Seguridad de los productos biológicos"
      case "1Clinical Trials":
        return "Ensayos clínicos"
      case "1Cosmetics Safety":
        return "Seguridad de los cosméticos"
      case "1Drug Safety":
        return "Seguridad de los medicamentos"
      case "1Food Safety":
        return "Seguridad alimenticia"
      case "1Medical Device Safety":
        return "Seguridad de dispositivos médicos"
      case "1Observational Studies":
        return "Estudios observacionales"
      case "1Public Health":
        return "Salud pública"
      case "1Radiation-Emitting Products":
        return "Productos de radiación"
      case "1Tobacco Use":
        return "El consumo de tabaco"
      default:
        return category // Category is in English OR category Not recognised
      }
    }
  
    /**
     Used to set the Study Language
     @param study    Access the data from Study Class
     */
    func setStudyLanguage(study: Study){
        
        let locale3 = getLanguageLocale()
        
        print("studyId \(study.studyId) study name is \(study.name)study Language \(study.studyLanguage) and locale is \(locale3)")
        if ((locale3.hasPrefix("es") &&
             study.studyLanguage.containsIgnoringCase("spanish")) ||
            (locale3.hasPrefix("en") && study.studyLanguage.containsIgnoringCase("english"))) {
            labelStudylanguage?.text = ""
        }else{
            if (study.studyLanguage.containsIgnoringCase("english")){
                labelStudylanguage?.text = NSLocalizedStrings("English", comment: "")
            }else{
                labelStudylanguage?.text = NSLocalizedStrings("Spanish", comment: "")
            }
        }
    }
    
    /**
     Used to set the Study State
     @param study    Access the data from Study Class
     */
    func setStudyStatus(study: Study){
        
        labelStudyStatus?.text = NSLocalizedStrings("\(study.status.rawValue.uppercased())", comment: "")
        
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
    func setUserStatusForStudy(study: Study){
        let currentUser = User.currentUser
        if let userStudyStatus = currentUser.participatedStudies.filter({$0.studyId == study.studyId}).first {
            
            //assign to study
            study.userParticipateState = userStudyStatus
            
            //user study status
            
            switch study.status {
            case .Active:
                labelStudyUserStatus?.text = NSLocalizedStrings("\(userStudyStatus.status.description)", comment: "")
            case .Closed:
                labelStudyUserStatus?.text = NSLocalizedStrings("\(userStudyStatus.status.closedStudyDescription)", comment: "")
            case .Upcoming:
                labelStudyUserStatus?.text = NSLocalizedStrings("\(userStudyStatus.status.upcomingStudyDescription)", comment: "")
            default:
                labelStudyUserStatus?.text = NSLocalizedStrings("\(userStudyStatus.status.description)", comment: "")
            }
          
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
            case .Withdrawn:
                studyUserStatusIcon?.image = #imageLiteral(resourceName: "withdrawn_icn1")
            case .completed:
                studyUserStatusIcon?.image = #imageLiteral(resourceName: "completed_icn")
                
            }
            // bookMarkStatus
            buttonBookmark?.isSelected = userStudyStatus.bookmarked
        }
        else {
            study.userParticipateState = UserStudyStatus()
            labelStudyUserStatus?.text = UserStudyStatus.StudyStatus.yetToJoin.description
            studyUserStatusIcon?.image = #imageLiteral(resourceName: "yet_to_join_icn")
            buttonBookmark?.isSelected = false
        }
    }
    
    
// MARK:- Button Actions
    
  /// Updates the icon for `Study`
     /// - Parameter study: Instance of Study.
     fileprivate func updateStudyImage(_ study: Study) {
         // Update study logo using SDWEBImage and cache it.
         if let logoURLString = study.logoURL,
             let url = URL(string: logoURLString) {
             studyLogoImage?.sd_setImage(with: url, placeholderImage: nil, options: .progressiveLoad, completed: { [weak self] (image, error, _, _) in
                 if let image = image {
                     self?.studyLogoImage?.image = image
                 }
             })
         }
     }
  
    // MARK:- Button Actions
    
    /// Button bookmark clicked and delegate it back to Study home and
    /// Study list View controller.
    @IBAction func buttonBookmardAction(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
        }
        else {
            sender.isSelected = true
        }
        delegate?.studyBookmarked(self, bookmarked: sender.isSelected, forStudy: self.selectedStudy)
    }
}
