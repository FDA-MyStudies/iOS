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
    
    case txt = "text" //text/plain
    case html = "html" //text/html
    case css = "text/css"
    case xml = "text/xml"
    
    case pdf = "pdf" //application/pdf
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

//MARK: Api Constants
let kFileMIMEType = "mimeType"
let kFileName = "name"
let kFileLink = "link"

let kFileTypeForStudy = "type"
let kFileTitleForStudy = "title"
let kFileLinkForStudy = "content"

//MARK: File class
class File{
    var mimeType : MimeType?
    var name : String?
    var link : String?
    var localPath : String?
    
    
    init() {
        self.mimeType = MimeType.txt
        self.name = ""
        self.link  = ""
        //self.localPath = ""
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
        
        if Utilities.isValidObject(someObject: dict){
            
            if Utilities.isValidValue(someObject: dict[kFileMIMEType] as AnyObject)   {
                self.mimeType = dict[kFileMIMEType] as? MimeType
            }
            if Utilities.isValidValue(someObject: dict[kFileName] as AnyObject)  {
                self.name = dict[kFileName] as? String
            }
            if Utilities.isValidValue(someObject: dict[kFileLink] as AnyObject)  {
                self.link = dict[kFileLink] as? String
            }
           
            
        }
        else{
            Logger.sharedInstance.debug("File Dictionary is null:\(dict)")
        }
        
        
        
        
        
    }
    
    func setFileForStudy(dict:NSDictionary)  {
        
        if Utilities.isValidObject(someObject: dict){
            
            if Utilities.isValidValue(someObject: dict[kFileTypeForStudy] as AnyObject)   {
                self.mimeType = MimeType(rawValue:dict[kFileTypeForStudy] as! String)
            }
            if Utilities.isValidValue(someObject: dict[kFileTitleForStudy] as AnyObject)  {
                self.name = dict[kFileTitleForStudy] as? String
            }
            if Utilities.isValidValue(someObject: dict[kFileLinkForStudy] as AnyObject)  {
                self.link = dict[kFileLinkForStudy] as? String
            }
            
            
            
        }
        else{
            Logger.sharedInstance.debug("File Dictionary is null:\(dict)")
        }
    }
    
    /*
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
    }*/
}



