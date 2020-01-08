//
//  MyPageViewController.swift
//  Training
//
//  Created by ManhLD on 12/16/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit


class MyPageViewController: UIViewController {

    @IBOutlet weak var uiBtnLogOut: UIButton!
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var incaditorLeading: NSLayoutConstraint!
    @IBOutlet weak var going: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    
    func setUpView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        let myPageGoingVC = MyPageGoingViewController()
        let myPageWentVC = MyPageWentViewController()
        setUpTabLayout(viewControllerLeft: myPageGoingVC, viewControllerRight: myPageWentVC, leftViewInput: leftView, rightViewInput: rightView)
    }
    
    
    func logOut() {
        deleteToken()
        navigationController?.popViewController(animated: true)
    }
       
    func deleteToken() {
        UserDefaults.standard.removeObject(forKey: "userToken")
    }

    @IBAction func goingBtn(_ sender: Any) {
         scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    
    @IBAction func wentBtn(_ sender: Any) {
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width , y: scrollView.contentOffset.y), animated: true)
    }
    
    @IBAction func logOut(_ sender: Any) {
        logOut()
    }
    
    @IBAction func backHome(_ sender: Any) {
        let tabbarController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as! TabbarViewController
        UIApplication.shared.windows.first?.rootViewController = tabbarController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    

}

extension MyPageViewController: UIScrollViewDelegate {
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


