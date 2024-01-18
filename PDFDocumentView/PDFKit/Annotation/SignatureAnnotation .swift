//
//  SignatureAnnotation .swift
//  PDFDocumentView
//
//  Created by adel radwan on 05/07/1445 AH.
//

import UIKit
import PDFKit

class SignatureAnnotation: PDFAnnotation {
    
    
    private let image: UIImage
    
    var rotateValue: RotateValue = .init(angle: 0, radian: 0) {
        didSet {
            shouldDisplay = true
        }
    }
    
    //MARK: - LifeCycle
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public init(bounds: CGRect, image: UIImage, name: String) {
        self.image = image
        super.init(bounds: bounds, forType: .stamp, withProperties: nil)
        self.modificationDate = Date()
        self.stampName = name
    }

    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        drawAnnotation(box: box, context: context)
    }
    
}

//MARK: - Helper
private extension SignatureAnnotation {
    
    func drawAnnotation(box: PDFDisplayBox, context: CGContext) {
        UIGraphicsPushContext(context)
        context.saveGState()
        
        let pageBounds = page!.bounds(for: box)
        context.translateBy(x: -pageBounds.origin.x, y: -pageBounds.origin.y)
        let translateX = bounds.width/2 + bounds.origin.x
        let translateY = bounds.height/2 + bounds.origin.y
        context.translateBy(x: translateX, y: translateY)
        context.rotate(by: -rotateValue.radian)
        context.translateBy(x: -translateX, y: -translateY)
        drawImage(context: context)
        context.restoreGState()
        UIGraphicsPopContext()
    }
    
    
    func drawImage(context: CGContext) {
        guard let cgImage = self.image.cgImage else { return }
        let point = CGPoint(x: bounds.origin.x, y: bounds.origin.y)
        let size = CGSize(width: bounds.width, height: bounds.height)
        let rect = CGRect(x: point.x, y: point.y, width: size.width, height: size.height)
        context.draw(cgImage, in: rect)
    }
    
}
