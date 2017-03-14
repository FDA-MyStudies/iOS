//
//  UIUtilities.swift
//  Utilities
//
//  Created by Reddanna on 04/08/16.
//  Copyright © 2016 BTC. All rights reserved.
//

import Foundation
import UIKit

let alert = UIAlertView()

public typealias AlertAction = () -> Void

class UIUtilities: NSObject {
    
    
    class func showAlertWithTitleAndMessage(title: NSString, message : NSString)->Void {
        
        
          let alert = UIAlertController(title:"",message:message as String,preferredStyle: UIAlertControllerStyle.alert)
          alert.addAction(UIAlertAction(title:NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
          UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
         
        
        
    }
    
    
    
    class func dismissAlert(){
        alert.dismiss(withClickedButtonIndex: 0, animated: false)
    }
    
    class func showAlertWithMessage(alertMessage:String)->Void{
        
        self.showAlertWithTitleAndMessage(title:"", message: alertMessage as NSString)
        
    }
    
    
    class func paddingViewForTextFiled(textFiled:UITextField)->Void{
        
        
        let paddingView =  UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: textFiled.frame.height))
        textFiled.leftView = paddingView
        textFiled.leftViewMode = UITextFieldViewMode.always
        
        
    }
    
    class func addingBorderToTextField(textField:UITextField)->UITextField {
        
        //  textField.borderStyle =  UITextBorderStyle.RoundedRect
        textField.layer.borderWidth = 2
        textField.layer.borderColor = Utilities.hexStringToUIColor("556085").cgColor
        textField.backgroundColor =  Utilities.hexStringToUIColor("414c6f")
        
        return textField
        
    }
    
    class func getTextfieldWithInvalidInputBorder(textField:UITextField, layerBorderColor : String, backgroundColor : String) {
        
        //textField.borderStyle =  UITextBorderStyle.RoundedRect
        textField.layer.borderWidth = 2
        textField.layer.borderColor = Utilities.hexStringToUIColor(layerBorderColor).cgColor
        textField.backgroundColor =  Utilities.hexStringToUIColor(backgroundColor)
        //"bf7266"
        //"414c6f"
    }
    
    class func removeTheBorderToTextField(textField:UITextField)->UITextField {
        
        textField.borderStyle =  UITextBorderStyle.none
        textField.layer.borderWidth = 0
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.backgroundColor =  Utilities.hexStringToUIColor("556085")
        
        return textField
        
    }
    
    class func segmentSeparatorColor(color:UIColor,segment:UISegmentedControl) -> UIImage {
        
        // let rect = CGRectMake(0.0, 0.0, 1.5, segment.frame.size.height)
        
        let rect =  CGRect(x: 0.0, y: 0.0, width: 1.5, height: segment.frame.size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
        
    }
    
    class func applyBlurrEffect()-> UIVisualEffectView
    {
        
        let blurEffect = UIBlurEffect.init(style: UIBlurEffectStyle.dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        visualEffect.tag = 100
        visualEffect.alpha = 1
        visualEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return visualEffect
    }
    
    class func applyBlurrEffectForFrequency()-> UIVisualEffectView
    {
        
        let blurEffect = UIBlurEffect.init(style: UIBlurEffectStyle.dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        visualEffect.tag = 500
        visualEffect.alpha = 1
        visualEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return visualEffect
    }
    
    
    class func removeBlurFromFrequency(fromView : UIView) {
        for subView in fromView.subviews{
            if subView.tag == 500{
                subView.removeFromSuperview()
            }
        }
    }
    
    class func removeBlur(fromView : UIView) {
        for subView in fromView.subviews{
            if subView.tag == 100{
                subView.removeFromSuperview()
            }
        }
    }
    
    class func addSpinAnimation(withDuration duration : CFTimeInterval)-> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = 360
        animation.duration = duration
        return animation
    }
    class  func getHexColors() -> NSArray {
        
        let hexColors = ["ff9f30","fdf22f","b6ff14","07f51c"]
        return hexColors as NSArray
    }
    
    class  func addFadedGreenView(view:UIView) ->UIView{
        
        let greenView = UIView.init(frame:view.frame)
        greenView.backgroundColor = Utilities.hexStringToUIColor("1eebb4")
        greenView.alpha = 0.5
        greenView.tag = 200
        view.addSubview(greenView)
        
        return greenView
    }
    
    class  func addFadedGreenViewForFrequencyAttributes(view:UIView) ->UIView{
        
        let greenView = UIView.init(frame:view.frame)
        greenView.backgroundColor = Utilities.hexStringToUIColor("1eebb4")
        greenView.alpha = 0.8
        greenView.tag = 300
        view.addSubview(greenView)
        
        return greenView
    }
    
    
    
    class func setWhiteBorderOnView(view : UIView, borderWidth : CGFloat, cornerRadius : CGFloat){
        
        view.layer.borderWidth = borderWidth
        view.layer.cornerRadius = cornerRadius
        view.layer.borderColor = UIColor.white.cgColor
    }
    
    class func setRedBorderOnView(view : UIView, borderWidth : CGFloat, cornerRadius : CGFloat){
        
        view.layer.borderWidth = borderWidth
        view.layer.cornerRadius = cornerRadius
        view.layer.borderColor = Utilities.hexStringToUIColor("kInvalidBorderColor").cgColor
    }
    
    
    class func convertDictionaryIntoString(mutableDic:NSMutableDictionary) ->String{
        
        var jsonString:String!
        do{
            let jsonData: NSData = try JSONSerialization.data(withJSONObject: mutableDic, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
            jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
        }
        catch{
            
        }
        return jsonString
        
    }
    
    
    class func convertNSMutableArrayIntoString(mutableArray:NSMutableArray) ->String {
        
        var socialMediaNamesString:String!
        do{
            let jsonData: NSData = try JSONSerialization.data(withJSONObject: mutableArray, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
            socialMediaNamesString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
        }
        catch{
        }
        return socialMediaNamesString
    }
    
    class func showAlertMessageWithTwoActionsAndHandler(_ errorTitle : String,errorMessage : String,errorAlertActionTitle : String ,errorAlertActionTitle2 : String?,viewControllerUsed : UIViewController, action1:@escaping AlertAction, action2:@escaping AlertAction){
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle:UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: errorAlertActionTitle, style: UIAlertActionStyle.default, handler: { (action) in
            action1()
        }))
        if errorAlertActionTitle2 != nil {
            alert.addAction(UIAlertAction(title: errorAlertActionTitle2, style: UIAlertActionStyle.default, handler: { (action) in
                action2()
            }))
        }
        
        viewControllerUsed.present(alert, animated:true, completion: nil)
    }
    
    class func showAlertMessageWithActionHandler(_ title : String,message : String,buttonTitle : String ,viewControllerUsed : UIViewController, action:@escaping AlertAction){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle:UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: { (alertAction) in
            action()
        }))
        
        
        viewControllerUsed.present(alert, animated:true, completion: nil)
    }
    
    class func showAlertMessage(_ errorTitle : String,errorMessage : String,errorAlertActionTitle : String ,viewControllerUsed : UIViewController?){
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle:UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: errorAlertActionTitle, style: UIAlertActionStyle.default, handler: nil))
        viewControllerUsed!.present(alert, animated:true, completion: nil)
    }
    
//    //Used to show gif loader
//    class func showGifLoader() {
//        GiFHUD.setGifWithImageName("localive_preloader@3x.gif")
//        GiFHUD.showWithOverlay()
//    }
//    
//    //used to dismiss gif loader
//    class func hideGifLoader(){
//        GiFHUD.dismiss()
//    }
    
    
    
    
    
}
