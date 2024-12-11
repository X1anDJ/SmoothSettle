//  ArchiveTripController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/18.
//
import UIKit
import SwiftUI
import Charts // Ensure you have imported the Charts framework

class ArchiveTripController: UIViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
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
        
        // Transactions Table View
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        transactionsTableView.isScrollEnabled = false // Disable internal scrolling
        transactionsTableView.isSelectable = true
        
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
        settleButton.setTitleColor(Colors.background1, for: .normal)
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
            
            // Transactions Table View Constraints
            transactionsTableView.topAnchor.constraint(equalTo: chartHostingController.view.bottomAnchor, constant: 24),
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
        guard let tripId = trip?.id, let repository = tripRepository else { return }
        
        // Fetch all transactions for the trip
        let transactions = repository.fetchAllTransactions(for: tripId)
        
        // Mark all transactions as settled
        for transaction in transactions {
            transaction.settled = true
        }
        
        // Save changes
        repository.saveContext()
        
        // Reload the transactions table view
        transactionsTableView.loadTransactions()
        
        // Optionally, update the UI to reflect the changes
        // For example, navigate back or show an alert
        let alert = UIAlertController(title: "Success", message: "All transactions have been settled.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


// MARK: - Chart Data Model
struct ChartData: Identifiable {
    let id = UUID()
    let name: String
    let owes: Double
    let formattedOwes: String
}

// MARK: - SwiftUI Chart View
struct OwesChartView: View {
    var data: [ChartData]
    var timePeriod: String
    var totalAmount: String

    // Define a color palette to assign consistent colors to each person
    private let colorPalette: [Color] = [
        Color(UIColor(hex: "ba3133")), // Color 1
        Color(UIColor(hex: "f94144")), // Color 2
        Color(UIColor(hex: "f3722c")), // Color 3
        Color(UIColor(hex: "f8961e")), // Color 4
        Color(UIColor(hex: "f9c74f")), // Color 5
        Color(UIColor(hex: "90be6d")), // Color 6
        Color(UIColor(hex: "43aa8b")), // Color 7
        Color(UIColor(hex: "4d908e")), // Color 8
        Color(UIColor(hex: "577590")), // Color 9
        Color(UIColor(hex: "4d94b2"))  // Color 10
    ]
    
    // Function to assign a color to each person based on their index
    private func color(for index: Int) -> Color {
        return colorPalette[index % colorPalette.count]
    }
    
    var body: some View {
        VStack {
            HStack {
                let expensesByPersonLocalized = String(localized: "expenses_by_person")
                Text(expensesByPersonLocalized)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 16) // Increased padding for better spacing
                    .foregroundColor(Color(Colors.primaryDark))
                Spacer()
            }
            HStack {
                Text(timePeriod)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            if data.isEmpty {
                let noExpensesLocalized = String(localized: "no_expenses")
                Text(noExpensesLocalized)
                    .foregroundColor(Color(.darkGray))
                    .padding()
            } else {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Chart {
                            ForEach(Array(data.enumerated()), id: \.element.id) { index, entry in
                                SectorMark(
                                    angle: .value("Amount", entry.owes),
                                    innerRadius: .ratio(0.4),
                                    angularInset: 1
                                )
                                .foregroundStyle(color(for: index))
                                .annotation(position: .overlay) {
                                    // Optional: Add labels inside the pie slices
                                    // set text to bold
                                    
                                   // Text(String(format: "$%.0f", entry.owes))
                                    Text(entry.formattedOwes)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(0))
                                }
                            }
                        }
                        .chartLegend(.hidden) // Hide default legend
                        .frame(width: geometry.size.width * 2 / 3.4 , height: geometry.size.width * 2 / 3.4)
                        
                        Spacer()
                        
                        VStack {
                            LegendView(data: data, colorPalette: colorPalette)

                            Spacer()
                            // total amount label
                            VStack(spacing: 8) {
                                
                                Text(String(localized: "Total"))
                                    .font(.footnote)
                                    .foregroundColor(.primary)
                                    .padding(.top, 16)
                                    
                               // Text(String(format: "$%.2f", data.reduce(0) { $0 + $1.owes }))
                                Text(totalAmount)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(Colors.accentOrange))
                                    .padding(.bottom, 16)
                            }
                            .frame(width: geometry.size.width / 3 )
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(Colors.background1))
//                                    .shadow(radius: 1, x: 0, y: 2)
                            )

                        
                        }
                        .frame(width: geometry.size.width / 3 )

                    }
                }
            }
        }
        
    }
}


// MARK: - Legend View
struct LegendView: View {
    var data: [ChartData]
    var colorPalette: [Color]
    
    // Function to assign a color to each person based on their index
    private func color(for index: Int) -> Color {
        return colorPalette[index % colorPalette.count]
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, entry in
                HStack {
                    Circle()
                        .fill(color(for: index))
                        .frame(width: 12, height: 12)
                    Text(entry.name)
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(Colors.background1))
//                .shadow(radius: 1, x: 0, y: 2)
        )
    }
}
