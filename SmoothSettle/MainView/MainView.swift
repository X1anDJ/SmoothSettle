//
//  MainView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//
import UIKit

class MainView: UIView {
    
    // UI Components
    let stackView = UIStackView()
    let titleLabel = UILabel()
    let userButton = UIButton(type: .system)
    let currentTripButton = UIButton()
    let peopleSliderView = PeopleSliderView()
    
    // card
    let cardHeaderView = UIView()
    let cardTitleLabel = UILabel()
    let cardRightArrowButton = UIButton(type: .system)
    let shadowContainerView = UIView()
    let containerView = UIView()
    let customTableView = UITableView()
    
    // settle and addBill
    let settleButton = UIButton(type: .system)
    let addBillButton = UIButton(type: .system)
    let buttonsStackView = UIStackView()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setBackgroundImage()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setBackgroundImage() {
        let backgroundImageView = UIImageView()
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = UIImage(named: "background5")
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
        // Configure the main UI components
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Current Trip"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
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
        let currentTripText = NSMutableAttributedString(string: "Add a Trip")
        currentTripText.append(NSAttributedString(attachment: arrowIconAttachment))
        currentTripButton.setAttributedTitle(currentTripText, for: .normal)
        currentTripButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        currentTripButton.contentHorizontalAlignment = .left

        peopleSliderView.translatesAutoresizingMaskIntoConstraints = false

        // Style the card header view
        cardHeaderView.translatesAutoresizingMaskIntoConstraints = false
        cardHeaderView.backgroundColor = .white
        
        cardTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        let trayImageAttachment = NSTextAttachment()
        if let trayImage = UIImage(systemName: "tray.full.fill") {
            trayImageAttachment.image = trayImage.withTintColor(Colors.primaryThin, renderingMode: .alwaysOriginal)
            trayImageAttachment.bounds = CGRect(x: 0, y: -2, width: trayImage.size.width, height: trayImage.size.height)
        }

        let trayAttributedString = NSMutableAttributedString(attachment: trayImageAttachment)

        let billsText = NSAttributedString(string: "  Bills", attributes: [
            .foregroundColor: Colors.primaryThin,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ])

        trayAttributedString.append(billsText)
        cardTitleLabel.attributedText = trayAttributedString

        cardRightArrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        cardRightArrowButton.translatesAutoresizingMaskIntoConstraints = false
        cardRightArrowButton.tintColor = .systemGray

        shadowContainerView.translatesAutoresizingMaskIntoConstraints = false
        shadowContainerView.backgroundColor = .clear
        shadowContainerView.layer.shadowColor = UIColor.black.cgColor
        shadowContainerView.layer.shadowOpacity = 0.1
        shadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowContainerView.layer.shadowRadius = 5
        shadowContainerView.layer.masksToBounds = false

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = true

        customTableView.translatesAutoresizingMaskIntoConstraints = false
        customTableView.register(UITableViewCell.self, forCellReuseIdentifier: "BillCell")

        // Style the Settle Button
        settleButton.translatesAutoresizingMaskIntoConstraints = false
        settleButton.layer.cornerRadius = 20
        settleButton.layer.borderWidth = 2
        settleButton.layer.borderColor = Colors.primaryMedium.cgColor
        settleButton.setTitleColor(Colors.primaryMedium, for: .normal)
        settleButton.setTitle(" Settle", for: .normal)
        settleButton.setImage(UIImage(systemName: "shuffle"), for: .normal)
        settleButton.tintColor = Colors.primaryMedium
        settleButton.backgroundColor = .systemBackground

        // Style the Add Bill Button
        addBillButton.translatesAutoresizingMaskIntoConstraints = false
        addBillButton.layer.cornerRadius = 20
        addBillButton.setTitle(" Bill", for: .normal)
        addBillButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addBillButton.tintColor = .systemBackground
        addBillButton.setTitleColor(.systemBackground, for: .normal)
        addBillButton.backgroundColor = Colors.primaryMedium
        addBillButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        addBillButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

        // Configure the buttons stack view
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 16
        buttonsStackView.distribution = .fillEqually

        buttonsStackView.addArrangedSubview(settleButton)
        buttonsStackView.addArrangedSubview(addBillButton)
    }

    func layout() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(currentTripButton)
        
        addSubview(userButton)
        addSubview(stackView)
        addSubview(peopleSliderView)
        addSubview(shadowContainerView)
        addSubview(buttonsStackView)
        
        shadowContainerView.addSubview(containerView)

        containerView.addSubview(cardHeaderView)
        containerView.addSubview(customTableView)

        cardHeaderView.addSubview(cardTitleLabel)
        cardHeaderView.addSubview(cardRightArrowButton)
        
        // Set up layout constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            userButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            userButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            userButton.widthAnchor.constraint(equalToConstant: 40),
            userButton.heightAnchor.constraint(equalToConstant: 40),
            
            peopleSliderView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            peopleSliderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            peopleSliderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            peopleSliderView.heightAnchor.constraint(equalToConstant: 80),

            shadowContainerView.topAnchor.constraint(equalTo: peopleSliderView.bottomAnchor, constant: 16),
            shadowContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            shadowContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            shadowContainerView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -24),

            containerView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor),

            cardHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            cardHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cardHeaderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cardHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            cardTitleLabel.leadingAnchor.constraint(equalTo: cardHeaderView.leadingAnchor, constant: 16),
            cardTitleLabel.centerYAnchor.constraint(equalTo: cardHeaderView.centerYAnchor),
            
            cardRightArrowButton.trailingAnchor.constraint(equalTo: cardHeaderView.trailingAnchor, constant: -16),
            cardRightArrowButton.centerYAnchor.constraint(equalTo: cardHeaderView.centerYAnchor),

            customTableView.topAnchor.constraint(equalTo: cardHeaderView.bottomAnchor),
            customTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            customTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            customTableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Buttons Stack View Constraints
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
