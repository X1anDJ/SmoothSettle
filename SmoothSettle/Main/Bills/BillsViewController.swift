//
//  BillsViewController.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//

import Foundation
import UIKit
class BillsViewController: UIViewController {

    let customTableView = UITableView()
    let searchBar = UISearchBar() // Add the search bar
    let separatorLine = UIView()
    
    // ViewModel for this controller
    var viewModel: MainViewModel

    // Array to hold filtered bills
    var filteredBills: [Bill] = []

    // Track if we are currently filtering
    var isFiltering: Bool {
        return !searchBar.text!.isEmpty
    }

    // Custom initializer to inject the view model
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        self.filteredBills = viewModel.bills // Start with all bills
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Bills"
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        setupSearchBar() // Setup the search bar
        setupTableView() // Setup the table view
    }

    func setupSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.placeholder = "Search bills"
        
        // Remove the background/border
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear

        view.addSubview(searchBar)

        // Configure the separator line
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = .systemGray5

        view.addSubview(separatorLine)

        NSLayoutConstraint.activate([
            // Search bar constraints
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            // Separator line constraints
            separatorLine.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5) // Height of the separator
        ])
    }


    func setupTableView() {
        customTableView.translatesAutoresizingMaskIntoConstraints = false
        customTableView.register(BillTableViewCell.self, forCellReuseIdentifier: "BillCell")
        view.addSubview(customTableView)

        NSLayoutConstraint.activate([
            customTableView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            customTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Set the delegate and data source for the table view
        customTableView.delegate = self
        customTableView.dataSource = self
    }
}


// UITableView Delegate and DataSource methods
extension BillsViewController: UITableViewDelegate, UITableViewDataSource {

    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredBills.count : viewModel.bills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillCell", for: indexPath) as? BillTableViewCell else {
            return UITableViewCell()
        }

        let bill = isFiltering ? filteredBills[indexPath.row] : viewModel.bills[indexPath.row]

        // Configure the cell using actual data from the bill
        cell.configure(
            billTitle: bill.title ?? "Untitled Bill",
            date: formatDate(bill.date),
            amount: String(format: "%.2f", bill.amount),
            payerName: bill.payer?.name ?? "Unknown",
            involversCount: bill.involvers?.count ?? 0
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let billDetailVC = BillDetailViewController()
        let selectedBill = isFiltering ? filteredBills[indexPath.row] : viewModel.bills[indexPath.row]
        let billDetailViewModel = BillDetailViewModel(tripRepository: viewModel.tripRepository, bill: selectedBill)
        billDetailVC.viewModel = billDetailViewModel
        navigationController?.pushViewController(billDetailVC, animated: true)

    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    // Handle the deletion when the user swipes and taps "Delete"
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bill = viewModel.bills[indexPath.row]
            viewModel.deleteBill(by: bill.id)
            
            // Remove the row from the table view with animation
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension BillsViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredBills = viewModel.bills // Reset to all bills
        } else {
            filteredBills = viewModel.bills.filter { bill in
                let titleMatch = bill.title?.lowercased().contains(searchText.lowercased()) ?? false
                let payerMatch = bill.payer?.name?.lowercased().contains(searchText.lowercased()) ?? false
                return titleMatch || payerMatch
            }
        }
        customTableView.reloadData() // Reload table view with the filtered data
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredBills = viewModel.bills // Reset to all bills
        customTableView.reloadData()
    }
}
