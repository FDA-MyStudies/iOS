//
//  File.swift
//  FDA
//
//  Created by Arun Kumar on 2/7/17.
//  Copyright © 2017 BTC. All rights reserved.
//

import Foundation
import MobileCoreServices

enum MimeType:String{
    
    case txt = "text/plain"
    case html = "text/html"
    case css = "text/css"
    case xml = "text/xml"
    
    case pdf = "application/pdf"
    case json = "application/json"
    case docx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    
    case png = "image/png"
    case bmp = "image/x-ms-bmp"
    case svg = "image/svg+xml"
    case gif = "image/gif"
    case jpeg = "image/jpeg"
    
    case mp3 = "audio/mpeg"
    
    case threegp = "video/3gpp"
    case mp4 = "video/mp4"
    case mpeg = "video/mpeg"
    case avi = "video/x-msvideo"
    
}



class File{
    var mimeType : MimeType?
    var name : String?
    var link : String?
    var localPath : String?
    
    
    init() {
        self.mimeType = MimeType.txt
        self.name = ""
        self.link  = ""
        self.localPath = ""
    }
    
    func getMIMEType() -> String {
        return self.mimeType!.rawValue
    }
    func getFileName() -> String {
        return self.name!
    }
    func getFileLink() -> String {
        return self.link!
    }
    func getFileLocalPath() -> String {
        return self.localPath!
    }
    
    
    func setFile(dict:NSDictionary)  {
        
        if (dict["mimeType"]) != nil &&  Utilities.isNull(someObject:dict["mimeType"]  as AnyObject?) == false    {
            self.mimeType = dict["mimeType"] as? MimeType
        }
        if (dict["name"]) != nil &&  Utilities.isNull(someObject:dict["name"]  as AnyObject?) == false {
            self.name = dict["name"] as? String
        }
        if (dict["link"]) != nil &&  Utilities.isNull(someObject:dict["link"]  as AnyObject?) == false {
            self.link = dict["link"] as? String
        }
        //download data
        var fileData:NSData?
        
         fileData = NSData()
        //save data
        if fileData != nil{
            if saveDataIntoDocuments(data: fileData!)  {
                NSLog("File saved successfully")
            }
            else{
                 NSLog("File could not be saved")
            }
        }
        
        
    }
    
    
    func saveDataIntoDocuments(data:NSData) -> Bool {
        
        do {
            var documentsURL = FileManager.documentsDir()
            
            var fileURL = NSURL()
            //check if file exist with same name at specified path
            if FileManager.default.fileExists(atPath: documentsURL){
                
                // get new file name and save it
                
                documentsURL = documentsURL.appending("abc")
                fileURL = NSURL(fileURLWithPath: documentsURL)
            }
            else{
                
                
                documentsURL = documentsURL.appending(self.name!)
                fileURL = NSURL(fileURLWithPath: documentsURL)
            }
            try data.write(to: fileURL as URL, options: .atomic)
            
            // setting the local path to model object
            self.localPath = fileURL.absoluteString
            
            return true
        } catch {
            
            self.localPath = ""
            return false
        }
    }
}



