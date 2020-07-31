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
import PDFKit

class PDFCreator: NSObject {
  var title: String
  var body: String
  let image: UIImage
  let relation: String
    let firstName: String
    let lastName: String
  
  init(title: String, body: String, image: UIImage, relation: String, firstName: String, lastName: String) { //
    self.title = title
    self.body = body
    self.image = image
    self.relation = relation
    self.firstName = firstName
    self.lastName = lastName
  }
  
  func createFlyer() -> Data {
    // 1
    let pdfMetaData = [
      kCGPDFContextCreator: "",
      kCGPDFContextAuthor: "",
      kCGPDFContextTitle: title
    ]
    let format = UIGraphicsPDFRendererFormat()
    format.documentInfo = pdfMetaData as [String: Any]
    
    // 2
    let pageWidth = 8.5 * 72.0
    let pageHeight = 11 * 72.0
    let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
    
    // 3
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    // 4
    let data = renderer.pdfData { (context) in
      // 5
      context.beginPage()
      // 6
        
      let titleBottom = addTitle(pageRect: pageRect)
      let body1TextBottom = addBody1Text(pageRect: pageRect, textTop: titleBottom + 24.0)
        let body2TextBottom = addBody2Text(pageRect: pageRect, textTop: body1TextBottom + 34.0, title1: "Participant first name:", title2: firstName)
    let lastNameBottom = addBody2Text(pageRect: pageRect, textTop: body2TextBottom + 14.0, title1: "Participant last name:", title2: lastName)
        
      let signatureImageBottom = addImage(pageRect: pageRect, imageTop: lastNameBottom + 18.0)
        let context = context.cgContext
        drawLine(context, pageRect: pageRect, top: signatureImageBottom + 5, xValue: 10)
        
        let signatureTextBottom = addBody3Text(pageRect: pageRect, textTop: signatureImageBottom + 14.0, title: "(Signature)", xValue: 10)
        drawLine(context, pageRect: pageRect, top: signatureImageBottom + 5, xValue: (CGFloat(3 * pageWidth / 4)) )
        let dateTextBottom = addBody3Text(pageRect: pageRect, textTop: signatureImageBottom + 14.0, title: "(Date)", xValue: 10)
        
        
      
//      let context = context.cgContext
//      drawTearOffs(context, pageRect: pageRect, tearOffY: pageRect.height * 4.0 / 5.0, numberTabs: 8)
//      drawContactLabels(context, pageRect: pageRect, numberTabs: 8)
    }
    
    return data
  }
  
  func addTitle(pageRect: CGRect) -> CGFloat {
    title = "Consent by a Legally Authorized Representative"
    // 1
    let titleFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
    // 2
    let titleAttributes: [NSAttributedString.Key: Any] =
      [NSAttributedString.Key.font: titleFont]
    let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
    // 3
    let titleStringSize = attributedTitle.size()
    // 4
    let titleStringRect = CGRect(x: 10,
                                 y: 36, width: titleStringSize.width,
                                 height: titleStringSize.height)
    // 5
    attributedTitle.draw(in: titleStringRect)
    // 6
    return titleStringRect.origin.y + titleStringRect.size.height
  }

  func addBody1Text(pageRect: CGRect, textTop: CGFloat) -> CGFloat {
    body = "I am signing the consent document on behalf of the participant, as a legally-authorized representative of the participant."
    // 1
    let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
    // 2
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .natural
    paragraphStyle.lineBreakMode = .byWordWrapping
    // 3
    let textAttributes = [
      NSAttributedString.Key.paragraphStyle: paragraphStyle,
      NSAttributedString.Key.font: textFont
    ]
    let attributedText = NSAttributedString(string: body, attributes: textAttributes)
    // 4
    let textRect = CGRect(x: 10, y: textTop, width: pageRect.width - 20,
                          height: pageRect.height - textTop - pageRect.height / 5.0)
    attributedText.draw(in: textRect)
    
    let titleStringSize = attributedText.size()
    let titleStringRect = CGRect(x: 10,
                                 y: textTop , width: titleStringSize.width,
                                 height: titleStringSize.height)
    
    return titleStringRect.origin.y + titleStringRect.size.height
  }
  
    func addBody2Text(pageRect: CGRect, textTop: CGFloat, title1: String, title2: String) -> CGFloat {
    // 1
    let titleFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
    let titleFont2 = UIFont.systemFont(ofSize: 12.0, weight: .bold)
    // 2
    let titleAttributes: [NSAttributedString.Key: Any] =
      [NSAttributedString.Key.font: titleFont]
    let attributedTitle1 = NSMutableAttributedString(string: title1, attributes: titleAttributes)
    
    let titleAttributes2: [NSAttributedString.Key: Any] =
      [NSAttributedString.Key.font: titleFont2]
    let attributedTitle2 = NSMutableAttributedString(string: title2, attributes: titleAttributes2)
    
    let attributedTitle: NSMutableAttributedString = attributedTitle1
    attributedTitle.append(attributedTitle2)
    // 3
    let textRect = CGRect(x: 10, y: textTop, width: pageRect.width - 20,
                          height: pageRect.height - textTop - pageRect.height / 5.0)
    attributedTitle.draw(in: textRect)
    
    let titleStringSize = attributedTitle.size()
    let titleStringRect = CGRect(x: 10,
                                 y: textTop , width: titleStringSize.width,
                                 height: titleStringSize.height)
    
    return titleStringRect.origin.y + titleStringRect.size.height
  }
    
