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
    
    weak var delegate: AddBillViewControllerDelegate?
    
    let tripTitleLabel = UILabel()
    let billTitleTextField = UITextField()
    let amountTextField = UITextField()
    let datePicker = UIDatePicker()
    let payerLabel = UILabel()
    let payerSliderView = PeopleSliderView()
    let involversLabel = UILabel()
    let involversSliderView = PeopleSliderView()
    let confirmButton = UIButton(type: .system)
    
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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        involversSliderView.delegate = self // Use the same slider view for selecting involvers
        payerSliderView.delegate = self // Use the same slider view for selecting the payer
        payerSliderView.allowSelection = true
        involversSliderView.allowSelection = true
        
        payerSliderView.people = people
        involversSliderView.people = people
//        
//        print("people in this trip: \(people.count)")
        
        animatePopup(show: true)
    }
    
    // Animate the popup from the bottom
    private func animatePopup(show: Bool) {
        let targetPosition = show ? view.bounds.height * 0.4 : view.bounds.height
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = targetPosition
        }
    }
    
    // Dismiss the view with animation
    @objc private func dismissPopup() {
        animatePopup(show: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // Handle confirm button action
    @objc private func didTapConfirmButton() {
        guard let title = billTitleTextField.text, !title.isEmpty,
              let amountText = amountTextField.text, let amount = Double(amountText),
              let payer = selectedPayer else {
            // Show alert if necessary fields are missing
            let alert = UIAlertController(title: "Invalid Input", message: "Please fill all the required fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Notify the delegate with the new bill data
        delegate?.didAddBill(title: title, amount: amount, date: datePicker.date, payer: payer, involvers: selectedInvolvers)
        dismissPopup()
    }
}

// MARK: - Styling and Layout
extension AddBillViewController {
    
    private func style() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        // Trip Title Label
        tripTitleLabel.text = currentTrip?.title
        tripTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        tripTitleLabel.textAlignment = .center
        tripTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Bill Title TextField
        billTitleTextField.placeholder = "Enter bill title"
        billTitleTextField.borderStyle = .roundedRect
        billTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount TextField
        amountTextField.placeholder = "Enter amount"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Date Picker
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Payer Label
        payerLabel.text = "Who Paid?"
        payerLabel.font = UIFont.systemFont(ofSize: 16)
        payerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Payer Slider View
        payerSliderView.translatesAutoresizingMaskIntoConstraints = false
        payerSliderView.people = people

        
        // Involvers Label
        involversLabel.text = "Who's Involved?"
        involversLabel.font = UIFont.systemFont(ofSize: 16)
        involversLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Involvers Slider View
        involversSliderView.translatesAutoresizingMaskIntoConstraints = false
        involversSliderView.people = people

        
        // Confirm Button
        confirmButton.setTitle("Add Bill", for: .normal)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
    }
    
    private func layout() {
        view.addSubview(tripTitleLabel)
        view.addSubview(billTitleTextField)
        view.addSubview(amountTextField)
        view.addSubview(datePicker)
        view.addSubview(payerLabel)
        view.addSubview(payerSliderView)
        view.addSubview(involversLabel)
        view.addSubview(involversSliderView)
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            // Trip Title Label Constraints
            tripTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            tripTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tripTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Bill Title TextField Constraints
            billTitleTextField.topAnchor.constraint(equalTo: tripTitleLabel.bottomAnchor, constant: 16),
            billTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            billTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Amount TextField
            // Amount TextField Constraints
            amountTextField.topAnchor.constraint(equalTo: billTitleTextField.bottomAnchor, constant: 16),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Date Picker Constraints
            datePicker.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Payer Label Constraints
            payerLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            payerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            payerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Payer Slider View Constraints
            payerSliderView.topAnchor.constraint(equalTo: payerLabel.bottomAnchor, constant: 8),
            payerSliderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            payerSliderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            payerSliderView.heightAnchor.constraint(equalToConstant: 80),
            
            // Involvers Label Constraints
            involversLabel.topAnchor.constraint(equalTo: payerSliderView.bottomAnchor, constant: 16),
            involversLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            involversLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Involvers Slider View Constraints
            involversSliderView.topAnchor.constraint(equalTo: involversLabel.bottomAnchor, constant: 8),
            involversSliderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            involversSliderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            involversSliderView.heightAnchor.constraint(equalToConstant: 80),
            
            // Confirm Button Constraints
            confirmButton.topAnchor.constraint(equalTo: involversSliderView.bottomAnchor, constant: 16),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 44),
            confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        // Swipe down to dismiss the view
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissPopup))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }
}

// MARK: - PeopleSliderViewDelegate for Payer and Involvers
extension AddBillViewController: PeopleSliderViewDelegate {
    func didTapAddPerson(for trip: Trip?) {
        
    }
    
    func didSelectPerson(_ person: Person, for trip: Trip?, context: SliderContext) {
        switch context {
        case .payer:
            print("Payer selected: \(String(describing: person.name))")
            // Handle payer selection separately
            if selectedPayer == person {
                selectedPayer = nil
            } else {
                selectedPayer = person
            }
            
            // Update the slider view for payer
            payerSliderView.selectedPayer = selectedPayer
            payerSliderView.reload()
            
        case .involver:
            // Handle involver selection separately
            print("Involver selected: \(String(describing: person.name))")
            if selectedInvolvers.contains(person) {
                selectedInvolvers.removeAll { $0 == person }
            } else {
                selectedInvolvers.append(person)
            }
            
            // Update the slider view for involvers
            involversSliderView.selectedInvolvers = selectedInvolvers
            involversSliderView.reload()
        }
    }


}
