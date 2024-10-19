//
//  PeopleCell.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//
import Foundation
import UIKit

protocol PeopleCellDelegate: AnyObject {
    func didRequestRemovePerson(_ personId: UUID?)
}

class PeopleCell: UICollectionViewCell {
    
    private let circleView = UIView()
    private let initialsLabel = UILabel()
    private let removePersonButton = UIButton()

    weak var delegate: PeopleCellDelegate?
    private var personId: UUID?  // Store the person's UUID instead of the Person object
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Circle view setup
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = (self.frame.height - 20) / 2
        circleView.backgroundColor = .systemGray6
        contentView.addSubview(circleView)
        
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
            circleView.widthAnchor.constraint(equalTo: contentView.heightAnchor, constant: -20),
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor),
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
//            removePersonButton.centerXAnchor.constraint(equalTo: circleView.centerXAnchor, constant: 30),
//            removePersonButton.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: -30),
            
            removePersonButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            removePersonButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            removePersonButton.widthAnchor.constraint(equalToConstant: 20),
            removePersonButton.heightAnchor.constraint(equalToConstant: 20),
            
            initialsLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor)
        ])
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure the cell with a person's UUID and initials, and a flag for whether they're selected
    func configure(with personId: UUID, name: String?, isSelected: Bool) {
        self.personId = personId
        guard let name = name else {
            print("Invalid person in cell")
            return
        }
        
        let initials = name.components(separatedBy: " ").compactMap { $0.first }.map { String($0) }.joined()
        initialsLabel.text = initials
        initialsLabel.textColor = .white
        circleView.backgroundColor = Colors.primaryLight // Set background color for person cells
        
        // Apply a border if selected, otherwise no border
        if isSelected {
            circleView.layer.borderWidth = 2.0
            circleView.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            circleView.layer.borderWidth = 0
        }
    }
    
    // Configure the cell as a "plus" button for adding new people
    func configureAsAddButton() {
        personId = nil  // No UUID for the add button
        initialsLabel.text = "+"
        initialsLabel.textColor = .white
        circleView.backgroundColor = Colors.primaryMedium
        circleView.layer.borderWidth = 0 // No border for the add button
        removePersonButton.isHidden = true
    }
    
    // Configure an empty button
    func configureEmptyButton() {
        personId = nil
        initialsLabel.text = ""
        initialsLabel.textColor = .clear
        circleView.backgroundColor = .white
        circleView.layer.borderColor = UIColor.systemGray5.cgColor
        circleView.layer.borderWidth = 1
        removePersonButton.isHidden = true
    }
    
    @objc private func removePerson() {
        if let personId = personId {
            delegate?.didRequestRemovePerson(personId)  // Pass the person's UUID to the delegate
        }
    }
    
    func hideRemoveButton() {
        removePersonButton.isHidden = true
    }
    
    func showRemoveButton() {
        print("people cell remove detected")
        if personId != nil {
            removePersonButton.isHidden = false
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Only perform hit testing for the removePersonButton if it is visible and enabled
        if !removePersonButton.isHidden && removePersonButton.isEnabled {
            let buttonPoint = removePersonButton.convert(point, from: self)
            if removePersonButton.bounds.insetBy(dx: -20, dy: -20).contains(buttonPoint) {
                return removePersonButton
            }
        }
        return super.hitTest(point, with: event)
    }


}
