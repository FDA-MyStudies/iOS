//
//  ResourcesDetailViewControllerCopy.swift
//  FDA
//
//  Created by Arun Kumar on 4/6/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import MessageUI
import WebKit
import SafariServices
//let resourcesDownloadPath = AKUtility.baseFilePath + "/Resources"

class ResourcesDetailViewControllerCopy: UIViewController {
    
    @IBOutlet var webViewContainer : UIView?
     var webView : WKWebView?
    
    @IBOutlet var progressBar : UIProgressView?
    @IBOutlet var bottomToolBar : UIToolbar?
    
    
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
        
        let webConfiguration = WKWebViewConfiguration()
        
        let webViewFrame = CGRect.init(x: 0, y: 0, width: (webViewContainer?.frame.width)!, height: (webViewContainer?.frame.height)! - 44.0)
        webView = WKWebView.init(frame: webViewFrame, configuration: webConfiguration)
        
       
        webViewContainer?.addSubview(webView!)
        
       
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
             self.activityIndicator.hidesWhenStopped = true
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
                
                 webView?.allowsBackForwardNavigationGestures = true
                
                _ = webView?.loadHTMLString(self.requestLink!, baseURL: nil)
                 
               
            }
        }
        else{
            
        }
        
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        }
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // self.tabBar.isHidden = false
    }
    
    func loadWebViewWithPath(path:String){
        
        let url:URL? = URL.init(string:path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
        let urlRequest = URLRequest(url: url!)
        
        
    
        webView?.allowsBackForwardNavigationGestures = true
        _ = webView?.load(urlRequest)
       // webView?.loadRequest(urlRequest)
    }
    func loadWebViewWithData(data:Data){
        
         webView?.allowsBackForwardNavigationGestures = true
        
       _ = self.webView?.load(data, mimeType: "application/pdf", characterEncodingName: "UTF-8", baseURL: URL.init(fileURLWithPath: ""))
        
       // self.webView?.load(data, mimeType: "application/pdf", textEncodingName: "UTF-8", baseURL:URL.init(fileURLWithPath: "") )
        
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
    
    @IBAction func buttonActionBack(_ sender : UIBarButtonItem){
       
        if (webView?.canGoBack)!{
           _ =  webView?.goBack()
        }
        else if webView?.backForwardList.backList.count == 0 {
            if  self.resource?.file?.mimeType != .pdf {
                _ = webView?.loadHTMLString(self.requestLink!, baseURL: nil)

            }
        }
    }
    
    @IBAction func buttonActionGoForward(_ sender : UIBarButtonItem){
        if (webView?.canGoForward)!{
           _ = webView?.goForward()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ResourcesDetailViewControllerCopy:UIWebViewDelegate{
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator.stopAnimating()
       
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.activityIndicator.stopAnimating()
      
        
        let buttonTitleOK = NSLocalizedString("OK", comment: "")
        let alert = UIAlertController(title:NSLocalizedString(kTitleError, comment: ""),message:error.localizedDescription,preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction.init(title:buttonTitleOK, style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
}

extension ResourcesDetailViewControllerCopy:WKUIDelegate,WKNavigationDelegate{
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        print("webView:\(webView) didStartProvisionalNavigation:\(navigation)")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation) {
        print("webView:\(webView) didCommitNavigation:\(navigation)")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(decisionHandler)")
        
        switch navigationAction.navigationType {
        case .linkActivated:
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
        default:
            break
        }
        self.activityIndicator.startAnimating()
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: (@escaping (WKNavigationResponsePolicy) -> Void)) {
        print("webView:\(webView) decidePolicyForNavigationResponse:\(navigationResponse) decisionHandler:\(decisionHandler)")
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("webView:\(webView) didReceiveAuthenticationChallenge:\(challenge) completionHandler:\(completionHandler)")
        
        switch (challenge.protectionSpace.authenticationMethod) {
        case NSURLAuthenticationMethodHTTPBasic:
            let alertController = UIAlertController(title: "Authentication Required", message: webView.url?.host, preferredStyle: .alert)
            weak var usernameTextField: UITextField!
            alertController.addTextField { textField in
                textField.placeholder = "Username"
                usernameTextField = textField
            }
            weak var passwordTextField: UITextField!
            alertController.addTextField { textField in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
                passwordTextField = textField
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                completionHandler(.cancelAuthenticationChallenge, nil)
            }))
            alertController.addAction(UIAlertAction(title: "Log In", style: .default, handler: { action in
                guard let username = usernameTextField.text, let password = passwordTextField.text else {
                    completionHandler(.rejectProtectionSpace, nil)
                    return
                }
                let credential = URLCredential(user: username, password: password, persistence: URLCredential.Persistence.forSession)
                completionHandler(.useCredential, credential)
            }))
            present(alertController, animated: true, completion: nil)
        default:
            completionHandler(.rejectProtectionSpace, nil);
        }
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation) {
        print("webView:\(webView) didReceiveServerRedirectForProvisionalNavigation:\(navigation)")
    }
 
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        print("webView:\(webView) didFinishNavigation:\(navigation)")
        
        self.activityIndicator.stopAnimating()
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        print("webView:\(webView) didFailNavigation:\(navigation) withError:\(error)")
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        print("webView:\(webView) didFailProvisionalNavigation:\(navigation) withError:\(error)")
    }
    
    // MARK: WKUIDelegate methods
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (@escaping () -> Void)) {
        print("webView:\(webView) runJavaScriptAlertPanelWithMessage:\(message) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: frame.request.url?.host, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completionHandler()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (@escaping (Bool) -> Void)) {
        print("webView:\(webView) runJavaScriptConfirmPanelWithMessage:\(message) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: frame.request.url?.host, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completionHandler(false)
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completionHandler(true)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        print("webView:\(webView) runJavaScriptTextInputPanelWithPrompt:\(prompt) defaultText:\(defaultText) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: frame.request.url?.host, message: prompt, preferredStyle: .alert)
        weak var alertTextField: UITextField!
        alertController.addTextField { textField in
            textField.text = defaultText
            alertTextField = textField
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completionHandler(nil)
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completionHandler(alertTextField.text)
        }))
        present(alertController, animated: true, completion: nil)
    }

}



extension ResourcesDetailViewControllerCopy:MFMailComposeViewControllerDelegate{
    
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


extension ResourcesDetailViewControllerCopy:FileDownloadManagerDelegates{
    
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
            
            self.webView?.load(data!, mimeType: mimeType, characterEncodingName: mimeType, baseURL: URL.init(fileURLWithPath: "") )
            
            //self.webView?.load(data!, mimeType: mimeType, textEncodingName: mimeType, baseURL:URL.init(fileURLWithPath: "") )
        }
        
    }
    func download(manager: FileDownloadManager, didFailedWithError error: Error) {
        
    }
    
    
}
