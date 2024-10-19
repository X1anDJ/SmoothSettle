//
//  CardView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/14.
//

import Foundation
import UIKit

class CardView: UIView {
    
    // UI Components
    let shadowContainerView = UIView()
    let containerView = UIView()
    let cardHeaderView = UIView()
    let cardTitleLabel = UILabel()
    let cardTrailerView = UIView()
    let settledLabel = UILabel()
    let settledIconImageView = UIImageView()
    let dateLabel = UILabel()
    
    // Tap Action
    var onCardTapped: (() -> Void)?
    
    // Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        style()
        layout()
    }
    
    private func setup() {
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    private func style() {
        // Shadow Container View
        shadowContainerView.translatesAutoresizingMaskIntoConstraints = false
        shadowContainerView.backgroundColor = .clear
        shadowContainerView.layer.shadowColor = UIColor.black.cgColor
        shadowContainerView.layer.shadowOpacity = 0.1
        shadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowContainerView.layer.shadowRadius = 3
        shadowContainerView.layer.masksToBounds = false
        
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        
        // Card Header View
        cardHeaderView.translatesAutoresizingMaskIntoConstraints = false
        cardHeaderView.backgroundColor = .white
        
        // Card Title Label
        cardTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        // Card Trailer View
        cardTrailerView.translatesAutoresizingMaskIntoConstraints = false
        cardTrailerView.backgroundColor = .white
        
        // Date Label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        dateLabel.textColor = .systemGray
        
        // Settled Label
        settledLabel.translatesAutoresizingMaskIntoConstraints = false
        settledLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        // Settled Icon ImageView
        settledIconImageView.translatesAutoresizingMaskIntoConstraints = false
        settledIconImageView.contentMode = .scaleAspectFit
        
    }
    
    private func layout() {
        addSubview(shadowContainerView)
        shadowContainerView.addSubview(containerView)
        containerView.addSubview(cardHeaderView)
        containerView.addSubview(cardTrailerView)
        
        cardHeaderView.addSubview(cardTitleLabel)
        cardTrailerView.addSubview(dateLabel)
        cardTrailerView.addSubview(settledLabel)
        cardTrailerView.addSubview(settledIconImageView)
        
        NSLayoutConstraint.activate([
            // Shadow Container View
            shadowContainerView.topAnchor.constraint(equalTo: topAnchor),
            shadowContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shadowContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            shadowContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Container View
            containerView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor),
            
            // Card Header View
            cardHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            // Card Title Label
            cardTitleLabel.leadingAnchor.constraint(equalTo: cardHeaderView.leadingAnchor, constant: 16),
            cardTitleLabel.centerYAnchor.constraint(equalTo: cardHeaderView.centerYAnchor),
            
            // Card Trailer View
            cardTrailerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardTrailerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardTrailerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            cardTrailerView.heightAnchor.constraint(equalToConstant: 44),
            
            // Date Label
            dateLabel.leadingAnchor.constraint(equalTo: cardTrailerView.leadingAnchor, constant: 16),
            dateLabel.centerYAnchor.constraint(equalTo: cardTrailerView.centerYAnchor),
            
            // Settled Label
            settledLabel.trailingAnchor.constraint(equalTo: settledIconImageView.leadingAnchor, constant: -8),
            settledLabel.centerYAnchor.constraint(equalTo: cardTrailerView.centerYAnchor),
            
            // Settled Icon ImageView
            settledIconImageView.trailingAnchor.constraint(equalTo: cardTrailerView.trailingAnchor, constant: -16),
            settledIconImageView.centerYAnchor.constraint(equalTo: cardTrailerView.centerYAnchor),
            settledIconImageView.widthAnchor.constraint(equalToConstant: 24),
            settledIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Empty space (for future use)
            // Adjust as needed
            cardHeaderView.bottomAnchor.constraint(equalTo: cardTrailerView.topAnchor)
        ])
    }
    
    // MARK: - Configure Method
    func configure(with trip: Trip) {
        cardTitleLabel.text = trip.title
        
        // Format date to show only day and month
        if let tripDate = trip.date {
            dateLabel.text = tripDate.formatted(.dateTime.month(.abbreviated).day(.twoDigits))
        } else {
            dateLabel.text = "No Date"
        }
            
        if trip.settled {
            settledLabel.text = "Settled"
            settledLabel.textColor = .systemGreen
            settledIconImageView.image = UIImage(systemName: "checkmark.circle")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        } else {
            settledLabel.text = "Unsettled"
            settledLabel.textColor = .systemRed
            settledIconImageView.image = UIImage(systemName: "multiply.circle")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        }
    }
    
    // MARK: - Actions
    @objc private func cardTapped() {
        onCardTapped?()
    }
}
