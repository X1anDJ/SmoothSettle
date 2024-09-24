//
//  PeopleCell.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//

import Foundation
import UIKit
class PeopleCell: UICollectionViewCell {
    
    private let circleView = UIView()
    private let initialsLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Circle view setup
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = 30
        circleView.backgroundColor = .systemGray6
        contentView.addSubview(circleView)
        
        // Initials label setup
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        initialsLabel.textAlignment = .center
        circleView.addSubview(initialsLabel)
        
        // Add layout constraints for circle and initials
        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: 60),
            circleView.heightAnchor.constraint(equalToConstant: 60),
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            initialsLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure the cell with a person and a flag for whether they're selected
    func configure(with person: Person, isSelected: Bool) {
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
        initialsLabel.text = "+"
        initialsLabel.textColor = .white
        circleView.backgroundColor = .systemGreen
        circleView.layer.borderWidth = 0 // No border for the add button
    }
    
    // Configure a empty button
    func configureEmptyButton() {
        initialsLabel.text = ""
        initialsLabel.textColor = .clear
        circleView.backgroundColor = .white
        circleView.layer.borderColor = UIColor.systemGray5.cgColor
        circleView.layer.borderWidth = 1
    }
}