    func addBody3Text(pageRect: CGRect, textTop: CGFloat, title: String, xValue: CGFloat) -> CGFloat {
      let titleFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
      // 2
      let titleAttributes: [NSAttributedString.Key: Any] =
        [NSAttributedString.Key.font: titleFont]
      let attributedTitle = NSMutableAttributedString(string: title, attributes: titleAttributes)
      // 3
      let textRect = CGRect(x: 10, y: textTop, width: pageRect.width - 20,
                            height: pageRect.height - textTop - pageRect.height / 5.0)
      attributedTitle.draw(in: textRect)
      
      let titleStringSize = attributedTitle.size()
      let titleStringRect = CGRect(x: xValue,
                                   y: textTop , width: titleStringSize.width,
                                   height: titleStringSize.height)
      
      return titleStringRect.origin.y + titleStringRect.size.height
    }

  func addImage(pageRect: CGRect, imageTop: CGFloat) -> CGFloat {
    // 1
    let maxHeight = pageRect.height * 0.4
    let maxWidth = pageRect.width * 0.8
    // 2
    let aspectWidth = maxWidth / image.size.width
    let aspectHeight = maxHeight / image.size.height
    let aspectRatio = min(aspectWidth, aspectHeight)
    // 3
    let scaledWidth = pageRect.width / 4 // image.size.width * aspectRatio
    let scaledHeight = pageRect.width / 4 // image.size.height * aspectRatio
    // 4
//    let imageX = (pageRect.width - scaledWidth) / 2.0
    let imageRect = CGRect(x: 10, y: imageTop,
                           width: scaledWidth, height: scaledHeight) // / 4
    // 5
    image.draw(in: imageRect)
    return imageRect.origin.y + imageRect.size.height
  }
    
    func drawLine(_ drawContext: CGContext, pageRect: CGRect, top: CGFloat, xValue: CGFloat) {
        drawContext.saveGState()
        drawContext.setLineWidth(1.0)
        
        // 3
        drawContext.move(to: CGPoint(x: xValue, y: top))
        drawContext.addLine(to: CGPoint(x: pageRect.width / 4, y: top))
        drawContext.strokePath()
        drawContext.restoreGState()
    }
  
  // 1
  func drawTearOffs(_ drawContext: CGContext, pageRect: CGRect,
                    tearOffY: CGFloat, numberTabs: Int) {
    // 2
    drawContext.saveGState()
    drawContext.setLineWidth(2.0)
    
    // 3
    drawContext.move(to: CGPoint(x: 0, y: tearOffY))
    drawContext.addLine(to: CGPoint(x: pageRect.width, y: tearOffY))
    drawContext.strokePath()
    drawContext.restoreGState()
    
    // 4
    drawContext.saveGState()
    let dashLength = CGFloat(72.0 * 0.2)
    drawContext.setLineDash(phase: 0, lengths: [dashLength, dashLength])
    // 5
    let tabWidth = pageRect.width / CGFloat(numberTabs)
    for tearOffIndex in 1..<numberTabs {
      // 6
      let tabX = CGFloat(tearOffIndex) * tabWidth
      drawContext.move(to: CGPoint(x: tabX, y: tearOffY))
      drawContext.addLine(to: CGPoint(x: tabX, y: pageRect.height))
      drawContext.strokePath()
    }
    // 7
    drawContext.restoreGState()
  }
  
//  func drawContactLabels(_ drawContext: CGContext, pageRect: CGRect, numberTabs: Int) {
//    let contactTextFont = UIFont.systemFont(ofSize: 10.0, weight: .regular)
//    let paragraphStyle = NSMutableParagraphStyle()
//    paragraphStyle.alignment = .natural
//    paragraphStyle.lineBreakMode = .byWordWrapping
//    let contactBlurbAttributes = [
//      NSAttributedString.Key.paragraphStyle: paragraphStyle,
//      NSAttributedString.Key.font: contactTextFont
//    ]
//    let attributedContactText = NSMutableAttributedString(string: contactInfo, attributes: contactBlurbAttributes)
//    // 1
//    let textHeight = attributedContactText.size().height
//    let tabWidth = pageRect.width / CGFloat(numberTabs)
//    let horizontalOffset = (tabWidth - textHeight) / 2.0
//    drawContext.saveGState()
//    // 2
//    drawContext.rotate(by: -90.0 * CGFloat.pi / 180.0)
//    for tearOffIndex in 0...numberTabs {
//      let tabX = CGFloat(tearOffIndex) * tabWidth + horizontalOffset
//      // 3
//      attributedContactText.draw(at: CGPoint(x: -pageRect.height + 5.0, y: tabX))
//    }
//    drawContext.restoreGState()
//  }
}
