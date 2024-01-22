//
//  ResizableView.swift
//  Resizable
//
//  Created by Caroline on 6/09/2014.
//  Copyright (c) 2014 Caroline. All rights reserved.
//

import UIKit
import PDFKit

struct RotateValue {
    var angle: CGFloat
    var radian: CGFloat
}

//MARK: - Protocol
protocol ResizableViewDelegate: AnyObject {
    func delete()
    func didEndChanging(rect: CGRect?, rotate: RotateValue)
}

class ResizableView: UIView {
    //MARK: - Model
    struct ResizableViewAppearance {
        var rotateImage: String = "arrow.triangle.2.circlepath"
        var rotateImageTinitColor: UIColor = .greens
        var sidedDotBorderColor: UIColor = UIColor.greens.withAlphaComponent(0.3)
        var sidedDotColor: UIColor = .greens
        var dashedColor: UIColor = .lightGray
        var optionImage: String = "trash.fill"
        var optionColor: UIColor = .red
    }
    
    //MARK: - Variables
    weak var delegate: ResizableViewDelegate?
    private var previousLocation = CGPoint.zero
    private var location: CGPoint?
    private var rotateLine = CAShapeLayer()
    private(set) var annotationRotateValue: RotateValue?
    private(set) var annotationRect: CGRect?
    
    var appearance: ResizableViewAppearance = ResizableViewAppearance() {
        didSet {
            setAppearance()
        }
    }
    
    
    
    //MARK: - UI Variables
    var topLeft: DragHandle!
    var topRight: DragHandle!
    var bottomLeft: DragHandle!
    var bottomRight: DragHandle!
    private var rotateHandle: DragHandle!
    var borderView: ResizeBorder!
    private var optionButton: DragButtonHandle!
    private let minWidthHeight: CGFloat = 50
    
    var imageview: UIImageView = {
       let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.tintColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //MARK: - LifeCycle
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMoveToSuperview() {
        setAppearance()
        settings()
        setupViews()
        updateDragHandles()
        didConfirmAction()
        annotationRotateValue = .init(angle: 0, radian: 0)
    }
    
    func set(image: ImageResource?, pdf: PDFView, yOffset: CGFloat = 30) {
        let height: CGFloat = 130
        let y = yOffset == 0 ? 30 : yOffset - height - 30
        let signViewFrame = CGRect(x: 30, y: y, width: 150, height: height)
        self.frame = signViewFrame
        self.updateDragHandles()
        self.annotationRect = signViewFrame
        self.annotationRotateValue = .init(angle: 0, radian: 0)
        self.delegate?.didEndChanging(
            rect: image == nil ? .zero : signViewFrame,
            rotate: annotationRotateValue ?? .init(angle: 0, radian: 0)
        )
        self.imageview.image = image == nil ? nil : UIImage(resource: image!)
    }
    
    func setImage(data: Data?, pdf: PDFDocumentView) {
        let signViewFrame = CGRect(x: 30, y: 30, width: 150, height: 130)
        self.frame = signViewFrame
        self.updateDragHandles()
        self.annotationRect = signViewFrame
        self.annotationRotateValue = .init(angle: 0, radian: 0)
        self.delegate?.didEndChanging(
            rect: data == nil ? .zero : signViewFrame,
            rotate: annotationRotateValue ?? .init(angle: 0, radian: 0)
        )
                
        self.imageview.image = data == nil ? nil : UIImage(data: data!)
    }
    
}

//MARK: - Settings
private extension ResizableView {
    
