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
    let participantFirstName: String
    let participantLastName: String
    let startTime: String
    let firstName: String
    let lastName: String
    
    init(title: String, body: String, image: UIImage, relation: String, participantFirstName: String, participantLastName: String, startTime: String, firstName: String, lastName: String) { //
        self.title = title
        self.body = body
        self.image = image
        self.relation = relation
        self.participantFirstName = participantFirstName
        self.participantLastName = participantLastName
        self.startTime = startTime
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
            let body2TextBottom = addBody2Text(pageRect: pageRect, textTop: body1TextBottom + 34.0, title1: "Participant first name:", title2: participantFirstName)
            let lastNameBottom = addBody2Text(pageRect: pageRect, textTop: body2TextBottom + 14.0, title1: "Participant last name:", title2: participantLastName)
            
            let signatureImageBottom = addImage(pageRect: pageRect, imageTop: lastNameBottom + 14.0)
            let context = context.cgContext
            drawLine(context, XValueStart: 10, top: signatureImageBottom + 5, xValueEnd: (CGFloat(1 * (pageWidth / 4)) + 10))
            let signatureTextBottom = addBody3Text(pageRect: pageRect, textTop: signatureImageBottom + 14.0, title: "(Signature)", xValue: 15)
            
            drawLine(context, XValueStart: 454, top: signatureImageBottom + 5, xValueEnd: CGFloat(pageWidth - 20))
            let dateHeaddingBottom = addBody3Text(pageRect: pageRect, textTop: signatureImageBottom + 14.0, title: "(Date)", xValue: 556)
            let dateTextBottom = addBody3Text(pageRect: pageRect, textTop: signatureImageBottom - 16, title: startTime, xValue: 522)
            //        print("pageWidth---\(pageWidth)---\(CGFloat(3 * (pageWidth / 4)) + 10)")
            
            
            let firstTextBottom = addBody3Text(pageRect: pageRect, textTop: dateHeaddingBottom + 14.0, title: firstName, xValue: 15)
            drawLine(context, XValueStart: 10, top: firstTextBottom + 5, xValueEnd: (CGFloat(1 * (pageWidth / 4)) + 10))
            let firstHeaddingTextBottom = addBody3Text(pageRect: pageRect, textTop: firstTextBottom + 14.0, title: "(First name)", xValue: 15)
            
            let lastTextBottom = addBody3Text(pageRect: pageRect, textTop: dateHeaddingBottom + 14.0, title: lastName, xValue: (CGFloat(1.3 * (pageWidth / 4)) + 10))
            drawLine(context, XValueStart: (CGFloat(1.3 * (pageWidth / 4)) + 10), top: firstTextBottom + 5, xValueEnd: (CGFloat(2.5 * (pageWidth / 4)) + 10))
            let lastHeaddingTextBottom = addBody3Text(pageRect: pageRect, textTop: firstTextBottom + 14.0, title: "(Last name)", xValue: (CGFloat(1.3 * (pageWidth / 4)) + 10))
            
            let relationshipTextBottom = addBody3Text(pageRect: pageRect, textTop: dateHeaddingBottom + 14.0, title: relation, xValue: 454)
            drawLine(context, XValueStart: 454, top: firstTextBottom + 5, xValueEnd: CGFloat(pageWidth - 20))
            let relationshipHeaddingTextBottom = addBody3Text(pageRect: pageRect, textTop: firstTextBottom + 14.0, title: "(Relationship to participant)", xValue: 435)
            
            
            //            let pageCountBottom = addBody3Text(pageRect: pageRect, textTop: firstTextBottom + 224.0, title: "Page 2 of 2", xValue: (CGFloat(1.5 * (pageWidth / 4)) + 10))
            
        }
        
        return data
    }
    
    func addTitle(pageRect: CGRect) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.font: titleFont]
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        let titleStringSize = attributedTitle.size()
        
        let titleStringRect = CGRect(x: 15,
                                     y: 36, width: titleStringSize.width,
                                     height: titleStringSize.height)
        
        attributedTitle.draw(in: titleStringRect)
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    func addBody1Text(pageRect: CGRect, textTop: CGFloat) -> CGFloat {
        let textFont = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]
        let attributedText = NSAttributedString(string: body, attributes: textAttributes)
        let textRect = CGRect(x: 15, y: textTop, width: pageRect.width - 20,
                              height: pageRect.height - textTop - pageRect.height / 5.0)
        attributedText.draw(in: textRect)
        
        let titleStringSize = attributedText.size()
        let titleStringRect = CGRect(x: 10,
                                     y: textTop , width: titleStringSize.width,
                                     height: titleStringSize.height)
        
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    func addBody2Text(pageRect: CGRect, textTop: CGFloat, title1: String, title2: String) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        let titleFont2 = UIFont.systemFont(ofSize: 13.0, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.font: titleFont]
        let attributedTitle1 = NSMutableAttributedString(string: title1, attributes: titleAttributes)
        
        let titleAttributes2: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.font: titleFont2]
        let attributedTitle2 = NSMutableAttributedString(string: title2, attributes: titleAttributes2)
        
        let attributedTitle: NSMutableAttributedString = attributedTitle1
        attributedTitle.append(attributedTitle2)
        
        let textRect = CGRect(x: 15, y: textTop, width: pageRect.width - 20,
                              height: pageRect.height - textTop - pageRect.height / 5.0)
        attributedTitle.draw(in: textRect)
        
        let titleStringSize = attributedTitle.size()
        let titleStringRect = CGRect(x: 15,
                                     y: textTop , width: titleStringSize.width,
                                     height: titleStringSize.height)
        
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    func addBody3Text(pageRect: CGRect, textTop: CGFloat, title: String, xValue: CGFloat) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        // 2
        let titleAttributes: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.font: titleFont]
        let attributedTitle = NSMutableAttributedString(string: title, attributes: titleAttributes)
        let textRect = CGRect(x: xValue, y: textTop, width: pageRect.width - 20,
                              height: pageRect.height - textTop - pageRect.height / 5.0)
        attributedTitle.draw(in: textRect)
        
        let titleStringSize = attributedTitle.size()
        let titleStringRect = CGRect(x: xValue,
                                     y: textTop , width: titleStringSize.width,
                                     height: titleStringSize.height)
        
        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    func addImage(pageRect: CGRect, imageTop: CGFloat) -> CGFloat {
        let scaledWidth = pageRect.width / 4 // image.size.width * aspectRatio
        let scaledHeight = pageRect.width / 4
        
        let imageRect = CGRect(x: 15, y: imageTop,
                               width: scaledWidth, height: scaledHeight) // / 4
        image.draw(in: imageRect)
        return imageRect.origin.y + imageRect.size.height
    }
    
    func drawLine(_ drawContext: CGContext, XValueStart: CGFloat, top: CGFloat, xValueEnd: CGFloat) {
        drawContext.saveGState()
        drawContext.setLineWidth(1.0)
        
        drawContext.move(to: CGPoint(x: XValueStart, y: top))
        drawContext.addLine(to: CGPoint(x: xValueEnd, y: top))
        drawContext.strokePath()
        drawContext.restoreGState()
    }
    
}
