//
//  SettleViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//
import UIKit

class SettleViewController: UIViewController {

    // UI Elements
    let scrollView = UIScrollView()  // Scroll view to hold the content
    let contentView = UIView()  // Content view inside the scroll view
    let circleLayoutView = CircleLayoutView()  // Custom circle layout view
    let transactionsTableView = TransactionsTableView() // Transactions table view
    let settleButton = UIButton(type: .system)
    let closeButton = UIButton(type: .system)
    
    // Reference to the MainViewModel
    var viewModel: MainViewModel?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the view background and style
        view.backgroundColor = .secondarySystemBackground

        setupViews()
        setupConstraints()

        // Fetch the people in the trip and pass their full names to the CircleLayoutView
        if let viewModel = viewModel, let currentTrip = viewModel.currentTrip {
            let fullNames = currentTrip.peopleArray.compactMap { $0.name }  // Get full names of people
            circleLayoutView.userNames = fullNames  // Set the full names to the custom view

            // Pass the repository and current trip to the TransactionsTableView
            transactionsTableView.tripRepository = viewModel.tripRepository
            transactionsTableView.currentTrip = currentTrip

            // Load transactions and pass them to CircleLayoutView via the completion handler
            transactionsTableView.loadTransactions { [weak self] sections in
                print("Transactions loaded and passed to CircleLayoutView:", sections)
                self?.circleLayoutView.transactions = sections
            }
        }
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
        settleButton.setTitle("Settle", for: .normal)
        settleButton.setTitleColor(.white, for: .normal)
        settleButton.backgroundColor = Colors.primaryDark
        settleButton.layer.cornerRadius = 16
        settleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        settleButton.addTarget(self, action: #selector(didTapSettleTrip), for: .touchUpInside)
        contentView.addSubview(settleButton)

        // Close Button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(Colors.primaryDark, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        contentView.addSubview(closeButton)
    }

    // Setup layout constraints
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View Constraints
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View Constraints (inside the scroll view)
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),  // Make contentView the same width as the scroll view
            
            // Circle Layout View Constraints
            circleLayoutView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            circleLayoutView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleLayoutView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            circleLayoutView.heightAnchor.constraint(equalTo: circleLayoutView.widthAnchor),  // Make it a square

            // Transactions Table View Constraints
            transactionsTableView.topAnchor.constraint(equalTo: circleLayoutView.bottomAnchor, constant: 24),
            transactionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transactionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Settle Button Constraints
            settleButton.topAnchor.constraint(equalTo: transactionsTableView.bottomAnchor, constant: 16),
            settleButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            settleButton.heightAnchor.constraint(equalToConstant: 44),
            settleButton.widthAnchor.constraint(equalToConstant: 200),

            // Close Button Constraints
            closeButton.topAnchor.constraint(equalTo: settleButton.bottomAnchor, constant: 16),
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.widthAnchor.constraint(equalToConstant: 150),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)  // Important: Make sure contentView's bottom is constrained to closeButton
        ])
    }



    // Action to settle the trip
    @objc func didTapSettleTrip() {
        guard let viewModel = viewModel else { return }
        
        // Settle the current trip
        viewModel.settleCurrentTrip()
        dismiss(animated: true, completion: nil)
    }

    // Action to dismiss the view controller
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
