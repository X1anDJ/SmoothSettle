//
//  SettleViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//

import UIKit
import Combine

class SettleViewController: UIViewController {

    // UI Elements
    let scrollView = UIScrollView()  // Scroll view to hold the content
    let contentView = UIView()  // Content view inside the scroll view
    let circleLayoutView = CircleLayoutView()  // Custom circle layout view
    let transactionsTableView = TransactionsTableView() // Transactions table view
    let settleButton = UIButton(type: .system)
    let closeButton = UIButton(type: .system)
    let buttonsView = UIStackView()
    
    // Reference to the MainViewModel
    var viewModel: MainViewModel?

    // Add a PassthroughSubject to notify MainViewController
    var settleSubject = PassthroughSubject<Void, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the view background and style
        view.backgroundColor = Colors.background0

        setupViews()
        setupConstraints()

        // Fetch the people in the trip and pass their UUIDs to the CircleLayoutView
        if let viewModel = viewModel, let currentTripId = viewModel.currentTripId {
            // Fetch the current trip from the repository using the currentTripId
            if let currentTrip = viewModel.tripRepository.fetchTrip(by: currentTripId) {
                let userIds = currentTrip.peopleArray.compactMap { $0.id }  // Get UUIDs of people
                circleLayoutView.userIds = userIds  // Set the UUIDs to the custom view

                // Pass the repository and current trip to the TransactionsTableView
                transactionsTableView.tripRepository = viewModel.tripRepository
                transactionsTableView.currentTrip = currentTripId
                transactionsTableView.isSelectable = false
                // Load transactions and pass them to CircleLayoutView via the completion handler
                transactionsTableView.loadTransactions { [weak self] sections in
                    self?.circleLayoutView.transactions = sections
                }
            }
        }
    }

    // Function to check if scrolling is needed
    func scrollingIsNeeded() -> Bool {
        return scrollView.contentSize.height > scrollView.bounds.height
    }

    // Setup UI elements
    func setupViews() {
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Circle Layout View
        circleLayoutView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(circleLayoutView)

        // Transactions Table View
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        transactionsTableView.isScrollEnabled = false  // Disable scrolling within the table to avoid conflicts
        contentView.addSubview(transactionsTableView)

        // Settle Button
        settleButton.translatesAutoresizingMaskIntoConstraints = false
        settleButton.setTitle("Archive", for: .normal)
        settleButton.setTitleColor(.white, for: .normal)
        settleButton.backgroundColor = Colors.primaryDark
        settleButton.layer.cornerRadius = 22
        settleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        settleButton.addTarget(self, action: #selector(didTapSettleTrip), for: .touchUpInside)

        // Close Button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(Colors.primaryDark, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        // Buttons View
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.axis = .vertical
        buttonsView.spacing = 8
        buttonsView.distribution = .fillProportionally  // Or .fill depending on desired behavior
        buttonsView.addArrangedSubview(settleButton)
        buttonsView.addArrangedSubview(closeButton)
        
        contentView.addSubview(buttonsView)
    }

    // Setup layout constraints
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View Constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Content View Constraints (using contentLayoutGuide)
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // Content View Width Constraint (using frameLayoutGuide)
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // **Ensure contentView's height is at least as tall as scrollView's frame**
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),
            
            // Circle Layout View Constraints
            circleLayoutView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            circleLayoutView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleLayoutView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            circleLayoutView.heightAnchor.constraint(equalTo: circleLayoutView.widthAnchor),  // Make it a square

            // Transactions Table View Constraints
            transactionsTableView.topAnchor.constraint(equalTo: circleLayoutView.bottomAnchor, constant: 24),
            transactionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transactionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Buttons View Constraints
            buttonsView.topAnchor.constraint(equalTo: transactionsTableView.bottomAnchor, constant: 24),
            buttonsView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buttonsView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),

            // **Remove** the fixed height constraint on buttonsView
            // buttonsView.heightAnchor.constraint(equalToConstant: 48),
            
            // Maintain a bottom constraint to contentView
            buttonsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            // Set buttons' heights
            settleButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // Action to settle the trip
    @objc func didTapSettleTrip() {
        guard let viewModel = viewModel else { return }
        
        // Settle the current trip
        viewModel.settleCurrentTrip()
        
        // Notify MainViewController about the trip settlement
        settleSubject.send(())
        
        // Dismiss this view controller
        dismiss(animated: true, completion: nil)
    }
    
    // Action to dismiss the view controller
    @objc func closeButtonTapped() {
//        print("Close button tapped")
        dismiss(animated: true, completion: nil)
    }

    // Update scrolling status after layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollingStatus()
    }
    
    func updateScrollingStatus() {
        let canScroll = scrollView.contentSize.height > scrollView.bounds.height
        if canScroll {
//            print("Scrolling is possible")
            // Perform any additional actions, such as showing a scrollbar indicator
        } else {
//            print("Scrolling is not needed")
            // Hide scrollbar indicators or adjust layout if necessary
        }
    }
}
