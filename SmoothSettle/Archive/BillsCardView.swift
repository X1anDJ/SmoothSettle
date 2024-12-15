// BillsCardView.swift
// SmoothSettle
//
// Created by Dajun Xian on 2024/10/XX.
//

import UIKit
class BillsCardView: UIView {
    
    // MARK: - UI Components
    private let shadowContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.layer.masksToBounds = false
        return view
    }()
    
    private let cardContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.background1
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    private let cardHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        // Enable user interaction
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let cardTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up the tray icon and text to match the main view
        let trayImageAttachment = NSTextAttachment()
        if let trayImage = UIImage(systemName: "tray.full.fill") {
            trayImageAttachment.image = trayImage.withTintColor(Colors.accentOrange, renderingMode: .alwaysOriginal)
            trayImageAttachment.bounds = CGRect(x: 0, y: -2, width: trayImage.size.width, height: trayImage.size.height)
        }
        
        let billsTextLocalized = String(localized: "Bills")
        let trayAttributedString = NSMutableAttributedString(attachment: trayImageAttachment)
        let billsText = NSAttributedString(string: "  \(billsTextLocalized)", attributes: [
            .foregroundColor: Colors.accentOrange,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ])
        trayAttributedString.append(billsText)
        label.attributedText = trayAttributedString
        
        return label
    }()
    
    let cardRightArrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = Colors.accentOrange
        // No target added here, since the entire header is now tappable
        return button
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    let customTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private let cardTailView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    let totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = String(localized: "Total")
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = Colors.primaryDark
        return label
    }()
    
    let totalAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "$0.00"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = Colors.accentOrange
        return label
    }()
    
    // MARK: - Closure to handle taps
    var onRightArrowTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        setupGesture()
    }
    
    private func setupViews() {
        addSubview(shadowContainerView)
        shadowContainerView.addSubview(cardContainerView)
        
        cardContainerView.addSubview(cardHeaderView)
        cardHeaderView.addSubview(cardTitleLabel)
        cardHeaderView.addSubview(cardRightArrowButton)
        
        cardContainerView.addSubview(customTableView)
        cardContainerView.addSubview(separatorLine)
        
        cardContainerView.addSubview(cardTailView)
        cardTailView.addSubview(totalLabel)
        cardTailView.addSubview(totalAmountLabel)
        
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            shadowContainerView.topAnchor.constraint(equalTo: self.topAnchor),
            shadowContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            shadowContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            shadowContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            cardContainerView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
            cardContainerView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor),
            cardContainerView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor),
            cardContainerView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor),
            
            cardHeaderView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            cardHeaderView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            cardHeaderView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            cardHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            cardTitleLabel.leadingAnchor.constraint(equalTo: cardHeaderView.leadingAnchor, constant: 16),
            cardTitleLabel.centerYAnchor.constraint(equalTo: cardHeaderView.centerYAnchor),
            
            cardRightArrowButton.trailingAnchor.constraint(equalTo: cardHeaderView.trailingAnchor, constant: -16),
            cardRightArrowButton.centerYAnchor.constraint(equalTo: cardHeaderView.centerYAnchor),
            
            customTableView.topAnchor.constraint(equalTo: cardHeaderView.bottomAnchor),
            customTableView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            customTableView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            customTableView.bottomAnchor.constraint(equalTo: separatorLine.topAnchor),
            
            separatorLine.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            separatorLine.bottomAnchor.constraint(equalTo: cardTailView.topAnchor),
            
            cardTailView.heightAnchor.constraint(equalToConstant: 44),
            cardTailView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            cardTailView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            cardTailView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor),
            
            totalAmountLabel.centerYAnchor.constraint(equalTo: cardTailView.centerYAnchor),
            totalAmountLabel.trailingAnchor.constraint(equalTo: cardTailView.trailingAnchor, constant: -16),
            
            totalLabel.centerYAnchor.constraint(equalTo: totalAmountLabel.centerYAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: totalAmountLabel.leadingAnchor, constant: -8)
        ])
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardHeaderTapped))
        cardHeaderView.addGestureRecognizer(tapGesture)
    }
    
    func configure(title: String, total: String, tableViewDelegate: UITableViewDelegate?, tableViewDataSource: UITableViewDataSource?) {

        let trayImageAttachment = NSTextAttachment()
        if let trayImage = UIImage(systemName: "tray.full.fill") {
            trayImageAttachment.image = trayImage.withTintColor(Colors.accentOrange, renderingMode: .alwaysOriginal)
            trayImageAttachment.bounds = CGRect(x: 0, y: -2, width: trayImage.size.width, height: trayImage.size.height)
        }
        
        let trayAttributedString = NSMutableAttributedString(attachment: trayImageAttachment)
        let billsText = NSAttributedString(string: "  \(title)", attributes: [
            .foregroundColor: Colors.accentOrange,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ])
        trayAttributedString.append(billsText)
        cardTitleLabel.attributedText = trayAttributedString
        
        totalAmountLabel.text = total
        
        customTableView.delegate = tableViewDelegate
        customTableView.dataSource = tableViewDataSource
        
        // Register the BillTableViewCell
        customTableView.register(BillTableViewCell.self, forCellReuseIdentifier: "BillCell")
    }
    
    @objc private func cardHeaderTapped() {
        // Trigger the closure
        onRightArrowTapped?()
    }
}
