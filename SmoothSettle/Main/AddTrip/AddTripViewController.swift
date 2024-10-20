//
//  AddTripViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//

import UIKit

protocol AddTripViewControllerDelegate: AnyObject {
    func didAddTrip(title: String, people: [Person], date: Date)
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
    
    // People array to add to the trip
    var people: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
        
        //MARK: recognizing the taps on the app screen, not the keyboard...
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
    }
    
    // Handle confirm button action
    @objc private func didTapAddButton() {
        guard let title = titleTextField.text, !title.isEmpty else {
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter a title for the trip.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        delegate?.didAddTrip(title: title, people: people, date: datePicker.date)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Styling and Layout
extension AddTripViewController {
    
    private func style() {
        view.backgroundColor = Colors.background1 // Light gray background
        
        // Title TextField
        titleTextField.placeholder = "Enter trip title"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // People Slider View
        peopleSliderView.translatesAutoresizingMaskIntoConstraints = false
        peopleSliderView.delegate = self
        
        // Date Picker
        datePicker.datePickerMode = .date
        datePicker.contentHorizontalAlignment = .leading
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup Navigation Bar (without a separate background and separator)
        let navItem = UINavigationItem(title: "New Trip")
        let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelButton))
        let addItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(didTapAddButton))
        navItem.leftBarButtonItem = cancelItem
        navItem.rightBarButtonItem = addItem
        
        navigationBar.setItems([navItem], animated: false)
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear // No background color
        navigationBar.shadowImage = UIImage() // Remove the shadow line
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Section Titles
        titleSectionLabel.text = "Trip Title"
        titleSectionLabel.font = UIFont.systemFont(ofSize: 14)
        titleSectionLabel.textColor = .gray
        titleSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        peopleSectionLabel.text = "People"
        peopleSectionLabel.font = UIFont.systemFont(ofSize: 14)
        peopleSectionLabel.textColor = .gray
        peopleSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateSectionLabel.text = "Date"
        dateSectionLabel.font = UIFont.systemFont(ofSize: 14)
        dateSectionLabel.textColor = .gray
        dateSectionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func layout() {
        view.addSubview(navigationBar)
        view.addSubview(titleSectionLabel)
        view.addSubview(titleTextField)
        view.addSubview(peopleSectionLabel)
        view.addSubview(peopleSliderView)
        view.addSubview(dateSectionLabel)
        view.addSubview(datePicker)
        
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
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    //MARK: Hide Keyboard...
    @objc func hideKeyboardOnTap(){
        //MARK: removing the keyboard from screen...
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
        let alert = UIAlertController(title: "Add Person", message: "Enter the name of the person", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Person Name"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
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
