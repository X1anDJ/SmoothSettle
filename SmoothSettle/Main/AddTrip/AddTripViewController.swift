//
//  AddTripViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//

import UIKit

protocol AddTripViewControllerDelegate: AnyObject {
    func didAddTrip(title: String, people: [Person], date: Date, currency: String)
}

class AddTripViewController: UIViewController {
    
    // Delegate to notify the MainViewController of the added trip
    weak var delegate: AddTripViewControllerDelegate?
    
    // UI Elements
    let titleTextField = UITextField()
    let peopleSliderView = PeopleSliderView()
    let datePicker = UIDatePicker()
    let navigationBar = UINavigationBar()
    
    let titleSectionLabel = UILabel()
    let peopleSectionLabel = UILabel()
    let dateSectionLabel = UILabel()
    
    // New Currency Section Elements
    let currencySectionLabel = UILabel()
    let currencyButton = UIButton(type: .system)
    var selectedCurrency: String? // To store the selected currency code
    
    // People array to add to the trip
    var people: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
        
        // Recognize taps to hide keyboard
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        // Setting the presentation style to pageSheet
        if #available(iOS 15.0, *) {
            self.modalPresentationStyle = .pageSheet
            self.sheetPresentationController?.detents = [.medium()]
            self.sheetPresentationController?.prefersGrabberVisible = false
        } else {
            self.modalPresentationStyle = .formSheet
        }
        
        // Set default currency based on locale
        if let defaultCurrency = Locale.current.currencyCode {
            selectedCurrency = defaultCurrency
            if let currencyName = Locale.current.localizedString(forCurrencyCode: defaultCurrency) {
                currencyButton.setTitle("\(defaultCurrency) - \(currencyName)", for: .normal)
            } else {
                currencyButton.setTitle(defaultCurrency, for: .normal)
            }
        }
    }
    
    // Handle confirm button action
    @objc private func didTapAddButton() {
        guard let title = titleTextField.text, !title.isEmpty else {
            let alert = UIAlertController(
                title: String(localized: "invalid_alert_title"),
                message: String(localized: "invalid_enter_title_message"),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "OK"), style: .default))
            present(alert, animated: true)
            return
        }
        
        // Ensure a currency is selected or default to user's locale currency
        let currency = selectedCurrency ?? Locale.current.currencyCode ?? "USD"
        delegate?.didAddTrip(title: title, people: people, date: datePicker.date, currency: currency)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // Handle currency button tap
    @objc private func currencyButtonTapped() {
        let alert = UIAlertController(title: NSLocalizedString("select_currency", comment: "Prompt to select currency"), message: nil, preferredStyle: .actionSheet)
        
        // Dynamically fetch all available currency codes and their localized names
        let availableCurrencyCodes = Locale.commonISOCurrencyCodes.sorted()
        let currencies = availableCurrencyCodes.map { code -> (String, String) in
            let name = Locale.current.localizedString(forCurrencyCode: code) ?? code
            return (code, name)
        }
        
        // Add an action for each currency
        for (code, name) in currencies {
            let action = UIAlertAction(title: "\(code) - \(name)", style: .default) { [weak self] _ in
                self?.selectedCurrency = code
                self?.currencyButton.setTitle("\(code) - \(name)", for: .normal)
            }
            alert.addAction(action)
        }
        
        // Add cancel action
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel action"), style: .cancel, handler: nil))
        
        // For iPad, configure the popover presentation
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = currencyButton
            popoverController.sourceRect = currencyButton.bounds
        }
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Styling and Layout
extension AddTripViewController {
    
