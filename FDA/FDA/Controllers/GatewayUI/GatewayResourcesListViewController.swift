//
//  ResourcesListViewController.swift
//  FDA
//
//  Created by Surender Rathore on 3/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

class GatewayResourcesListViewController: UIViewController {

    @IBOutlet var tableView:UITableView?
    
    
    func loadResources(){
        
        let plistPath = Bundle.main.path(forResource: "Resources", ofType: ".plist", inDirectory:nil)
        let arrayContent = NSMutableArray.init(contentsOfFile: plistPath!)
        
        do {
           
           // let resources = response[kResources] as! Array<Dictionary<String,Any>>
            var listOfResources:Array<Resource>! = []
            for resource in arrayContent!{
                let resourceObj = Resource(detail: resource as! Dictionary<String, Any>)
                listOfResources.append(resourceObj)
            }
            
            //assgin to Gateway
            Gateway.instance.resources = listOfResources
            
            
            self.tableView?.reloadData()
        } catch {
            print("json error: \(error.localizedDescription)")
        }


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title =  NSLocalizedString("RESOURCES", comment: "")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.setNavigationBarItem()
        //WCPServices().getGatewayResources(delegate: self)
        self.loadResources()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func handleResourcesReponse(){
        self.tableView?.reloadData()
    }

}
//MARK: TableView Data source
extension GatewayResourcesListViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Gateway.instance.resources?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resourcesCell", for: indexPath) as! ResourcesListCell
        
        
        let resource = Gateway.instance.resources?[indexPath.row]
        cell.labelResourceTitle?.text = resource?.title
        
        return cell
    }
}

//MARK: TableView Delegates
extension GatewayResourcesListViewController :  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let resource = Gateway.instance.resources?[indexPath.row]
        let storyboard = UIStoryboard(name: "Study", bundle: nil)
        let resourceDetail =   storyboard.instantiateViewController(withIdentifier: "ResourceDetailViewControllerIdentifier") as! ResourcesDetailViewController
        resourceDetail.resource = resource
        self.navigationController?.pushViewController(resourceDetail, animated: true)
        
    }
}


extension GatewayResourcesListViewController:NMWebServiceDelegate {
    func startedRequest(_ manager: NetworkManager, requestName: NSString) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.addProgressIndicator()
    }
    func finishedRequest(_ manager: NetworkManager, requestName: NSString, response: AnyObject?) {
        Logger.sharedInstance.info("requestname : \(requestName) response : \(response)" )
        
        self.removeProgressIndicator()
        
        if requestName as String == WCPMethods.gatewayInfo.method.methodName {
            
            self.handleResourcesReponse()
            
        }
        
        
        
    }
    func failedRequest(_ manager: NetworkManager, requestName: NSString, error: NSError) {
        Logger.sharedInstance.info("requestname : \(requestName)")
        self.removeProgressIndicator()
        
        
        
    }
}
