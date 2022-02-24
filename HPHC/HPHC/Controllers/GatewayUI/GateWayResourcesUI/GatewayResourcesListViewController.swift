/*
 License Agreement for FDA My Studies
Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.
Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class GatewayResourcesListViewController: UIViewController {

    @IBOutlet var tableView: UITableView?
    
    func loadResources() {
        
        var plistPath = Bundle.main.path(forResource: "Resources", ofType: ".plist", inDirectory: nil)
        let localeDefault = getLanguageLocale()
        print("Krishna gatewaystring resource list \(localeDefault)")
        if !(localeDefault.hasPrefix("es") || localeDefault.hasPrefix("en")) {
          plistPath = Bundle.main.path(forResource: "Resources", ofType: ".plist", inDirectory: nil, forLocalization: "Base")
        } else if localeDefault.hasPrefix("en"){
            plistPath = Bundle.main.path(forResource: "Resources", ofType: ".plist", inDirectory: nil, forLocalization: "Base")
        } else if localeDefault.hasPrefix("es") {
            plistPath = Bundle.main.path(forResource: "Resources", ofType: ".plist", inDirectory: nil, forLocalization: "es")
        }
        let arrayContent = NSMutableArray.init(contentsOfFile: plistPath!)
        
        do {
           
           // let resources = response[kResources] as! Array<Dictionary<String, Any>>
            var listOfResources: Array<Resource>! = []
            for resource in arrayContent!{
                let resourceObj = Resource(detail: resource as! Dictionary<String, Any>)
                listOfResources.append(resourceObj)
            }
            
            // assgin to Gateway
            Gateway.instance.resources = listOfResources
                
            self.tableView?.reloadData()
        } catch {
            print("json error: \(error.localizedDescription)")
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title =  NSLocalizedStrings("RESOURCES", comment: "")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.setNavigationBarItem()
        // WCPServices().getGatewayResources(delegate: self)
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
// MARK: TableView Data source
extension GatewayResourcesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Gateway.instance.resources?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // let tableViewData = tableViewRowDetails?.object(at: indexPath.row) as! NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resourcesCell", for: indexPath) as! ResourcesListCell
        
        let resource = Gateway.instance.resources?[indexPath.row]
        cell.labelResourceTitle?.text = resource?.title
        
        return cell
    }
}

// MARK: TableView Delegates
extension GatewayResourcesListViewController:  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let resource = Gateway.instance.resources?[indexPath.row]
        let storyboard = UIStoryboard(name: kStudyStoryboard, bundle: nil)
        let resourceDetail =   storyboard.instantiateViewController(withIdentifier: "ResourceDetailViewControllerIdentifier")
            as! ResourcesDetailViewController
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
        Logger.sharedInstance.info("requestname : \(requestName) response : \(String(describing:response))" )
        
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
