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
    
    private var holderView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
        
    lazy var resizable: ResizableView = {
        let v = ResizableView(frame: .init(x: 30, y: 30, width: 150, height: 130))
        v.backgroundColor = .clear
        v.delegate = self
        return v
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enable(mode: ModeType, image: ImageResource? = nil) {
        guard let pdf = self.pdf else { return }
        switch mode {
        case .signature:
            self.resizable.set(image: image, pdf: pdf)
            self.resizable.show()
            self.canvasView.isUserInteractionEnabled = false
        case .drawing:
            self.resizable.hide(withImage: false)
            self.canvasView.isUserInteractionEnabled = true
        case .defualt:
            //image == nil ? self.resizable.hide(withImage: true) : self.resizable.show()
            self.resizable.show()
            self.canvasView.isUserInteractionEnabled = false
        }
    }
    
}

//MARK: - Settings
private extension PDFKitDrawingView {
    
    func setupViews() {
        addSubview(holderView)
        addSubview(canvasView)
        addSubview(resizable)
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: topAnchor),
            canvasView.trailingAnchor.constraint(equalTo: trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            holderView.topAnchor.constraint(equalTo: topAnchor),
            holderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            holderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            holderView.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
    }

}

extension PDFKitDrawingView: ResizableViewDelegate {
    
    func delete() {
        self.enable(mode: .defualt)
        self.resizable.set(image: nil, pdf: self.pdf ?? PDFView())
        self.resizable.hide(withImage: true)
    }
    
    func didEndChanging(rect: CGRect?, rotate: RotateValue) {
    }
    
    
}
