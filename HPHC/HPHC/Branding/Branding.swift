/*
 License Agreement for FDA My Studies
Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.
Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
 */

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
    
      var plistPath = Bundle.main.path(forResource: "Branding", ofType: ".plist", inDirectory: nil)
      let localeDefault = getLanguageLocale()
    print("Krishna branding plist \(localeDefault)")
      if !(localeDefault.hasPrefix("es") || localeDefault.hasPrefix("en")) {
        plistPath = Bundle.main.path(forResource: "Branding", ofType: ".plist", inDirectory: nil, forLocalization: "Base")
        print("Krishna branding plist inside if \(Bundle.main.path(forResource: "Branding", ofType: ".plist", inDirectory: nil, forLocalization: "Base"))")
      }else if localeDefault.hasPrefix("en"){
        plistPath = Bundle.main.path(forResource: "Branding", ofType: ".plist", inDirectory: nil, forLocalization: "Base")
      }else if localeDefault.hasPrefix("es"){
        plistPath = Bundle.main.path(forResource: "Branding", ofType: ".plist", inDirectory: nil, forLocalization: "es")
      }
      print("Krishna branding plist path : \(plistPath)")
      if let path = plistPath {
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
      return brandConfig[JSONKey.ValidatedTitle] as? String ?? kEligibilityValidationTitle
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
