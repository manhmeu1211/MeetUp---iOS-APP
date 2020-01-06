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
    func roundCornersView(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
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
        layer.borderColor = UIColor.systemGray6.cgColor
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
    
    func setUpTabLayout(vc1 : UIViewController, vc2 : UIViewController, leftViewInput : UIView, rightViewInput : UIView) {
        let leftView = leftViewInput
        let rightView = rightViewInput
          let vc1 = vc1
          addChild(vc1)
          leftView.addSubview(vc1.view)
          vc1.view.frame = leftView.bounds
          vc1.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          vc1.didMove(toParent: self)
          let vc2 = vc2
          addChild(vc2)
          rightView.addSubview(vc2.view)
          vc2.view.frame = rightView.bounds
          vc2.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          vc2.didMove(toParent: self)
    }

}


extension UIImageView {
    public func roundCorners() {
        let maskPath1 = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}



