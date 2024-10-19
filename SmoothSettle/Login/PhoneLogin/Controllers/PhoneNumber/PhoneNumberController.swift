import UIKit

class PhoneNumberController: PhoneNumberViewController {
    
    override func configurePhoneNumberContainerView() {
        super.configurePhoneNumberContainerView()
//        print("        super.configurePhoneNumberContainerView()")
        
        phoneNumberViewContainer.instructions.text = "Enter your phone number to login"
        phoneNumberViewContainer.terms.text = "Sign in with phone number indicates you agree to our Terms of Service and Privacy Policy"

        let attributes = [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().mainSubTitleColor]
        phoneNumberViewContainer.phoneNumber.attributedPlaceholder = NSAttributedString(string: "Phone number", attributes: attributes)
    }
    
    override func rightBarButtonDidTap() {
        super.rightBarButtonDidTap()
        
        let destination = VerificationController()
        destination.verificationContainerView.titleNumber.text = phoneNumberViewContainer.countryCode.text! + phoneNumberViewContainer.phoneNumber.text!
        navigationController?.pushViewController(destination, animated: true)
    }
}
