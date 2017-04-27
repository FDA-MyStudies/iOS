//
//  FileDownloadManager.swift
//  DownloadManager
//
//  Created by Surender Rathore on 2/24/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import UIKit

protocol FileDownloadManagerDelegates {
    func download(manager:FileDownloadManager,didUpdateProgress progress:Float)
    func download(manager:FileDownloadManager,didFinishDownloadingAtPath path:String)
    func download(manager:FileDownloadManager,didFailedWithError error:Error)
}

class FileDownloadManager : NSObject {
    
    var sessionManager: Foundation.URLSession!
    open var downloadingArray: [FileDownloadModel] = []
    var delegate:FileDownloadManagerDelegates?
    let taskStartedDate = Date()
    func downloadFile(_ fileName: String, fileURL: String, destinationPath: String){
        
        let url = URL(string: fileURL as String)!
        let request = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        sessionManager = Foundation.URLSession.init(configuration: config, delegate: self , delegateQueue: nil)
        let downloadTask = sessionManager.downloadTask(with: request)
        //sessionManager.delegate = self
        downloadTask.taskDescription = [fileName, fileURL, destinationPath].joined(separator: ",")
        downloadTask.resume()
        
        
        let downloadModel = FileDownloadModel.init(fileName: fileName, fileURL: fileURL, destinationPath: destinationPath)
        downloadModel.startTime = Date()
        downloadModel.status = TaskStatus.downloading.description()
        downloadModel.task = downloadTask
        
        downloadingArray.append(downloadModel)
    }
    
    
    
}



extension FileDownloadManager:URLSessionDelegate{
    
    func URLSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            let receivedBytesCount = Double(downloadTask.countOfBytesReceived)
            let totalBytesCount = Double(downloadTask.countOfBytesExpectedToReceive)
            let progress = Float(receivedBytesCount / totalBytesCount)
            
            self.delegate?.download(manager: self, didUpdateProgress: progress)
            
             //downloadModel.startTime!
            //let timeInterval = self.taskStartedDate.timeIntervalSinceNow
            //let downloadTime = TimeInterval(-1 * timeInterval)
            
            //let speed = Float(totalBytesWritten) / Float(downloadTime)
            
            //let remainingContentLength = totalBytesExpectedToWrite - totalBytesWritten
            
            //let remainingTime = Int(remainingContentLength) / Int(speed)
            //let hours = Int(remainingTime) / 3600
            //let minutes = (Int(remainingTime) - hours * 3600) / 60
            //let seconds = Int(remainingTime) - hours * 3600 - minutes * 60
            
            //print(progress)
            

        })
        
    }
     func URLSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: URL) {
        
         debugPrint("didFinishDownloadingToURL location \(location)")
        
        for (index, downloadModel) in downloadingArray.enumerated() {
            if downloadTask.isEqual(downloadModel.task) {
                let fileName = downloadModel.fileName as NSString
                let basePath = downloadModel.destinationPath == "" ? AKUtility.baseFilePath : downloadModel.destinationPath
                let destinationPath = (basePath as NSString).appendingPathComponent(fileName as String)
                
                let fileManager : FileManager = FileManager.default
                
                //If all set just move downloaded file to the destination
                //if fileManager.fileExists(atPath: basePath) {
                    let fileURL = URL(fileURLWithPath: destinationPath as String)
                    debugPrint("directory path = \(destinationPath)")
                    
                    do {
                        try fileManager.moveItem(at: location, to: fileURL)
                        self.delegate?.download(manager: self, didFinishDownloadingAtPath:destinationPath)
                    } catch let error as NSError {
                        debugPrint("Error while moving downloaded file to destination path:\(error)")
                        DispatchQueue.main.async(execute: { () -> Void in
                           self.delegate?.download(manager: self, didFailedWithError: error)
                        })
                    }
               // } else {
                    //Opportunity to handle the folder doesnot exists error appropriately.
                    //Move downloaded file to destination
                    //Delegate will be called on the session queue
                    //Otherwise blindly give error Destination folder does not exists
                    
//                    if let _ = self.delegate?.downloadRequestDestinationDoestNotExists {
//                        self.delegate?.downloadRequestDestinationDoestNotExists?(downloadModel, index: index, location: location)
//                    } else {
//                        let error = NSError(domain: "FolderDoesNotExist", code: 404, userInfo: [NSLocalizedDescriptionKey : "Destination folder does not exists"])
//                        //self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
//                    }
              //  }
                
                break
            }
        }
        
    }
     func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
         debugPrint("task id: \(task.taskIdentifier)")
         debugPrint("Completed with error \(error?.localizedDescription)")
        if error != nil {
            self.delegate?.download(manager: self, didFailedWithError: error!)
        }
        
    }
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
//        if let backgroundCompletion = self.backgroundSessionCompletionHandler {
//            DispatchQueue.main.async(execute: {
//                backgroundCompletion()
//            })
//        }
//        debugPrint("All tasks are finished")
        
    }
    
}
