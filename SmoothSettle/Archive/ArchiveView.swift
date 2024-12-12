//
//  ArchiveView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/14.
//


import UIKit

class ArchiveView: UIView {
    
    // UI Components
    let titleLabel = UILabel()
    let scrollView = UIScrollView()
    let contentView = UIView()
    let emptyStateLabel = UILabel()
    let emptyStateImageView = UIImageView()
    
    // Stack view to hold CardViews
    let stackView = UIStackView()
    
    // Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Colors.background0
        setBackgroundImage()
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setBackgroundImage()
        style()
        layout()
    }
       
    func setBackgroundImage() {
        let backgroundImageView = UIImageView()
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
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
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = String(localized: "archived_title")
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .left
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Content View inside Scroll View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Stack View
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        
        
        // Empty State Label
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = String(localized: "no_archived_trips")
        emptyStateLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        emptyStateLabel.textColor = Colors.primaryMedium
        emptyStateLabel.tintColor = Colors.primaryMedium
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true  // Hidden by default
        
        // Empty State Image View
                emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
                let trayImage = UIImage(systemName: "tray")
                emptyStateImageView.image = trayImage
                emptyStateImageView.contentMode = .scaleAspectFit
                emptyStateImageView.tintColor = Colors.primaryMedium // Set tint color if needed
                emptyStateImageView.isHidden = true  // Hidden by default
    }
    
    func layout() {
        addSubview(titleLabel)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        addSubview(emptyStateLabel)
        addSubview(emptyStateImageView)
        
        NSLayoutConstraint.activate([
            // Title Label Constraints
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            // Scroll View Constraints
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            // Content View Constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Stack View Constraints
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            emptyStateImageView.bottomAnchor.constraint(equalTo: emptyStateLabel.topAnchor, constant: -8),
            emptyStateImageView.heightAnchor.constraint(equalTo: emptyStateLabel.heightAnchor, multiplier: 2.5),
            emptyStateImageView.widthAnchor.constraint(equalTo: emptyStateLabel.heightAnchor, multiplier: 2.5)
        ])
    }
    
    // Method to add a year label to the stack view
    func addYearLabel(_ year: Int) {
        let yearLabel = UILabel()
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.text = "\(year)"
        yearLabel.font = UIFont.boldSystemFont(ofSize: 24)
        yearLabel.textColor = .darkGray
        stackView.addArrangedSubview(yearLabel)
    }
    
    // Method to add CardViews to the stack view
    func addCardViews(forTrips tripsByYear: [Int: [Trip]]) {
        clearCards()  // Clear the stack view first

        if tripsByYear.isEmpty {
            showEmptyState(true)
        } else {
            showEmptyState(false)
            // Iterate through each year and its trips
            for (year, trips) in tripsByYear.sorted(by: { $0.key > $1.key }) {
                // Add a year label
                addYearLabel(year)
                
                // Add a CardView for each trip in that year
                for trip in trips {
                    let cardView = CardView()
                    cardView.configure(with: trip)
                    addCardView(cardView)
                }
            }
        }
    }
    
    // Method to add a CardView to the stack view
    func addCardView(_ cardView: UIView) {
        stackView.addArrangedSubview(cardView)
    }
    
    // Method to clear all CardViews from the stack view
    func clearCards() {
        for subview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
    
    func showEmptyState(_ show: Bool) {
        emptyStateLabel.isHidden = !show
        emptyStateImageView.isHidden = !show
        stackView.isHidden = show
    }
}
