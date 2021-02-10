//
//  SceneDelegate.swift
//  LoginDemo
//
//  Created by Tommy on 2021/1/17.
//

import UIKit
import FacebookCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let userInfo = UserInfo.readFile()
        if let sessionToken = userInfo?.sessionToken {
            if sessionToken.isEmpty {
                // No sessionToken will do...
                print("no user log in")
            } else {
                // Have sessionToken will do...
                print("user already log in")
                guard let profile = userInfo?.profile else { return }
                self.showProfileView(profile: profile)
            }
        }
    }
    
    // 顯示個人頁面
    func showProfileView(profile: Profile) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(identifier: "\(ProfileTableViewController.self)") as? ProfileTableViewController {
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .fullScreen // 設定present樣式
            controller.profile = profile
            self.window?.rootViewController = navController
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let context = URLContexts.first else {
            return
        }

        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: context.url,
            sourceApplication: context.options.sourceApplication,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}


