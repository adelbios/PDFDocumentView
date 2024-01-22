//
//  PDFDocumentOverlay.swift
//  PDFDocumentView
//
//  Created by adel radwan on 05/07/1445 AH.
//

import UIKit
import PDFKit

class PDFDocumentOverlay: NSObject, PDFPageOverlayViewProvider {
    
    var pageToViewMapping = [PDFDocumentPage: PDFKitDrawingView]()
    
    func pdfView(_ view: PDFView, overlayViewFor page: PDFPage) -> UIView? {
        var resultView: PDFKitDrawingView? = nil
        guard let page = page as? PDFDocumentPage else { return nil }
        
        if let overlayView = self.pageToViewMapping[page] {
            overlayView.page = page
            resultView = overlayView
        } else {
            let canvasView = PDFKitDrawingView(frame: .zero)
            canvasView.backgroundColor = UIColor.clear
            canvasView.page = page
            self.pageToViewMapping[page] = canvasView
            resultView = canvasView
        }
        
      
        if let container = page.resizableContainerView {
            resultView?.resizable = container.resizable
            resultView?.canvasView.drawing = container.canvasView.drawing
            resultView?.page = page
            page.resizableContainerView = resultView
        }
        
//        if let drawing = page.resizableContainerView?.canvasView.drawing {
//            resultView?.canvasView.drawing = drawing
//            resultView?.pdf = view
//            page.resizableContainerView = resultView
//        }
        
//        resultView?.pdf = view
        
        return resultView
        
    }
    
    func pdfView(_ pdfView: PDFView, willDisplayOverlayView overlayView: UIView, for page: PDFPage) {
    }
    
    func pdfView(_ pdfView: PDFView, willEndDisplayingOverlayView overlayView: UIView, for page: PDFPage) {
//        let overlayView = overlayView as! PDFKitDrawingView
//        let page = page as! PDFDocumentPage
//        page.resizableContainerView?.resizable.imageview = overlayView.resizable.imageview
//        pageToViewMapping.removeValue(forKey: page)
    }
    
}
