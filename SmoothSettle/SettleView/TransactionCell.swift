//
//  TransactionCell.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//
import UIKit

class TransactionCell: UITableViewCell {

    // Labels for the transaction
    let toNameLabel = UILabel()
    let amountLabel = UILabel()
    let separatorLine = UIView() // Manual separator

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Set up the labels
    private func setupViews() {
        toNameLabel.font = UIFont.systemFont(ofSize: 16)
        toNameLabel.textColor = .black
        toNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(toNameLabel)
        
        amountLabel.font = UIFont.systemFont(ofSize: 16)
        amountLabel.textColor = .darkGray
        amountLabel.textAlignment = .right
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(amountLabel)

        // Add separator line
        separatorLine.backgroundColor = UIColor.separator
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorLine)

        // Background color and shadow for the rounded section look
        self.backgroundColor = .systemBackground // Cell's background is clear
        self.layer.masksToBounds = false // Disable content clipping
    }

    // Set up the constraints for the labels and separator
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            toNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            toNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            // Separator line constraints
            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    // Method to configure the cell and apply rounded corners
    func configure(toName: String, amount: Double, isFirst: Bool, isLast: Bool) {
        toNameLabel.text = toName
        amountLabel.text = String(format: "%.2f USD", amount)

        // Reset corners before applying new ones
        self.layer.cornerRadius = 0
        self.layer.maskedCorners = []

        // Apply corner radius for first and last cells
        if isFirst && isLast {
            self.layer.cornerRadius = 12
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            self.layer.cornerRadius = 12
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            self.layer.cornerRadius = 12
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }

        // Hide separator for last cell in a section
        separatorLine.isHidden = isLast
    }
}
