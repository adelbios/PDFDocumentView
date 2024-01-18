//
//  DragButtonHandle.swift
//  CTS
//
//  Created by adel radwan on 06/10/2022.
//

import UIKit

class DragButtonHandle: UIButton {

    //MARK: - Variables
    private let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .medium)
    @Published private(set) var isConfirmActionFire: Bool?
    @Published private(set) var isDeleteActionFire: Bool?
    
    //MARK: - .Init
    required init(coder aDecoder: NSCoder) { fatalError() }
    
    init(color: UIColor, image: String) {
        super.init(frame:CGRect(x: 0, y: 0, width: diameter, height: diameter))
        self.setImage(UIImage(systemName: image, withConfiguration: config), for: .normal)
        self.tintColor = color
    }
    
}
