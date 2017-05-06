//
//  NotificationTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/1/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet var labelNotificationText : UILabel?
    @IBOutlet var labelNotificationTime : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    /**
     
     Used to populate cell data
     
     @param appNotification    Access the data from AppNotification class

     */
    func populateCellWith(appNotification:AppNotification?) {
        
        if Utilities.isValidValue(someObject: appNotification?.message! as AnyObject?){
            labelNotificationText?.text =  appNotification?.message!
        }
        else{
            labelNotificationText?.text = ""
        }
    }
}
