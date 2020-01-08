//
//  MyPageMainViewController.swift
//  Training
//
//  Created by ManhLD on 12/17/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import Localize_Swift

class MyPageMainViewController: UIViewController {

    @IBOutlet weak var btnLoginUI: UIButton!
    
    @IBOutlet weak var lblMyPage: UILabel!
    
    @IBOutlet weak var lblHaveToLogin: UILabel!
    
    @IBOutlet weak var lblPleaseLogin: UILabel!
    
    
    @IBOutlet weak var lblDontHaveAccount: UILabel!
    
    
    @IBOutlet weak var btnSignUpNow: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        if UserDefaults.standard.string(forKey: "userToken") != nil {
            handleMypage()
        } else {
            print("Not logged in".localized)
        }
    }
    
    
    private func setUpView() {
        btnLoginUI.roundedButton()
    }
    
    
    private func handleMypage() {
        let myPage = MyPageViewController()
        navigationController?.pushViewController(myPage, animated: false)
    }
    
    private func handleMainSignUp() {
        let mainSUp = SignUpMainViewController()
        navigationController?.pushViewController(mainSUp, animated: true)
    }
    
    @IBAction func signUpHandle(_ sender: Any) {
       handleMainSignUp()
    }

    @IBAction func loginHandle(_ sender: Any) {
        handleMainSignUp()
    }
}
