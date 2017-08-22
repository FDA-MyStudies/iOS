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

enum FilterType:Int {
    case studyStatus = 0
    case bookMark
    case participantStatus
    case category
    
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
    
    var previousCollectionData:Array<Array<String>> = []
    
    //MARK:- Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applyButton?.layer.borderColor = kUicolorForButtonBackground
        cancelButton?.layer.borderColor = kUicolorForCancelBackground
        
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let plistPath = Bundle.main.path(forResource: "FilterData", ofType: ".plist", inDirectory:nil)
        filterData = NSMutableArray.init(contentsOfFile: plistPath!)!
        
        
        StudyFilterHandler.instance.filterOptions = []
        
       if StudyFilterHandler.instance.filterOptions.count == 0 {
            var filterOptionsList:Array<FilterOptions> = []
        
        var i = 0
        
            for options in filterData! {
                let values = (options as! Dictionary<String,Any>)["studyData"] as! Array<Dictionary<String,Any>>
                let filterOptions = FilterOptions()
                filterOptions.title = (options as! Dictionary<String,Any>)["headerText"] as! String!
                
                
                var selectedValues:Array<String> = []
                if previousCollectionData.count > 0{
                    selectedValues = previousCollectionData[i]
                }
                
                
                var filterValues:Array<FilterValues> = []
                for value in values {
                    
                   var isContained = false
                    
                    let filterValue = FilterValues()
                    filterValue.title = value["name"] as! String!
                    
                    if selectedValues.count > 0 {
                        isContained = selectedValues.contains(value["name"] as! String)
                        
                    }
                    
                    if isContained == false{
                        
                        if previousCollectionData.count == 0{
                            // this means that we are first time accessing the filter screen
                            
                            filterValue.isSelected =  value["isEnabled"] as! Bool
                        }
                        else{
                            // means that filter is already set
                            filterValue.isSelected = false
                        }
                        
                    }
                    else{
                        filterValue.isSelected = true
                    }
                
    
                    filterValues.append(filterValue)
                }
                filterOptions.filterValues = filterValues
                filterOptionsList.append(filterOptions)
                
                i = i + 1
                
            }
            StudyFilterHandler.instance.filterOptions = filterOptionsList
        }
       
        self.collectionView?.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //filterData?.removeAllObjects()
    }
    
    
    //MARK:- Button Actions
    
    /**
     
     Navigate to Studylist screen on Apply button clicked
     
     @param sender    accepts Anyobject in sender
     
     */
    @IBAction func applyButtonAction(_ sender: AnyObject){
        
        //categories = ["Food Safety","Observational Studies","Cosmetics Safety"]
        //pariticipationsStatus = ["Food Safety","Observational Studies"]
        
        var i:Int = 0
        var isbookmarked = false
        for filterOptions in StudyFilterHandler.instance.filterOptions{
            
            let filterType = FilterType.init(rawValue: i)
            let filterValues = (filterOptions.filterValues.filter({$0.isSelected == true}))
            for value in filterValues{
                switch (filterType!) {
                    
                case .studyStatus:
                    studyStatus.append(value.title)
                case .participantStatus:
                    pariticipationsStatus.append(value.title)
                case .bookMark:
                    bookmark = (value.isSelected)
                    isbookmarked = true
                case .category:
                    categories.append(value.title)
                default:break
                }
            }
            i = i + 1
        }
        
        // studyStatus = ["Closed","Paused"]
        //searchText = "Human"
        
        previousCollectionData = []
        
        previousCollectionData.append(studyStatus)
        if isbookmarked{
            previousCollectionData.append((bookmark == true ? ["Bookmarked"]:[]))
        }
        else{
            previousCollectionData.append([])
            bookmark = false
        }
        
        previousCollectionData.append(pariticipationsStatus)
        previousCollectionData.append(categories.count == 0 ? [] : categories)
        
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
        return StudyFilterHandler.instance.filterOptions.count //filterData!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FilterListCollectionViewCell

        //let data = filterData?[indexPath.row] as! NSDictionary
        let filterOption = StudyFilterHandler.instance.filterOptions[indexPath.row]
        cell.displayCollectionData(data: filterOption)

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

/*
extension StudyFilterViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenwidth = UIScreen.main.bounds.size.width
        let filterOptions = StudyFilterHandler.instance.filterOptions[indexPath.row]
        var headerHeight = 0
        if filterOptions.title.characters.count > 0 {
            headerHeight = 40
        }
        let height:CGFloat = CGFloat((filterOptions.filterValues.count * 50) + headerHeight)
        
        return CGSize.init(width: (screenwidth-20)/2, height: height) //CGSizeMake(64, 64)
    }
}
*/
extension StudyFilterViewController:PinterestLayoutDelegate{
    // 1. Returns the photo height
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth width:CGFloat) -> CGFloat {
        let screenwidth = UIScreen.main.bounds.size.width
        
        let filterOptions = StudyFilterHandler.instance.filterOptions[indexPath.row]
        var headerHeight = 0
        if filterOptions.title.characters.count > 0 {
            headerHeight = 40
        }
        let height:CGFloat = CGFloat((filterOptions.filterValues.count * 50) + headerHeight)
        return height
    }
    
    // 2. Returns the annotation size based on the text
    func collectionView(_ collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        return 0
    }
}

class StudyFilterHandler {
    var filterOptions:Array<FilterOptions> = []
    var previousAppliedFilters:Array<Array<String>> = []
    static var instance = StudyFilterHandler()
}

class FilterOptions{
    var title:String!
    var filterValues:Array<FilterValues> = []
}
class FilterValues {
    
    var title:String!
    var isSelected = false
}



