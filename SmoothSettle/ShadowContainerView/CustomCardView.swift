////
////  CustomCardView.swift
////  SmoothSettle
////
////  Created by Dajun Xian on 2024/10/23.
////
//
//import UIKit
//
//class CustomCardView: UIView {
//    
//    // MARK: - UI Components
//    private let shadowContainerView = UIView()
//    private let containerView = UIView()
//    private let cardHeaderView = UIView()
//    private let cardTitleLabel = UILabel()
//    private let cardRightArrowButton = UIButton(type: .system)
//    let tableView = UITableView()
//    
//    // MARK: - Configuration Properties
//    var cardTitle: String? {
//        didSet {
//            updateCardTitle()
//        }
//    }
//    
//    var cardImage: UIImage? {
//        didSet {
//            updateCardTitle()
//        }
//    }
//    
//    var onCardTapped: (() -> Void)?
//    
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//        style()
//        layout()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setup()
//        style()
//        layout()
//    }
//    
//    // MARK: - Setup
//    private func setup() {
//        // Add tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
//        self.addGestureRecognizer(tapGesture)
//        
//        // Button action
//        cardRightArrowButton.addTarget(self, action: #selector(cardTapped), for: .touchUpInside)
//    }
//    
//    // MARK: - Style
//    private func style() {
//        // Shadow Container View
//        shadowContainerView.translatesAutoresizingMaskIntoConstraints = false
//        shadowContainerView.backgroundColor = .clear
//        shadowContainerView.layer.shadowColor = UIColor.black.cgColor
//        shadowContainerView.layer.shadowOpacity = 0.1
//        shadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        shadowContainerView.layer.shadowRadius = 5
//        shadowContainerView.layer.masksToBounds = false
//        
//        // Container View
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.backgroundColor = .white
//        containerView.layer.cornerRadius = 15
//        containerView.layer.masksToBounds = true
//        
//        // Card Header View
//        cardHeaderView.translatesAutoresizingMaskIntoConstraints = false
//        cardHeaderView.backgroundColor = .white
//        
//        // Card Title Label
//        cardTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        cardTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
//        
//        // Card Right Arrow Button
//        cardRightArrowButton.translatesAutoresizingMaskIntoConstraints = false
//        cardRightArrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
//        cardRightArrowButton.tintColor = .systemGray
//        
//        // Table View
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//    }
//    
//    // MARK: - Layout
//    private func layout() {
//        addSubview(shadowContainerView)
//        shadowContainerView.addSubview(containerView)
//        containerView.addSubview(cardHeaderView)
//        containerView.addSubview(tableView)
//        cardHeaderView.addSubview(cardTitleLabel)
//        cardHeaderView.addSubview(cardRightArrowButton)
//        
//        NSLayoutConstraint.activate([
//            // Shadow Container View
//            shadowContainerView.topAnchor.constraint(equalTo: topAnchor),
//            shadowContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            shadowContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            shadowContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            
//            // Container View
//            containerView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
//            containerView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor),
//            containerView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor),
//            
//            // Card Header View
//            cardHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
//            cardHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//            cardHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            cardHeaderView.heightAnchor.constraint(equalToConstant: 44),
//            
//            // Card Title Label
//            cardTitleLabel.leadingAnchor.constraint(equalTo: cardHeaderView.leadingAnchor, constant: 16),
//            cardTitleLabel.centerYAnchor.constraint(equalTo: cardHeaderView.centerYAnchor),
//            
//            // Card Right Arrow Button
//            cardRightArrowButton.trailingAnchor.constraint(equalTo: cardHeaderView.trailingAnchor, constant: -16),
//            cardRightArrowButton.centerYAnchor.constraint(equalTo: cardHeaderView.centerYAnchor),
//            
//            // Table View
//            tableView.topAnchor.constraint(equalTo: cardHeaderView.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
//        ])
//    }
//    
//    // MARK: - Actions
//    @objc private func cardTapped() {
//        onCardTapped?()
//    }
//    
//    // MARK: - Helper Methods
//    private func updateCardTitle() {
//        let attributedString = NSMutableAttributedString()
//        
//        if let image = cardImage {
//            let imageAttachment = NSTextAttachment()
//            imageAttachment.image = image.withTintColor(Colors.primaryThin, renderingMode: .alwaysOriginal)
//            imageAttachment.bounds = CGRect(x: 0, y: -2, width: image.size.width, height: image.size.height)
//            attributedString.append(NSAttributedString(attachment: imageAttachment))
//        }
//        
//        if let title = cardTitle {
//            let titleString = NSAttributedString(string: "  \(title)", attributes: [
//                .foregroundColor: Colors.primaryThin,
//                .font: UIFont.preferredFont(forTextStyle: .headline)
//            ])
//            attributedString.append(titleString)
//        }
//        
//        cardTitleLabel.attributedText = attributedString
//    }
//}
