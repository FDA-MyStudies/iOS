//
//  FilterListViewController.swift
//  FDA
//
//  Created by Ravishankar on 7/11/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import UIKit


//Used to do filter based on Apply and Cancel actions
protocol StudyFilterDelegates {
    
    func appliedFilter(studyStatus : Array<String>, pariticipationsStatus : Array<String>, categories: Array<String> , searchText:String,bookmarked:Bool)
    
    func didCancelFilter(_ cancel:Bool)
}

class StudyFilterViewController: UIViewController {

    @IBOutlet weak var collectionView : UICollectionView?
    
    @IBOutlet weak var cancelButton : UIButton?
    @IBOutlet weak var applyButton : UIButton?
    
    var delegate : StudyFilterDelegates?
    
    var studyStatus : Array<String> = []
    var pariticipationsStatus : Array<String> = []
    var categories: Array<String> = []
    var searchText:String = ""
    var bookmark = true
    var filterData : NSMutableArray?
    
    //MARK:- Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applyButton?.layer.borderColor = kUicolorForButtonBackground
        cancelButton?.layer.borderColor = kUicolorForCancelBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let plistPath = Bundle.main.path(forResource: "FilterData", ofType: ".plist", inDirectory:nil)
        filterData = NSMutableArray.init(contentsOfFile: plistPath!)!
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        filterData?.removeAllObjects()
    }
    
    
    //MARK:- Button Actions
    
    /**
     
     Navigate to Studylist screen on Apply button clicked
     
     @param sender    accepts Anyobject in sender
     
     */
    @IBAction func applyButtonAction(_ sender: AnyObject){
        
        //categories = ["Food Safety","Observational Studies","Cosmetics Safety"]
        //pariticipationsStatus = ["Food Safety","Observational Studies"]
        studyStatus = ["Closed","Paused"]
        searchText = "Human"
        
        delegate?.appliedFilter(studyStatus: studyStatus, pariticipationsStatus: pariticipationsStatus, categories: categories,searchText:searchText,bookmarked: bookmark)
        self.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    
    /**
     
     Navigate to Studylist screen on Cancel button clicked
     
     @param sender    accepts Anyobject in sender
     
     */
    @IBAction func cancelButtonAction(_ sender: AnyObject){
        self.delegate?.didCancelFilter(true)
        self.dismiss(animated: true, completion: nil)
    }
}




////MARK:- Collection Data source & Delegate
extension StudyFilterViewController : UICollectionViewDataSource{//,UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterData!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FilterListCollectionViewCell

        let data = filterData?[indexPath.row] as! NSDictionary
        cell.displayCollectionData(data: data)

        return cell
    }

//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
//
//        let data = self.upcomingEventsArray[indexPath.row] as! NSDictionary
//        eventDetailsDictionary = data//data["liveEvents"] as? NSDictionary
//        UserInfoModel.streamName = eventDetailsDictionary["streamName"] as! String
//
//        self.performSegue(withIdentifier: keventDetailsSegue, sender: nil)
//    }
}








