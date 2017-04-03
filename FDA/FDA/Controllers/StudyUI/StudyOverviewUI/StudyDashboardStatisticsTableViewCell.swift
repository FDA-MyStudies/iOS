//
//  StudyDashboardStatisticsTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StudyDashboardStatisticsTableViewCell: UITableViewCell {

    //Fifth cell Outlets
    @IBOutlet var statisticsCollectionView: UICollectionView?
    
    @IBOutlet var buttonDay : UIButton?
    @IBOutlet var buttonWeek : UIButton?
    @IBOutlet var buttonMonth : UIButton?
    
    var statisticsArrayData : NSMutableArray?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //Configure the view for the selected state
        
    }
    
    @IBAction func dayWeekMonthButtonAction(_ sender: AnyObject){
        
        if sender.tag == 11{
            //Day clicked
            buttonDay?.setTitle("  DAY  ", for: UIControlState.normal)
            buttonWeek?.setTitle("WEEK", for: UIControlState.normal)
            buttonMonth?.setTitle("MONTH", for: UIControlState.normal)
            
            buttonDay?.setTitleColor(UIColor.white, for: UIControlState.normal)
            buttonWeek?.setTitleColor(kGreyColor, for: UIControlState.normal)
            buttonMonth?.setTitleColor(kGreyColor, for: UIControlState.normal)
            
            buttonDay?.backgroundColor = kDarkBlueColor
            buttonWeek?.backgroundColor = UIColor.white
            buttonMonth?.backgroundColor = UIColor.white
            
        }else if sender.tag == 12{
            //Week clicked
            buttonWeek?.setTitle("  WEEK  ", for: UIControlState.normal)
            buttonDay?.setTitle("DAY", for: UIControlState.normal)
            buttonMonth?.setTitle("MONTH", for: UIControlState.normal)
            
            buttonWeek?.setTitleColor(UIColor.white, for: UIControlState.normal)
            buttonDay?.setTitleColor(kGreyColor, for: UIControlState.normal)
            buttonMonth?.setTitleColor(kGreyColor, for: UIControlState.normal)
            
            buttonWeek?.backgroundColor = kDarkBlueColor
            buttonDay?.backgroundColor = UIColor.white
            buttonMonth?.backgroundColor = UIColor.white
            
        }else if sender.tag == 13{
            //Months clicked
            buttonMonth?.setTitle("  MONTH  ", for: UIControlState.normal)
            buttonDay?.setTitle("DAY", for: UIControlState.normal)
            buttonWeek?.setTitle("WEEK", for: UIControlState.normal)
            
            buttonMonth?.setTitleColor(UIColor.white, for: UIControlState.normal)
            buttonDay?.setTitleColor(kGreyColor, for: UIControlState.normal)
            buttonWeek?.setTitleColor(kGreyColor, for: UIControlState.normal)
            
            buttonMonth?.backgroundColor = kDarkBlueColor
            buttonDay?.backgroundColor = UIColor.white
            buttonWeek?.backgroundColor = UIColor.white
        }
    }
}

//MARK: Collection delegates
extension StudyDashboardStatisticsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return statisticsArrayData!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let activityCellData = statisticsArrayData?.object(at: indexPath.row) as! NSDictionary
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kStatisticsCollectionViewCell, for: indexPath) as! StudyDashboardStatisticsCollectionViewCell
        cell.displayStatisics(data: activityCellData)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
    }
}
