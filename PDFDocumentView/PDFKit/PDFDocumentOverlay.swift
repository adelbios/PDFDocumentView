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
            resultView?.pdf = view
            resultView = overlayView
        } else {
            let canvasView = PDFKitDrawingView(frame: .zero)
            canvasView.backgroundColor = UIColor.clear
            self.pageToViewMapping[page] = canvasView
            resultView = canvasView
            resultView?.pdf = view
        }
        
      
        if let container = page.resizableContainerView {
            resultView?.resizable = container.resizable
            resultView?.pdf = view
            page.resizableContainerView = resultView
        }
        
        if let drawing = page.resizableContainerView?.canvasView.drawing {
            resultView?.canvasView.drawing = drawing
            resultView?.pdf = view
            page.resizableContainerView = resultView
        }
        
        resultView?.pdf = view
        
        return resultView
        
    }
    
    func pdfView(_ pdfView: PDFView, willDisplayOverlayView overlayView: UIView, for page: PDFPage) {
    }
    
    func pdfView(_ pdfView: PDFView, willEndDisplayingOverlayView overlayView: UIView, for page: PDFPage) {
    }
    
}
