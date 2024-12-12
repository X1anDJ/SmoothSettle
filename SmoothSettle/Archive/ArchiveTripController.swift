//  ArchiveTripController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/18.
//
import UIKit
import SwiftUI


class ArchiveTripController: UIViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let transactionTableTitleLabel = UILabel()
    private let transactionsTableView = TransactionsTableView()
    private let noTransactionsLabel = UILabel() // Placeholder label
    private let chartHostingController = UIHostingController(rootView: OwesChartView(data: [], timePeriod: "", totalAmount: "")) // Initial empty chart
    
    // New Settle Button
    private let settleButton = UIButton(type: .system)
    
    // MARK: - Data
    var trip: Trip? // The trip to display
    var tripRepository: TripRepository? // Reference to the repository
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background0
        chartHostingController.view.backgroundColor = .clear
        setupViews()
        setupConstraints()
        configureView()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Transactions Table Title Label
        transactionTableTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        let transactionsLocalized = String(localized: "transactions")
        transactionTableTitleLabel.text = transactionsLocalized
        //set font as .title2 and semibold
        transactionTableTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        //set color as primaryDark
        transactionTableTitleLabel.textColor = Colors.primaryDark
        contentView.addSubview(transactionTableTitleLabel)
        
        // Transactions Table View
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        transactionsTableView.isScrollEnabled = false // Disable internal scrolling
        transactionsTableView.isSelectable = true
        transactionsTableView.transactionsDelegate = self
        
        contentView.addSubview(transactionsTableView)
        
        // No Transactions Label
        noTransactionsLabel.translatesAutoresizingMaskIntoConstraints = false
        let noTransaction = String(localized: "no_transactions")
        noTransactionsLabel.text = noTransaction
        noTransactionsLabel.textColor = .systemGray
        noTransactionsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        noTransactionsLabel.textAlignment = .center
        noTransactionsLabel.isHidden = true // Initially hidden
        contentView.addSubview(noTransactionsLabel)
        
        // Add the chart's hosting controller as a child view controller
        addChild(chartHostingController)
        chartHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(chartHostingController.view)
        chartHostingController.didMove(toParent: self)
        
        // Settle Button
        settleButton.translatesAutoresizingMaskIntoConstraints = false
        let settleAllLocalized = String(localized: "settle_all")
        settleButton.setTitle(settleAllLocalized, for: .normal)
        settleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        settleButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        settleButton.layer.cornerRadius = 15
        settleButton.tintColor = Colors.background1
        settleButton.titleLabel?.tintColor = Colors.background1
        settleButton.backgroundColor = Colors.primaryDark
        settleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        settleButton.imageView?.contentMode = .scaleAspectFit
        settleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true // Adjust height as needed
        
        // Adjust image and title position
        settleButton.semanticContentAttribute = .forceLeftToRight
        settleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        
        // Add action for the button
        settleButton.addTarget(self, action: #selector(settleButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(settleButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View Constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View Constraints
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // Content View Width Constraint
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Chart Hosting Controller Constraints
            chartHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            chartHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartHostingController.view.heightAnchor.constraint(equalToConstant: 300), // Adjust height as needed
            
            // Transactions Table Title Label Constraints
            transactionTableTitleLabel.topAnchor.constraint(equalTo: chartHostingController.view.bottomAnchor, constant: 16),
            transactionTableTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transactionTableTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            
            // Transactions Table View Constraints
            transactionsTableView.topAnchor.constraint(equalTo: transactionTableTitleLabel.bottomAnchor),
            transactionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transactionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            // Remove the bottom constraint to contentView
            // transactionsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Settle Button Constraints
            settleButton.topAnchor.constraint(equalTo: transactionsTableView.bottomAnchor, constant: 24),
            settleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            settleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            settleButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])
    }
    
    private func configureView() {
        guard let trip = trip else {
            // Optionally, handle the case where trip is nil
            transactionsTableView.tripRepository = nil
            transactionsTableView.currentTrip = nil
            transactionsTableView.sections = []
            transactionsTableView.reloadData()
            return
        }
        
        // Set the navigation bar title to the trip's title
        self.title = trip.title ?? "Trip Details"
        
        // Configure TransactionsTableView
        transactionsTableView.tripRepository = tripRepository
        transactionsTableView.currentTrip = trip.id
        transactionsTableView.loadTransactions()
        
        // Get the time period
        let timePeriod = tripRepository?.getTimePeriod(for: trip) ?? ""
        
        updateChartData(timePeriod: timePeriod)
    }
    
    // MARK: - Chart Data Update
    private func updateChartData(timePeriod: String) {
        guard let trip = trip,
              let tripRepository = tripRepository else {
            chartHostingController.rootView = OwesChartView(data: [], timePeriod: "", totalAmount: "")
            return
        }
        
        // Fetch the total amounts per person
        let chartData = transactionsTableView.calculateTotalAmountsPerPerson()
      //  let tripTotalAmount = chartData.
        let totalFormattedAmount = tripRepository.fetchAmount(chartData.reduce(0) { $0 + $1.owes }, by: trip.id)
        // Update the chart's data on the main thread
        DispatchQueue.main.async {
            self.chartHostingController.rootView = OwesChartView(data: chartData, timePeriod: timePeriod, totalAmount: totalFormattedAmount)
        }
        
        // Handle visibility of transactions table and no transactions label
        if chartData.isEmpty {
            transactionsTableView.isHidden = true
            noTransactionsLabel.isHidden = false
            settleButton.isHidden = true // Hide the settle button if there are no transactions
        } else {
            transactionsTableView.isHidden = false
            noTransactionsLabel.isHidden = true
            settleButton.isHidden = false // Show the settle button
        }
    }
    
    // MARK: - Actions
    @objc private func settleButtonTapped() {
        // Create the alert controller
        let alert = UIAlertController(
            title: String(localized: "Confirm Settlement"),
            message: String(localized: "Are you sure you want to settle all transactions?"),
            preferredStyle: .alert
        )
        
        // "Yes" action
        let yesAction = UIAlertAction(title: String(localized: "Yes"), style: .default) { [weak self] _ in
            self?.performSettlement()
        }
        
        // "Cancel" action
        let cancelAction = UIAlertAction(title: String(localized: "Cancel"), style: .cancel, handler: nil)
        
        // Add actions to the alert
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Settlement Logic
    private func performSettlement() {
        guard let tripId = trip?.id, let repository = tripRepository else { return }
        
        // Fetch all unsettled transactions for the trip
        let transactions = repository.fetchAllTransactions(for: tripId).filter { !$0.settled }
        
        // Check if there are transactions to settle
        guard !transactions.isEmpty else {
            let noTransactionsAlert = UIAlertController(
                title: String(localized: "No Transactions"),
                message: String(localized: "There are no unsettled transactions to settle."),
                preferredStyle: .alert
            )
            noTransactionsAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(noTransactionsAlert, animated: true)
            return
        }
        
        // Mark all transactions as settled
        for transaction in transactions {
            transaction.settled = true
        }
        
        // Save changes to the repository
        repository.saveContext()
        
        // Reload the transactions table view
        transactionsTableView.loadTransactions()
        
        // Update the chart data
        if let trip = trip {
            let timePeriod = tripRepository?.getTimePeriod(for: trip) ?? ""
            updateChartData(timePeriod: timePeriod)
        }
        
        // Show success alert
        let successAlert = UIAlertController(
            title: String(localized: "Success"),
            message: String(localized: "All transactions have been settled."),
            preferredStyle: .alert
        )
        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(successAlert, animated: true)
        // disable settle button
        settleButton.isEnabled = false
    }

}

extension ArchiveTripController: TransactionsTableViewDelegate {
    func transactionsTableView(_ tableView: TransactionsTableView, didChangeSettlementStatus hasUnsettledTransactions: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.settleButton.isEnabled = hasUnsettledTransactions
            print("settlebutton status: \(String(describing: self?.settleButton.isEnabled))")
//            self?.settleButton.alpha = !hasUnsettledTransactions ? 1.0 : 0.5 // Optional: Visual feedback
        }
    }
    
    
    
}