    func settings() {
        rotateLine.opacity = 0.0
        rotateLine.lineDashPattern = [3,2]
        
        var pan = UIPanGestureRecognizer(target: self, action: #selector(ResizableView.handlePan(_:)))
        topLeft.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(ResizableView.handlePan(_:)))
        topRight.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(ResizableView.handlePan(_:)))
        bottomLeft.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(ResizableView.handlePan(_:)))
        bottomRight.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(ResizableView.handleRotate(_:)))
        rotateHandle.addGestureRecognizer(pan)
        pan = UIPanGestureRecognizer(target: self, action: #selector(ResizableView.handleMove(_:)))
        self.addGestureRecognizer(pan)
        
    }
    
    func setAppearance() {
        let resizeFillColor = appearance.sidedDotColor
        let resizeStrokeColor = appearance.sidedDotBorderColor
        topLeft = DragHandle(fillColor: resizeFillColor, strokeColor: resizeStrokeColor)
        topRight = DragHandle(fillColor: resizeFillColor, strokeColor: resizeStrokeColor)
        bottomLeft = DragHandle(fillColor: resizeFillColor, strokeColor: resizeStrokeColor)
        bottomRight = DragHandle(fillColor: resizeFillColor, strokeColor: resizeStrokeColor)
        rotateHandle = DragHandle(fillColor: .clear, strokeColor: .clear, image: appearance.rotateImage)
        optionButton = DragButtonHandle(color: appearance.optionColor, image: appearance.optionImage)
        rotateHandle.rotateImageView.tintColor = appearance.rotateImageTinitColor
        //TODO: - Enable This Line 
//        enablePointersFor(buttons: [optionButton, rotateHandle, topLeft, topRight, bottomLeft, bottomRight])
    }
    
    func minimize(_ views: [UIView]) {
        views.forEach {
            $0.transform = .init(scaleX: 0.8, y: 0.8)
        }
    }
    
    func setupViews() {
        borderView = ResizeBorder(frame:self.bounds)
        borderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(borderView)
        self.addSubview(imageview)
        superview?.addSubview(topLeft)
        superview?.addSubview(topRight)
        superview?.addSubview(bottomLeft)
        superview?.addSubview(bottomRight)
        superview?.addSubview(rotateHandle)
        superview?.addSubview(optionButton)
        self.layer.addSublayer(rotateLine)
        NSLayoutConstraint.activate([
            imageview.topAnchor.constraint(equalTo: topAnchor),
            imageview.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageview.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageview.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
        
    }
    
}

//MARK: - Events
 extension ResizableView {
     
     @objc func confirmDeleting() {
         DispatchQueue.main.async { [weak self] in
             guard let self = self else { return }
             self.delete()
         }
     }
    
    func didConfirmAction() {
        optionButton.addTarget(self, action: #selector(confirmDeleting), for: .touchUpInside)
    }
    
    func updateDragHandles() {
        topLeft.center = self.transformedTopLeft()
        topRight.center = self.transformedTopRight()
        bottomLeft.center = self.transformedBottomLeft()
        bottomRight.center = self.transformedBottomRight()
        rotateHandle.center = self.transformedRotateHandle()
        optionButton.center = self.transformedOptionHandle()
        borderView.bounds = self.bounds
        borderView.setNeedsDisplay()
    }
    
}



//MARK: - Rotate
private extension ResizableView {
    
    @objc func handleRotate(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            previousLocation = rotateHandle.center
            self.drawRotateLine(CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2), toPoint:CGPoint(x: self.bounds.size.width + diameter, y: self.bounds.size.height/2))
        case .ended:
            self.rotateLine.opacity = 0.0
            self.delegate?.didEndChanging(rect: annotationRect, rotate: annotationRotateValue ?? .init(angle: 0, radian: 0))
        case .changed:
            let location = sender.location(in: self.superview!)
            let angle = angleBetweenPoints(previousLocation, endPoint: location)
            self.transform = self.transform.rotated(by: angle)
            previousLocation = location
            
            
            let x = center.x - bounds.width/2.0
            let y = center.y - bounds.height/2.0
            let finalPoint = CGPoint(x: x, y: y)
            self.annotationRect = .init(origin: finalPoint, size: bounds.size)
            self.annotationRotateValue = .init(angle: self.transform.angle, radian: self.transform.radian)
            updateDragHandles()
            
        default:()
        }
    }
    
}

//MARK: - Scaled
private extension ResizableView {
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        switch gesture.view! {
        case topLeft:
            if gesture.state == .began {
                self.setAnchorPoint(CGPoint(x: 1, y: 1))
            }
            
            self.bounds.size.width -= translation.x
            self.bounds.size.height -= translation.y
            setResize(x: center.x - self.bounds.width, y: center.y - self.bounds.height, gesture: gesture)            
            
        case topRight:
            if gesture.state == .began {
                self.setAnchorPoint(CGPoint(x: 0, y: 1))
            }
            
            self.bounds.size.width += translation.x
            self.bounds.size.height -= translation.y
            setResize(x: center.x, y: center.y - self.bounds.height, gesture: gesture)
            
        case bottomLeft:
            if gesture.state == .began {
                self.setAnchorPoint(CGPoint(x: 1, y: 0))
            }
            self.bounds.size.width -= translation.x
            self.bounds.size.height += translation.y
            setResize(x: center.x - self.bounds.size.width, y: center.y, gesture: gesture)
            
            
        case bottomRight:
            if gesture.state == .began {
                self.setAnchorPoint(CGPoint.zero)
            }

            self.bounds.size.width += translation.x
            self.bounds.size.height += translation.y
            setResize(x: center.x, y: center.y, gesture: gesture)
            
            
        default:()
        }
        
