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
import UIKit

class HPHCSettings {
    
    func setupDefaultURLs() {
        let ud = UserDefaults.standard
        ud.setValue("https://hpwcp-stage.lkcompliant.net/StudyMetaData/", forKey: "WCPBaseURL")
        ud.setValue("https://hpreg-stage.lkcompliant.net/fdahpUserRegWS/", forKey: "URBaseURL")
        ud.setValue("https://hpresp-stage.lkcompliant.net/mobileappstudy-", forKey: "RSBaseURL")
        ud.synchronize()
    }
    
    func showSettings(_ presenter:UIViewController, handler:(() -> Void)){
        
      let kChangeServer = NSLocalizedStrings("Change server to", comment: "")
        let alertConrtolelr = UIAlertController.init(title: kChangeServer, message: nil, preferredStyle: .actionSheet)
        
        let ud = UserDefaults.standard
        
        let production = UIAlertAction(title: "Production", style: .default, handler:{ (_: UIAlertAction!) -> Void in
            ud.setValue("https://hpwcp-stage.lkcompliant.net/StudyMetaData/", forKey: "WCPBaseURL")
            ud.setValue("https://hpreg-stage.lkcompliant.net/fdahpUserRegWS/", forKey: "URBaseURL")
            ud.setValue("https://hpresp-stage.lkcompliant.net/mobileappstudy-", forKey: "RSBaseURL")
            ud.synchronize()
        })
        
        let stagging = UIAlertAction(title: "Stagging", style: .default, handler:{(_: UIAlertAction!) -> Void in
            ud.setValue("https://hpwcp-stage.lkcompliant.net/StudyMetaData/", forKey: "WCPBaseURL")
            ud.setValue("https://hpreg-stage.lkcompliant.net/fdahpUserRegWS/", forKey: "URBaseURL")
            ud.setValue("https://hpresp-stage.lkcompliant.net/mobileappstudy-", forKey: "RSBaseURL")
            ud.synchronize()
        })
        
        let local = UIAlertAction(title: "Local", style: .default, handler:{(_: UIAlertAction!) -> Void in
            ud.setValue("http://192.168.0.44:8080/StudyMetaData/", forKey: "WCPBaseURL")
            ud.setValue("http://192.168.0.125:8081/labkey/fdahpUserRegWS/", forKey: "URBaseURL")
            ud.setValue("https://hpresp-stage.lkcompliant.net/mobileappstudy-", forKey: "RSBaseURL")
            ud.synchronize()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel(Staging)", style: .cancel, handler:{(_: UIAlertAction!) -> Void in
            ud.setValue("https://hpwcp-stage.lkcompliant.net/StudyMetaData/", forKey: "WCPBaseURL")
            ud.setValue("https://hpreg-stage.lkcompliant.net/fdahpUserRegWS/", forKey: "URBaseURL")
            ud.setValue("https://hpresp-stage.lkcompliant.net/mobileappstudy-", forKey: "RSBaseURL")
            ud.synchronize()
        })
        
        alertConrtolelr.addAction(production)
        alertConrtolelr.addAction(stagging)
        alertConrtolelr.addAction(local)
        alertConrtolelr.addAction(cancelAction)
        presenter.present(alertConrtolelr, animated: true, completion: {
            ud.synchronize()
        })
        
    }
    
}
