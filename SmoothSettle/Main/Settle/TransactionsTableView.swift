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
        let fromId: UUID    // Using UUID instead of fromName
        var transactions: [(toId: UUID, amount: Double)]  // Using UUID for toName
    }
    
    // Array to store grouped and sorted transactions
    var sections: [Section] = []
    
    // Reference to the TripRepository to get simplified transactions
    var tripRepository: TripRepository?
    
    var currentTrip: UUID? {
        didSet {
            // Uncomment when you want to trigger the load
            // loadTransactions()
        }
    }

    // Initializer
    init() {
        super.init(frame: .zero, style: .plain)
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

    // Load transactions from the repository, passing the loaded sections via the completion handler
    func loadTransactions(completion: @escaping ([Section]) -> Void) {
        guard let tripId = currentTrip, let repository = tripRepository else { return }

        // Get the simplified transactions based on UUIDs
        let transactions = repository.simplifyTransactions(for: tripId)

        // Fetch people involved in the trip for easy mapping of UUID to name
        let people = repository.fetchPeople(for: tripId)
        let uuidToName = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0.name ?? "Unknown") })

        // Group transactions by the payer's UUID (fromId)
        let groupedTransactions = Dictionary(grouping: transactions, by: { $0.fromId })
        
        // Create sections from the grouped transactions using UUIDs
        self.sections = groupedTransactions.map { (fromId, transactions) in
            // Map the transactions for each section using UUIDs
            let sortedTransactions = transactions.map { transaction -> (toId: UUID, amount: Double) in
                return (toId: transaction.toId, amount: transaction.amount)
            }.sorted { uuidToName[$0.toId] ?? "Unknown" < uuidToName[$1.toId] ?? "Unknown" }
            
            // Return a section object containing the payer's UUID and their transactions
            return Section(fromId: fromId, transactions: sortedTransactions)
        }

        // Call the completion handler to pass the loaded transactions (sections with UUIDs)
        completion(self.sections)

        // Reload the table view to display the new transactions
        self.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        let transaction = sections[indexPath.section].transactions[indexPath.row]

        // Fetch the toName using the UUID
        let toPerson = tripRepository?.fetchPerson(by: transaction.toId)
        let toName = toPerson?.name ?? "Unknown"

        // Configure the cell with rounded corners where necessary
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == sections[indexPath.section].transactions.count - 1
        cell.configure(toName: toName, amount: transaction.amount, isFirst: isFirst, isLast: isLast)
        
        return cell
    }

    // UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        // Fetch the fromName using the UUID
        let fromPerson = tripRepository?.fetchPerson(by: sections[section].fromId)
        let fromName = fromPerson?.name ?? "Unknown"
        
        let label = UILabel()
        label.text = "\(fromName) owes"
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
}
