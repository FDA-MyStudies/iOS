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

import UIKit
enum RegistrationMethods: String {
    //TODO : Write exact name for request method
    case login
    case register
    case confirmRegistration
    case userProfile
    case updateUserProfile
    case userPreferences
    case updatePreferences
    case updateEligibilityConsentStatus
    case consentPDF
    case updateStudyState
    case studyState
    case updateActivityState
    case activityState
    case withdraw
    case forgotPassword
    case logout
    case deleteAccount
    case changePassword
    case resendConfirmation
    case deactivate
    case verify
    case refreshToken
    case versionInfo
    case feedback
    case contactUs
    
    var description: String{
        switch self {
            
        default:
            return self.rawValue+".api"
        }
    }
    
    var method: Method{
        
        switch self {
            
        case .activityState, .consentPDF, .deleteAccount, .confirmRegistration, .userProfile, .userPreferences, .studyState, .versionInfo:
            //GET Methods
            return Method(methodName: (self.rawValue+".api"), methodType: .httpMethodGet, requestType: .requestTypeHTTP)
        case .withdraw,.logout, .deactivate:
            //DELETE Methods
            return Method(methodName: (self.rawValue+".api"), methodType: .httpMethodDELETE, requestType: .requestTypeJSON)
        default:
            //POST Methods
            return Method(methodName: (self.rawValue+".api"), methodType: .httpMethodPOST, requestType: .requestTypeJSON)
        }
    }

}
struct RegistrationServerURLConstants {

//  static let ProductionURL = "https://35.222.67.4:8082/myStudiesUserMgmtWS/"
//  static let DevelopmentURL = "https://35.222.67.4:8082/myStudiesUserMgmtWS/"
  
    //Staging server
    static let ProductionURL = API.registrationURL
    static let DevelopmentURL = API.registrationURL
    
    //Demo server
    //    static let ProductionURL = "https://reg.demo.mystudiesapp.org/fdahpUserRegWS/"
    //    static let DevelopmentURL = "https://reg.demo.mystudiesapp.org/fdahpUserRegWS/"

}

class RegistrationServerConfiguration: NetworkConfiguration {
    static let configuration = RegistrationServerConfiguration()
    
    
    // MARK:  Delegates
    override func getProductionURL() -> String {
        return RegistrationServerURLConstants.ProductionURL
    }
    override func getDevelopmentURL() -> String {
        return RegistrationServerURLConstants.DevelopmentURL
    }
    
    override func getDefaultHeaders() -> [String: String] {
      let locale = Locale.current.languageCode ?? "en"
      var language = "English"
      print("locale--\(locale)")
      if locale.hasPrefix("es") { // true
          print("Prefix exists")
        language = "Spanish"
      }
        
      let appId = AppDetails.applicationID
      let orgId = AppDetails.organizationID
        
        //let ud = UserDefaults.standard
        if User.currentUser.authToken != nil {
            return [kUserAuthToken: User.currentUser.authToken,
                    "applicationId": appId,
                    "orgId": orgId,
                    "language": language
            ]
        }
        else {
            return [
                "applicationId": appId,
                "orgId": orgId,
              "language": language
            ]
        }
    }
    
    override func getDefaultRequestParameters() -> [String : Any] {
        return Dictionary()
    }
    override func shouldParseErrorMessage() -> Bool {
        return false
    }
    
    
}
