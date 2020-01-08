//
//  TabbarViewController.swift
//  Training
//
//  Created by ManhLD on 12/18/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit



class TabbarViewController: UITabBarController {
    // MARK: - Check index tabbar view
    var isLoginVC = false
    private let userToken = UserDefaults.standard.string(forKey: "userToken")
    override func viewDidLoad() {
        super.viewDidLoad()
        isLoginView()
        
    }
    private func isLoginView() {
        if isLoginVC == true {
            self.selectedIndex = 3
        } else {
            self.selectedIndex = 0
        }
    }

}
