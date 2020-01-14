//
//  ExtensionButton.swift
//  Training
//
//  Created by ManhLD on 1/3/20.
//  Copyright © 2020 ManhLD. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func setUpButton() {
          layer.borderWidth = 0.5
          layer.cornerRadius = 5
      }
    
    func roundedButton() {
        let maskPath1 = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 25, height: 25))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    @IBInspectable var localizeTitle: String {
        set(value) {
            self.setTitle(NSLocalizedString(value, comment: ""), for: .normal)
        }
        get {
            return ""
        }
    }
}


