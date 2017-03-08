//
//  StudyListViewController.swift
//  FDA
//
//  Created by Surender Rathore on 3/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class StudyListViewController: UIViewController {


    @IBOutlet var tableView:UITableView?
    
    
    func loadTestData(){
        
        
        let filePath  = Bundle.main.path(forResource: "StudyList", ofType: "json")
        
        let data = NSData(contentsOfFile: filePath!)
        
        
        do {
            let response = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
            
            
            let studies = response?[kStudies] as! Array<Dictionary<String,Any>>
            var listOfStudies:Array<Study> = []
            for study in studies{
                let studyModelObj = Study(studyDetail: study)
                listOfStudies.append(studyModelObj)
            }
            
            //assgin to Gateway
            Gateway.instance.studies = listOfStudies
            
            
           
        } catch {
            print("json error: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //self.addRightBarButton() //Phase2
        //self.addLeftBarButton()
        self.title = NSLocalizedString("FDA LISTENS!", comment: "")
        self.loadTestData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBarItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     //MARK:Custom Bar Buttons
    
    func addLeftBarButton(){
        
        let button = UIButton(type: .custom)
        //button.setImage(UIImage(named: "imagename"), for: .normal)
        button.setTitle("FDA LISTENS!", for: .normal)
        button.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Medium", size: 18)
        button.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(Utilities.getUIColorFromHex(0x007cba), for: .normal)
        let barItem = UIBarButtonItem(customView: button)
        
        self.navigationItem.setLeftBarButton(barItem, animated: true)
    }
    
    func addRightBarButton(){
        
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "filter_icn"), for: .normal)
        //button.setTitle("FDA LISTENS!", for: .normal)
        //button.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Medium", size: 18)
        button.frame = CGRect(x: 0, y: 0, width: 19, height: 22.5)
        //button.contentHorizontalAlignment = .left
       // button.setTitleColor(Utilities.getUIColorFromHex(0x007cba), for: .normal)
        let barItem = UIBarButtonItem(customView: button)
        
        self.navigationItem.setRightBarButton(barItem, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
//MARK: TableView Data source
extension StudyListViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Gateway.instance.studies?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier = "studyCell"
        
        //check if current user is anonymous
        let user = User.currentUser
        if user.userType == .AnonymousUser {
            cellIdentifier = "anonymousStudyCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! StudyListCell
        
        cell.populateCellWith(study: (Gateway.instance.studies?[indexPath.row])!)
        cell.delegate = self
        
        return cell
    }
}

//MARK: TableView Delegates
extension StudyListViewController :  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

//MARK: StudyListDelegates
extension StudyListViewController : StudyListDelegates {
    
    func studyBookmark(_ cell: StudyListCell, didTapped button: UIButton, forStudy study: Study) {
        
    }
}
