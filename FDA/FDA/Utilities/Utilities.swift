//
//  Utilities.swift
//  Utilities
//
//  Created by Reddanna on 04/08/16.
//  Copyright © 2016 BTC. All rights reserved.
//

import Foundation
import UIKit

let MAX_WIDTH = 1000
let MAX_HEIGHT = 100

let alert = UIAlertView()

public typealias AlertAction = () -> Void

enum DirectoryType : String{
    case study = "Study"
    case gateway = "Gateway"
}

struct ScreenSize {
    
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

struct iOSVersion {
    
    static let SYS_VERSION_FLOAT = (UIDevice.current.systemVersion as NSString).floatValue
    static let iOS7 = (iOSVersion.SYS_VERSION_FLOAT < 8.0 && iOSVersion.SYS_VERSION_FLOAT >= 7.0)
    static let iOS8 = (iOSVersion.SYS_VERSION_FLOAT >= 8.0 && iOSVersion.SYS_VERSION_FLOAT < 9.0)
    static let iOS9 = (iOSVersion.SYS_VERSION_FLOAT >= 9.0 && iOSVersion.SYS_VERSION_FLOAT < 10.0)
}

class Utilities: NSObject {
    
    
    class func getAttributedText(plainString pstr: String, boldString bstr: String, fontSize size: CGFloat,plainFontName:String,boldFontName:String) -> NSAttributedString {
        
        let title:String = pstr + " " + bstr
        let attributedString = NSMutableAttributedString(string: title)
        let stringAttributes1 = [NSFontAttributeName:UIFont(name:plainFontName, size: size)!]
        let stringAttributes2 = [NSFontAttributeName:UIFont(name:boldFontName, size: size)!]
        
        attributedString.addAttributes(stringAttributes1, range: (title as NSString).range(of: pstr))
        attributedString.addAttributes(stringAttributes2, range: (title as NSString).range(of: bstr))
        
        return attributedString
        
    }
    
    
    class func getUIColorFromHex(_ hexInt: Int, alpha:CGFloat? = 1.0) -> UIColor {
        
        let red = CGFloat((hexInt & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexInt & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexInt & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    class  func hexStringToUIColor(_ hex:String) -> UIColor {
        
        var cString:String =  hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        //hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    class func getDateStringWithFormat(_ dateFormatter:String,date:Date) ->String{
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us")
        formatter.dateStyle = DateFormatter.Style.full
        formatter.dateFormat = dateFormatter
        let dateString = formatter.string(from: date)
        
        return dateString
        
    }
    
    class func getDateFromStringWithFormat(_ dateFormate:String,resultDate:String)->Date {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "us")
        formatter.dateStyle = DateFormatter.Style.full
        formatter.dateFormat = dateFormate
        let resDate = formatter.date(from: resultDate)
        
        return  resDate!
        
    }
    
    class func frameForText(_ text: String, font: UIFont) -> CGSize {
        
        let attrString = NSAttributedString.init(string: text, attributes: [NSFontAttributeName:font])
        let rect = attrString.boundingRect(with: CGSize(width: MAX_WIDTH,height: MAX_HEIGHT), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        let size = CGSize(width: rect.size.width, height: rect.size.height)
        return size
    }
    
    
    class func paddingViewForTextFiled(_ textFiled:UITextField)->Void{
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textFiled.frame.height))
        textFiled.leftView = paddingView
        textFiled.leftViewMode = UITextFieldViewMode.always
        // textFiled.layoutIfNeeded()
        
        
    }
    
    class func clearTheNotificationData(){
        //clearing notificationArray inUserdefaults
        UserDefaults.standard.removeObject(forKey: "NotifName")
        UserDefaults.standard.removeObject(forKey: "NotifTime")
    }
    class func validateInputValue(value : String, valueType : String)-> Bool{
        
