//
//  ExtensionUIImageVIew.swift
//  Training
//
//  Created by ManhLD on 1/6/20.
//  Copyright © 2020 ManhLD. All rights reserved.
//

import Foundation
import UIKit


var imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    public func roundCorners() {
        let maskPath1 = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}


