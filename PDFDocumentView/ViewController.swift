//
//  ViewController.swift
//  PDFDocumentView
//
//  Created by adel radwan on 03/07/1445 AH.
//

import UIKit
import PDFKit
import PencilKit

class ViewController: UIViewController {
    
    private var isDrawing: Bool = false
    
    
    private lazy var pdfView: PDFDocumentView = {
        let view = PDFDocumentView(frame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = Bundle.main.url(forResource: "adel", withExtension: "pdf") else { return }
        pdfView.loadPDF(url: url)
        view.addSubview(pdfView)
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.topAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    
    
    @IBAction func SaveButtonClicked(_ sender: Any) {
        pdfView.save()
    }
    
    @IBAction func AddImageSig1(_ sender: Any) {
        let img = ImageResource.sign1
        pdfView.signature(image: img)
    }
    
    @IBAction func AddImageSig2(_ sender: Any) {
        let img = ImageResource.sign2
        pdfView.signature(image: img)
    }
    
    
    @IBAction func ShareButtonClciekd(_ sender: Any) {
        isDrawing.toggle()
        pdfView.drawing(isEnable: isDrawing)
    }
    
}


