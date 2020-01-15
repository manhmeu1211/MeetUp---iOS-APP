//
//  Common.swift
//  Training
//
//  Created by ManhLD on 12/13/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func roundCornersView(radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners:  [.topLeft , .topRight], cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func setUpCardView() {
        layer.masksToBounds = false
        layer.cornerRadius = 3.0
        layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 1.0
        layer.borderWidth = 1.0
    }
    
    func setUpBorderView() {
        layer.masksToBounds = false
        layer.cornerRadius = 5.0
        layer.borderColor = UIColor(rgb: 0xF6F6F6).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2.0
        layer.borderWidth = 0.5
    }
    
    func setUpBGView() {
        layer.cornerRadius = frame.height / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
    

}

extension UIViewController {
    func showAlert(message : String, titleBtn : String, completion : @escaping () -> Void) {
        let alert = CustomAlertViewController()
        alert.modalPresentationStyle = .overCurrentContext
        alert.handle = {
            completion()
        }
        alert.titleAlert = message
        alert.titleBtn = titleBtn
        present(alert, animated: false, completion: nil)
    }
    
    func setUpTabLayout(viewControllerLeft : UIViewController, viewControllerRight : UIViewController, leftViewInput : UIView, rightViewInput : UIView) {
        let leftView = leftViewInput
        let rightView = rightViewInput
          let vcLeft = viewControllerLeft
          addChild(vcLeft)
          leftView.addSubview(vcLeft.view)
          vcLeft.view.frame = leftView.bounds
          vcLeft.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          vcLeft.didMove(toParent: self)
          let vcRight = viewControllerRight
          addChild(vcRight)
          rightView.addSubview(vcRight.view)
          vcRight.view.frame = rightView.bounds
          vcRight.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          vcRight.didMove(toParent: self)
    }

}

