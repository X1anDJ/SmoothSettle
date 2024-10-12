//
//  AppDelegate.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/22.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    let mainViewController = MainViewController()
    let loginViewController = LoginViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        //Google sign-in instance and configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else { return false }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
//        window?.rootViewController = mainViewController
        
        
        
        loginViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: loginViewController)
        window?.rootViewController = navigationController
        
        if Auth.auth().currentUser == nil {
            window?.rootViewController = navigationController
            //window?.rootViewController = smsController
        } else {
            //window?.rootViewController = mainViewController
            window?.rootViewController = mainViewController
        }
        
        return true
    }


}

extension AppDelegate {
    func setRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard animated, let window = self.window else {
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
            return
        }
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
    //Google login
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

extension AppDelegate: LoginViewControllerDelegate {
    func didLogin() {
        setRootViewController(mainViewController)
    }
}


extension AppDelegate: LogoutDelegate {
    func didLogout() {
        do {
            try Auth.auth().signOut()
            let navigationController = UINavigationController(rootViewController: loginViewController)
            setRootViewController(navigationController)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
