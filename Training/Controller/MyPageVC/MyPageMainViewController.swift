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
        if UserDefaults.standard.string(forKey: "userToken") != nil {
            handleMypage()
        } else {
             print("Not logged in")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    
    private func setUpView() {
        btnLoginUI.setTitle("Login".localized(using: "LaunchScreen"), for: .normal)
        btnLoginUI.roundedButton()
//        btnSignUpNow.setTitle("SignUpNow".localized(using: "LaunchScreen"), for: .normal)
//        lblMyPage.text = "MyPage".localized()
//        lblHaveToLogin.text = "HaveToLogin".localized(using: "LaunchScreen")
//        lblPleaseLogin.text = "PleaseLogin".localized(using: "LaunchScreen")
//        lblDontHaveAccount.text = "DontHaveAccount".localized(using: "LaunchScreen")
    }
    
    
    private func handleMypage() {
        let myPage = MyPageViewController()
        navigationController?.pushViewController(myPage, animated: true)
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
