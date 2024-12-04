//
//  MainView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//

import UIKit

class MainView: UIView {
    
    // MARK: - UI Components
    
    // Main Header
    let mainHeaderStackView = UIStackView()
    let titleLabel = UILabel()
    let userButton = UIButton(type: .system)
    let currentTripButton = UIButton(type: .system)
    let peopleSliderView = PeopleSliderView()
    
    // Card
    let shadowContainerView = UIView()
    let cardContainerView = UIView()
    let cardHeaderView = UIView()
    let cardTitleLabel = UILabel()
    let cardRightArrowButton = UIButton(type: .system)
    let separatorLine1 = UIView()
    let customTableView = UITableView()
    let separatorLine2 = UIView()
    let cardTailView = UIView()
    let totalLabel = UILabel()
    let totalAmountLabel = UILabel()
    
    // Archive and AddBill Buttons with Shadow Containers
    let archiveButtonShadowContainer = UIView()
    let addBillButtonShadowContainer = UIView()
    let computeButton = UIButton(type: .system)
    let addBillButton = UIButton(type: .system)
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setBackgroundImage()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods
    
    func setBackgroundImage() {
        self.backgroundColor = Colors.background0
        let backgroundImageView = UIImageView()
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
//         Background image
         backgroundImageView.image = UIImage(named: "backgroundGradient")
        backgroundImageView.contentMode = .scaleAspectFill
        self.addSubview(backgroundImageView)
        self.sendSubviewToBack(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func style() {
        // -------------------------------------- Main Header --------------------------------------
        // Configure the main UI components
        mainHeaderStackView.translatesAutoresizingMaskIntoConstraints = false
        mainHeaderStackView.axis = .vertical
        mainHeaderStackView.spacing = 16
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Current Trip"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .left
        
        userButton.translatesAutoresizingMaskIntoConstraints = false
        userButton.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        userButton.tintColor = Colors.primaryDark
        userButton.layer.cornerRadius = 20
        userButton.clipsToBounds = true
        userButton.imageView?.contentMode = .scaleAspectFill
        userButton.contentHorizontalAlignment = .fill
        userButton.contentVerticalAlignment = .fill
        
        currentTripButton.translatesAutoresizingMaskIntoConstraints = false
        let arrowIconAttachment = NSTextAttachment()
        arrowIconAttachment.image = UIImage(systemName: "chevron.down")
        let currentTripText = NSMutableAttributedString(string: "Add a Trip ")
        currentTripText.append(NSAttributedString(attachment: arrowIconAttachment))
        currentTripButton.setAttributedTitle(currentTripText, for: .normal)
        currentTripButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        currentTripButton.tintColor = Colors.primaryDark
        currentTripButton.contentHorizontalAlignment = .left

        peopleSliderView.translatesAutoresizingMaskIntoConstraints = false
        
        // -------------------------------------- Card --------------------------------------
        
        // Shadow + Card Container
        shadowContainerView.translatesAutoresizingMaskIntoConstraints = false
        shadowContainerView.backgroundColor = .clear
        shadowContainerView.layer.shadowColor = UIColor.black.cgColor
        shadowContainerView.layer.shadowOpacity = 0.1
        shadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowContainerView.layer.shadowRadius = 5
        shadowContainerView.layer.masksToBounds = false

        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardContainerView.backgroundColor = Colors.background1
        cardContainerView.layer.cornerRadius = 15
        cardContainerView.layer.masksToBounds = true

        // Header
        cardHeaderView.translatesAutoresizingMaskIntoConstraints = false
        cardHeaderView.backgroundColor = .clear
        
        cardTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        let trayImageAttachment = NSTextAttachment()
        if let trayImage = UIImage(systemName: "tray.full.fill") {
            trayImageAttachment.image = trayImage.withTintColor(Colors.accentOrange, renderingMode: .alwaysOriginal)
            trayImageAttachment.bounds = CGRect(x: 0, y: -2, width: trayImage.size.width, height: trayImage.size.height)
        }
        let trayAttributedString = NSMutableAttributedString(attachment: trayImageAttachment)
        let billsText = NSAttributedString(string: "  Bills", attributes: [
            .foregroundColor: Colors.accentOrange,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ])
        trayAttributedString.append(billsText)
        cardTitleLabel.attributedText = trayAttributedString

        cardRightArrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        cardRightArrowButton.translatesAutoresizingMaskIntoConstraints = false
        cardRightArrowButton.tintColor = .systemGray

        // Table
        customTableView.translatesAutoresizingMaskIntoConstraints = false
        customTableView.register(UITableViewCell.self, forCellReuseIdentifier: "BillCell")
        customTableView.backgroundColor = .clear

        // Separator 2
        separatorLine2.translatesAutoresizingMaskIntoConstraints = false
        separatorLine2.backgroundColor = Colors.accentYellow

        // Tail
        cardTailView.translatesAutoresizingMaskIntoConstraints = false
        cardTailView.backgroundColor = .clear
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.text = " "
        totalLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        totalLabel.textColor = Colors.primaryDark
        totalAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        totalAmountLabel.text = "$0.00"
        totalAmountLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        totalAmountLabel.textColor = Colors.accentOrange

        // -------------------------------------- Archive and AddBill Buttons --------------------------------------
        // Style the Archive Button
        computeButton.translatesAutoresizingMaskIntoConstraints = false
        computeButton.setTitle("Compute", for: .normal)
        computeButton.setImage(UIImage(systemName: "shuffle"), for: .normal)
        computeButton.layer.cornerRadius = 15
//        computeButton.layer.borderWidth = 0
//        computeButton.layer.borderColor = Colors.primaryDark.cgColor
        computeButton.setTitleColor(Colors.primaryDark, for: .normal)
        computeButton.tintColor = Colors.primaryDark
        computeButton.backgroundColor = Colors.background1
        computeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        // archiveButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        // Style the Add Bill Button
        addBillButton.translatesAutoresizingMaskIntoConstraints = false
        addBillButton.setTitle("Bill", for: .normal)
        addBillButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addBillButton.layer.cornerRadius = 15
        addBillButton.tintColor = Colors.background1
        addBillButton.setTitleColor(Colors.background1, for: .normal)
        addBillButton.backgroundColor = Colors.primaryDark
        addBillButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        // addBillButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        // -------------------------------------- Shadow Containers for Buttons --------------------------------------
        // archive Button Shadow Container
        archiveButtonShadowContainer.translatesAutoresizingMaskIntoConstraints = false
        archiveButtonShadowContainer.backgroundColor = .clear
        archiveButtonShadowContainer.layer.shadowColor = UIColor.black.cgColor
        archiveButtonShadowContainer.layer.shadowOpacity = 0.2
        archiveButtonShadowContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        archiveButtonShadowContainer.layer.shadowRadius = 5
        archiveButtonShadowContainer.layer.masksToBounds = false

        // Add Bill Button Shadow Container
        addBillButtonShadowContainer.translatesAutoresizingMaskIntoConstraints = false
        addBillButtonShadowContainer.backgroundColor = .clear
        addBillButtonShadowContainer.layer.shadowColor = UIColor.black.cgColor
        addBillButtonShadowContainer.layer.shadowOpacity = 0.2
        addBillButtonShadowContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        addBillButtonShadowContainer.layer.shadowRadius = 5
        addBillButtonShadowContainer.layer.masksToBounds = false
    }
    
    func layout() {
        // -------------------------------------- Main Header Layout --------------------------------------
        mainHeaderStackView.addArrangedSubview(titleLabel)
        mainHeaderStackView.addArrangedSubview(currentTripButton)
        
        // Add subviews to card header
        cardHeaderView.addSubview(cardTitleLabel)
        cardHeaderView.addSubview(cardRightArrowButton)
        
        // Add subviews to card tail view
        cardTailView.addSubview(totalLabel)
        cardTailView.addSubview(totalAmountLabel)
        
        // Add subviews to card container
        cardContainerView.addSubview(cardHeaderView)
        cardContainerView.addSubview(customTableView)
        cardContainerView.addSubview(separatorLine2)
        cardContainerView.addSubview(cardTailView)
        
        // Add card container to its shadow container
        shadowContainerView.addSubview(cardContainerView)

        // Add buttons to their shadow containers
        archiveButtonShadowContainer.addSubview(computeButton)
        addBillButtonShadowContainer.addSubview(addBillButton)

        // Add main subviews to the main view
        addSubview(mainHeaderStackView)
        addSubview(userButton)
        addSubview(peopleSliderView)
        addSubview(shadowContainerView)
        addSubview(archiveButtonShadowContainer)
        addSubview(addBillButtonShadowContainer)

        // -------------------------------------- Layout Constraints --------------------------------------
        NSLayoutConstraint.activate([
            // Main Header Stack View Constraints
            mainHeaderStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            mainHeaderStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainHeaderStackView.trailingAnchor.constraint(lessThanOrEqualTo: userButton.leadingAnchor, constant: -16),
            
            // User Button Constraints
            userButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            userButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            userButton.widthAnchor.constraint(equalToConstant: 40),
            userButton.heightAnchor.constraint(equalToConstant: 40),
            
            // People Slider View Constraints
            peopleSliderView.topAnchor.constraint(equalTo: mainHeaderStackView.bottomAnchor, constant: 16),
            peopleSliderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            peopleSliderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            peopleSliderView.heightAnchor.constraint(equalToConstant: 70),

            // ---------------------- Card ----------------------
            // Shadow Container for Card Constraints
            shadowContainerView.topAnchor.constraint(equalTo: peopleSliderView.bottomAnchor, constant: 16),
            shadowContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            shadowContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            shadowContainerView.bottomAnchor.constraint(equalTo: archiveButtonShadowContainer.topAnchor, constant: -24),

            // Card Container Constraints
            cardContainerView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
            cardContainerView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor),
            cardContainerView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor),
            cardContainerView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor),

            // Card Header Constraints
            cardHeaderView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            cardHeaderView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            cardHeaderView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            cardHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            cardTitleLabel.leadingAnchor.constraint(equalTo: cardHeaderView.leadingAnchor, constant: 16),
            cardTitleLabel.centerYAnchor.constraint(equalTo: cardHeaderView.centerYAnchor),
            
            cardRightArrowButton.trailingAnchor.constraint(equalTo: cardHeaderView.trailingAnchor, constant: -16),
            cardRightArrowButton.centerYAnchor.constraint(equalTo: cardHeaderView.centerYAnchor),

            // Custom Table View Constraints
            customTableView.topAnchor.constraint(equalTo: cardHeaderView.bottomAnchor),
            customTableView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            customTableView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            customTableView.bottomAnchor.constraint(equalTo: separatorLine2.topAnchor),

            // Separator Line 2 Constraints
            separatorLine2.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 16),
            separatorLine2.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),
            separatorLine2.heightAnchor.constraint(equalToConstant: 0),
            separatorLine2.bottomAnchor.constraint(equalTo: cardTailView.topAnchor),

