//
//  ActivityFilterView.swift
//  FDA
//
//  Created by Arun Kumar on 10/08/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
//MARK:- ActivitySchedules Class

enum ActivityFilterType:Int {
    case all = 0
    case surveys
    case tasks
}


protocol ActivityFilterViewDelegate {
    func setSelectedFilter(selectedIndex:ActivityFilterType)
}


class ActivityFilterView:UIView,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var tableview:UITableView?
    @IBOutlet var buttonCancel:UIButton!
    @IBOutlet var heightLayoutConstraint:NSLayoutConstraint!
    var delegate:ActivityFilterViewDelegate?
    var filterArray = ["All","Surveys", "Tasks"]
    var selectedIndex:ActivityFilterType  = ActivityFilterType(rawValue: 0)!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    class func instanceFromNib(frame:CGRect , selectedIndex:ActivityFilterType) -> ActivityFilterView {
        let view = UINib(nibName: "ActivityFilterView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ActivityFilterView
        view.frame = frame
       
        view.selectedIndex = selectedIndex
        
        view.tableview?.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.tableview?.delegate = view
        view.tableview?.dataSource = view
        let height = (3*44) + 104
        let maxViewHeight = Int(UIScreen.main.bounds.size.height - 67)
        view.heightLayoutConstraint.constant = CGFloat((height > maxViewHeight) ? maxViewHeight:height)
        view.layoutIfNeeded()
        
        return view
    }
    
    
    //MARK:- Button Action
    @IBAction func buttonCancelClicked(_:UIButton) {
        self.removeFromSuperview()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15)
       
        cell.textLabel?.text = filterArray[indexPath.row]
        
        if indexPath.row == self.selectedIndex.rawValue {
            cell.textLabel?.textColor = kBlueColor
        }
        else  {
            cell.textLabel?.textColor = UIColor.gray
        }
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = ActivityFilterType.init(rawValue: indexPath.row)!
        self.delegate?.setSelectedFilter(selectedIndex: self.selectedIndex)
        self.tableview?.reloadData()
        
        self.removeFromSuperview()
    }
}
