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
    let isLAR: Bool
    let isAdditionalSign: Bool
    let additionalArrSign: [String]
    let pageCount: Int
    
    let pageWidth = 612.0
    let pageHeight = 792.0
    let pageRect = CGRect(x: 0, y: 0, width: 612.0, height: 792.0)
    let kPage = NSLocalizedStrings("Page", comment: "")
    let kof = NSLocalizedStrings("of", comment: "")
    
    init(title: String,
         body: String,
         image: UIImage,
         relation: String,
         participantFirstName: String,
         participantLastName: String,
         startTime: String,
         firstName: String,
         lastName: String,
         isLAR: Bool,
         isAdditionalSign: Bool,
         additionalArrSign: [String],
         pageCount: Int) { //
        self.title = title
        self.body = body
        self.image = image
        self.relation = relation
        self.participantFirstName = participantFirstName
        self.participantLastName = participantLastName
        self.startTime = startTime
        self.firstName = firstName
        self.lastName = lastName
        self.isLAR = isLAR
        self.isAdditionalSign = isAdditionalSign
        self.additionalArrSign = additionalArrSign
        self.pageCount = pageCount
    }
    
    func createFlyer() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "",
            kCGPDFContextAuthor: "",
            kCGPDFContextTitle: title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            
            context.beginPage()
            let context = context.cgContext
            
            let titleBottom = addTitle()
            var body1TextBottom = addBody1TextParagraph(textTop: titleBottom + 24.0)
            
            if isLAR {
                let body2TextBottom = addBody2TextSideBySide(textTop: body1TextBottom + 24.0,
                                                             title1: LocalizableString.consentLARParticipantFirstName2.localizedString,
                                                             title2: participantFirstName)
                let lastNameBottom = addBody2TextSideBySide(textTop: body2TextBottom + 12.0,
                                                            title1: LocalizableString.consentLARParticipantLastName2.localizedString,
                                                            title2: participantLastName)
                
                let signatureImageBottom = addImage(imageTop: lastNameBottom + 6.0, xValue: 15)
                
                drawLine(context, XValueStart: 10, top: signatureImageBottom + 5, xValueEnd: (CGFloat(1 * (pageWidth / 4)) + 10))
                _ = addBody1TextRegular(textTop: signatureImageBottom + 14.0, title: "(\(LocalizableString.consentLARParticipantSignature.localizedString))", xValue: 15)
                
                drawLine(context, XValueStart: 454, top: signatureImageBottom + 5, xValueEnd: CGFloat(pageWidth - 20))
                body1TextBottom = addBody1TextRegular(textTop: signatureImageBottom + 14.0, title: "(\(LocalizableString.consentLARParticipantDate.localizedString))", xValue: 556)
                _ = addBody1TextRegular(textTop: signatureImageBottom - 16, title: startTime, xValue: 522)
            }
            else {
                body1TextBottom += 104.0
            }
            
            let firstTextBottom = addBody1TextRegular(textTop: body1TextBottom + 22.0, title: isLAR ? firstName : "\(firstName) \(lastName)", xValue: 15)
            drawLine(context, XValueStart: 10, top: firstTextBottom + 5, xValueEnd: (CGFloat(1 * (pageWidth / 4)) + 10))
            _ = addBody1TextRegular(textTop: firstTextBottom + 14.0, title: isLAR ? "(\(LocalizableString.consentLARFirstName.localizedString))" : LocalizableString.consentAddSignParticipantName.localizedString, xValue: 15)
            
            if isLAR {
                _ = addBody1TextRegular(textTop: body1TextBottom + 22.0, title: lastName, xValue: (CGFloat(1.3 * (pageWidth / 4)) + 10))
            }
            else {
                _ = addImage(imageTop: firstTextBottom - 84.0, xValue: (CGFloat(1.3 * (pageWidth / 4)) + 10))
            }
            drawLine(context,
                     XValueStart: (CGFloat(1.3 * (pageWidth / 4)) + 10),
                     top: firstTextBottom + 5,
                     xValueEnd: (CGFloat(2.5 * (pageWidth / 4)) + 10))
            _ = addBody1TextRegular(textTop: firstTextBottom + 14.0, title: isLAR ? "(\(LocalizableString.consentLARLastName.localizedString))" : LocalizableString.consentAddSignParticipantSignature.localizedString, xValue: (CGFloat(1.3 * (pageWidth / 4)) + 10))
            
            _ = addBody1TextRegular(textTop: body1TextBottom + 22.0, title: isLAR ? relation : startTime, xValue: 454)
            drawLine(context, XValueStart: 454, top: firstTextBottom + 5, xValueEnd: CGFloat(pageWidth - 20))
            _ = addBody1TextRegular(textTop: firstTextBottom + 14.0, title:  isLAR ? "(\(LocalizableString.consentLARParticipantRelationship.localizedString))" : LocalizableString.consentLARParticipantDate.localizedString, xValue: isLAR ? 435 : 454)
            
            if isAdditionalSign {
                addSign(top: firstTextBottom, context: context)
            }
            
            drawPageNumber(pageCount, pageWidth: CGFloat(pageWidth), pageHeight: CGFloat(pageHeight))
        }
        
        return data
    }
    
    func addSign(top: CGFloat, context: CGContext) {
        let studyStaffSignatureBottom =
            addBody1TextBold(textTop: top + 56.0, title: LocalizableString.consentAddSignStudyStaffSignature.localizedString, xValue: 15)
        
        var topVal = studyStaffSignatureBottom
        let signatureArr = additionalArrSign
        
        for i in 1 ... signatureArr.count {
            topVal = helperAddMultipleSign(top: topVal, context: context, headerText: "- \(signatureArr[i - 1])")
        }
    }
    
    func helperAddMultipleSign(top: CGFloat, context: CGContext, headerText: String) -> CGFloat {
        let topValueForLater = addBody1TextBold(textTop: top + 12.0, title: headerText, xValue: 15)
        
        drawLine(context, XValueStart: 15, top: topValueForLater + 30, xValueEnd: 147)
        let bottomValue = addBody1TextRegular(textTop: topValueForLater + 34.0, title: "(\(LocalizableString.consentLARFirstName.localizedString))", xValue: 15)
        
        drawLine(context, XValueStart: 166, top: topValueForLater + 30, xValueEnd: 296)
        _ = addBody1TextRegular(textTop: topValueForLater + 34.0, title: "(\(LocalizableString.consentLARLastName.localizedString))", xValue: 166)
        
        drawLine(context, XValueStart: 315, top: topValueForLater + 30, xValueEnd: 445)
        _ = addBody1TextRegular(textTop: topValueForLater + 34.0, title: "(\(LocalizableString.consentLARParticipantSignature.localizedString))", xValue: 315)
        
        drawLine(context, XValueStart: 464, top: topValueForLater + 30, xValueEnd: 594)
        _ = addBody1TextRegular(textTop: topValueForLater + 34.0, title: "(\(LocalizableString.consentLARParticipantDate.localizedString))", xValue: 464)
        
        return bottomValue
    }
    
    func addTitle() -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 13.0, weight: .bold)
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
    
    func addBody1TextParagraph(textTop: CGFloat) -> CGFloat {
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
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
    
    func addBody2TextSideBySide(textTop: CGFloat, title1: String, title2: String) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        let titleFont2 = UIFont.systemFont(ofSize: 12.0, weight: .bold)
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
    
    func addBody1TextRegular(textTop: CGFloat, title: String, xValue: CGFloat) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
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
    
    func addBody1TextBold(textTop: CGFloat, title: String, xValue: CGFloat) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 12.0, weight: .bold)
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
    
    func addImage(imageTop: CGFloat, xValue: CGFloat) -> CGFloat {
        let scaledWidth = CGFloat(80)
        let scaledHeight = CGFloat(80)
        
        let imageRect = CGRect(x: xValue, y: imageTop,
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
    
    func drawPageNumber(_ pageNum: Int, pageWidth: CGFloat, pageHeight: CGFloat) {
        let theFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        let pageString = NSMutableAttributedString(string: "\(kPage) \(pageNum) \(kof) \(pageNum)")
        pageString.addAttribute(NSAttributedString.Key.font, value: theFont, range: NSRange(location: 0, length: pageString.length))
        
        let pageStringSize =  pageString.size()
        
        let stringRect = CGRect(x: (pageWidth - pageStringSize.width) / 2.0,
                                y: pageHeight - (pageStringSize.height) / 2.0 - 15,
                                width: pageStringSize.width,
                                height: pageStringSize.height)
        
        pageString.draw(in: stringRect)
        
    }
    
}
