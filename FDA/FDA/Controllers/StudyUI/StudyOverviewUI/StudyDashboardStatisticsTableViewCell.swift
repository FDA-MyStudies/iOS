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
    
    var statisticsArrayData : NSMutableArray?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

//MARK: Collection delegates
extension StudyDashboardStatisticsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return statisticsArrayData!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let activityCellData = statisticsArrayData?.object(at: indexPath.row) as! NSDictionary
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kStatisticsCollectionViewCell, for: indexPath) as! StudyDashboardCollectionViewCell
        cell.displayStatisics(data: activityCellData)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
    }
}
