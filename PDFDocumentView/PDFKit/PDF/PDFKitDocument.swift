//
//  PDFKitDocument.swift
//  PDFDocumentView
//
//  Created by adel radwan on 05/07/1445 AH.
//

import UIKit
import PDFKit

class PDFKitDocument: UIDocument {
    
    var pdfDocument: PDFDocument?
    var pdf: PDFDocumentView
    
    enum MyPencilKitOverPDFDocumentError: Error {
        case open
    }
    
    init(fileURL url: URL, pdf: PDFDocumentView) {
        self.pdf = pdf
        super.init(fileURL: url)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let typeName = typeName else { throw MyPencilKitOverPDFDocumentError.open }
        self.load(typeName: typeName, contents: contents)
    }
    
    
    override func contents(forType typeName: String) throws -> Any {
        guard let pdfDocument = pdfDocument else { return Data() }
        for i in 0...pdfDocument.pageCount-1 {
            guard let page = pdfDocument.page(at: i) else { return Data() }
            addDrawingAnnottion(page)
            addSignatureAnnotaion(page)
        }
        
        let options = [PDFDocumentWriteOption.burnInAnnotationsOption: true]
        guard let resultData = pdfDocument.dataRepresentation(options: options) else { return Data() }
        return resultData
    }
    
}

//MARK: - Helper
extension PDFKitDocument {
    
    func load(typeName: String, contents: Any) {
        switch typeName {
        case "com.adobe.pdf":
            guard let data = contents as? Data else { self.pdfDocument = nil; return }
            self.pdfDocument = PDFDocument(data: data)
        default:
            print("loadFromContents: typeName : \(String(describing: typeName))")
        }
    }
    
    func addDrawingAnnottion(_ page: PDFPage) {
        if let page = (page as? PDFDocumentPage),
           let drawing = page.resizableContainerView?.canvasView.drawing {
            let mediaBoxBounds = page.bounds(for: .cropBox)
            let mediaBoxHeight = page.bounds(for: .cropBox).height
            let userDefinedAnnotationProperties = [DrawingAnnotation.pdfPageMediaBoxHeightKey:NSNumber(value: mediaBoxHeight)]
            let newAnnotation = DrawingAnnotation(
                bounds: mediaBoxBounds, forType: .stamp, withProperties: userDefinedAnnotationProperties
            )
            
            do {
                let codedData = try NSKeyedArchiver.archivedData(withRootObject: drawing, requiringSecureCoding: true)
                newAnnotation.setValue(codedData, forAnnotationKey: PDFAnnotationKey(rawValue: DrawingAnnotation.drawingDataKey))
            } catch {
                print("\(error.localizedDescription)")
            }

            page.addAnnotation(newAnnotation)
        }
    }
    
    func addSignatureAnnotaion(_ page: PDFPage) {
        guard let page = (page as? PDFDocumentPage) else { return }
        let pageRect = page.bounds(for: .cropBox)
        guard let image = page.resizableContainerView?.resizable.imageview.image else { return }
        guard let rotateValue = page.resizableContainerView?.resizable.annotationRotateValue else { return }
        guard let signatureRect = page.resizableContainerView?.resizable.annotationRect else { return }
        var locationOnPage = signatureRect
        let maxY = pageRect.maxY
        locationOnPage.origin.y = maxY - locationOnPage.origin.y - locationOnPage.size.height
        let finalPoint = CGPoint(x: locationOnPage.origin.x, y: locationOnPage.origin.y)
        let finalSize = CGSize(width: locationOnPage.width, height: locationOnPage.height)
        let finalRect: CGRect = .init(
            x: finalPoint.x, y: finalPoint.y, width: finalSize.width,
            height: finalSize.height
        )
        
        let id = page.pageRef?.pageNumber ?? 0
        let imageStamp = SignatureAnnotation(bounds: finalRect, image: image, name: "\(id)")
        imageStamp.rotateValue = rotateValue
        
        if let currentAnnotation = page.annotations.first(where: { $0.stampName == "\(id)" }) {
            page.removeAnnotation(currentAnnotation)
        }
        
        page.addAnnotation(imageStamp)
    }
    
}
