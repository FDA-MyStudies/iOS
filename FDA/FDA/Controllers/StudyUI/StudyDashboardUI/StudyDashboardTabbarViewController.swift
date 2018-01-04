//
//  StudyDashboardTabbarViewController.swift
//  FDA
//
//  Created by Arun Kumar on 4/4/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import MessageUI


class StudyDashboardTabbarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func shareScreenshotByEmail(image:UIImage!, subject:String!,fileName:String!){
        
        let imageData = UIImagePNGRepresentation(image)
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self as MFMailComposeViewControllerDelegate
        let finalSubject = "\((Study.currentStudy?.name)!)" + " " + subject
        
        mailComposerVC.setSubject(finalSubject)
        mailComposerVC.setMessageBody("", isHTML: false)
        
        let Filename =   "\((Study.currentStudy?.name)!)" + "_" + "\(fileName!)"  + ".png"
        
        mailComposerVC.addAttachmentData(imageData!, mimeType: "image/png", fileName: Filename)
        
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposerVC, animated: true, completion: nil)
        }
        else{
            
            let alert = UIAlertController(title:NSLocalizedString(kTitleError, comment: ""),message:"",preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction.init(title:NSLocalizedString(kTitleOk, comment: ""), style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: nil)
                
            }))
        }
    }
}

extension StudyDashboardTabbarViewController:MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

