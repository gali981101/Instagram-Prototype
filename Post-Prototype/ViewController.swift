//
//  ViewController.swift
//  Post-Prototype
//
//  Created by Terry Jason on 2023/8/7.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func logInClicked(_ sender: Any) {
        authUserData(registered: true)
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        authUserData(registered: false)
    }
    
}

// MARK: Auth Func

extension ViewController {
    
    private func authUserData(registered: Bool) {
        if emailText.text != "" && passwordText.text != "" {
            processUserState(registered: registered)
        } else {
            alertMessage()
        }
    }
    
    private func processUserState(registered: Bool) {
        if registered {
            userLogIn()
        } else {
            createUser()
        }
    }
    
    private func userLogIn() {
        Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { [self] result, error in
            failOrSuccess(error: error)
        }
    }
    
    private func createUser() {
        Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { [self] result, error in
            failOrSuccess(error: error)
        }
    }
    
    private func alertMessage() {
        makeAlert(title: "Error", message: "請填入正確郵件地址與密碼", self: self)
    }
    
    private func failOrSuccess(error: Error?) {
        if error != nil {
            authError(error: error)
        } else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nav = storyBoard.instantiateViewController(withIdentifier: "homeVC") as! UINavigationController
            
            nav.modalPresentationStyle = .fullScreen
            
            self.present(nav, animated: true)
        }
    }
    
    private func authError(error: Error?) {
        makeAlert(title: "Auth Failed", message: error?.localizedDescription ?? "註冊驗證失敗", self: self)
    }
    
}


