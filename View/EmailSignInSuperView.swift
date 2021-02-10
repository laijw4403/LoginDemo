//
//  EmailSignInSuperView.swift
//  LoginDemo
//
//  Created by Tommy on 2021/1/24.
//

import Foundation
import UIKit

class EmailSignInSuperView: UIView {
    
    func addEmailSignInView() {
        if let emailSignInView = Bundle(for: EmailSignInView.self).loadNibNamed("\(EmailSignInView.self)", owner: nil, options: nil)?.first as? UIView {
            
            addSubview(emailSignInView)
            
            //emailSignInView.translatesAutoresizingMaskIntoConstraints = false
            //emailSignInView.centerXAnchor.constraint(equalTo: superview!.centerXAnchor).isActive = true
            
            // 讓EmailSignInView和storyboard上的EmailSignInSuperView元件一樣大
            emailSignInView.frame = bounds
            
        }
    }
    
    // 將在storyboard裡的EamilSignInView元件被載入時觸發
    override func awakeFromNib() {
        super.awakeFromNib()
        addEmailSignInView()
    }
}
