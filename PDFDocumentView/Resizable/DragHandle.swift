//
//  DragHandle.swift
//  Resizable
//
//  Created by Caroline on 7/09/2014.
//  Copyright (c) 2014 Caroline. All rights reserved.
//

let diameter:CGFloat = 50

import UIKit

class DragHandle: UIButton {
    
    //MARK: - Variables
    private var fillColor = UIColor.darkGray
    private var strokeColor = UIColor.lightGray
    private var strokeWidth: CGFloat = 2.0
    private let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
    
    //MARK: - UI Variables
    var rotateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    //MARK: - .Init
    required init(coder aDecoder: NSCoder) {
        fatalError("Use init(fillColor:, strokeColor:)")
    }
    
    init(fillColor: UIColor, strokeColor: UIColor, strokeWidth width: CGFloat = 2.0, image: String? = nil) {
        super.init(frame:CGRect(x: 0, y: 0, width: diameter, height: diameter))
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.strokeWidth = width
        self.backgroundColor = UIColor.clear
        self.rotateImageView.isHidden = image == nil
        guard let image else { return }
        self.rotateImageView.image = UIImage(systemName: image, withConfiguration: config)
        self.setupRotateImageView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let handlePath = UIBezierPath(ovalIn: rect.insetBy(dx: 10 + strokeWidth, dy: 10 + strokeWidth))
        fillColor.setFill()
        handlePath.fill()
        strokeColor.setStroke()
        handlePath.lineWidth = strokeWidth
        handlePath.stroke()
    }
    
    func setupRotateImageView() {
        rotateImageView.transform = .init(scaleX: 0.9, y: 0.9)
        addSubview(rotateImageView)
        rotateImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rotateImageView.topAnchor.constraint(equalTo: topAnchor),
            rotateImageView.rightAnchor.constraint(equalTo: rightAnchor),
            rotateImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rotateImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
}
