import UIKit

class VerificationController: VerificationCodeViewController {
    
    weak var delegate: LoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRightBarButton(with: "Submit")
//        setLeftBarButton(with: "Back")
    }
    
    override func rightBarButtonDidTap() {
        super.rightBarButtonDidTap()
        authenticate()
    }
    
    override func leftBarButtonDidTap() {
        super.leftBarButtonDidTap()
        
        let destination = PhoneNumberViewController()
        navigationController?.pushViewController(destination, animated: true)
    }
    
    override func authenticate() {
        // Hide keyboard if necessary
        // verificationContainerView.verificationCode.resignFirstResponder()
        
        // Check for internet connectivity
        if currentReachabilityStatus == .notReachable {
            basicErrorAlertWith(title: "No internet connection", message: noInternetError, controller: self)
            return
        }
        
        // Get the verification code
        // let verificationCode = verificationContainerView.verificationCode.text!
        let verificationCode = verificationContainerView.fullVerificationCode
        
        // Verify the code using AuthManager
        AuthManager.shared.verifyCode(smsCode: verificationCode ) { [weak self] success in
            guard success else { return }
            // Phone log-in success!
            DispatchQueue.main.async {
                self?.delegate?.didLogin()  // Notify the delegate
            }
        }
    }
}
