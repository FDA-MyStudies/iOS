//
//  StudyDashboardActivityTableViewCell.swift
//  FDA
//
//  Created by Ravishankar on 3/28/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StudyDashboardActivityTableViewCell: UITableViewCell {

    //Fourth cell Outlets
    @IBOutlet var activityCollectionView: UICollectionView?
    
    var activityArrayData = NSMutableArray()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}


//MARK:- Collection Datasource and Delegates
extension StudyDashboardActivityTableViewCell: UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return activityArrayData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let activityCellData = activityArrayData.object(at: indexPath.row) as! NSDictionary
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kActivityCollectionViewCell, for: indexPath) as! StudyDashboardActivityCollectionViewCell
        cell.displayTodaysActivities(data: activityCellData)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
}




