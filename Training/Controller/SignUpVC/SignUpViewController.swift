//
//  SignUpViewController.swift
//  Training
//
//  Created by ManhLD on 12/17/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var uiBtn: UIButton!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    
    private var alert = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpKeyBoardObservers()
    }
    
    
    // MARK: - Function setup view
    
    private func setUpView() {
        nameView.setUpBorderView()
        emailView.setUpBorderView()
        passwordView.setUpBorderView()
        uiBtn.roundedButton()
        alert.createAlertLoading(target: self, isShowLoading: false)
        fullName.delegate = self
        password.delegate = self
        email.delegate = self
        fullName.tag = 0
    }
    
    private func setUpKeyBoardObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleKeyBoardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleKeyBoardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyBoardShow(notification: Notification) {
        if view.frame.origin.y == 0 {
             view.frame.origin.y -= 50
        }
    }
    
    @objc func handleKeyBoardHide(notification : Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    
    private func handleLogged() {
        let token = UserDefaults.standard.string(forKey: "userToken")
           if token != nil {
               let vc = MyPageViewController()
               navigationController?.pushViewController(vc, animated: false)
           } else {
                      
           }
       }
    
    private func handleLoginView() {
        navigationController?.popToRootViewController(animated: true)
    }
       
    
    
    // MARK: - Actions

    @IBAction func dismissKeyBoard(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        alert.createAlertLoading(target: self, isShowLoading: true)
        guard let mail = email.text , let name = fullName.text, let pass = password.text else { return }
        if ValidatedString.getInstance.isValidEmail(stringEmail: mail) == false {
            ToastView.shared.short(self.view, txt_msg: "Email is not correct, Try again!")
            email.text = ""
            alert.createAlertLoading(target: self, isShowLoading: false)
        } else if ValidatedString.getInstance.isValidPassword(stringPassword: pass) == false {
                        ToastView.shared.short(self.view, txt_msg: "Password must be 6-16 character, Try again!")
                        password.text = ""
                        alert.createAlertLoading(target: self, isShowLoading: false)
        } else if email.text!.isEmpty || password.text!.isEmpty || fullName.text!.isEmpty {
                        ToastView.shared.long(self.view, txt_msg: "Please fill your infomation")
                        alert.createAlertLoading(target: self, isShowLoading: false)
        } else {
            let params = [
                "name": name,
                "email": mail,
                "password": pass
                ]
            let queue = DispatchQueue(label: "Register")
            queue.async {
                getDataService.getInstance.register(params: params) { (json, errcode) in
                    if errcode == 1 {
                        ToastView.shared.short(self.view, txt_msg: "Register Success")
                        self.handleLoginView()
                        self.alert.createAlertLoading(target: self, isShowLoading: false)
                    } else {
                        self.alert.createAlertLoading(target: self, isShowLoading: false)
                        ToastView.shared.short(self.view, txt_msg: "Register Failed, Check your network")
                    }
                }
            }
        }
    }
 
    @IBAction func btnIgnore(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}


extension SignUpViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fullName {
           email.becomeFirstResponder()
        }
        if textField == email {
           password.becomeFirstResponder()
        }
        if textField == password {
            view.endEditing(true)
        }
        return false
    }
    
}