        var valueRegex = ""
        if valueType == "Phone"{
            
            
        }else if valueType == "Name"{
            valueRegex = "[a-zA-z]+([ '-][a-zA-Z]+)*$"
        }else if valueType == "Email"{
            
            valueRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        }
        else if valueType == "Password"{
            
            // password validation for which is length >= 8 && contains any special character
            
            valueRegex = "^(?=.*[!\"#$%&'()*+,-./:;<=>?@\\^_`{|}~\\[\\]])[0-9A-Za-z!\"#$%&'()*+,-./:;<=>?@\\^_`{|}~\\[\\]]{8,}$"
        }
        
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", valueRegex)
        let isValid = predicate.evaluate(with: value as String)
        return isValid
    }
    
    class func isValidEmail(testStr:String) -> Bool {
        
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    class func formatNumber( mobileNumber: NSString)-> NSString
    {
        var mobileNumber = mobileNumber
        mobileNumber = mobileNumber.replacingOccurrences(of: "(", with: "") as NSString
        mobileNumber = mobileNumber.replacingOccurrences(of: ")", with: "") as NSString
        mobileNumber = mobileNumber.replacingOccurrences(of: " ", with: "") as NSString
        mobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "") as NSString
        mobileNumber = mobileNumber.replacingOccurrences(of: "+", with: "") as NSString
        
        let length = mobileNumber.length
        if(length > 10)
        {
            mobileNumber = mobileNumber.substring(from: length - 10) as NSString
            //print(mobileNumber)
            
        }
        
        return mobileNumber;
    }
    
    
    class  func getLength( mobileNumber : NSString) -> Int
    {
        var mobileNumber = mobileNumber
        mobileNumber = mobileNumber.replacingOccurrences(of: "(", with: "") as NSString
        mobileNumber = mobileNumber.replacingOccurrences(of: ")", with: "") as NSString
        mobileNumber = mobileNumber.replacingOccurrences(of: " ", with: "") as NSString
        mobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "") as NSString
        mobileNumber = mobileNumber.replacingOccurrences(of: "+", with: "") as NSString
        
        let length = mobileNumber.length
        
        return length
    }
    
    class func checkTextSufficientComplexity(password : String) -> Bool{
        
        //let capitalLetterRegEx  = ".*[A-Z]+.*"
        
        //€£• _-/:;.,?'|
        
        let capitalLetterRegEx  = ".*[~!@#$%^&*()_]+.*"
        
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluate(with: password)
        
        print("\(capitalresult)")
        
        
        let numberRegEx  = ".*[a-z0-9A-Z]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = texttest1.evaluate(with: password)
        
        print("\(numberresult)")
        
        return capitalresult && numberresult
        
    }
    
    class func isValidValue(someObject: AnyObject?) -> Bool {
      /*
         Method to validate a value for Null condition
         @someObject: can be String,Int or Bool
         returns a Boolean on valid data
        */
    
        guard let someObject = someObject else {
            // is null
            
            return false
        }
        // is not null
        
        if (someObject is NSNull) ==  false {
            
            if someObject as? Int != nil && (someObject as? Int)! >= 0 {
                return true
            }
            else if someObject as? String != nil && ((someObject as? String)?.characters.count)! > 0 && (someObject as? String) != ""{
                return true
            }
            else if someObject as? Bool != nil && (someObject as! Bool == true || someObject as! Bool == false){
                return true
            }
            else  if someObject as? Double != nil && (someObject as? Double)?.isFinite == true && (someObject as? Double)?.isZero == false && (someObject as? Double)! > 0 {
                return true
            }
            else if someObject as? Date != nil {
                return true
            }
            else{
                Logger.sharedInstance.debug("Value is null:\(someObject)")
                return false
            }
            
        }
        else{
            return false
        }
    }
    
    
    class func isValidValueAndOfType(someValue:AnyObject? , type:AnyClass )->Bool{
        /* Method to check if value is of specific Type
         @someValue:can be any value
         @type:must a specific class Type
         returns boolean 
         NOTE:current not in use, need modifications
         */
        
        guard let someObject = someValue else {
            // is null
            
            return false
        }
        // is not null
        
