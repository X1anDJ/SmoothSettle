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
    let archivedLabel = UILabel()
    let archivedIconImageView = UIImageView()
    let dateLabel = UILabel()
    
    // Tap Action
    var onCardTapped: (() -> Void)?
    var onLongPress: (() -> Void)?
    
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
        setupLongPressGesture()
        
    }
    
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        // Optionally, set minimum press duration
        longPressGesture.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        // Ensure the gesture is in the began state to avoid multiple triggers
        if gesture.state == .began {
            onLongPress?()
        }
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
        containerView.backgroundColor = Colors.background1
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        
        // Card Header View
        cardHeaderView.translatesAutoresizingMaskIntoConstraints = false
        cardHeaderView.backgroundColor = Colors.background1
        
        // Card Title Label
        cardTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        // Card Trailer View
        cardTrailerView.translatesAutoresizingMaskIntoConstraints = false
        cardTrailerView.backgroundColor = Colors.background1
        
        // Date Label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        dateLabel.textColor = .systemGray
        
        // archived Label
                archivedLabel.translatesAutoresizingMaskIntoConstraints = false
                archivedLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        // archived Icon ImageView
        archivedIconImageView.translatesAutoresizingMaskIntoConstraints = false
        archivedIconImageView.contentMode = .scaleAspectFit
        
    }
    
    private func layout() {
        addSubview(shadowContainerView)
        shadowContainerView.addSubview(containerView)
        containerView.addSubview(cardHeaderView)
        containerView.addSubview(cardTrailerView)
        
        cardHeaderView.addSubview(cardTitleLabel)
        cardTrailerView.addSubview(dateLabel)
        cardTrailerView.addSubview(        archivedLabel)
        cardTrailerView.addSubview(archivedIconImageView)
        
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
            
            // archived Label
                    archivedLabel.trailingAnchor.constraint(equalTo: archivedIconImageView.leadingAnchor, constant: -4),
                    archivedLabel.centerYAnchor.constraint(equalTo: cardTrailerView.centerYAnchor),
            
            // archived Icon ImageView
            archivedIconImageView.trailingAnchor.constraint(equalTo: cardTrailerView.trailingAnchor, constant: -16),
            archivedIconImageView.centerYAnchor.constraint(equalTo: cardTrailerView.centerYAnchor),
            archivedIconImageView.widthAnchor.constraint(equalToConstant: 18),
            archivedIconImageView.heightAnchor.constraint(equalToConstant: 18),
            
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
            archivedLabel.text = "Settled"
            archivedLabel.textColor = Colors.lightGreen
            archivedIconImageView.image = UIImage(systemName: "checkmark.circle")?.withTintColor(Colors.lightGreen, renderingMode: .alwaysOriginal)
        } else {
            archivedLabel.text = "Unsettled"
            archivedLabel.textColor = Colors.accentOrange
            archivedIconImageView.image = UIImage(systemName: "minus.circle")?.withTintColor(Colors.accentOrange, renderingMode: .alwaysOriginal)
        }
    }
    
    // MARK: - Actions
    @objc private func cardTapped() {
        onCardTapped?()
    }
}
