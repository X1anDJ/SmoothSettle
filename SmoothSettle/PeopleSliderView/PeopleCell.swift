//
//  PeopleCell.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//

import Foundation
import UIKit

protocol PeopleCellDelegate: AnyObject {
    func didRequestRemovePerson(_ person: Person)
}

class PeopleCell: UICollectionViewCell {
    
    private let circleView = UIView()
    private let initialsLabel = UILabel()
    private let removePersonButton = UIButton()
    //private var longpressed = false
    
    weak var delegate: PeopleCellDelegate?
    private var person: Person?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Circle view setup
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = 30
        circleView.backgroundColor = .systemGray6
        contentView.addSubview(circleView)
//        setupLongPressGesture()
        
        // RemovePersonButton setup
        removePersonButton.translatesAutoresizingMaskIntoConstraints = false
        removePersonButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        removePersonButton.tintColor = UIColor.red
        removePersonButton.addTarget(self, action: #selector(removePerson), for: .touchUpInside)
        removePersonButton.isHidden = true
        
        // Initials label setup
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        initialsLabel.textAlignment = .center
        circleView.addSubview(initialsLabel)
        circleView.addSubview(removePersonButton)
        
        // Add layout constraints for circle and initials
        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: 60),
            circleView.heightAnchor.constraint(equalToConstant: 60),
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            
//            removePersonButton.widthAnchor.constraint(equalToConstant: 30),
//            removePersonButton.heightAnchor.constraint(equalToConstant: 30),
            removePersonButton.centerXAnchor.constraint(equalTo: circleView.centerXAnchor, constant: 30),
            removePersonButton.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: -30),
            
            initialsLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Configure the cell with a person and a flag for whether they're selected
    func configure(with person: Person, isSelected: Bool) {
        self.person = person
        guard let name = person.name else {
                print("Invalid person in cell")
                return
            }
        
        let initials = person.name?.components(separatedBy: " ").compactMap { $0.first }.map { String($0) }.joined() ?? "?"
        initialsLabel.text = initials
        initialsLabel.textColor = .white
        circleView.backgroundColor = Colors.primaryLight // Set background color for person cells
        
        // Apply a red border if selected, otherwise no border
        if isSelected {
            circleView.layer.borderWidth = 2.0
            circleView.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            circleView.layer.borderWidth = 0
        }
    }
    
    // Configure the cell as a "plus" button for adding new people
    func configureAsAddButton() {
        person = nil
        initialsLabel.text = "+"
        initialsLabel.textColor = .white
        circleView.backgroundColor = Colors.accentYellow
        circleView.layer.borderWidth = 0 // No border for the add button
//        print("Configure add button")
        removePersonButton.isHidden = true
    }
    
    // Configure a empty button
    func configureEmptyButton() {
        person = nil
        initialsLabel.text = ""
        initialsLabel.textColor = .clear
        circleView.backgroundColor = .white
        circleView.layer.borderColor = UIColor.systemGray5.cgColor
        circleView.layer.borderWidth = 1
//        print("Configure empty button")
        removePersonButton.isHidden = true
    }
    
//    private func setupLongPressGesture() {
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        longPressGesture.minimumPressDuration = 0.5
//        circleView.addGestureRecognizer(longPressGesture)
//    }
    
//    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
//        if gestureRecognizer.state == .began {
//            removePersonButton.isHidden = false
//            print("Long press detected")
//        }
//    }
    
    @objc private func removePerson() {
        if let person = person {
//            print("People cell request remove")
            delegate?.didRequestRemovePerson(person)
        }
    }
    
    func hideRemoveButton() {
        removePersonButton.isHidden = true
//        print("hide RemoveButton")
    }
    
    func showRemoveButton() {
        if let person = person {
//            print("Person is \(String(describing: person.name))")
            removePersonButton.isHidden = false
//            print("show RemoveButton")
        }
    }
}
