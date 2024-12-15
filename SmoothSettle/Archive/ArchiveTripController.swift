//
//  ArchiveTripController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/18.
//

import UIKit
import SwiftUI

class ArchiveTripController: UIViewController {
    
    // MARK: - UI Elements
    // Removed scrollView and contentView
    
    // Segmented Control
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: [String(localized: "checklist"), String(localized: "chart")])
        sc.selectedSegmentIndex = 0 // Default selection
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.backgroundColor = Colors.background1
        sc.selectedSegmentTintColor = Colors.primaryDark
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        return sc
    }()
    
    // Transactions Section
    private let transactionsTableView = TransactionsTableView()
    private let noTransactionsLabel = UILabel() // Placeholder label
    
    // Chart Section
    private let chartHostingController = UIHostingController(rootView: OwesChartView(data: [], timePeriod: "", totalAmount: "")) // Initial empty chart
    
    // Bills Card View
    private let billsCardView = BillsCardView()
    
    // Settle Button
    private let settleButton = UIButton(type: .system)
    
    // Container views for segmentation
    private let chartContainerView = UIView()
    private let checklistContainerView = UIView()
    
    // MARK: - Data
    var trip: Trip? // The trip to display
    var tripRepository: TripRepository? // Reference to the repository
    
    // Bills Data
    private var bills: [Bill] = []
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background0
        chartHostingController.view.backgroundColor = .clear
        setupViews()
        setupConstraints()
        configureView()
        setupSegmentedControl()
        
        // Add the action for the billsCardView arrow button
        billsCardView.onRightArrowTapped = { [weak self] in
            guard let self = self, let trip = self.trip, let tripRepository = self.tripRepository else { return }
            let archivedBillsVC = ArchivedBillsViewController(tripRepository: tripRepository, trip: trip)
            self.navigationController?.pushViewController(archivedBillsVC, animated: true)
        }
        
        print("Settle Button Enabled: 73 \(settleButton.isEnabled)")
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        // Add Segmented Control at the top
        view.addSubview(segmentedControl)
        
        // Configure TransactionsTableView
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        transactionsTableView.isScrollEnabled = true // Enable scrolling in the table
        transactionsTableView.isSelectable = true
        transactionsTableView.transactionsDelegate = self
        
        noTransactionsLabel.translatesAutoresizingMaskIntoConstraints = false
        let noTransaction = String(localized: "no_transactions")
        noTransactionsLabel.text = noTransaction
        noTransactionsLabel.textColor = .systemGray
        noTransactionsLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        noTransactionsLabel.textAlignment = .center
        noTransactionsLabel.isHidden = true
        
        // CheckList Container (for "CheckList" segment)
        checklistContainerView.translatesAutoresizingMaskIntoConstraints = false
        checklistContainerView.addSubview(transactionsTableView)
        checklistContainerView.addSubview(noTransactionsLabel)
        
        // Settle Button
        settleButton.translatesAutoresizingMaskIntoConstraints = false
        let settleAllLocalized = String(localized: "settle_all")
        settleButton.setTitle(settleAllLocalized, for: .normal)
        settleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        settleButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        settleButton.layer.cornerRadius = 15
        settleButton.tintColor = Colors.background1
        settleButton.backgroundColor = Colors.primaryDark
        settleButton.imageView?.contentMode = .scaleAspectFit
        settleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        settleButton.semanticContentAttribute = .forceLeftToRight
        settleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        settleButton.addTarget(self, action: #selector(settleButtonTapped), for: .touchUpInside)
        
        view.addSubview(settleButton)
        
        // Checklist Container Constraints
        // We will set constraints for transactionsTableView and noTransactionsLabel later
        
        // Chart Container (for "Chart" segment)
        chartContainerView.translatesAutoresizingMaskIntoConstraints = false
        addChild(chartHostingController)
        chartHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        chartContainerView.addSubview(chartHostingController.view)
        chartHostingController.didMove(toParent: self)
        
        // Bills Card View
        billsCardView.translatesAutoresizingMaskIntoConstraints = false
        billsCardView.configure(
            title: String(localized: "Bills"),
            total: "$0.00",
            tableViewDelegate: self,
            tableViewDataSource: self
        )
        chartContainerView.addSubview(billsCardView)
        
        // Add container views to main view
        view.addSubview(chartContainerView)
        view.addSubview(checklistContainerView)
        
        // Initially show checklist view, hide chart view
        chartContainerView.isHidden = true
        checklistContainerView.isHidden = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Segmented Control Constraints
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            // Settle Button Constraints
            settleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            settleButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        // Checklist Container Constraints
        NSLayoutConstraint.activate([
            checklistContainerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            checklistContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            checklistContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            checklistContainerView.bottomAnchor.constraint(equalTo: settleButton.topAnchor, constant: -16),
        ])
        
        // Transactions Table View Constraints
        NSLayoutConstraint.activate([
            transactionsTableView.topAnchor.constraint(equalTo: checklistContainerView.topAnchor),
            transactionsTableView.leadingAnchor.constraint(equalTo: checklistContainerView.leadingAnchor),
            transactionsTableView.trailingAnchor.constraint(equalTo: checklistContainerView.trailingAnchor),
            transactionsTableView.bottomAnchor.constraint(equalTo: settleButton.topAnchor, constant: -16),
        ])
        
        // No Transactions Label Constraints
        NSLayoutConstraint.activate([
            noTransactionsLabel.centerXAnchor.constraint(equalTo: checklistContainerView.centerXAnchor),
            noTransactionsLabel.centerYAnchor.constraint(equalTo: checklistContainerView.centerYAnchor),
            noTransactionsLabel.leadingAnchor.constraint(equalTo: checklistContainerView.leadingAnchor),
            noTransactionsLabel.trailingAnchor.constraint(equalTo: checklistContainerView.trailingAnchor),
        ])
        
        // Chart Container Constraints
        NSLayoutConstraint.activate([
            chartContainerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            chartContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartContainerView.bottomAnchor.constraint(equalTo: settleButton.topAnchor, constant: -16),
        ])
        
        // Chart Hosting Controller Constraints
        NSLayoutConstraint.activate([
            chartHostingController.view.topAnchor.constraint(equalTo: chartContainerView.topAnchor),
            chartHostingController.view.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor),
            chartHostingController.view.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor),
            chartHostingController.view.heightAnchor.constraint(equalToConstant: 300),
            
            billsCardView.topAnchor.constraint(equalTo: chartHostingController.view.bottomAnchor, constant: 16),
            billsCardView.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor),
            billsCardView.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor),
         //   billsCardView.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor),
            billsCardView.heightAnchor.constraint(equalToConstant: 260),
        ])
    }
    
    private func setupSegmentedControl() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        updateViewForSelectedSegment()
    }
    
    private func configureView() {
        guard let trip = trip else {
            transactionsTableView.tripRepository = nil
            transactionsTableView.currentTrip = nil
            transactionsTableView.sections = []
            transactionsTableView.reloadData()
            return
        }
        
        self.title = trip.title ?? "Trip Details"
        
        // Configure TransactionsTableView
        transactionsTableView.tripRepository = tripRepository
        transactionsTableView.currentTrip = trip.id
        transactionsTableView.loadTransactions()
        settleButton.isEnabled = transactionsTableView.hasUnsettled
        print("transactionTableView.section.transactions: \(transactionsTableView.sections.count)")
        print("transactionsTableView.hasUnsettled: \(transactionsTableView.hasUnsettled)")
        print("line 240 Settle Button Enabled: \(settleButton.isEnabled)")
        
        // Load Bills
        loadBills()
        
        let timePeriod = tripRepository?.getTimePeriod(for: trip) ?? ""
        
        updateChartData(timePeriod: timePeriod)
    }
    
    // MARK: - Load Bills Data
    private func loadBills() {
        guard let trip = trip, let tripRepository = tripRepository else { return }
        bills = tripRepository.fetchBills(for: trip.id)
        billsCardView.totalAmountLabel.text = getTotalAmount()
        billsCardView.customTableView.reloadData()
        
    }
    
    private func getTotalAmount() -> String {
        let total = bills.reduce(0) { $0 + $1.amount }
        return viewModelGetAmount(for: total)
    }
    
    // Helper function to format amount
    private func viewModelGetAmount(for amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    // MARK: - Chart Data Update
    private func updateChartData(timePeriod: String) {
        guard let trip = trip,
              let tripRepository = tripRepository else {
            chartHostingController.rootView = OwesChartView(data: [], timePeriod: "", totalAmount: "")
            billsCardView.configure(title: String(localized: "Bills"), total: "$0.00", tableViewDelegate: self, tableViewDataSource: self)
            return
        }
        
        let chartData = transactionsTableView.calculateTotalAmountsPerPerson()
        let totalFormattedAmount = tripRepository.fetchAmount(chartData.reduce(0) { $0 + $1.owes }, by: trip.id)
        
        DispatchQueue.main.async {
            self.chartHostingController.rootView = OwesChartView(data: chartData, timePeriod: timePeriod, totalAmount: totalFormattedAmount)
        }
        
        loadBills()
        
        if chartData.isEmpty {
            transactionsTableView.isHidden = true
            noTransactionsLabel.isHidden = false
            settleButton.isHidden = true
        } else {
            transactionsTableView.isHidden = false
            noTransactionsLabel.isHidden = true
            settleButton.isHidden = false
            settleButton.isEnabled = transactionsTableView.hasUnsettled
        }
    }
    
    // MARK: - Segmented Control Action
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        updateViewForSelectedSegment()
    }
    
    private func updateViewForSelectedSegment() {
        let isChecklistSelected = segmentedControl.selectedSegmentIndex == 0
        chartContainerView.isHidden = isChecklistSelected
        checklistContainerView.isHidden = !isChecklistSelected
        
        // Adjust visibility of settleButton based on segment
        settleButton.isHidden = !isChecklistSelected
    }
    
    // MARK: - Actions
    @objc private func settleButtonTapped() {
        let alert = UIAlertController(
            title: String(localized: "Confirm Settlement"),
            message: String(localized: "Are you sure you want to settle all transactions?"),
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: String(localized: "Yes"), style: .default) { [weak self] _ in
            self?.performSettlement()
        }
        
        let cancelAction = UIAlertAction(title: String(localized: "Cancel"), style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    private func performSettlement() {
        guard let tripId = trip?.id, let repository = tripRepository else { return }
        
        let transactions = repository.fetchAllTransactions(for: tripId).filter { !$0.settled }
        
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
        
        for transaction in transactions {
            transaction.settled = true
        }
        
        repository.saveContext()
        
        transactionsTableView.loadTransactions()
        
        if let trip = trip {
            let timePeriod = tripRepository?.getTimePeriod(for: trip) ?? ""
            updateChartData(timePeriod: timePeriod)
        }
        
        let successAlert = UIAlertController(
            title: String(localized: "Success"),
            message: String(localized: "All transactions have been settled."),
            preferredStyle: .alert
        )
        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(successAlert, animated: true)
        
        settleButton.isEnabled = false
    }

}

// MARK: - TransactionsTableViewDelegate
extension ArchiveTripController: TransactionsTableViewDelegate {
    func transactionsTableView(_ tableView: TransactionsTableView, didChangeSettlementStatus hasUnsettledTransactions: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.settleButton.isEnabled = hasUnsettledTransactions
        }
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource for BillsCardView
extension ArchiveTripController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView == billsCardView.customTableView else { return 0 }
        return bills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard tableView == billsCardView.customTableView else {
            return UITableViewCell()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillCell", for: indexPath) as? BillTableViewCell else {
            return UITableViewCell()
        }

        let bill = bills[indexPath.row]
        
        cell.configure(
            billTitle: bill.title ?? "Untitled Bill",
            date: formatDate(bill.date),
            amount: viewModelGetAmount(for: bill.amount),
            payerName: bill.payer?.name ?? "Unknown",
            involversCount: bill.involvers?.count ?? 0
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == billsCardView.customTableView else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedBill = bills[indexPath.row]
        let billDetailVC = BillDetailViewController()
        let billDetailViewModel = BillDetailViewModel(tripRepository: tripRepository!, bill: selectedBill)
        billDetailVC.viewModel = billDetailViewModel
        navigationController?.pushViewController(billDetailVC, animated: true)
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
}
