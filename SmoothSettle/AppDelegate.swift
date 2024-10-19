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

        // Google sign-in instance and configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else { return false }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground

        loginViewController.delegate = self
        let loginNavController = UINavigationController(rootViewController: loginViewController)

        if Auth.auth().currentUser == nil {
            window?.rootViewController = loginNavController
        } else {
            setupTabBarController()
        }
        TripRepository.shared.createMockData()
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

    // Google login
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

extension AppDelegate: LoginViewControllerDelegate {
    func didLogin() {
        setupTabBarController()
    }
}

extension AppDelegate: LogoutDelegate {
    func didLogout() {
        do {
            try Auth.auth().signOut()
            let loginNavController = UINavigationController(rootViewController: loginViewController)
            setRootViewController(loginNavController)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
import UIKit

extension AppDelegate {
    // Function to set up the UITabBarController with the main and archive view controllers
    private func setupTabBarController() {
        let tabBarController = UITabBarController()

        // MainViewController setup
        let mainViewController = MainViewController()
        let mainNavController = UINavigationController(rootViewController: mainViewController)
        mainViewController.tabBarItem = UITabBarItem(title: "Main", image: UIImage(systemName: "house.fill"), tag: 0)

        // ArchiveViewController setup
        let archiveViewController = ArchiveViewController()
        let archiveNavController = UINavigationController(rootViewController: archiveViewController)
        archiveViewController.tabBarItem = UITabBarItem(title: "Archive", image: UIImage(systemName: "archivebox.fill"), tag: 1)

        // Add view controllers to the tab bar
        tabBarController.viewControllers = [mainNavController, archiveNavController]

        // Set the appearance of the tab bar items
        tabBarController.tabBar.tintColor = Colors.primaryDark // Selected item color
        tabBarController.tabBar.unselectedItemTintColor = .systemGray3 // Unselected item color

        // Set up the shadow for the tab bar
        tabBarController.tabBar.backgroundColor = .systemBackground
        tabBarController.tabBar.layer.shadowColor = UIColor.systemGray.cgColor
        tabBarController.tabBar.layer.shadowOpacity = 0.1
        tabBarController.tabBar.layer.shadowOffset = CGSize(width: 0, height: -2) // Negative height to apply shadow above the tab bar
        tabBarController.tabBar.layer.shadowRadius = 4
        tabBarController.tabBar.layer.masksToBounds = false

        // Set the tab bar controller as the root view controller
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}
