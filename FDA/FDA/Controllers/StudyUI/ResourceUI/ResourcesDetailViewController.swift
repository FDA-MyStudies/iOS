//
//  ResourcesDetailViewController.swift
//  FDA
//
//  Created by Arun Kumar on 4/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import MessageUI

let resourcesDownloadPath = AKUtility.baseFilePath + "/Resources"

class ResourcesDetailViewController: UIViewController {
    
    
    @IBOutlet var webView : UIWebView?
    @IBOutlet var progressBar : UIProgressView?
    
    var activityIndicator:UIActivityIndicatorView!
    var requestLink:String?
    var type:String?
    var htmlString: String?
    var resource:Resource?
    var isEmailComposerPresented:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        self.addBackBarButton()
        self.isEmailComposerPresented = false
        self.title = resource?.title
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        
        if self.isEmailComposerPresented == false{
        
        
        if self.resource?.file?.link != nil {
            
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY-100)
            
           
            self.view.addSubview(activityIndicator)
            
            
            activityIndicator.startAnimating()
            
            if self.resource?.file?.mimeType == .pdf{
                
                if self.resource?.file?.localPath != nil {
                    
                    if self.resource?.file?.localPath == "BundlePath"{
                        
                        let path = Bundle.main.path(forResource: self.resource?.file?.link!, ofType: ".pdf")
                        self.loadWebViewWithPath(path: path!)
                    }
                    else {
                        let path = resourcesDownloadPath + "/" + (self.resource?.file?.localPath)!
                        let pdfData = FileDownloadManager.decrytFile(pathURL:URL(string:path))
                        self.loadWebViewWithData(data: pdfData!)

                    }
                    
                                      //self.loadWebViewWithPath(path: (self.resource?.file?.localPath)!)
                }
                else {
                   //let path = resourcesDownloadPath + "/PDF_linking.pdf"
                    self.startDownloadingfile()
                    //let pdfData = FileDownloadManager.decrytFile(pathURL:URL(string:path))
                    //self.loadWebViewWithData(data: pdfData!)
                }
                
                
            }
            else{
                webView?.loadHTMLString(self.requestLink!, baseURL:nil)
            }
        }
        else{
            
        }
        
        webView?.delegate = self
        }
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // self.tabBar.isHidden = false
    }
    
    func loadWebViewWithPath(path:String){
        
        let url:URL? = URL.init(string:path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
        let urlRequest = URLRequest(url: url!)
        webView?.loadRequest(urlRequest)
    }
    func loadWebViewWithData(data:Data){
        
        self.webView?.load(data, mimeType: "application/pdf", textEncodingName: "UTF-8", baseURL:URL.init(fileURLWithPath: "") )
        
//        let url:URL? = URL.init(string:path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
//        let urlRequest = URLRequest(url: url!)
//        webView?.loadRequest(urlRequest)
    }
    
    func startDownloadingfile(){
        
        if !FileManager.default.fileExists(atPath: resourcesDownloadPath) {
            try! FileManager.default.createDirectory(atPath: resourcesDownloadPath, withIntermediateDirectories: true, attributes: nil)
        }
        debugPrint("custom download path: \(resourcesDownloadPath)")
        
       
        
        let fileURL =  (self.resource?.file?.link)!
        
        let url = URL(string:fileURL)
        
        var fileName : NSString = url!.lastPathComponent as NSString
        
        fileName = AKUtility.getUniqueFileNameWithPath((resourcesDownloadPath as NSString).appendingPathComponent(fileName as String) as NSString)
        
        let fdm = FileDownloadManager()
        fdm.delegate = self
        fdm.downloadFile(fileName as String, fileURL: fileURL.addingPercentEscapes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, destinationPath: resourcesDownloadPath)
    }
    
    
    //MARK:Button Actions
    
    @IBAction func cancelButtonClicked(_ sender : Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonActionForward(_ sender : UIBarButtonItem){
        
        self.sendEmail()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ResourcesDetailViewController:UIWebViewDelegate{
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
        
        let buttonTitleOK = NSLocalizedString("OK", comment: "")
        let alert = UIAlertController(title:NSLocalizedString(kTitleError, comment: ""),message:error.localizedDescription,preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction.init(title:buttonTitleOK, style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
}

extension ResourcesDetailViewController:MFMailComposeViewControllerDelegate{
    
    func sendEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        
        composeVC.setSubject("Resources")
        
        if resource?.file?.localPath != nil {
            
            if self.resource?.file?.localPath == "BundlePath"{
                
                do {
                    let file = Bundle.main.url(forResource: self.resource?.file?.link!, withExtension: "pdf")
                    let data = try Data(contentsOf: file!)
                    composeVC.addAttachmentData(data, mimeType: "application/pdf", fileName: (resource?.file?.name)!)
                }
                catch{
                    
                }
            }
            else {
                
                do {
                    
                    let fullPath = resourcesDownloadPath + "/" + (self.resource?.file?.localPath)!
                    
                    let data = FileDownloadManager.decrytFile(pathURL: URL.init(string: fullPath))
                    
                    composeVC.addAttachmentData(data!, mimeType: "application/pdf", fileName: (resource?.file?.name)!)
                }
                catch let error as NSError{
                    print("error \(error)")
                }
            }
            
            
            
        }
        else {
            composeVC.setMessageBody((resource?.file?.link)!, isHTML: true)
        }
        
        
        if MFMailComposeViewController.canSendMail()
        {
            self.present(composeVC, animated: true, completion: nil)
            
            
           
        }
        else{
            let alert = UIAlertController(title:NSLocalizedString(kTitleError, comment: ""),message:"",preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction.init(title:NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: nil)
                
            }))
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        
         self.isEmailComposerPresented = true
        
        controller.dismiss(animated: true, completion: nil)
    }
    
}


extension ResourcesDetailViewController:FileDownloadManagerDelegates{
    
    func download(manager: FileDownloadManager, didUpdateProgress progress: Float) {
        
        self.progressBar?.progress = progress
    }
    func download(manager: FileDownloadManager, didFinishDownloadingAtPath path:String) {
        
        
         let fullPath = resourcesDownloadPath + "/" + path
        
        
        let data = FileDownloadManager.decrytFile(pathURL: URL.init(string: fullPath))
        
        if data != nil{
            self.resource?.file?.localPath = path
            // self.loadWebViewWithPath(path: path)
            
            let mimeType = "application/" + "\((self.resource?.file?.mimeType?.rawValue)!)"
            
            self.webView?.load(data!, mimeType: mimeType, textEncodingName: "UTF-8", baseURL:URL.init(fileURLWithPath: "") )
        }
        
    }
    func download(manager: FileDownloadManager, didFailedWithError error: Error) {
        
    }
    
    
}
