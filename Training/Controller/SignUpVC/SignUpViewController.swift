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
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpKeyBoardObservers()
        checkTextfiedToDisableButton()
    }
    
  
    
    override func viewDidAppear(_ animated: Bool) {
        nameView.center.x -= view.bounds.width
        passwordView.center.x -= view.bounds.width
        emailView.center.x -= view.bounds.width
        
        UIView.animate(withDuration: 0.6) {
            self.nameView.center.x += self.view.bounds.width
        }
        UIView.animate(withDuration: 0.7) {
            self.emailView.center.x += self.view.bounds.width
        }
        
        UIView.animate(withDuration: 0.8) {
            self.passwordView.center.x += self.view.bounds.width
        }
                  
    }
    
    
    // MARK: - Function setup view
    
    private func setUpView() {
        fullName.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        email.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        password.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        loading.handleLoading(isLoading: false)
        nameView.setUpBorderView()
        emailView.setUpBorderView()
        passwordView.setUpBorderView()
        uiBtn.roundedButton()
        fullName.delegate = self
        password.delegate = self
        email.delegate = self
        fullName.tag = 0
    }
    
    
  @objc func textFieldDidChange(sender: UITextField) {
        checkTextfiedToDisableButton()
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
            let myPageViewVC = MyPageViewController()
            navigationController?.pushViewController(myPageViewVC, animated: false)
        }
    }
    
    private func handleLoginView() {
        navigationController?.popViewController(animated: true)
    }
       
    
    
    // MARK: - Actions

    @IBAction func dismissKeyBoard(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        guard let mail = email.text , let name = fullName.text, let pass = password.text else { return }
        if ValidatedString.getInstance.isValidEmail(stringEmail: mail) == false {
            ToastView.shared.short(self.view, txt_msg: "alert.validEmail.text".localized)
        } else if ValidatedString.getInstance.isValidPassword(stringPassword: pass) == false {
            ToastView.shared.short(self.view, txt_msg: "alert.validPassword.text".localized)
        } else if email.text!.isEmpty || password.text!.isEmpty || fullName.text!.isEmpty {
            ToastView.shared.long(self.view, txt_msg: "alert.fillInfomation.text".localized)
        } else {
            loading.handleLoading(isLoading: true)
            RegisterAPI(email: mail, password: pass, fullname: name).excute(completionHandler: { [weak self] (response) in
                if response?.registerResponse.status == 1 {
                    self?.loading.handleLoading(isLoading: false)
                    self?.showAlert(message: "alert.registerSuccess".localized, titleBtn: "alert.titleBtn.OK".localized) {
                         self?.handleLoginView()
                    }
                } else {
                    self?.showAlert(message: response?.registerResponse.errorMessage ?? "", titleBtn: "alert.titleBtn.OK".localized) {
                        print(response?.registerResponse.errorMessage ?? "")
                        self?.loading.handleLoading(isLoading: false)
                    }
                }
            }) { (err) in
                self.showAlert(message: "alert.alert.connectFailed.text".localized, titleBtn: "alert.titleBtn.OK".localized) {
                    print(err ?? "")
                    self.loading.handleLoading(isLoading: false)
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
    
   
    
    private func checkTextfiedToDisableButton() {
        if email.text!.isEmpty || password.text!.isEmpty || fullName.text!.isEmpty {
            uiBtn.isEnabled = false
            if #available(iOS 13.0, *) {
                uiBtn.backgroundColor = UIColor.systemGray6
            } else {
                uiBtn.backgroundColor = UIColor.systemGray
            }
        } else {
            uiBtn.isEnabled = true
            uiBtn.backgroundColor = UIColor(rgb: 0x5D20CD)
        }
    }
}
