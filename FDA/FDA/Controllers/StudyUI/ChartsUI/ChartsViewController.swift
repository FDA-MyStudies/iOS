//
//  ChartsViewController.swift
//  FDA
//
//  Created by Surender Rathore on 5/9/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class ChartsViewController: UIViewController {

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var backButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = NSLocalizedString("TRENDS", comment: "")
        //self.addBackBarButton()
        
        //unhide navigationbar
        //self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        //UINavigationBar.appearance().tintColor = UIColor.red
        
        
        
        DBHandler.loadChartsForStudy(studyId: (Study.currentStudy?.studyId)!) { (chartList) in
            
            if chartList.count != 0 {
                StudyDashboard.instance.charts = chartList
                self.tableView?.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonAction(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareButtonAction(_ sender: AnyObject){
        
        self.shareScreenShotByMail()
    }

    func shareScreenShotByMail() {
        
        //Create the UIImage
        
        let savedContentOffset = self.tableView.contentOffset
        let savedFrame = tableView.frame
        
        
        UIGraphicsBeginImageContextWithOptions(tableView.contentSize, self.view.isOpaque, 0.0)
        tableView.contentOffset = .zero
        tableView.frame = CGRect(x: 0, y: 0, width: tableView.contentSize.width, height: tableView.contentSize.height)
        tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        tableView.contentOffset = savedContentOffset
        tableView.frame = savedFrame
        
        (self.tabBarController as! StudyDashboardTabbarViewController).shareScreenshotByEmail(image: image, subject: kEmailSubjectCharts)
    
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

extension ChartsViewController:UITableViewDelegate{
    
}
extension ChartsViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return StudyDashboard.instance.charts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
       
        
        let chart = StudyDashboard.instance.charts[indexPath.section]
        
        if chart.chartType == "line-chart"{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "lineChart") as! LineChartCell
            cell.setupLineChart(chart: chart)
            return cell
        }
        else {
            let cell = UITableViewCell()
            return cell
        }
        
       
    }
}
