//
//  EmailSignInView.swift
//  LoginDemo
//
//  Created by Tommy on 2021/1/23.
//

import Foundation
import UIKit

class EmailSignInView: UIView {
    
    var delegate: LoginViewController?
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func clickContinue(_ sender: Any) {
        print("click continue")
        
        
        // 建立storyboard物件
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let delegate = self.delegate else {
            return print("delegate is nil")
        }
        
        guard let email = emailTextField.text else {
            return print("email is nil")
        }
        
        if validateEmail(email: email) {
            // email格式符合
            let controller = storyboard.instantiateViewController(identifier: "\(EmailSignUpViewController.self)") as EmailSignUpViewController
            controller.email = email
            
            delegate.present(controller, animated: true, completion: {
                print("present success")
            })
        } else {
            // email格式不符
            delegate.showAleart(message: "Please enter a valid email address")
        }
    }
    
    // 驗證email
    func validateEmail(email: String) -> Bool {
        if email.count == 0 {
            return false
        }
        let emailPattern = "^([a-z0-9]+(?:[._-][a-z0-9]+)*)@([a-z0-9]+(?:[.-][a-z0-9]+)*\\.[a-z]{2,3})$"
        let emailRegular = try! NSRegularExpression(pattern: emailPattern, options: .caseInsensitive)
        let result = emailRegular.matches(in: email, range: NSMakeRange(0, (email as NSString).length))
        guard result.count > 0 else {
            return false
        }
        return true
    }

}