            // Card Tail View Constraints
            cardTailView.heightAnchor.constraint(equalToConstant: 44),
            cardTailView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            cardTailView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            cardTailView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor),
            
            totalAmountLabel.centerYAnchor.constraint(equalTo: cardTailView.centerYAnchor),
            totalAmountLabel.trailingAnchor.constraint(equalTo: cardTailView.trailingAnchor, constant: -16),
            
            totalLabel.centerYAnchor.constraint(equalTo: totalAmountLabel.centerYAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: totalAmountLabel.leadingAnchor, constant: -8),
            
            // ---------------------- Archive and AddBill Buttons ----------------------

            // Settle Button Shadow Container Constraints
            archiveButtonShadowContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            archiveButtonShadowContainer.trailingAnchor.constraint(equalTo: addBillButtonShadowContainer.leadingAnchor, constant: -16),
            archiveButtonShadowContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24),
            archiveButtonShadowContainer.heightAnchor.constraint(equalToConstant: 44),
            archiveButtonShadowContainer.widthAnchor.constraint(equalTo: addBillButtonShadowContainer.widthAnchor),
            
            // Archive Button Constraints within its Shadow Container
//            computeButton.centerXAnchor.constraint(equalTo: archiveButtonShadowContainer.centerXAnchor),
//            computeButton.centerYAnchor.constraint(equalTo: archiveButtonShadowContainer.centerYAnchor, constant: -22),
//            computeButton.widthAnchor.constraint(equalTo: archiveButtonShadowContainer.widthAnchor, multiplier: 0.45),
//            computeButton.heightAnchor.constraint(equalTo: archiveButtonShadowContainer.heightAnchor, multiplier: 0.9),
            
            computeButton.topAnchor.constraint(equalTo: archiveButtonShadowContainer.topAnchor),
            computeButton.leadingAnchor.constraint(equalTo: archiveButtonShadowContainer.leadingAnchor),
            computeButton.trailingAnchor.constraint(equalTo: archiveButtonShadowContainer.trailingAnchor),
            computeButton.bottomAnchor.constraint(equalTo: archiveButtonShadowContainer.bottomAnchor),
            
            // Add Bill Button Shadow Container Constraints
