//
//  ViewController.swift
//  FDA
//
//  Created by Arun Kumar on 2/2/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit
import ResearchKit

//let user = User()
let activitybuilder:ActivityBuilder? = ActivityBuilder.currentActivityBuilder
let consentbuilder:ConsentBuilder? = ConsentBuilder()
let user = User.currentUser


let resourceArray : Array<Any>? = nil
class ViewController: UIViewController,ORKTaskViewControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.userProfile()
        self.setPrefereneces()
        self.addResources()
        
        //self.buildTask()
       // self.kickCounterTaskTest()
        
        
        
        
        user.bookmarkStudy(studyId: "121")
        
        user.updateStudyStatus(studyId: "121", status:.yetToJoin)
        
        user.bookmarkActivity(studyId: "121", activityId: "151")
        
        print(user.getStudyStatus(studyId: "121").description)
        
        //not available
//        let start = "2017-03-01"
//        let end = "2017-03-05"
        
        
        //run completed
        let start = "2017-01-26 10:00:00"
        let end = "2017-01-30"
        let runtime = "2017-03-12"
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let endDate:Date = dateFormatter.date(from: end)!
        
        
        let sdateFormatter = DateFormatter()
        sdateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startDate:Date = sdateFormatter.date(from: start)!
        
        
        
        let rdateFormatter = DateFormatter()
        rdateFormatter.dateFormat = "yyyy-MM-dd"
        let rendDate:Date = rdateFormatter.date(from: runtime)!
        
        let schedular = Schedule()
        schedular.startTime = startDate
        schedular.endTime = endDate
        schedular.lastRunTime = rendDate
        
        //schedular.setDailyRuns()
        //schedular.setWeeklyRuns()
        //schedular.setMonthlyRuns()
        //schedular.setDailyFrequenyRuns()
        schedular.setScheduledRuns()
        
    }
    
    
    
    //MARK:ORKTaskViewController Delegate
    
    
    func taskViewControllerSupportsSaveAndRestore(_ taskViewController: ORKTaskViewController) -> Bool {
        return true
    }
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        
        var taskResult:Any?
        
        switch reason {
            
        case ORKTaskViewControllerFinishReason.completed:
            print("completed")
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.failed:
            print("failed")
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.discarded:
            print("discarded")
            taskResult = taskViewController.result
        case ORKTaskViewControllerFinishReason.saved:
            print("saved")
            taskResult = taskViewController.restorationData
            
            if taskViewController.task?.identifier == "ConsentTask"{
                
            }
            else{
                activitybuilder?.activity?.restortionData = taskViewController.restorationData
            }
        }
        
        if  taskViewController.task?.identifier == "ConsentTask"{
            consentbuilder?.consentResult?.initWithORKTaskResult(taskResult:taskViewController.result )
        }
        else{
            activitybuilder?.actvityResult?.initWithORKTaskResult(taskResult: taskViewController.result)
        }
        
        
        taskViewController.dismiss(animated: true, completion: nil)
        
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        
        
    }
    
    //MARK:StepViewController Delegate
    public func stepViewController(_ stepViewController: ORKStepViewController, didFinishWith direction: ORKStepViewControllerNavigationDirection){
        
    }
    
    public func stepViewControllerResultDidChange(_ stepViewController: ORKStepViewController){
        
    }
    public func stepViewControllerDidFail(_ stepViewController: ORKStepViewController, withError error: Error?){
        
    }
    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        
        if step.identifier == "FetalKickCounter" {
            
             let ttController = self.storyboard?.instantiateViewController(withIdentifier: "FetalKickCounterStepViewController") as! FetalKickCounterStepViewController
            ttController.step = step
          
            
            return ttController
        } else {
            return nil
        }
    }
    
    //MARK: methods
    
    
    func kickCounterTaskTest()   {
        
        let fetalKickCouterTask:FetalKickCounterTask? = FetalKickCounterTask()
        let task:ORKTask?
        let taskViewController:ORKTaskViewController?
        
        task = fetalKickCouterTask?.getTask()
        taskViewController = ORKTaskViewController(task:task, taskRun: nil)
        taskViewController?.delegate = self
        taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        present(taskViewController!, animated: true, completion: nil)

        
    }
    
    
    
    func buildTask()  {
        
        // let filePath  = Bundle.main.path(forResource: "LatestActive_Taskdocument", ofType: "json")
        
        //let filePath  = Bundle.main.path(forResource: "ActiveTask", ofType: "json")
        
         let filePath  = Bundle.main.path(forResource: "TaskSchema", ofType: "json")
        
        //let filePath  = Bundle.main.path(forResource: "Acivity_Question", ofType: "json")
        
        let data = NSData(contentsOfFile: filePath!)
        
        
        do {
            let dataDict = try JSONSerialization.jsonObject(with: data! as Data, options: []) as? Dictionary<String,Any>
            
            if  Utilities.isValidObject(someObject: dataDict as AnyObject?) && (dataDict?.count)! > 0 {
                
                
                let task:ORKTask?
                let taskViewController:ORKTaskViewController?
                
                if Utilities.isValidObject(someObject: dataDict?["Result"] as? Dictionary<String, Any> as AnyObject?){
                    
                    
                     activitybuilder?.initActivityWithDict(dict: dataDict?["Result"] as! Dictionary<String, Any>)
                    
                     task = activitybuilder?.createTask()
                    
                
                   // consentbuilder?.initWithMetaData(metaDataDict:dataDict?["Result"] as! Dictionary<String, Any> )
                   // task = consentbuilder?.createConsentTask()
                    
                    taskViewController = ORKTaskViewController(task:task, taskRun: nil)
                    
                   // consentbuilder?.consentResult =   ConsentResult()
                   // consentbuilder?.consentResult?.consentDocument =  consentbuilder?.consentDocument
                    
                    taskViewController?.delegate = self
                    taskViewController?.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    present(taskViewController!, animated: true, completion: nil)
                }
            }
            
            // use anyObj here
        } catch {
            print("json error: \(error.localizedDescription)")
        }
        
      
        
    }
    
    
    
    
    
    func addResources()  {
        
        if let path = Bundle.main.path(forResource: "Resources", ofType: "plist") {
            
            if let responseArray = NSArray(contentsOfFile: path) {
                
                if Utilities.isValidObject(someObject: responseArray) {
                    
                    for i in 0 ..< responseArray.count {
                        
                        if Utilities.isValidObject(someObject:responseArray[i] as AnyObject? )  {
                            let resource:Resource? = Resource()
                            
                            resource?.setResource(dict:(responseArray[i] as? NSDictionary)! )
                            responseArray.adding(resource as Any)
                        }
                        
                    }
                }
                
            }
            
            if let dict = NSDictionary(contentsOfFile: path) as? [String:Any] {
                user.setUser(dict:dict as NSDictionary)
                
                Logger.sharedInstance.debug(dict)
                Logger.sharedInstance.info(dict)
                Logger.sharedInstance.error(dict)
                
                
            }
        }
        
    }
    
    
    
    func userProfile()  {
        
        if let path = Bundle.main.path(forResource: "UserProfile", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? [String:Any] {
                user.setUser(dict:dict as NSDictionary)
                
                Logger.sharedInstance.debug(dict)
                Logger.sharedInstance.info(dict)
                Logger.sharedInstance.error(dict)
                
                
            }
        }
        
    }
    
    func setPrefereneces()  {
        
        if let path = Bundle.main.path(forResource: "UserPreferences", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? [String:Any] {
                user.setUser(dict:dict as NSDictionary)
                
                //studies
                let studies = dict[kStudies] as! Array<Dictionary<String, Any>>
                
                for study in studies {
                    let participatedStudy = UserStudyStatus(detail: study)
                    user.participatedStudies.append(participatedStudy)
                }
                
                //activities
                let activites = dict[kActivites]  as! Array<Dictionary<String, Any>>
                for activity in activites {
                    let participatedActivity = UserActivityStatus(detail: activity)
                    user.participatedActivites.append(participatedActivity)
                }
                
            }
        }
        
    }
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


