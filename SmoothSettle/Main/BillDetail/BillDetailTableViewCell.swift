//
//  BillDetailTableViewCell.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//

import UIKit

class BillDetailTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let circleView = UIView()
    private let circleLabel = UILabel()
    private let nameLabel = UILabel()
    private let amountLabel = UILabel()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    // MARK: - Setup UI
    private func setupView() {
        // Circle View
        circleView.layer.cornerRadius = 20 // Assuming circle diameter is 40
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        // Circle Label
        circleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        circleLabel.textColor = .white
        circleLabel.textAlignment = .center
        circleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add circleLabel to circleView
        circleView.addSubview(circleLabel)
        
        // Name Label
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount Label
        amountLabel.font = UIFont.systemFont(ofSize: 16)
        amountLabel.textAlignment = .right
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews to contentView
        contentView.addSubview(circleView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(amountLabel)
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Circle View
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            circleView.widthAnchor.constraint(equalToConstant: 40),
            circleView.heightAnchor.constraint(equalToConstant: 40),
            
            // Circle Label inside Circle View
            circleLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            circleLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            circleLabel.widthAnchor.constraint(equalTo: circleView.widthAnchor),
            circleLabel.heightAnchor.constraint(equalTo: circleView.heightAnchor),
            
            // Name Label
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            // Amount Label
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountLabel.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Configuration Method
    func configure(with person: Person, amount: Double, isPayer: Bool) {
        nameLabel.text = person.name
        
        // Set amount label with "$" and the amount formatted to two decimal places
        amountLabel.text = String(format: "$%.2f", amount)
        
        // Set circle properties based on whether the person is the payer or an involver
        if isPayer {
            circleView.backgroundColor = Colors.primaryMedium
        } else {
            circleView.backgroundColor = Colors.accentYellow
        }
        
        // Set the circle label to the initials of the person
        if let name = person.name {
            circleLabel.text = getInitials(from: name)
        } else {
            circleLabel.text = "?"
        }
    }

    
    // Helper method to get initials from a name
    private func getInitials(from name: String) -> String {
        let words = name.components(separatedBy: " ")
        let initials = words.compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
}