//            addBillButtonShadowContainer.leadingAnchor.constraint(equalTo: archiveButtonShadowContainer.trailingAnchor, constant: 16),
//            addBillButtonShadowContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            addBillButtonShadowContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24),
//            addBillButtonShadowContainer.heightAnchor.constraint(equalToConstant: 44),
            addBillButtonShadowContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            addBillButtonShadowContainer.heightAnchor.constraint(equalTo: archiveButtonShadowContainer.heightAnchor),
            addBillButtonShadowContainer.widthAnchor.constraint(equalTo: archiveButtonShadowContainer.widthAnchor),
            addBillButtonShadowContainer.centerYAnchor.constraint(equalTo: archiveButtonShadowContainer.centerYAnchor),
            
//            // Add Bill Button Constraints within its Shadow Container
//            addBillButton.centerXAnchor.constraint(equalTo: addBillButtonShadowContainer.centerXAnchor),
//            addBillButton.centerYAnchor.constraint(equalTo: addBillButtonShadowContainer.centerYAnchor, constant: -22),
//            addBillButton.widthAnchor.constraint(equalTo: addBillButtonShadowContainer.widthAnchor, multiplier: 0.45),
//            addBillButton.heightAnchor.constraint(equalTo: addBillButtonShadowContainer.heightAnchor, multiplier: 0.9),
                
                addBillButton.topAnchor.constraint(equalTo: addBillButtonShadowContainer.topAnchor),
                addBillButton.leadingAnchor.constraint(equalTo: addBillButtonShadowContainer.leadingAnchor),
                addBillButton.trailingAnchor.constraint(equalTo: addBillButtonShadowContainer.trailingAnchor),
                addBillButton.bottomAnchor.constraint(equalTo: addBillButtonShadowContainer.bottomAnchor)
        ])
    }
}
