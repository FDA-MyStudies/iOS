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

enum Configuration {
  enum Error: Swift.Error {
    case missingKey, invalidValue
  }

  static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
    guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
      throw Error.missingKey
    }

    switch object {
    case let value as T:
      return value
    case let string as String:
      guard let value = T(string) else { fallthrough }
      return value
    default:
      throw Error.invalidValue
    }
  }
}

enum API {

  private enum AppProtocol {
    private static let http = "http://"
    private static let https = "https://"
    static var value: String {
      #if DEBUG
        return https
      #else
        return https
      #endif
    }
  }

  static var wcpURL: String {

    return   "http://" + ((try? Configuration.value(for: "WCP_URL")) ?? "")
    // return AppProtocol.value + ((try? Configuration.value(for: "WCP_URL")) ?? "")
  }

  static var responseURL: String {
    return AppProtocol.value + ((try? Configuration.value(for: "RESPONSE_URL")) ?? "")
  }

  static var registrationURL: String {
  return  "http://" + ((try? Configuration.value(for: "REGISTRATION_URL")) ?? "")
 //   return AppProtocol.value + ((try? Configuration.value(for: "REGISTRATION_URL")) ?? "")
  }
  
}
