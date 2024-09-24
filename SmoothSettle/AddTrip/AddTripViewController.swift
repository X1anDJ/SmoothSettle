//
//  AddTripViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/22.
//
import Foundation
import UIKit

protocol AddTripViewControllerDelegate: AnyObject {
    func didAddTrip(title: String, people: [Person], date: Date)
}

class AddTripViewController: UIViewController {
    
    // Delegate to notify the MainViewController of the added trip
    weak var delegate: AddTripViewControllerDelegate?
    
    // UI Elements
    let addTripTitleLabel = UILabel()
    let titleTextField = UITextField()
    let titleSectionLabel = UILabel()
    let peopleSliderView = PeopleSliderView()
    let peopleSectionLabel = UILabel()
    let datePicker = UIDatePicker()
    let dateSectionLabel = UILabel()
    let confirmButton = UIButton(type: .system)
    
    // People array to add to the trip
    var people: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animatePopup(show: true)
    }
    
    // Animate the popup from the bottom
    private func animatePopup(show: Bool) {
        let targetPosition = show ? view.bounds.height * 0.5 : view.bounds.height
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
        guard let title = titleTextField.text, !title.isEmpty else {
            // Alert user if title is empty
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter a title for the trip.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        // Notify the delegate with the new trip data
        delegate?.didAddTrip(title: title, people: people, date: datePicker.date)
        dismissPopup()
    }
}

// MARK: - Styling and Layout
extension AddTripViewController {
    
    private func style() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        // Add Trip Title Label
        addTripTitleLabel.text = "Add a Trip"
        addTripTitleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        addTripTitleLabel.textAlignment = .center
        addTripTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Title Section Label
        titleSectionLabel.text = "Trip Title"
        titleSectionLabel.font = UIFont.systemFont(ofSize: 16)
        titleSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Title TextField
        titleTextField.placeholder = "Enter trip title"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // People Section Label
        peopleSectionLabel.text = "People"
        peopleSectionLabel.font = UIFont.systemFont(ofSize: 16)
        peopleSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // People Slider
        peopleSliderView.translatesAutoresizingMaskIntoConstraints = false
        peopleSliderView.delegate = self
        
        // Date Section Label
        dateSectionLabel.text = "Date"
        dateSectionLabel.font = UIFont.systemFont(ofSize: 16)
        dateSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Date Picker
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Confirm Button
        confirmButton.setTitle("Add Trip", for: .normal)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
    }
    
    private func layout() {
        view.addSubview(addTripTitleLabel)
        view.addSubview(titleSectionLabel)
        view.addSubview(titleTextField)
        view.addSubview(peopleSectionLabel)
        view.addSubview(peopleSliderView)
        view.addSubview(dateSectionLabel)
        view.addSubview(datePicker)
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            // Add Trip Title Label Constraints
            addTripTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            addTripTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Title Section Label Constraints
            titleSectionLabel.topAnchor.constraint(equalTo: addTripTitleLabel.bottomAnchor, constant: 16),
            titleSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleSectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Title TextField Constraints
            titleTextField.topAnchor.constraint(equalTo: titleSectionLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
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
            
            // Confirm Button Constraints
            confirmButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
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

// MARK: - PeopleSliderViewDelegate
extension AddTripViewController: PeopleSliderViewDelegate {
    func didSelectPerson(_ person: Person, for trip: Trip?, context: SliderContext) {
        
    }
    
    
    func didTapAddPerson(for trip: Trip?) {
        // Show alert to add a person
        let alert = UIAlertController(title: "Add Person", message: "Enter the name of the person", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Person Name"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                // Create a new Person object for the new trip being created
                let person = Person(context: CoreDataManager.shared.context)
                person.name = name
                self?.people.append(person)
                self?.peopleSliderView.people = self?.people ?? []
            }
        }))
        present(alert, animated: true)
    }
    
}
