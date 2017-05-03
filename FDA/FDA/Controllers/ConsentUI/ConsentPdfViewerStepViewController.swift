//
//  ConsentPdfViewerStepViewController.swift
//  FDA
//
//  Created by Arun Kumar on 4/20/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import MessageUI
import ResearchKit



class ConsentPdfViewerStep: ORKStep {
    
   
}

class ConsentPdfViewerStepViewController: ORKStepViewController {
    
      @IBOutlet var webView : UIWebView?
    var pdfData:Data?
    
    @IBOutlet weak var buttonEmailPdf:UIBarButtonItem?
    
    @IBOutlet weak var buttonNext:UIButton?
    
    
    //MARK:ORKstepView Controller Init methods
    override init(step: ORKStep?) {
        super.init(step: step)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func hasNextStep() -> Bool {
        super.hasNextStep()
        return true
    }
    
    override func goForward(){
        
        super.goForward()
        
    }
    
    
    
    //MARK:Button Actions
    
    @IBAction func buttonActionNext(sender: UIBarButtonItem?) {
        
        self.goForward()
    }
    
    @IBAction func buttonActionEmailPdf(sender: UIBarButtonItem?) {
        
      self.sendConsentByMail()
        
    }
    
    //MARK:View controller delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let step = step as? ConsentPdfViewerStep {
           
        }
        
        
       self.webView?.load(pdfData!, mimeType: "application/pdf", textEncodingName: "UTF-8", baseURL:URL.init(fileURLWithPath: "") )
         webView?.delegate = self
    }
    
    func sendConsentByMail() {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        
        mailComposerVC.setSubject("Signed Consent")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        
        let dir = FileManager.getStorageDirectory(type: .study)
        
         let fullPath = "file://" + dir + "/" + "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + "_" + "\(ConsentBuilder.currentConsent?.version)" + ".pdf"

      let Filename = "Consent" +  "_" + "\((Study.currentStudy?.studyId)!)" + ".pdf"
        
        mailComposerVC.addAttachmentData(pdfData!, mimeType: "application/pdf", fileName: Filename)
       
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposerVC, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title:NSLocalizedString(kTitleError, comment: ""),message:"",preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction.init(title:NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: nil)
                
            }))
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ConsentPdfViewerStepViewController:MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}


extension ConsentPdfViewerStepViewController:UIWebViewDelegate{
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
    self.removeProgressIndicator()
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        self.removeProgressIndicator()
        
        let buttonTitleOK = NSLocalizedString("OK", comment: "")
        let alert = UIAlertController(title:NSLocalizedString(kTitleError, comment: ""),message:error.localizedDescription,preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction.init(title:buttonTitleOK, style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
}




