//
//  UIViewController+Extensions.swift
//  LoginDemo
//
//  Created by Tommy on 2021/1/28.
//

import Foundation
import UIKit

extension UIViewController {
    func showAleart(message: String) {
        print(message)
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showProfileTableView() {
        if let controller = self.storyboard?.instantiateViewController(identifier: "\(ProfileTableViewController.self)") as? ProfileTableViewController {
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .fullScreen // 設定present樣式
            self.present(navController, animated: true, completion: nil)
        }
    }
}