        gesture.setTranslation(CGPoint.zero, in: self)
        updateDragHandles()
        
        if gesture.state == .ended {
            self.setAnchorPoint(CGPoint(x: 0.5, y: 0.5))
            self.setViewMovedUsing(gesture)
            self.delegate?.didEndChanging(rect: annotationRect, rotate: annotationRotateValue ?? .init(angle: 0, radian: 0))
        }
        
        
    }
    
    private func setResize(x: CGFloat, y: CGFloat, gesture: UIPanGestureRecognizer) {
        self.annotationRect = .init(x: x , y: y, width: bounds.size.width, height: bounds.size.height)
    }
    
}

//MARK: - Move
 extension ResizableView {
    
    @objc func handleMove(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
        } else if sender.state == .changed {
            setViewMovedUsing(sender)
        }else if sender.state == .ended {
            self.delegate?.didEndChanging(rect: annotationRect, rotate:  annotationRotateValue ?? .init(angle: 0, radian: 0))
        }
        updateDragHandles()
    }
    
    func setViewMovedUsing(_ sender: UIPanGestureRecognizer) {
        var shockX: CGFloat = 0
        var shockY: CGFloat = 0
        
        shockX = super.center.x
        shockY = super.center.y
        
        let point = sender.translation(in: superview)
        shockX += point.x
        shockY += point.y
        let annotationSize = annotationRect?.size ?? .zero
        
//        print("shockY = \(shockY)")
        let dotSize = bottomLeft.frame.height - 5
//        let maxYBounds = min(max(shockY, 100), pageSize.height - annotationSize.height + dotSize)
//        min(shockX, (size.width - 100))
        let centerPoint = CGPoint(x: shockX, y: shockY)
        self.center = centerPoint
        sender.setTranslation(.zero, in: superview)
        let x = center.x - bounds.width/2.0
        let y = center.y - bounds.height/2.0
        let finalPoint = CGPoint(x: x, y: y)
        self.annotationRect = .init(origin: finalPoint, size: bounds.size)
        
    }
    
}

//MARK: - GestureRecognizer Helper
private extension ResizableView {
    
    func angleBetweenPoints(_ startPoint:CGPoint, endPoint:CGPoint)  -> CGFloat {
        let a = startPoint.x - self.center.x
        let b = startPoint.y - self.center.y
        let c = endPoint.x - self.center.x
        let d = endPoint.y - self.center.y
        let atanA = atan2(a, b)
        let atanB = atan2(c, d)
        return atanA - atanB
        
    }
    
    func drawRotateLine(_ fromPoint:CGPoint, toPoint:CGPoint) {
        let linePath = UIBezierPath()
        linePath.move(to: fromPoint)
        linePath.addLine(to: toPoint)
        rotateLine.path = linePath.cgPath
        rotateLine.fillColor = nil
        rotateLine.strokeColor = UIColor.orange.cgColor
        rotateLine.lineWidth = 2.0
        rotateLine.opacity = 1.0
    }
    
}

//MARK: - show
 extension ResizableView {
    
    func show() {
        set(show: true, hideImage: false)
    }
    
     func hide(withImage: Bool) {
         set(show: false, hideImage: withImage)
    }
     
     func delete() {
         self.hide(withImage: true)
         self.delegate?.delete()
     }
    
     private func set(show: Bool, hideImage: Bool) {
         topLeft.alpha = show ? 1 : 0
         topRight.alpha = show ? 1 : 0
         bottomLeft.alpha = show ? 1 : 0
         bottomRight.alpha = show ? 1 : 0
         rotateHandle.alpha = show ? 1 : 0
         optionButton.alpha = show ? 1 : 0
         borderView.alpha = show ? 1 : 0
         imageview.alpha = hideImage ? 0 : 1
     }
    
}
