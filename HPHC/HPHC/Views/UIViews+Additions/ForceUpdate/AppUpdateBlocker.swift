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

class AppUpdateBlocker: UIView {
  
  @IBOutlet weak var labelMessage: UILabel!
  @IBOutlet weak var labelVersionNumber: UILabel!
  @IBOutlet weak var appIconView: UIImageView!
  @IBOutlet var upgradeStackView: UIStackView!
  @IBOutlet weak var buttonUpgrade: UIButton!
  @IBOutlet weak var cancelBtn: UIButton!

  var appIcon: UIImage? {
    guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? NSDictionary,
          let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? NSDictionary,
          let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? NSArray,
          // First will be smallest for the device class, last will be the largest for device class
          let lastIcon = iconFiles.lastObject as? String,
          let icon = UIImage(named: lastIcon) else {
      return nil
    }
    return icon
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  class func instanceFromNib(frame: CGRect, detail: Dictionary<String, Any>) -> AppUpdateBlocker {
    let view = UINib(nibName: "AppUpdateBlocker", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AppUpdateBlocker
    view.frame = frame
    view.layoutIfNeeded()
    return view
  }
  
  func configureView(with latestVersion: String, isForceUpdate: Bool) {
    self.buttonUpgrade.layer.borderColor = #colorLiteral(red: 0, green: 0.4862745098, blue: 0.7294117647, alpha: 1)
    self.cancelBtn.layer.borderColor = #colorLiteral(red: 0, green: 0.4862745098, blue: 0.7294117647, alpha: 1)
    //        self.labelMessage.text = kBlockerScreenLabelText
    self.appIconView.image = self.appIcon
    if isForceUpdate {
      self.labelMessage.text = kBlockerScreenLabelText
    }else{
      self.labelMessage.text = kAppManualUpdateText
      self.upgradeStackView.addArrangedSubview(self.cancelBtn)
    }
  }
  
  @IBAction func buttonUpgradeAction() {
    guard let appleID = AppConfiguration.appleID, !appleID.isEmpty else {
      // Ask user to update from AppStore.
      Utilities.showAlertWithMessage(alertMessage: kAppStoreUpdateText)
      return
    }
    let appStoreLink = "https://apps.apple.com/app/apple-store"
    let appLink = appStoreLink + "/id" + appleID
    if let url = URL(string: appLink), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  @IBAction func buttonCancelAction(){
    //        for view in self.subviews {
    //            view.removeFromSuperview()
    //        }
    //        self.removeFromSuperview()
    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
    UIApplication.shared.keyWindow?.rootViewController = storyboard.instantiateInitialViewController()
  }
}

extension UIView {
  /// Remove all subview
  func removeAllSubviews() {
    subviews.forEach { $0.removeFromSuperview() }
  }
  
  /// Remove all subview with specific type
  func removeAllSubviews<T: UIView>(type: T.Type) {
    subviews
      .filter { $0.isMember(of: type) }
      .forEach { $0.removeFromSuperview() }
  }
}
