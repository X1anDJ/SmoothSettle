//
//  TransactionsTableView.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/10/12.
//
import UIKit

class TransactionsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    // Data structure to hold the grouped transactions
    struct Section {
        let fromPerson: Person
        let transactions: [Transaction]
    }

    
    // Array to store grouped and sorted transactions
    var sections: [Section] = []
    
    // Reference to the TripRepository to get simplified transactions
    var tripRepository: TripRepository?
    
    var currentTrip: UUID? {
        didSet {
            // Uncomment when you want to trigger the load
            loadTransactions()
        }
    }
    
    // Property to control whether cells are selectable
    var isSelectable: Bool = false {
        didSet {
            self.allowsSelection = isSelectable
            self.allowsMultipleSelection = true
            self.reloadData()
        }
    }
    
    // Set to keep track of selected indexPaths
    private var selectedIndexPaths = Set<IndexPath>()
    
    // Initializer
    init() {
        super.init(frame: .zero, style: .plain)
        // selected indexPaths based on whether transaction is settled
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Set up the table view
    private func setupTableView() {
        self.delegate = self
        self.dataSource = self
        self.isScrollEnabled = false  // Disable scrolling to allow intrinsic size adjustment
        self.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        self.separatorStyle = .none
        self.backgroundColor = .clear
    }
    
    func calculateTotalAmountsPerPerson() -> [ChartData] {
        var chartData: [ChartData] = []
        
        for section in sections {
            let fromPerson = section.fromPerson
            let totalAmount = section.transactions.reduce(0.0) { $0 + $1.amount }
            let personName = fromPerson.name ?? "Unnamed"
            
            let data = ChartData(name: personName, owes: totalAmount)
            chartData.append(data)
        }
        
        return chartData
    }
    
    // Load transactions from the repository and organize into sections
    func loadTransactions() {
        guard let tripId = currentTrip, let repository = tripRepository else {
            // print("Current trip ID or repository not set.")
            return
        }

        // Fetch transactions from Core Data
        let transactions = repository.fetchAllTransactions(for: tripId)
        
        // Fetch people involved in the trip for easy mapping of UUID to name
        let people = repository.fetchPeople(for: tripId)
        let uuidToName = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0.name ?? "Unknown") })

        // Group transactions by the payer's (fromPerson) UUID
        let groupedTransactions = Dictionary(grouping: transactions, by: { $0.fromPerson })
        
        // Create sections from the grouped transactions
        self.sections = groupedTransactions.map { (fromPerson, transactions) in
            // Sort transactions by toPerson's name
            let sortedTransactions = transactions.sorted {
                ($0.toPerson.name ?? "Unknown") < ($1.toPerson.name ?? "Unknown")
            }
            
            return Section(fromPerson: fromPerson, transactions: sortedTransactions)
        }.sorted {
            ($0.fromPerson.name ?? "Unknown") < ($1.fromPerson.name ?? "Unknown")
        }
        
        // Clear previous selection
        selectedIndexPaths.removeAll()
        
        // Determine which transactions are settled and prepare selectedIndexPaths
        for (sectionIndex, section) in sections.enumerated() {
            for (rowIndex, transaction) in section.transactions.enumerated() {
                if transaction.settled {
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    selectedIndexPaths.insert(indexPath)
                }
            }
        }
        
        // Reload the table view to display the new transactions
        self.reloadData()
        // print("Loaded \(sections.count) sections with \(transactions.count) transactions for tripId: \(tripId)")
        
        // Select the rows that are already settled
        for indexPath in selectedIndexPaths {
            self.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        // Check if all transactions are settled
        if transactions.allSatisfy({ $0.settled }) {
            // All transactions are settled, mark the trip as settled
            repository.markTripAsSettled(tripId: tripId)
            // print("All transactions settled. Trip \(tripId) marked as settled.")
        }
    }
    
    // Override intrinsicContentSize to dynamically calculate the height
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()  // Ensure the layout is up to date
        return CGSize(width: UIView.noIntrinsicMetric, height: self.contentSize.height)
    }
    
    // UITableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell else {
            return UITableViewCell()
        }
        
        let transaction = sections[indexPath.section].transactions[indexPath.row]

        // Fetch the toName using the UUID
        let toPerson = tripRepository?.fetchPerson(by: transaction.toPerson.id)
        let toName = toPerson?.name ?? "Unknown"

        // Determine if the cell is first or last in the section
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == sections[indexPath.section].transactions.count - 1

        // Determine if the cell is selected based on whether transaction is settled.
        let isSettled = selectedIndexPaths.contains(indexPath)
        
        // Configure the cell with rounded corners where necessary and symbol visibility
        cell.configure(
            toName: toName,
            amount: transaction.amount,
            isFirst: isFirst,
            isLast: isLast,
            showSymbol: isSelectable,
            isSettled: isSettled
        )
        //set cell's selected background is clear
        cell.selectedBackgroundView?.isHidden = true
        
        return cell
    }
    
    // UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear

        let fromPerson = sections[section].fromPerson
        let fromPersonLocalized = String(localized: "unknown_person")
        let fromName = fromPerson.name ?? fromPersonLocalized

        let label = UILabel()
        let localizedOwes = String(localized: "owes")
        label.text = "\(fromName) \(localizedOwes)"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    // Handle cell selection to toggle the symbol and mark transaction as settled
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isSelectable, let repository = tripRepository, let tripId = currentTrip else {
            // print("Selection not allowed or repository/tripId not set.")
            return
        }

        let transaction = sections[indexPath.section].transactions[indexPath.row]
        
        // Toggle the settled status
        transaction.settled.toggle()
        repository.saveContext()
        // print("Transaction \(transaction.id) settled status is now \(transaction.settled)")
        
        if transaction.settled {
            selectedIndexPaths.insert(indexPath)
        } else {
            selectedIndexPaths.remove(indexPath)
        }
        
        // Reload the specific row to update the symbol
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        // Check if all transactions are settled
        let allSettled = sections.allSatisfy { section in
            section.transactions.allSatisfy { $0.settled }
        }
        
        if allSettled {
            // All transactions are settled, mark the trip as settled
            repository.markTripAsSettled(tripId: tripId)
            // print("All transactions settled. Trip \(tripId) marked as settled.")
        } else {
            repository.markTripAsNotSettled(tripId: tripId)
        }
    }
    
    // Optionally handle deselection if multiple selection is allowed
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard isSelectable, let repository = tripRepository, let tripId = currentTrip else {
            // print("Deselection not allowed or repository/tripId not set.")
            return
        }
        
        let transaction = sections[indexPath.section].transactions[indexPath.row]
        
        // Toggle the settled status
        transaction.settled.toggle()
        repository.saveContext()
        // print("Transaction \(transaction.id) settled status is now \(transaction.settled)")
        
        if transaction.settled {
            selectedIndexPaths.insert(indexPath)
        } else {
            selectedIndexPaths.remove(indexPath)
        }
        
        // Reload the specific row to update the symbol
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        // Check if all transactions are settled
        let allSettled = sections.allSatisfy { section in
            section.transactions.allSatisfy { $0.settled }
        }
        
        if allSettled {
            // All transactions are settled, mark the trip as settled
            repository.markTripAsSettled(tripId: tripId)
            // print("All transactions settled. Trip \(tripId) marked as settled.")
        } else {
            repository.markTripAsNotSettled(tripId: tripId)
        }
    }
}
