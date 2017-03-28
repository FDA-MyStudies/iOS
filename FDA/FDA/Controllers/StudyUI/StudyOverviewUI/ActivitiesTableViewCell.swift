//
//  ActivitiesTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/23/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class ActivitiesTableViewCell: UITableViewCell {

    @IBOutlet var imageIcon : UIImageView?
    @IBOutlet var labelDays : UILabel?
    @IBOutlet var labelHeading : UILabel?
    @IBOutlet var labelTime : UILabel?
    @IBOutlet var labelStatus : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func populateCellData(data: NSDictionary){
        self.labelDays?.text = data["day"] as? String
        self.labelHeading?.text = data["heading"] as? String
        self.labelTime?.text = data["time"] as? String
        self.labelStatus?.text = data["operation"] as? String
        
        if data["day"] as? String == "Weekely"{
            self.imageIcon?.image = UIImage.init(named: "taskIcon")
        }
        
        self.labelStatus?.isHidden = true
        if data["operation"] as? String != ""{
            self.labelStatus?.isHidden = false
            
            if data["operation"] as? String == "Resume"{
                self.labelStatus?.backgroundColor = UIColor.init(red: 245/255.0, green: 175/255.0, blue: 55/255.0, alpha: 1.0)
                self.labelStatus?.text = "  Resume  "
                
            }else if data["operation"] as? String == "Start"{
                self.labelStatus?.backgroundColor = UIColor.init(red: 0/255.0, green: 124/255.0, blue: 186/255.0, alpha: 1.0)
                self.labelStatus?.text = "  Start  "
                
            }else{
                self.labelStatus?.backgroundColor = UIColor.init(red: 76/255.0, green: 175/255.0, blue: 80/255.0, alpha: 1.0)
                self.labelStatus?.text = "  Completed  "
                
            }
        }
    }
    
}
