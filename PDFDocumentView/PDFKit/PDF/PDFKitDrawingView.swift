//
//  ResizableContainerView.swift
//  PDFViewer
//
//  Created by adel radwan on 02/07/1445 AH.
//

import UIKit
import PencilKit
import PDFKit

class PDFKitDrawingView: UIView {
    
    enum ModeType {
        case signature
        case drawing
        case defualt
    }
    
    var pdf: PDFView?
    var page: PDFDocumentPage?
    
    lazy var resizable: ResizableView = {
        let v = ResizableView(frame: .init(x: 50, y: 150, width: 150, height: 130))
        v.backgroundColor = .clear
        v.delegate = self
        return v
    }()
    
    private lazy var addSignatureButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.init(systemName: "signature"), for: .normal)
        button.setTitle("إضافة توقيع", for: .normal)
        button.addTarget(self, action: #selector(didAddSignatureButtonClicked), for: .touchUpInside)
        button.alpha = 0.7
        return button
    }()
    
    var canvasView: PKCanvasView = {
        let view = PKCanvasView(frame: .zero)
        view.drawingPolicy = .anyInput
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        self.resizable.hide(withImage: true)
        var config = UIButton.Configuration.filled()
        config.titlePadding = 0
        config.imagePlacement = .top
        config.imagePadding = 0
        addSignatureButton.configuration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enable(mode: ModeType, image: ImageResource? = nil) {
        //        guard let pdf = self.pdf else { return }
        switch mode {
        case .signature:
            self.resizable.show()
            self.addSignatureButton.alpha = 0
            self.canvasView.isUserInteractionEnabled = false
        case .drawing:
            self.resizable.hide(withImage: false)
            self.canvasView.isUserInteractionEnabled = true
        case .defualt:
            //image == nil ? self.resizable.hide(withImage: true) : self.resizable.show()
            self.resizable.show()
            self.canvasView.isUserInteractionEnabled = false
            self.addSignatureButton.alpha = 1
        }
    }
    
    @objc private func didAddSignatureButtonClicked() {
        guard let page = self.page else { return }
//        print(page.pageRef?.pageNumber)
//        guard let pdfPage = currentPage as? PDFDocumentPage else { return }
//        if pdfPage.resizableContainerView == nil {
//            pdfPage.resizableContainerView?.page = pdfPage
//            pdfPage.resizableContainerView = overlay.pageToViewMapping[pdfPage]
//        }
//        guard let resView = pdfPage.resizableContainerView else { return }
        let img = ImageResource.sign1
        self.enable(mode: .signature, image: img)
        let pageRect = page.bounds(for: .mediaBox).maxY
        print(pageRect)
        self.resizable.set(image: img, pdf: pdf ?? PDFDocumentView(), yOffset: pageRect)
        
    }
    
}

//MARK: - Settings
private extension PDFKitDrawingView {
    
    func setupViews() {
        addSubview(canvasView)
        addSubview(resizable)
        addSubview(addSignatureButton)
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: topAnchor),
            canvasView.trailingAnchor.constraint(equalTo: trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: leadingAnchor),
            // addSignatureButton
            addSignatureButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            addSignatureButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            addSignatureButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
}

//MARK: - ResizableViewDelegate
extension PDFKitDrawingView: ResizableViewDelegate {
    
    func delete() {
        self.enable(mode: .defualt)
        self.resizable.set(image: nil, pdf: self.pdf ?? PDFView())
        self.resizable.hide(withImage: true)
        guard let page = (self.pdf?.currentPage as? PDFDocumentPage) else { return }
        let id = page.pageRef?.pageNumber ?? 0
        guard let currentAnnotation = page.annotations.first(where: { $0.stampName == "\(id)" }) else { return }
        page.removeAnnotation(currentAnnotation)
    }
    
    func didEndChanging(rect: CGRect?, rotate: RotateValue) {
    }
    
}
