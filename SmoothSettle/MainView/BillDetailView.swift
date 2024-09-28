//
//  BillDetailView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/27.
//

import UIKit

class BillDetailView: UIView {
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let amountLabel = UILabel()
    private let payerLabel = UILabel()
    private let involversLabel = UILabel()
    private let closeButton = UIButton()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        // Configure view appearance
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        // Setup the labels
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        dateLabel.textAlignment = .center
        
        amountLabel.font = UIFont.systemFont(ofSize: 16)
        amountLabel.textAlignment = .center
        
        payerLabel.font = UIFont.systemFont(ofSize: 14)
        payerLabel.textAlignment = .center
        
        involversLabel.font = UIFont.systemFont(ofSize: 14)
        involversLabel.numberOfLines = 0
        involversLabel.textAlignment = .center
        
        // Setup the close button
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.systemBlue, for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        // Add subviews to the main view
        addSubview(titleLabel)
        addSubview(dateLabel)
        addSubview(amountLabel)
        addSubview(payerLabel)
        addSubview(involversLabel)
        addSubview(closeButton)
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        // Enable Auto Layout
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        payerLabel.translatesAutoresizingMaskIntoConstraints = false
        involversLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Define constraints for layout (this is just an example)
        NSLayoutConstraint.activate([
            // Title label at the top
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            // Date label below the title
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            // Amount label below the date
            amountLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            amountLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            // Payer label below the amount
            payerLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            payerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            payerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            // Involvers label below the payer
            involversLabel.topAnchor.constraint(equalTo: payerLabel.bottomAnchor, constant: 8),
            involversLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            involversLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            // Close button at the bottom
            closeButton.topAnchor.constraint(equalTo: involversLabel.bottomAnchor, constant: 16),
            closeButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration Method
    func configure(with bill: Bill) {
        titleLabel.text = bill.title ?? "Untitled Bill"
        dateLabel.text = formatDate(bill.date)
        amountLabel.text = String(format: "$%.2f", bill.amount)
        payerLabel.text = "Payer: \(bill.payer?.name ?? "Unknown")"
        
        // Safely cast involvers to Set<Person>
        if let involversSet = bill.involvers as? Set<Person> {
            // Extract names, handling possible nil names
            let involverNames = involversSet.compactMap { $0.name }.joined(separator: ", ")
            involversLabel.text = "Involvers: \(involverNames)"
        } else {
            involversLabel.text = "Involvers: None"
        }
    }

    
    // Helper method to format date
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Close Button Action
    @objc private func closeTapped() {
        // Animate the dismissal of the view
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

