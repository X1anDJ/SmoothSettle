//
//  AddBillViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//
import Foundation
import UIKit

protocol AddBillViewControllerDelegate: AnyObject {
    func didAddBill(title: String, amount: Double, date: Date, payer: Person, involvers: [Person])
}

class AddBillViewController: UIViewController {
    
    // Delegate to notify the MainViewController of the added bill
    weak var delegate: AddBillViewControllerDelegate?

    // UI Elements
    let billTitleTextField = UITextField()
    let amountTextField = UITextField()
    let datePicker = UIDatePicker()
    let payerSliderView = PeopleSliderView()
    let involversSliderView = PeopleSliderView()

    // Section labels
    let billTitleSectionLabel = UILabel()
    let amountSectionLabel = UILabel()
    let dateSectionLabel = UILabel()
    let payerSectionLabel = UILabel()
    let involversSectionLabel = UILabel()

    var selectedPayer: Person?
    var selectedInvolvers: [Person] = []

    // Pass the current trip and people
    var currentTrip: Trip?
    var people: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setupActions()
        payerSliderView.context = .payer
        involversSliderView.context = .involver
        
        if #available(iOS 15.0, *) {
            self.modalPresentationStyle = .pageSheet
            let requiredHeight = calculateRequiredHeight()
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("customHeight")) { _ in
                return requiredHeight
            }
            
            self.sheetPresentationController?.detents = [customDetent] // Set to use only the custom detent
            self.sheetPresentationController?.prefersGrabberVisible = false
        } else {
            self.modalPresentationStyle = .formSheet
        }

        if #available(iOS 15.0, *) {
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        involversSliderView.delegate = self
        payerSliderView.delegate = self
        payerSliderView.allowSelection = true
        involversSliderView.allowSelection = true
        
        payerSliderView.people = people
        involversSliderView.people = people
    }
    
    // Calculate the necessary height based on the content
    private func calculateRequiredHeight() -> CGFloat {
        let padding: CGFloat = 30
        
        // Example of how to calculate the height of all elements
        let billTitleHeight: CGFloat = 50 // TextField height
        let amountHeight: CGFloat = 50
        let datePickerHeight: CGFloat = 50
        let payerSliderHeight: CGFloat = 100
        let involverSliderHeight: CGFloat = 100
        
        // Add padding between elements and the total required height
        let totalHeight = billTitleHeight + amountHeight + datePickerHeight + payerSliderHeight + involverSliderHeight + (padding * 6)
        return totalHeight
    }
    
    // Handle confirm button action
    @objc private func didTapConfirmButton() {
        guard let title = billTitleTextField.text, !title.isEmpty,
              let amountText = amountTextField.text, let amount = Double(amountText),
              let payer = selectedPayer else {
            let alert = UIAlertController(title: "Invalid Input", message: "Please fill all the required fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Notify the delegate with the new bill data
        delegate?.didAddBill(title: title, amount: amount, date: datePicker.date, payer: payer, involvers: selectedInvolvers)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Styling and Layout
extension AddBillViewController {
    
    private func style() {
        view.backgroundColor = UIColor.systemGray6 // Light gray background
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        // Bill Title Section Label
        billTitleSectionLabel.text = "Bill Title"
        billTitleSectionLabel.font = UIFont.systemFont(ofSize: 14)
        billTitleSectionLabel.textColor = .gray
        billTitleSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Bill Title TextField
        billTitleTextField.placeholder = "Enter bill title"
        billTitleTextField.borderStyle = .roundedRect
        billTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount Section Label
        amountSectionLabel.text = "Amount"
        amountSectionLabel.font = UIFont.systemFont(ofSize: 14)
        amountSectionLabel.textColor = .gray
        amountSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount TextField
        amountTextField.placeholder = "Enter amount"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Date Section Label
        dateSectionLabel.text = "Date"
        dateSectionLabel.font = UIFont.systemFont(ofSize: 14)
        dateSectionLabel.textColor = .gray
        dateSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Date Picker
        datePicker.datePickerMode = .date
        datePicker.contentHorizontalAlignment = .leading
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Payer Section Label
        payerSectionLabel.text = "Who Paid?"
        payerSectionLabel.font = UIFont.systemFont(ofSize: 14)
        payerSectionLabel.textColor = .gray
        payerSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Payer Slider View
        payerSliderView.translatesAutoresizingMaskIntoConstraints = false
        
        // Involvers Section Label
        involversSectionLabel.text = "Who's Involved?"
        involversSectionLabel.font = UIFont.systemFont(ofSize: 14)
        involversSectionLabel.textColor = .gray
        involversSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Involvers Slider View
        involversSliderView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup Navigation Bar (transparent)
        navigationItem.title = "Add Bill"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(didTapConfirmButton))
        
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground() // Makes the navigation bar transparent
            appearance.backgroundColor = .clear // Sets the background to clear
            appearance.shadowImage = UIImage() // Removes the shadow image
            appearance.shadowColor = nil // Removes the shadow line

            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.isTranslucent = true // Ensure translucency
        }
    }
    
    private func layout() {
        view.addSubview(billTitleSectionLabel)
        view.addSubview(billTitleTextField)
        view.addSubview(amountSectionLabel)
        view.addSubview(amountTextField)
        view.addSubview(dateSectionLabel)
        view.addSubview(datePicker)
        view.addSubview(payerSectionLabel)
        view.addSubview(payerSliderView)
        view.addSubview(involversSectionLabel)
        view.addSubview(involversSliderView)
        
        NSLayoutConstraint.activate([
            // Bill Title Section
            billTitleSectionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            billTitleSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            billTitleSectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            billTitleTextField.topAnchor.constraint(equalTo: billTitleSectionLabel.bottomAnchor, constant: 8),
            billTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            billTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            billTitleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Amount Section
            amountSectionLabel.topAnchor.constraint(equalTo: billTitleTextField.bottomAnchor, constant: 16),
            amountSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            amountSectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            amountTextField.topAnchor.constraint(equalTo: amountSectionLabel.bottomAnchor, constant: 8),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            amountTextField.heightAnchor.constraint(equalToConstant: 44),
            // Date Section
            dateSectionLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 16),
            dateSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateSectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            datePicker.topAnchor.constraint(equalTo: dateSectionLabel.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Payer Section
            payerSectionLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            payerSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            payerSectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            payerSliderView.topAnchor.constraint(equalTo: payerSectionLabel.bottomAnchor, constant: 8),
            payerSliderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            payerSliderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            payerSliderView.heightAnchor.constraint(equalToConstant: 80),
            
            // Involvers Section
            involversSectionLabel.topAnchor.constraint(equalTo: payerSliderView.bottomAnchor, constant: 16),
            involversSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            involversSectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            involversSliderView.topAnchor.constraint(equalTo: involversSectionLabel.bottomAnchor, constant: 8),
            involversSliderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            involversSliderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            involversSliderView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupActions() {
        // Swipe down to dismiss the view
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(didTapCancelButton))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }
}

// MARK: - PeopleSliderViewDelegate for Payer and Involvers
extension AddBillViewController: PeopleSliderViewDelegate {
    func didRequestRemovePerson(_ person: Person) {
        // Handle removing a person
    }
    
    func didTapAddPerson(for trip: Trip?) {
        // Handle adding a person
    }
    
    func didSelectPerson(_ person: Person, for trip: Trip?, context: SliderContext) {
        switch context {
        case .payer:
            if selectedPayer == person {
                selectedPayer = nil
            } else {
                selectedPayer = person
            }
            payerSliderView.selectedPayer = selectedPayer
            payerSliderView.reload()
            
        case .involver:
            if selectedInvolvers.contains(person) {
                selectedInvolvers.removeAll { $0 == person }
            } else {
                selectedInvolvers.append(person)
            }
            involversSliderView.selectedInvolvers = selectedInvolvers
            involversSliderView.reload()
        }
    }
}
