//
//  TabbarViewController.swift
//  Training
//
//  Created by ManhLD on 12/18/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit



class TabbarViewController: UITabBarController {
    
    var isLoginVC = false
    private let userToken = UserDefaults.standard.string(forKey: "userToken")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitleTabbar()
        isLoginView()
    }
    
    
    private func setUpTitleTabbar() {
        tabBar.items![0].title = "header.label.text".localized
        tabBar.items![1].title = "near.title".localized
        tabBar.items![2].title = "categories.title".localized
        tabBar.items![3].title = "mypage.title".localized
    }
    
    
    private func isLoginView() {
        if isLoginVC == true {
            self.selectedIndex = 3
        } else {
            self.selectedIndex = 0
        }
    }
}
