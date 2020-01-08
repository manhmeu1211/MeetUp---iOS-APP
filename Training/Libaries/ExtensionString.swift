//
//  ExtensionString.swift
//  Training
//
//  Created by ManhLD on 1/6/20.
//  Copyright © 2020 ManhLD. All rights reserved.
//

import Foundation
import UIKit


extension String {
    var localized : String {
        return NSLocalizedString(self, comment: self)
    }
}


extension UILabel {
    @IBInspectable var localizeText: String {
        set(value) {
            self.text = NSLocalizedString(value, comment: "")
        }
        get {
            return ""
        }
    }
}

extension UIButton {
    @IBInspectable var localizeTitle: String {
        set(value) {
            self.setTitle(NSLocalizedString(value, comment: ""), for: .normal)
        }
        get {
            return ""
        }
    }
}

extension UITextField {
    @IBInspectable var localizePlaceholder: String {
        set(value) {
            self.placeholder = NSLocalizedString(value, comment: "")
        }
        get {
            return ""
        }
    }
}
