//
//  Branding.swift
//  HPHC
//
//  Created by Surender on 14/02/20.
//  Copyright © 2020 BTC. All rights reserved.
//

import Foundation

enum Branding {
  
  private enum JSONKey {
    static let JoinStudyButtonTitle = "JoinStudyButtonTitle"
    static let ViewConsentButtonTitle = "ViewConsentButtonTitle"
    static let VisitWebsiteButtonTitle = "VisitWebsiteButtonTitle"
    static let ConsentPDF = "ConsentPDF"
    static let LeaveStudy = "LeaveStudy"
    static let LeaveStudyConfirmationText = "LeaveStudyConfirmationText"
    static let WebsiteLink = "WebsiteLink"
    static let WebsiteButtonTitle = "WebsiteButtonTitle"
    static let TermsAndConditionURL = "TermsAndConditionURL"
    static let PrivacyPolicyURL = "PrivacyPolicyURL"
    static let ValidatedTitle = "ValidatedTitle"
    static let AllowFeedback = "AllowFeedback"
    static let NavigationTitleName = "NavigationTitleName"
    static let PoweredByTitleName = "PoweredByTitleName"
    static let ProductTitleName = "ProductTitleName"
  }
  
  private static var brandConfig: JSONDictionary {
      var nsDictionary: NSDictionary?
      if let path = Bundle.main.path(forResource: "Branding", ofType: "plist") {
         nsDictionary = NSDictionary(contentsOfFile: path)
      }
      return nsDictionary as? JSONDictionary ?? [:]
  }
  
  static var JoinStudyButtonTitle: String {
      return brandConfig[JSONKey.JoinStudyButtonTitle] as? String ?? ""
  }
  
  static var ViewConsentButtonTitle:String {
      return brandConfig[JSONKey.ViewConsentButtonTitle] as? String ?? ""
  }
  
  static var VisitWebsiteButtonTitle:String {
      return brandConfig[JSONKey.VisitWebsiteButtonTitle] as? String ?? ""
  }
  
  static var ConsentPDF:String {
      return brandConfig[JSONKey.ConsentPDF] as? String ?? ""
  }
  
  static var LeaveStudy: String {
      return brandConfig[JSONKey.LeaveStudy] as? String ?? ""
  }
  
  static var LeaveStudyConfirmationText:String {
      return brandConfig[JSONKey.LeaveStudyConfirmationText] as? String ?? ""
  }
  
  static var WebsiteLink:String {
      return brandConfig[JSONKey.WebsiteLink] as? String ?? ""
  }
  
  static var WebsiteButtonTitle:String {
    return brandConfig[JSONKey.WebsiteButtonTitle] as? String ?? Branding.WebsiteLink
  }
  
  static var TermsAndConditionURL: String {
      return brandConfig[JSONKey.TermsAndConditionURL] as? String ?? ""
  }
  
  static var PrivacyPolicyURL:String {
      return brandConfig[JSONKey.PrivacyPolicyURL] as? String ?? ""
  }
  
  static var ValidatedTitle:String {
      return brandConfig[JSONKey.ValidatedTitle] as? String ?? "Validated!"
  }
  
  static var AllowFeedback:Bool {
      return brandConfig[JSONKey.AllowFeedback] as? Bool ?? true
  }
  
  static var NavigationTitleName:String {
      return brandConfig[JSONKey.NavigationTitleName] as? String ?? ""
  }
  
  static var PoweredByTitleName:String {
      return brandConfig[JSONKey.PoweredByTitleName] as? String ?? ""
  }
  
  /// AppName
  static var productTitle: String {
    return brandConfig[JSONKey.ProductTitleName] as? String ?? ""
  }
}
