import UIKit

class PhoneNumberViewContainer: UIView {
    
    let title: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .center
        title.text = "Phone Number"
        title.textColor = .label
        title.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        title.sizeToFit()
        
        return title
    }()
    
    let instructions: UILabel = {
        let instructions = UILabel()
        instructions.translatesAutoresizingMaskIntoConstraints = false
        instructions.textAlignment = .center
        instructions.text = "Enter your phone number to login"
        instructions.numberOfLines = 2
        instructions.textColor = .tertiaryLabel
        instructions.font = UIFont.systemFont(ofSize: 18)
        instructions.sizeToFit()
        
        return instructions
    }()
    
    let terms: UILabel = {
        let terms = UILabel()
        terms.translatesAutoresizingMaskIntoConstraints = false
        terms.textAlignment = .left
        terms.text = "Login with phone number indicates you agree to our Terms of Service and Privacy Policy"
        terms.numberOfLines = 5
        terms.textColor = .tertiaryLabel
        terms.font = UIFont.systemFont(ofSize: 14)
        terms.sizeToFit()
        
        return terms
    }()
    
    let selectCountry: UIButton = {
        let selectCountry = UIButton()
        selectCountry.translatesAutoresizingMaskIntoConstraints = false
        selectCountry.setTitle("United States", for: .normal)
        selectCountry.setTitleColor(ThemeManager.currentTheme().buttonTitleColor, for: .normal)
        selectCountry.contentHorizontalAlignment = .center
        selectCountry.contentVerticalAlignment = .center
        selectCountry.titleLabel?.sizeToFit()
//        selectCountry.backgroundColor = ThemeManager.currentTheme().buttonColor
        selectCountry.backgroundColor = Colors.background0
        selectCountry.layer.cornerRadius = 25
       // selectCountry.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10.0, bottom: 0.0, right: 10.0)
        selectCountry.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        selectCountry.addTarget(self, action: #selector(PhoneNumberViewController.openCountryCodesList), for: .touchUpInside)
        
        return selectCountry
    }()
    
    var countryCode: UILabel = {
        var countryCode = UILabel()
        countryCode.translatesAutoresizingMaskIntoConstraints = false
        countryCode.text = "+1"
        countryCode.textAlignment = .center
        countryCode.textColor = ThemeManager.currentTheme().mainTitleColor
        countryCode.font = UIFont.systemFont(ofSize: 18)
        countryCode.sizeToFit()
        
        return countryCode
    }()
    
    let phoneNumber: UITextField = {
        let phoneNumber = UITextField()
        phoneNumber.font = UIFont.systemFont(ofSize: 18)
        phoneNumber.translatesAutoresizingMaskIntoConstraints = false
        phoneNumber.textAlignment = .center
        phoneNumber.keyboardType = .numberPad
        phoneNumber.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        phoneNumber.textColor = ThemeManager.currentTheme().mainTitleColor
        phoneNumber.addTarget(self, action: #selector(PhoneNumberViewController.textFieldDidChange(_:)), for: .editingChanged)
        
        return phoneNumber
    }()
    
    var phoneContainer: UIView = {
        var phoneContainer = UIView()
        phoneContainer.translatesAutoresizingMaskIntoConstraints = false
        phoneContainer.layer.cornerRadius = 25
        phoneContainer.layer.borderWidth = 1
        phoneContainer.layer.borderColor = ThemeManager.currentTheme().borderColor.cgColor
        
        return phoneContainer
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(title)
        addSubview(instructions)
        addSubview(selectCountry)
        addSubview(phoneContainer)
        addSubview(terms)
        phoneContainer.addSubview(countryCode)
        phoneContainer.addSubview(phoneNumber)
        
        phoneNumber.delegate = self
        
        let leftConstant: CGFloat = 20
        let rightConstant: CGFloat = -20
        let heightConstant: CGFloat = 50
        let spacingConstant: CGFloat = 20
        
        NSLayoutConstraint.activate([
            
            title.topAnchor.constraint(equalTo: topAnchor, constant: 150),
            title.rightAnchor.constraint(equalTo: rightAnchor, constant: rightConstant),
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: leftConstant),
            
            instructions.topAnchor.constraint(equalTo: title.bottomAnchor, constant: spacingConstant),
            instructions.rightAnchor.constraint(equalTo: title.rightAnchor),
            instructions.leftAnchor.constraint(equalTo: title.leftAnchor),
            
            selectCountry.topAnchor.constraint(equalTo: instructions.bottomAnchor, constant: spacingConstant),
            selectCountry.rightAnchor.constraint(equalTo: title.rightAnchor),
            selectCountry.leftAnchor.constraint(equalTo: title.leftAnchor),
            selectCountry.heightAnchor.constraint(equalToConstant: heightConstant),
            
            phoneContainer.topAnchor.constraint(equalTo: selectCountry.bottomAnchor, constant: spacingConstant),
            phoneContainer.rightAnchor.constraint(equalTo: title.rightAnchor),
            phoneContainer.leftAnchor.constraint(equalTo: title.leftAnchor),
            phoneContainer.heightAnchor.constraint(equalToConstant: heightConstant),
            
            countryCode.leftAnchor.constraint(equalTo: phoneContainer.leftAnchor, constant: leftConstant),
            countryCode.centerYAnchor.constraint(equalTo: phoneContainer.centerYAnchor),
            countryCode.heightAnchor.constraint(equalTo: phoneContainer.heightAnchor),
            
            phoneNumber.rightAnchor.constraint(equalTo: phoneContainer.rightAnchor, constant: rightConstant),
            phoneNumber.leftAnchor.constraint(equalTo: countryCode.rightAnchor, constant: leftConstant),
            phoneNumber.centerYAnchor.constraint(equalTo: phoneContainer.centerYAnchor),
            phoneNumber.heightAnchor.constraint(equalTo: phoneContainer.heightAnchor),
            
            terms.topAnchor.constraint(equalTo: phoneContainer.bottomAnchor, constant: 50),
            terms.rightAnchor.constraint(equalTo: phoneContainer.rightAnchor),
            terms.leftAnchor.constraint(equalTo: phoneContainer.leftAnchor),
            ])
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

extension PhoneNumberViewContainer: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 25
    }
}
