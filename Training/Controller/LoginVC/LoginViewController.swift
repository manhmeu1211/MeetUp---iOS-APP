//
//  LoginViewController.swift
//  Training
//
//  Created by ManhLD on 12/13/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var uiBtnLogin: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    private var alertLoginFailed = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpItemBar()
        setupView()
        checkTextfiedToDisableButton()
    }
    
    
    private func setupView() {
        txtEmail.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        txtPassword.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        loading.handleLoading(isLoading: false)
        uiBtnLogin.roundedButton()
        emailView.setUpBorderView()
        passwordView.setUpBorderView()
        uiBtnLogin.layoutIfNeeded()
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
          checkTextfiedToDisableButton()
      }
    
    private func setUpItemBar() {
        self.title = "login.title.text".localized
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "SignUp", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toRegister))
    }
    
    @objc func toRegister() {
        let regisVC = SignUpViewController()
        navigationController?.pushViewController(regisVC, animated: true)
    }

    private func handleForgotPass() {
        let resetPassVC = EventDetailV2Controller()
        present(resetPassVC, animated: true, completion: nil)
//        navigationController?.pushViewController(resetPassVC, animated: true)
    }
    
    private func handleMyPage() {
        let myPageVC = MyPageViewController()
        navigationController?.pushViewController(myPageVC, animated: true)
    }
    
    func isLoggedIn() -> Bool {
        return false
    }
    
    
    private func saveLogginRes(token : String) {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(token, forKey: "userToken")
        UserDefaults.standard.synchronize()
    }
    
    private func saveToken(token : String) {
          UserDefaults.standard.set(token, forKey: "userToken")
      }

    private func login() {
        loading.handleLoading(isLoading: true)
        guard let mail = txtEmail.text, let pass = txtPassword.text else { return }
        if txtEmail.text!.isEmpty || txtPassword.text!.isEmpty  {
            ToastView.shared.long(self.view, txt_msg: "alert.fillInfomation.text".localized)
            loading.handleLoading(isLoading: false)
        } else if ValidatedString.getInstance.isValidPassword(stringPassword: pass) == false {
            ToastView.shared.short(self.view, txt_msg: "Palert.validPassword.text".localized)
            txtPassword.text = ""
            loading.handleLoading(isLoading: false)
        } else if ValidatedString.getInstance.isValidEmail(stringEmail: mail) == false {
            ToastView.shared.short(self.view, txt_msg: "alert.validEmail.text".localized)
            txtEmail.text = ""
            loading.handleLoading(isLoading: false)
        } else {
            LoginAPI(email: mail, password: pass).excute(completionHandler: { [weak self] (response) in
                if response?.loginResponse.status == 1 {
                    let userToken = response?.userToken
                    self?.showAlert(message: "alert.loginSuccess".localized, titleBtn: "alert.titleBtn.OK".localized) {
                        self?.saveToken(token: userToken!)
                        self?.handleMyPage()
                    }
                } else {
                    self?.showAlert(message: "alert.wrongInfomation.text".localized, titleBtn: "alert.titleBtn.OK".localized) {
                        print("Login failed, wrong email or password ")
                    }
                }
            }) { (err) in
                self.showAlert(message: "alert.connectFailed.text".localized, titleBtn: "alert.titleBtn.OK".localized) {
                    print(err!)
                }
                self.loading.handleLoading(isLoading: false)
            }
        }
    }
    
    @IBAction func login(_ sender: Any) {
        login()
    }
    
  
    @IBAction func ignore(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func forgotPass(_ sender: Any) {
        handleForgotPass()
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
        containerView.endEditing(true)
    }
    
}

extension LoginViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        login()
        return true
    }
    
    
    private func checkTextfiedToDisableButton() {
        if txtEmail.text!.isEmpty || txtPassword.text!.isEmpty  {
            uiBtnLogin.isEnabled = false
            if #available(iOS 13.0, *) {
                uiBtnLogin.backgroundColor = UIColor.systemGray6
            } else {
                uiBtnLogin.backgroundColor = UIColor.systemGray
            }
        } else {
            uiBtnLogin.isEnabled = true
            uiBtnLogin.backgroundColor = UIColor(rgb: 0x5D20CD)
        }
    }
}




