//
//  LoginViewController.swift
//  LoginDemo
//
//  Created by Tommy on 2021/1/27.
//

import UIKit
import Foundation
import FBSDKLoginKit
import FacebookLogin
import GoogleSignIn
import OktaOidc

class LoginViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var emailSignInSuperView: EmailSignInSuperView!
    
    var googleSignInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotification()
        
        guard let emailSignInView = emailSignInSuperView.subviews.first as? EmailSignInView else {
            return print("emailSignInView is nil")
        }
        
        emailSignInView.delegate = self
        emailSignInView.emailTextField.delegate = self
        emailSignInView.emailTextField.keyboardType = .emailAddress
        
        // 建立tap, 點擊畫面時收起keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
        
        // 檢查FB使用者登入狀態
        if let token = AccessToken.current {
            print("FB User ID:\(token.userID), APP ID: \(token.appID)")
            //updateUI()
        } else {
            print("FB not login")
        }
        
        // FB Button
        //        let loginButton = FBLoginButton()
        //        loginButton.center = view.center
        //        view.addSubview(loginButton)
        
        
        // Let GIDSignIn know that this view controller is presenter of the sign-in sheet
        GIDSignIn.sharedInstance()?.presentingViewController = self
        // Register notification to update screen after user successfully signed in
        
        
    }
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        
        let contenInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contenInsets
        scrollView.scrollIndicatorInsets = contenInsets
    }
    
    @objc func keyboardWillBeHidden(_ notification: NSNotification) {
            let contentInsets = UIEdgeInsets.zero
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @IBAction func facebookLogIn(_ sender: UITapGestureRecognizer) {
        print("tap Continue with Facebook")
        let manager = LoginManager()
        
        // FB完成登入後，執行completion的closure程式，可由LoginResult的參數判斷登入結果，等於LoginResult.success時表示成功
        manager.logIn(permissions: [.email, .publicProfile]) { (result) in
            if case LoginResult.success(granted: _, declined: _, token: _) = result {
                print("login ok")
                self.showProfileTableView()
            } else {
                print("login fail")
            }
            //self.updateUI()
        }
    }
    
    @IBAction func googleLogIn(_ sender: UITapGestureRecognizer) {
        print("tap Continue with Google")
        GIDSignIn.sharedInstance()?.signIn()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidSignInGoogle(_:)),
                                               name: .signInGoogleCompleted,
                                               object: nil)
    }
    
    // MARK:- Notification
    @objc private func userDidSignInGoogle(_ notification: Notification) {
        // Update screen after user successfully signed in
        showProfileTableView()
    }
    

    
    // MARK: Test
    @IBAction func FBLogOut(_ sender: Any) {
        let manager = LoginManager()
        manager.logOut()
        print("Log Out")
        //updateUI()
    }
    
    @IBAction func GoogleLogOut(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
    }
    
    // Google Sign In
    @objc func googleSignInButtonTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
        
    }
    
    func googleLogInButton(){
        // Google Button
        googleSignInButton = UIButton()
        googleSignInButton.layer.cornerRadius = 10.0
        googleSignInButton.setTitle("Continue with Google", for: .normal)
        googleSignInButton.setTitleColor(.black, for: .normal)
        googleSignInButton.backgroundColor = .white
        googleSignInButton.addTarget(self, action: #selector(googleSignInButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(googleSignInButton)
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        googleSignInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        googleSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        googleSignInButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 離開responder
        return true
    }
}