    private func style() {
        view.backgroundColor = Colors.background1 // Light gray background
        
        // Title TextField
        let enterTripTitleLocalized = String(localized: "enter_trip_title")
        titleTextField.placeholder = enterTripTitleLocalized
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.autocorrectionType = .no
        // People Slider View
        peopleSliderView.translatesAutoresizingMaskIntoConstraints = false
        peopleSliderView.delegate = self
        
        // Date Picker
        datePicker.datePickerMode = .date
        datePicker.contentHorizontalAlignment = .leading
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup Navigation Bar (without a separate background and separator)
        let navItemLocalized = String(localized: "new_trip")
        let navItem = UINavigationItem(title: navItemLocalized)
        let cancelItem = UIBarButtonItem(title: String(localized: "close_button"), style: .plain, target: self, action: #selector(didTapCancelButton))
        let addTripLocalized = String(localized: "add_button")
        let addItem = UIBarButtonItem(title: addTripLocalized, style: .plain, target: self, action: #selector(didTapAddButton))
        navItem.leftBarButtonItem = cancelItem
        navItem.rightBarButtonItem = addItem
        
        navigationBar.setItems([navItem], animated: false)
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear // No background color
        navigationBar.shadowImage = UIImage() // Remove the shadow line
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Section Titles
        titleSectionLabel.text = String(localized: "trip_title")
        titleSectionLabel.font = UIFont.systemFont(ofSize: 14)
        titleSectionLabel.textColor = .gray
        titleSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        peopleSectionLabel.text = String(localized: "people")
        peopleSectionLabel.font = UIFont.systemFont(ofSize: 14)
        peopleSectionLabel.textColor = .gray
        peopleSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateSectionLabel.text = String(localized: "enter_date")
        dateSectionLabel.font = UIFont.systemFont(ofSize: 14)
        dateSectionLabel.textColor = .gray
        dateSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Currency Section Label
        currencySectionLabel.text = String(localized: "currency")
        currencySectionLabel.font = UIFont.systemFont(ofSize: 14)
        currencySectionLabel.textColor = .gray
        currencySectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Currency Button
        currencyButton.setTitle(String(localized: "select_currency"), for: .normal)
        currencyButton.setTitleColor(.systemBlue, for: .normal)
        currencyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        currencyButton.layer.borderColor = UIColor.systemBlue.cgColor
        currencyButton.layer.borderWidth = 1
        currencyButton.layer.cornerRadius = 8
        currencyButton.contentHorizontalAlignment = .left
        currencyButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        currencyButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add action to the button
        currencyButton.addTarget(self, action: #selector(currencyButtonTapped), for: .touchUpInside)
    }
    
    private func layout() {
        view.addSubview(navigationBar)
        view.addSubview(titleSectionLabel)
        view.addSubview(titleTextField)
        view.addSubview(peopleSectionLabel)
        view.addSubview(peopleSliderView)
        view.addSubview(dateSectionLabel)
        view.addSubview(datePicker)
        
        // Add Currency Section
        view.addSubview(currencySectionLabel)
        view.addSubview(currencyButton)
        
        NSLayoutConstraint.activate([
            // Navigation Bar Constraints
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Title Section Label Constraints
            titleSectionLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 20),
            titleSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleSectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Title TextField Constraints
            titleTextField.topAnchor.constraint(equalTo: titleSectionLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // People Section Label Constraints
            peopleSectionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            peopleSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            peopleSectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // People Slider View Constraints
            peopleSliderView.topAnchor.constraint(equalTo: peopleSectionLabel.bottomAnchor, constant: 8),
            peopleSliderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            peopleSliderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            peopleSliderView.heightAnchor.constraint(equalToConstant: 80),
            
            // Date Section Label Constraints
            dateSectionLabel.topAnchor.constraint(equalTo: peopleSliderView.bottomAnchor, constant: 16),
            dateSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateSectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Date Picker Constraints
            datePicker.topAnchor.constraint(equalTo: dateSectionLabel.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Currency Section Label Constraints
            currencySectionLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            currencySectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            currencySectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Currency Button Constraints
            currencyButton.topAnchor.constraint(equalTo: currencySectionLabel.bottomAnchor, constant: 8),
            currencyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            currencyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            currencyButton.heightAnchor.constraint(equalToConstant: 44),
//            
//            // Settle Button Constraints
//            settleButton.topAnchor.constraint(equalTo: currencyButton.bottomAnchor, constant: 24),
//            settleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            settleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            settleButton.heightAnchor.constraint(equalToConstant: 50),
//            settleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])
    }
    
    //MARK: Hide Keyboard...
    @objc func hideKeyboardOnTap(){
        // Remove the keyboard from the screen
        view.endEditing(true)
    }

}


// MARK: - PeopleSliderViewDelegate
extension AddTripViewController: PeopleSliderViewDelegate {
    func didRequestRemovePerson(_ personId: UUID?) {
        
    }
    
    func didSelectPerson(_ personId: UUID?, for tripId: UUID?, context: SliderContext) {
        
    }
    


    func didTapAddPerson(for tripId: UUID?) {
        let addPersonAlert = String(localized: "add_person_alert_title")
        let addPersonMessageAlert = String(localized: "add_person_alert_message")
        let personNameLocalized = String(localized: "person_name_placeholder")
        let alert = UIAlertController(title: addPersonAlert, message: addPersonMessageAlert, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = personNameLocalized
        }
        alert.addAction(UIAlertAction(title: String(localized: "add_button"), style: .default, handler: { [weak self] _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                // Create a new Person object in the CoreData context
                let person = Person(context: CoreDataManager.shared.context)
                person.id = UUID() // Assign a unique UUID if not already present
                person.name = name
                
                // Append the new person to the people list and update the UI
                self?.people.append(person)
                self?.peopleSliderView.people = self?.people ?? []
                
                // Optionally, save to CoreData
                try? CoreDataManager.shared.context.save()
            }
        }))
        present(alert, animated: true)
    }

}
