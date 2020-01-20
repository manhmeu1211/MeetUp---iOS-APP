//
//  CustomAlertViewController.swift
//  Training
//
//  Created by ManhLD on 1/3/20.
//  Copyright © 2020 ManhLD. All rights reserved.
//

import UIKit

class CustomAlertViewController: UIViewController {

    @IBOutlet weak var alertMessage: UILabel!
    @IBOutlet weak var btnAlert: UIButton!
    @IBOutlet weak var backgroundTitleView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var handle: (()-> Void)?
    var titleAlert: String?
    var titleBtn : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        view.addGestureRecognizer(tapGes)
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setUpView() {
        alertMessage.text = titleAlert!
        btnAlert.setTitle(titleBtn!, for: .normal)
        containerView.layer.cornerRadius = 10
        backgroundTitleView.layer.cornerRadius = 10
    }

    @IBAction func handleAlert(_ sender: Any) {
        handle?()
        dismissVC()
    }
    
}
