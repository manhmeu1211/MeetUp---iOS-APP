//
//  SignUpMainViewController.swift
//  Training
//
//  Created by ManhLD on 12/17/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit

class SignUpMainViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var incaditor: UIView!
    @IBOutlet weak var incaditorLeading: NSLayoutConstraint!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    var isLoginView : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLoginView()
    }
    
    
    private func checkLoginView() {
        if isLoginView {
            scrollView.setContentOffset(CGPoint(x: scrollView.frame.width , y: scrollView.contentOffset.y), animated: true)
        } else {

            scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        }
    }
    
    // MARK: - Function setup views
    
    private func setUpView() {
        tabBarController?.tabBar.isHidden = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        let loginVC = LoginViewController()
        let signUpVC = SignUpViewController()
        setUpTabLayout(viewControllerLeft: signUpVC, viewControllerRight: loginVC, leftViewInput: leftView, rightViewInput: rightView)
    }
    
    // MARK: - Actions
 
    @IBAction func loginBtn(_ sender: Any) {
         scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    
    
    @IBAction func signUpBtn(_ sender: Any) {
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width , y: scrollView.contentOffset.y), animated: true)
    }
    
}

// MARK: - Extension scrollview

extension SignUpMainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        incaditorLeading.constant = scrollView.contentOffset.x / 2
        if scrollView.contentOffset.x >= scrollView.bounds.width / 2 {
            if scrollView.contentOffset.x == scrollView.bounds.width {
                scrollView.setContentOffset(CGPoint(x: scrollView.bounds.width , y: scrollView.contentOffset.y), animated: false)
            }
        } else {
            if scrollView.contentOffset.x == 0 {
                scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
                scrollView.endEditing(true)
            }
        }
    }
}
