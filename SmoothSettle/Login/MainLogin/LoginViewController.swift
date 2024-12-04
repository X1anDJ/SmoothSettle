//
//  ViewController.swift
//  InventoryApp
//
//  Created by Dajun Xian on 2024/1/7.
//
import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

protocol LogoutDelegate: AnyObject {
    func didLogout()
}

protocol LoginViewControllerDelegate: AnyObject {
    func didLogin()
}

class LoginViewController: UIViewController {

    // New UIImageView for the icon
    let iconImageView = UIImageView()
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let phoneSignButton = UIButton(type: .system)
    let divider = DividerView()
    let authButtonsView = AuthenticationButtonsView()
    
    weak var delegate: LoginViewControllerDelegate?
//
//    var emailAddress: String? {
//        return loginView.emailTextField.text
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGoogleSignIn()
        style()
        layout()
        authButtonsView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        phoneSignButton.configuration?.showsActivityIndicator = false
    }
    
    private func setupGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
}

// MARK: Actions
extension LoginViewController : AuthenticationButtonsViewDelegate{
    

    @objc func phoneButtonTapped(sender: UIButton) {
        // Handle Phone sign-in
        print("phoneTapped")
        let phoneViewController = PhoneNumberViewController()
        phoneViewController.delegate = self.delegate
        self.navigationController?.pushViewController(phoneViewController, animated: true)
    }

    func googleSignInButtonTapped() {
        print("googleTapped")
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign-in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                // Handle error
                return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                // Handle error
                return
            }

            // Directly use the accessToken, as it's not optional
            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            // Authenticate with Firebase using the credential object
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    // Handle error
                    print("Auth failed")
                    return
                }
                // User is signed in
                self.delegate?.didLogin()
                print("Successful log-in LoginViewController")
            }
        }

    }



    func wechatSignInButtonTapped() {
        // Handle WeChat sign-in
    }

    func facebookSignInButtonTapped() {
        // Handle Facebook sign-in
    }

    func appleSignInButtonTapped() {
        // Handle Apple sign-in
    }
    
    private func login() {

    }
    
    private func configureView(withMessage message: String) {
        print(message)
    }
}

extension LoginViewController {
    
    private func style() {
        view.backgroundColor = Colors.background0
        
        // Style for iconImageView
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(named: "icon") // Ensure "icon" exists in your assets
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .white  // Adjust if your icon uses template rendering
                default:
                    return .black
            }
        }

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.preferredFont(forTextStyle: .extraLargeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.text = "Smooth Settle"
        titleLabel.textColor = Colors.primaryDark

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = "Simplify your transactions, smoothly"
        subtitleLabel.textColor = Colors.primaryDark

        phoneSignButton.translatesAutoresizingMaskIntoConstraints = false
        phoneSignButton.configuration = .filled()
        phoneSignButton.configuration?.imagePadding = 8 // for indicator spacing
        phoneSignButton.setTitle("Login with Phone", for: [])
        phoneSignButton.heightAnchor.constraint(equalToConstant: phoneSignButton.frame.height + 50).isActive = true
        phoneSignButton.layer.cornerRadius = 25
        phoneSignButton.clipsToBounds = true
        phoneSignButton.tintColor = Colors.primaryDark
        
        phoneSignButton.addTarget(self, action: #selector(phoneButtonTapped), for: .primaryActionTriggered)
        
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        authButtonsView.translatesAutoresizingMaskIntoConstraints = false

    }
    
    private func layout() {
        view.addSubview(iconImageView) // Add iconImageView to the view
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(phoneSignButton)
        view.addSubview(divider)
        view.addSubview(authButtonsView)
        // view.addSubview(errorMessageLabel)

        // Icon ImageView
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 250),  // Adjust width as needed
            iconImageView.heightAnchor.constraint(equalToConstant: 250)  // Adjust height as needed
        ])
        
        // Title
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: iconImageView.bottomAnchor, multiplier: 2),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Subtitle
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 3),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            // Removed centerX constraint to avoid conflicts
        ])
        
        // AuthButtonsView - Anchored to the bottom
        NSLayoutConstraint.activate([
            authButtonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            authButtonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authButtonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            authButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Divider - Above AuthButtonsView
        NSLayoutConstraint.activate([
            divider.bottomAnchor.constraint(equalTo: authButtonsView.topAnchor, constant: -20),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            divider.heightAnchor.constraint(equalToConstant: 20)
        ])

        // Phone Sign-In Button - Above Divider
        NSLayoutConstraint.activate([
            phoneSignButton.bottomAnchor.constraint(equalTo: divider.topAnchor, constant: -20),
            phoneSignButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneSignButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

    }

}
