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
