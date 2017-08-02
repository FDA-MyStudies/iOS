//
//  FilterListCollectionViewCell.swift
//  FDA
//
//  Created by Ravishankar on 7/26/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class FilterListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tableView : UITableView?
    @IBOutlet weak var tableViewHeader : UIView?
    @IBOutlet weak var labelHeaderTitle : UILabel?
    
    var headerName = ""
    var studyData = NSMutableArray()
    var filterOptions:FilterOptions!
    
    func displayCollectionData(data : FilterOptions){
    
        //studyData = data["studyData"] as! NSMutableArray
        filterOptions = data
        if filterOptions.title.characters.count == 0{
            tableView?.tableHeaderView = nil
        }
        else {
            labelHeaderTitle?.text = filterOptions.title
            tableView?.tableHeaderView = tableViewHeader
        }
        
        tableView?.reloadData()
    }
}


extension FilterListCollectionViewCell : UITableViewDelegate , UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions.filterValues.count //studyData.count
    }
    /*
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        view.backgroundColor = UIColor.lightGray
        
        let data = studyData[section] as! NSDictionary
        let arrayData = data["isHeaderAvailable"] as! String
        
        if arrayData == "YES" {
            
            let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            label.textAlignment = NSTextAlignment.left
            label.text = data["headerText"] as? String
            label.font = UIFont.boldSystemFont(ofSize: 14)

            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
            
        }else{
        
        
        }
     
        return view
    }
    
 
 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FilterListTableViewCell
        
        let data = filterOptions.filterValues[indexPath.row]
        cell.populateCellWith(filterValue: data)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = filterOptions.filterValues[indexPath.row]
        data.isSelected = !data.isSelected
        
        tableView.reloadData()
        
    }



}
