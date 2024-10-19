//
//  MainView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//
import UIKit

class MainView: UIView {
    
    // UI Components
    let mainHeaderStackView = UIStackView()
    let titleLabel = UILabel()
    let userButton = UIButton(type: .system)
    let currentTripButton = UIButton()
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
    
    
    // Settle and addBill
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
        self.backgroundColor = .secondarySystemGroupedBackground
        let backgroundImageView = UIImageView()
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
//        backgroundImageView.image = UIImage(named: "background5")
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
        let currentTripText = NSMutableAttributedString(string: "Add a Trip")
        currentTripText.append(NSAttributedString(attachment: arrowIconAttachment))
        currentTripButton.setAttributedTitle(currentTripText, for: .normal)
        currentTripButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
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
        cardContainerView.backgroundColor = .white
        cardContainerView.layer.cornerRadius = 15
        cardContainerView.layer.masksToBounds = true

        // Header
        
        cardHeaderView.translatesAutoresizingMaskIntoConstraints = false
        cardHeaderView.backgroundColor = .white
        
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
        
        // Separator 2
        separatorLine2.translatesAutoresizingMaskIntoConstraints = false
        separatorLine2.backgroundColor = Colors.accentYellow
        
        // Tail
        cardTailView.translatesAutoresizingMaskIntoConstraints = false
        cardTailView.backgroundColor = .white
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.text = " "
//        totalLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        totalLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        totalLabel.textColor = Colors.primaryDark
        totalAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        totalAmountLabel.text = "$0.00"
        totalAmountLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        totalAmountLabel.textColor = Colors.accentOrange

        // -------------------------------------- Main Bottom --------------------------------------
        // Style the Settle Button
        settleButton.translatesAutoresizingMaskIntoConstraints = false
        settleButton.setTitle("Compute", for: .normal)
        settleButton.setImage(UIImage(systemName: "shuffle"), for: .normal)
        settleButton.layer.cornerRadius = 20
        settleButton.layer.borderWidth = 2
        settleButton.layer.borderColor = Colors.primaryDark.cgColor
        settleButton.setTitleColor(Colors.primaryDark, for: .normal)
        settleButton.tintColor = Colors.primaryDark
        settleButton.backgroundColor = .systemBackground
        settleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        // Style the Add Bill Button
        addBillButton.translatesAutoresizingMaskIntoConstraints = false
        addBillButton.setTitle("Bill", for: .normal)
        addBillButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addBillButton.layer.cornerRadius = 20
        addBillButton.tintColor = .systemBackground
        addBillButton.setTitleColor(.systemBackground, for: .normal)
        addBillButton.backgroundColor = Colors.primaryDark
        addBillButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        // Configure the buttons stack view
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 16
        buttonsStackView.distribution = .fillEqually

        buttonsStackView.addArrangedSubview(settleButton)
        buttonsStackView.addArrangedSubview(addBillButton)
    }

    func layout() {
        
        mainHeaderStackView.addArrangedSubview(titleLabel)
        mainHeaderStackView.addArrangedSubview(currentTripButton)
        
        cardHeaderView.addSubview(cardTitleLabel)
        cardHeaderView.addSubview(cardRightArrowButton)
        cardTailView.addSubview(totalLabel)
        cardTailView.addSubview(totalAmountLabel)
        cardContainerView.addSubview(cardHeaderView)
        cardContainerView.addSubview(customTableView)
        cardContainerView.addSubview(separatorLine2)
        cardContainerView.addSubview(cardTailView)
        shadowContainerView.addSubview(cardContainerView)


        addSubview(mainHeaderStackView)
        addSubview(userButton)
        addSubview(peopleSliderView)
        addSubview(shadowContainerView)
        
        addSubview(buttonsStackView)

        
        // Set up layout constraints
        NSLayoutConstraint.activate([
            mainHeaderStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            mainHeaderStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            userButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            userButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            userButton.widthAnchor.constraint(equalToConstant: 40),
            userButton.heightAnchor.constraint(equalToConstant: 40),
            
            peopleSliderView.topAnchor.constraint(equalTo: mainHeaderStackView.bottomAnchor, constant: 16),
            peopleSliderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            peopleSliderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            peopleSliderView.heightAnchor.constraint(equalToConstant: 70),

            shadowContainerView.topAnchor.constraint(equalTo: peopleSliderView.bottomAnchor, constant: 16),
            shadowContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            shadowContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            shadowContainerView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -24),

            cardContainerView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
            cardContainerView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor),
            cardContainerView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor),
            cardContainerView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor),

            // Card Header
            cardHeaderView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            cardHeaderView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            cardHeaderView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            cardHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            cardTitleLabel.leadingAnchor.constraint(equalTo: cardHeaderView.leadingAnchor, constant: 16),
            cardTitleLabel.centerYAnchor.constraint(equalTo: cardHeaderView.centerYAnchor),
            
            cardRightArrowButton.trailingAnchor.constraint(equalTo: cardHeaderView.trailingAnchor, constant: -16),
            cardRightArrowButton.centerYAnchor.constraint(equalTo: cardHeaderView.centerYAnchor),
            
            // Card Content
            customTableView.topAnchor.constraint(equalTo: cardHeaderView.bottomAnchor),
            customTableView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            customTableView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            customTableView.bottomAnchor.constraint(equalTo: separatorLine2.topAnchor),
//            customTableView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor),

            separatorLine2.bottomAnchor.constraint(equalTo: cardTailView.topAnchor),
            separatorLine2.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 16),
            separatorLine2.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),
            separatorLine2.heightAnchor.constraint(equalToConstant: 0),
            
            // Card Tail
            cardTailView.heightAnchor.constraint(equalToConstant: 44),
            cardTailView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            cardTailView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            cardTailView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor),
            
            totalAmountLabel.centerYAnchor.constraint(equalTo: cardTailView.centerYAnchor),
            totalAmountLabel.trailingAnchor.constraint(equalTo: cardTailView.trailingAnchor, constant: -16),
            
//            totalLabel.centerYAnchor.constraint(equalTo: cardTailView.centerYAnchor),
            totalLabel.bottomAnchor.constraint(equalTo: totalAmountLabel.bottomAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: totalAmountLabel.leadingAnchor, constant: -8),
            
            
            
            // Buttons Stack View Constraints
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
