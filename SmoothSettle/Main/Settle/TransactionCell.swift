//
//  TransactionCell.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//
import UIKit

class TransactionCell: UITableViewCell {
    
    // SF Symbol ImageView
    let symbolImageView = UIImageView()
    
    // Labels for the transaction
    let toNameLabel = UILabel()
    let amountLabel = UILabel()
    let separatorLine = UIView() // Manual separator
    
    // Constraints for dynamic layout
    private var toNameWithSymbolConstraint: NSLayoutConstraint!
    private var toNameWithoutSymbolConstraint: NSLayoutConstraint!
    private var symbolWidthConstraint: NSLayoutConstraint!
    private var symbolWidthHiddenConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Set up the views including the symbolImageView
    private func setupViews() {
        // Configure symbolImageView
        symbolImageView.image = UIImage(systemName: "circle")
        symbolImageView.tintColor = Colors.accentYellow
        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        symbolImageView.isHidden = true // Hidden by default
        contentView.addSubview(symbolImageView)
        
        // Configure toNameLabel
        toNameLabel.font = UIFont.systemFont(ofSize: 16)
        toNameLabel.textColor = .black
        toNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(toNameLabel)
        
        // Configure amountLabel
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
        self.backgroundColor = Colors.background1 // Ensure Colors.background1 is defined
        self.layer.masksToBounds = false // Disable content clipping
    }
    
    // Set up the constraints for the symbolImageView, labels, and separator
    private func setupConstraints() {
        // Symbol ImageView Constraints
        symbolWidthConstraint = symbolImageView.widthAnchor.constraint(equalToConstant: 20)
        symbolWidthHiddenConstraint = symbolImageView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            symbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            symbolImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            symbolImageView.heightAnchor.constraint(equalToConstant: 20),
            // Initially hide the symbol
            symbolWidthHiddenConstraint
        ])
        
        // toNameLabel Constraints
        toNameWithSymbolConstraint = toNameLabel.leadingAnchor.constraint(equalTo: symbolImageView.trailingAnchor, constant: 8)
        toNameWithoutSymbolConstraint = toNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        NSLayoutConstraint.activate([
            // Initially, without symbol
            toNameWithoutSymbolConstraint,
            toNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        // amountLabel Constraints
        NSLayoutConstraint.activate([
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: toNameLabel.trailingAnchor, constant: 8)
        ])
        
        // Separator line constraints
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    // Method to configure the cell and apply rounded corners
    func configure(toName: String, amount: Double, isFirst: Bool, isLast: Bool, showSymbol: Bool, isSelected: Bool) {
        toNameLabel.text = toName
        amountLabel.text = String(format: "$%.2f", amount)

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
        
        // Show or hide the symbolImageView
        if showSymbol {
            symbolImageView.isHidden = false
            symbolWidthHiddenConstraint.isActive = false
            symbolWidthConstraint.isActive = true
            toNameWithoutSymbolConstraint.isActive = false
            toNameWithSymbolConstraint.isActive = true
            // Set the symbol based on selection state
            symbolImageView.image = isSelected ? UIImage(systemName: "circle.fill") : UIImage(systemName: "circle")
        } else {
            symbolImageView.isHidden = true
            symbolWidthConstraint.isActive = false
            symbolWidthHiddenConstraint.isActive = true
            toNameWithSymbolConstraint.isActive = false
            toNameWithoutSymbolConstraint.isActive = true
        }
        
        // Update layout
        setNeedsUpdateConstraints()
    }
}
