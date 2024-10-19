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
    private let chartHostingController = UIHostingController(rootView: OwesChartView(data: [])) // Initial empty chart
    
    // MARK: - Data
    var trip: Trip? // The trip to display
    var tripRepository: TripRepository? // Reference to the repository
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
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
        contentView.addSubview(transactionsTableView)
        
        // No Transactions Label
        noTransactionsLabel.translatesAutoresizingMaskIntoConstraints = false
        noTransactionsLabel.text = "No transactions available for this trip."
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
            chartHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            chartHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartHostingController.view.heightAnchor.constraint(equalToConstant: 300), // Adjust height as needed
            
            // Transactions Table View Constraints
            transactionsTableView.topAnchor.constraint(equalTo: chartHostingController.view.bottomAnchor, constant: 24),
            transactionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transactionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            transactionsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // No Transactions Label Constraints
            noTransactionsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            noTransactionsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            noTransactionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            noTransactionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
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
        transactionsTableView.loadTransactions { [weak self] sections in
            DispatchQueue.main.async {
                if sections.isEmpty {
                    self?.transactionsTableView.isHidden = true
                    self?.noTransactionsLabel.isHidden = false
                } else {
                    self?.transactionsTableView.isHidden = false
                    self?.noTransactionsLabel.isHidden = true
                }
                self?.updateChartData()
                self?.view.setNeedsLayout()
            }
        }
    }
    
    // MARK: - Chart Data Update
    private func updateChartData() {
        guard let trip = trip,
              let tripRepository = tripRepository else {
            chartHostingController.rootView = OwesChartView(data: [])
            return
        }
        
        // Fetch people and their balances
        let people = trip.peopleArray
        
        // Prepare data for the chart
        let chartData = people.map { person in
            ChartData(name: person.name ?? "Unnamed", owes: 100.0) // Replace 100.0 with actual balance
        }
        
        // Update the chart's data
        chartHostingController.rootView = OwesChartView(data: chartData)
    }
}

// MARK: - Chart Data Model
struct ChartData: Identifiable {
    let id = UUID()
    let name: String
    let owes: Double
}

// MARK: - SwiftUI Chart View
struct OwesChartView: View {
    var data: [ChartData]
    
    var body: some View {
        VStack {
            Text("Owes by Person")
                .font(.title2)
                .padding(.bottom, 8)
            
            if data.isEmpty {
                Text("No owes to display.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart {
                    ForEach(data) { entry in
                        BarMark(
                            x: .value("Person", entry.name),
                            y: .value("Owes", entry.owes)
                        )
                        .foregroundStyle(entry.owes > 0 ? Color.green : Color.red)
                        .annotation(position: .top) {
                            Text(String(format: "%.2f", entry.owes))
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .padding()
            }
        }
    }
}
