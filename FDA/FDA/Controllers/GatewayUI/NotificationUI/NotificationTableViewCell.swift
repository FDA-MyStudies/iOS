//
//  NotificationTableViewCell.swift
//  FDA
//
//  Created by ArunKumar on 3/1/17.
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
        
    }
    
    /**
     Used to populate cell data
     @param appNotification    Access the data from AppNotification class
     */
    func populateCellWith(notification:Any?) {
        
        if notification is AppNotification {
            let appNotification = notification as! AppNotification
            if appNotification.date != nil {
                self.labelNotificationTime?.text = NotificationTableViewCell.formatter.string(from: (appNotification.date)!)
                
                if appNotification.message != nil{
                    labelNotificationText?.text =  appNotification.message!
                    
                }else {
                    labelNotificationText?.text = ""
                }
            }else {
                
                let appNotification = notification as! AppLocalNotification
                self.labelNotificationTime?.text = NotificationTableViewCell.formatter.string(from: (appNotification.startDate)!)
                
                if appNotification.message != nil{
                    labelNotificationText?.text =  appNotification.message!
                    
                }else {
                    labelNotificationText?.text = ""
                }
            }
            
        }else {
            let appNotification = notification as! AppLocalNotification
            self.labelNotificationTime?.text = NotificationTableViewCell.formatter.string(from: (appNotification.startDate)!)
            
            if Utilities.isValidValue(someObject: appNotification.message! as AnyObject?){
                labelNotificationText?.text =  appNotification.message!
                
            }else {
                labelNotificationText?.text = ""
            }
        }
    }
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd YYYY"
        formatter.timeZone = TimeZone.init(abbreviation:"GMT")
        return formatter
    }()
}
