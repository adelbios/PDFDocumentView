//
//  ex+.swift
//  SignPDF
//
//  Created by adel radwan on 31/10/2022.
//

import UIKit

extension CGAffineTransform {
    
    var radian: CGFloat {
        return atan2(b, a)
    }
    
    var angle: CGFloat {
        return radian * (180.0 / .pi)
    }
}

extension CGPoint {
    static func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let fx = (p1.x - p2.x)
        let fy = (p1.y - p2.y)
        
        return sqrt(fx*fx + fy*fy)
    }
}
