//
//  PDFCreator.swift
//  HPHC
//
//  Created by admin on 29/7/20.
//  Copyright © 2020 BTC. All rights reserved.
//

import UIKit
import PDFKit

class PDFCreator: NSObject {
  var title: String
  var body: String
  let image: UIImage
  let contactInfo: String
  
  init(title: String, body: String, image: UIImage, contact: String) {
    self.title = title
    self.body = body
    self.image = image
    self.contactInfo = contact
  }
  
  func createFlyer() -> Data {
    // 1
    let pdfMetaData = [
      kCGPDFContextCreator: "Flyer Builder",
      kCGPDFContextAuthor: "raywenderlich.com",
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
      let body2TextBottom = addBody2Text(pageRect: pageRect, textTop: body1TextBottom + 34.0)
      let imageBottom = addImage(pageRect: pageRect, imageTop: body2TextBottom + 18.0)
      
//      let context = context.cgContext
//      drawTearOffs(context, pageRect: pageRect, tearOffY: pageRect.height * 4.0 / 5.0, numberTabs: 8)
//      drawContactLabels(context, pageRect: pageRect, numberTabs: 8)
    }
    
    return data
  }
  
  func addTitle(pageRect: CGRect) -> CGFloat {
    title = "Consent by a Legally Authorized Representative"
    // 1
    let titleFont = UIFont.systemFont(ofSize: 20.0, weight: .bold)
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
    let textFont = UIFont.systemFont(ofSize: 17.0, weight: .regular)
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
  
  func addBody2Text(pageRect: CGRect, textTop: CGFloat) -> CGFloat {
    let title1 = "Participant first name:"
    let title2 = "John"
    // 1
    let titleFont = UIFont.systemFont(ofSize: 18.0, weight: .regular)
    let titleFont2 = UIFont.systemFont(ofSize: 18.0, weight: .bold)
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

  func addImage(pageRect: CGRect, imageTop: CGFloat) -> CGFloat {
    // 1
    let maxHeight = pageRect.height * 0.4
    let maxWidth = pageRect.width * 0.8
    // 2
    let aspectWidth = maxWidth / image.size.width
    let aspectHeight = maxHeight / image.size.height
    let aspectRatio = min(aspectWidth, aspectHeight)
    // 3
    let scaledWidth = image.size.width * aspectRatio
    let scaledHeight = image.size.height * aspectRatio
    // 4
    let imageX = (pageRect.width - scaledWidth) / 2.0
    let imageRect = CGRect(x: imageX, y: imageTop,
                           width: scaledWidth / 4, height: scaledHeight/4)
    // 5
    image.draw(in: imageRect)
    return imageRect.origin.y + imageRect.size.height
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
  
  func drawContactLabels(_ drawContext: CGContext, pageRect: CGRect, numberTabs: Int) {
    let contactTextFont = UIFont.systemFont(ofSize: 10.0, weight: .regular)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .natural
    paragraphStyle.lineBreakMode = .byWordWrapping
    let contactBlurbAttributes = [
      NSAttributedString.Key.paragraphStyle: paragraphStyle,
      NSAttributedString.Key.font: contactTextFont
    ]
    let attributedContactText = NSMutableAttributedString(string: contactInfo, attributes: contactBlurbAttributes)
    // 1
    let textHeight = attributedContactText.size().height
    let tabWidth = pageRect.width / CGFloat(numberTabs)
    let horizontalOffset = (tabWidth - textHeight) / 2.0
    drawContext.saveGState()
    // 2
    drawContext.rotate(by: -90.0 * CGFloat.pi / 180.0)
    for tearOffIndex in 0...numberTabs {
      let tabX = CGFloat(tearOffIndex) * tabWidth + horizontalOffset
      // 3
      attributedContactText.draw(at: CGPoint(x: -pageRect.height + 5.0, y: tabX))
    }
    drawContext.restoreGState()
  }
}
