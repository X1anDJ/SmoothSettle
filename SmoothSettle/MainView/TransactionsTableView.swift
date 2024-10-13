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
        let fromName: String
        var transactions: [(toName: String, amount: Double)]
    }
    
    // Array to store grouped and sorted transactions
    var sections: [Section] = []
    
    // Reference to the TripRepository to get simplified transactions
    var tripRepository: TripRepository?
    
    var currentTrip: Trip? {
        didSet {
//            loadTransactions()
        }
    }

    // Initializer
    init() {
        super.init(frame: .zero, style: .grouped)
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
        guard let trip = currentTrip, let repository = tripRepository else { return }

        // Get the simplified transactions
        let transactions = repository.simplifyTransactions(for: trip)
        
        // Group and sort transactions by fromName
        let groupedTransactions = Dictionary(grouping: transactions, by: { $0.from })
        
        // Create sections from the grouped transactions and sort them by fromName
        self.sections = groupedTransactions.map { (fromName, transactions) in
            Section(fromName: fromName, transactions: transactions.map { (toName: $0.to, amount: $0.amount) }.sorted { $0.toName < $1.toName })
        }.sorted { $0.fromName < $1.fromName }

        // Debug: Print the loaded sections
//        print("Loaded transactions in sections:", sections)

        // Call the completion handler to pass the loaded transactions
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

        // Configure the cell with rounded corners where necessary
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == sections[indexPath.section].transactions.count - 1
        cell.configure(toName: transaction.toName, amount: transaction.amount, isFirst: isFirst, isLast: isLast)
        
        return cell
    }

    // UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.text = "\(sections[section].fromName) owes"
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
