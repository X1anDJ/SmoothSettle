//
//  ArchivedBillsViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 12/13/24.
//

import UIKit

class ArchivedBillsViewController: UIViewController {
    
    // MARK: - Properties
    private let searchBar = UISearchBar()
    private let separatorLine = UIView()
    private let tableView = UITableView()
    
    let tripRepository: TripRepository
    let trip: Trip
    
    // All bills for this trip
    private var allBills: [Bill] = []
    // Filtered bills based on search query
    private var filteredBills: [Bill] = []
    
    // Whether we are currently filtering results
    var isFiltering: Bool {
        return !(searchBar.text?.isEmpty ?? true)
    }
    
    // MARK: - Initializer
    init(tripRepository: TripRepository, trip: Trip) {
        self.tripRepository = tripRepository
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
        self.allBills = tripRepository.fetchBills(for: trip.id)
        self.filteredBills = allBills
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.background1
        title = String(localized: "Bills")
        
        setupSearchBar()
        setupTableView()
    }

    // MARK: - Setup Methods
    
    private func setupSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.placeholder = String(localized: "search_bills")
        
        // Minimal style, no background image
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        
        view.addSubview(searchBar)
        
        // Separator line
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = .systemGray5
        view.addSubview(separatorLine)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            separatorLine.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(BillTableViewCell.self, forCellReuseIdentifier: "BillCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        // Use the trip's currency to format
        return tripRepository.fetchAmount(amount, by: trip.id)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ArchivedBillsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredBills.count : allBills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillCell", for: indexPath) as? BillTableViewCell else {
            return UITableViewCell()
        }
        
        let bill = isFiltering ? filteredBills[indexPath.row] : allBills[indexPath.row]
        
        cell.configure(
            billTitle: bill.title ?? "Untitled Bill",
            date: formatDate(bill.date),
            amount: formatAmount(bill.amount),
            payerName: bill.payer?.name ?? String(localized: "unknown_person"),
            involversCount: bill.involvers?.count ?? 0
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBill = isFiltering ? filteredBills[indexPath.row] : allBills[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Show bill details
        let billDetailVC = BillDetailViewController()
        let billDetailViewModel = BillDetailViewModel(tripRepository: tripRepository, bill: selectedBill)
        billDetailVC.viewModel = billDetailViewModel
        navigationController?.pushViewController(billDetailVC, animated: true)
    }
    
    // No deletion or editing methods are implemented here
}

// MARK: - UISearchBarDelegate
extension ArchivedBillsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredBills = allBills
        } else {
            filteredBills = allBills.filter { bill in
                let titleMatch = bill.title?.lowercased().contains(searchText.lowercased()) ?? false
                let payerMatch = bill.payer?.name?.lowercased().contains(searchText.lowercased()) ?? false
                return titleMatch || payerMatch
            }
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredBills = allBills
        tableView.reloadData()
    }
}