        if (someObject is NSNull) ==  false {
            
            if (someValue?.isKind(of: type))! && someValue != nil {
                return true
            }
            else{
                return false
            }
        }
        else{
            Logger.sharedInstance.debug("Value is null:\(someObject)")
            return false
        }
        
    }
    
    
    
    class func isValidObject(someObject: AnyObject?)-> Bool{
        
        /* Method to Validate Object and checks for Null
         @someObject: can be either an Array or Dictionary
         returns a Boolean if someObject is not null
        */
        
        guard let someObject = someObject else {
            // is null
            
            return false
        }
        
        if (someObject is NSNull) ==  false {
            if someObject as? Dictionary<String, Any> != nil  && (someObject as? Dictionary<String, Any>)?.isEmpty == false && ((someObject as? Dictionary<String, Any>)?.count)! > 0{
                return true
            }
            else if someObject as? NSArray != nil && ((someObject as? NSArray)?.count)! > 0 {
                return true
            }
            else{
                return false
            }
        }
        else{
            Logger.sharedInstance.debug("Object is null:\(someObject)")
            return false
        }
        
        
    }
    
    class func getDateFromString(dateString:String)->Date?{
        /* Method to get DateFromString for default dateFormatter
         @dateString:a date String of format "yyyy-MM-dd'T'HH:mm:ssZ"
         returns date for the specified dateString in same format
        */
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        // dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        //"2016-08-01T08:00:00+0900"
        
        guard let date = dateFormatter.date(from: dateString) else {
            assert(false, "no date from string")
            return nil
        }
        
        dateFormatter.dateFormat = "yyyy MMM EEEE HH:mm"
        // dateFormatter.timeZone = NSTimeZone.local // NSTimeZone(name: "UTC") as TimeZone!
        let finalString = dateFormatter.string(from: date)
        let finalDate = dateFormatter.date(from: finalString)
        return finalDate
        
    }
    
    class func getStringFromDate(date:Date)->String?{
        /* Method to get StringFromDate for default dateFormatter
         @date:a date  of format "yyyy-MM-dd'T'HH:mm:ssZ"
         returns dateString for the specified date in same format
         */
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        let dateValue = dateFormatter.string(from: date)
        
        return dateValue
        
    }
    
    
    
    
    class func getAppVersion() -> String{
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0"
    }
    
    class func getBundleIdentifier()->String{
        
        return Bundle.main.bundleIdentifier!
    }
    
    class func showAlertWithMessage(alertMessage:String)->Void{
        
        self.showAlertWithTitleAndMessage(title:"", message: alertMessage as NSString)
        
    }
    
    class func showAlertWithTitleAndMessage(title: NSString, message : NSString)->Void {
        
        
        alert.title = title as String
        alert.message = message as String
        alert.addButton(withTitle: "OK")
        alert.show()
    }
    
}


extension FileManager {
    class func documentsDir() -> String {
        /* Method to get documentDirectory of Application
         return path of documentDirectory
        */
        
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    class func cachesDir() -> String {
        /* Method to get CacheDirectory of Application
         return path of CacheDirectory
         */
        var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    
    class func getStorageDirectory(type:DirectoryType) -> String{
        /* Method to create Study or gateway directory
         @type:DirectoryType can be study or gateway
         returns a directory path string if exists already or else create One and returns path
        */
        
        let fileManager = FileManager.default
        
        let fullPath = self.documentsDir() + "/" + "\(type)"
        
        var isDirectory : ObjCBool = false
        if fileManager.fileExists(atPath: fullPath, isDirectory:&isDirectory) {
            if isDirectory.boolValue {
                // file exists and is a directory
                return fullPath
            } else {
                // file exists and is not a directory
                return ""
            }
        } else {
            // file does not exist
            do {
                try FileManager.default.createDirectory(atPath: fullPath, withIntermediateDirectories: false, attributes: nil)
                return fullPath
            } catch let error as NSError {
                print(error.localizedDescription);
                return ""
            }
        }
    }
    
}
