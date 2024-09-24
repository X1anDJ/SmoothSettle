//
//  BillTableViewCell.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/23.
//

import UIKit

class BillTableViewCell: UITableViewCell {
    
    // UI Elements
    let billTitleLabel = UILabel()
    let dateLabel = UILabel()
    let payerCircleView = UIView()
    let payerInitialsLabel = UILabel() // Label for initials inside payer's circle
    let paidLabel = UILabel()
    var involversCircleStackView = UIStackView()
    let amountLabel = UILabel()
    
    // Initialize the cell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup UI elements
    private func setupViews() {
        // Bill Title Label
        billTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        billTitleLabel.textColor = .black
        
        // Date Label
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .darkGray
        dateLabel.textAlignment = .right
        
        // Payer Circle (blue) and Initials Label
        payerCircleView.layer.cornerRadius = 15
        payerCircleView.backgroundColor = .systemBlue
        payerCircleView.translatesAutoresizingMaskIntoConstraints = false
        
        payerInitialsLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        payerInitialsLabel.textColor = .white
        payerInitialsLabel.textAlignment = .center
        payerInitialsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        payerCircleView.addSubview(payerInitialsLabel) // Add initials label to the circle
        
        // Paid Label
        paidLabel.text = "paid"
        paidLabel.font = UIFont.systemFont(ofSize: 14)
        paidLabel.textColor = .black
        
        // Involvers Circle Stack View (for orange circles)
        involversCircleStackView = UIStackView()
        involversCircleStackView.axis = .horizontal
        involversCircleStackView.spacing = 4
        involversCircleStackView.distribution = .fillEqually
        involversCircleStackView.alignment = .center
        
        // Amount Label
        amountLabel.font = UIFont.boldSystemFont(ofSize: 18)
        amountLabel.textColor = .black
        amountLabel.textAlignment = .right
    }
    
    // Layout the UI elements
    private func layoutViews() {
        let firstRowStack = UIStackView(arrangedSubviews: [billTitleLabel, dateLabel])
        firstRowStack.axis = .horizontal
        firstRowStack.distribution = .equalSpacing
        
        let secondRowStack = UIStackView(arrangedSubviews: [payerCircleView, paidLabel, involversCircleStackView, amountLabel])
        secondRowStack.axis = .horizontal
        secondRowStack.spacing = 8
        secondRowStack.alignment = .center
        secondRowStack.distribution = .equalSpacing
        
        // Add the subviews
        contentView.addSubview(firstRowStack)
        contentView.addSubview(secondRowStack)
        
        // Constraints for first row (bill title and date)
        firstRowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstRowStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            firstRowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            firstRowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        // Constraints for payer circle
        NSLayoutConstraint.activate([
            payerCircleView.widthAnchor.constraint(equalToConstant: 30),
            payerCircleView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Center the initials inside the payer's circle
        NSLayoutConstraint.activate([
            payerInitialsLabel.centerXAnchor.constraint(equalTo: payerCircleView.centerXAnchor),
            payerInitialsLabel.centerYAnchor.constraint(equalTo: payerCircleView.centerYAnchor)
        ])
        
        // Constraints for second row (payer, paid label, involvers, and amount)
        secondRowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secondRowStack.topAnchor.constraint(equalTo: firstRowStack.bottomAnchor, constant: 8),
            secondRowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            secondRowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            secondRowStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // Configure the cell with data
    func configure(billTitle: String, date: String, amount: String, payerName: String, involversCount: Int) {
        billTitleLabel.text = billTitle
        dateLabel.text = date
        amountLabel.text = "$\(amount)"
        
        // Set payer initials
        payerInitialsLabel.text = getInitials(from: payerName)
        
        // Reset involvers
        involversCircleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create orange circles for each involver
        for _ in 0..<involversCount {
            let involverCircle = UIView()
            involverCircle.layer.cornerRadius = 10
            involverCircle.backgroundColor = .systemRed
            involversCircleStackView.addArrangedSubview(involverCircle)
            involverCircle.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                involverCircle.widthAnchor.constraint(equalToConstant: 20),
                involverCircle.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
    }
    
    // Helper function to get initials from the payer's name
    private func getInitials(from name: String) -> String {
        let nameComponents = name.components(separatedBy: " ")
        let initials = nameComponents.compactMap { $0.first }.map { String($0) }.joined()
        return initials
    }
}
