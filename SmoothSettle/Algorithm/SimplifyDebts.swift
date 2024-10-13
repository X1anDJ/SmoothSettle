//
//  SmoothSettleAlgorithmTests.swift
//  SmoothSettleAlgorithmTests
//
//  Created by 刘逸飞 on 2024/10/6.
//

// SimplifyDebts class
class SimplifyDebts {
    static let OFFSET: Int64 = 1000000000
    var visitedEdges: Set<Int64> = []
    var transactions: [EdgeKey: Int64] = [:]  // Stores transactions between people (indexed by EdgeKey)
    var personToIndex: [Person: Int] = [:]
    
    // Add a transaction between two people (from payer to involver)
    func addTransaction(from: Int, to: Int, amount: Int64) {
        let key = EdgeKey(from: from, to: to)
        transactions[key] = (transactions[key] ?? 0) + amount  // Accumulate if transaction already exists
    }
    
    // Process a list of bills and add transactions
    func processBills(bills: [Bill]) {
        for bill in bills {
            guard let involversSet = bill.involvers as? Set<Person>, let payer = bill.payer else {
                continue  // Skip this bill if involvers or payer are not properly set
            }
            
            // Convert bill amount to cents (Int64) to avoid floating-point issues
            let amountInCents = Int64(bill.amount * 100)
            let share = amountInCents / Int64(involversSet.count)  // Split the amount equally among involvers

            // Add transactions from the payer to each involver, excluding the payer
            for involver in involversSet {
                if involver != payer {
                    if let payerIndex = personToIndex[payer], let involverIndex = personToIndex[involver] {
                        addTransaction(from: payerIndex, to: involverIndex, amount: share)
                    }
                }
            }
        }
    }

    // Function to run the debt simplification algorithm
    func runSimplifyAlgorithm() -> String {
        let personCount = getUniquePeopleCount()  // Number of unique people involved in the transactions
        let solver = Dinics(n: personCount)
        
        // Simplify the transactions
        simplifyTransactions(solver: solver)
        
        // Return result for UI display
        return "Debts simplified successfully"
    }

    // Function to simplify transactions using Dinics algorithm
    private func simplifyTransactions(solver: Dinics) {
        // Calculate net balance for each person
        var netAmount = Array(repeating: Int64(0), count: solver.getPersonCount())
        for (key, amount) in transactions {
            netAmount[key.from] -= amount
            netAmount[key.to] += amount
        }
        
        // Clear old transactions to keep only simplified ones
        transactions.removeAll()
        
        // Pair creditors and debtors to simplify the transactions
        var creditors = [(Int, Int64)]()  // (person index, amount)
        var debtors = [(Int, Int64)]()    // (person index, amount)
        
        for (index, amount) in netAmount.enumerated() {
            if amount > 0 {
                creditors.append((index, amount))
            } else if amount < 0 {
                debtors.append((index, -amount))  // Store as positive amount
            }
        }
        
        print("\nSimplified transactions:")
        var i = 0, j = 0
        while i < creditors.count && j < debtors.count {
            let creditor = creditors[i]
            let debtor = debtors[j]
            
            let amount = min(creditor.1, debtor.1)
            
            print("\(solver.person[debtor.0]) pays \(amount) to \(solver.person[creditor.0])")
            
            // Add only the simplified transactions
            addTransaction(from: debtor.0, to: creditor.0, amount: amount)
            
            creditors[i].1 -= amount
            debtors[j].1 -= amount
            
            if creditors[i].1 == 0 { i += 1 }
            if debtors[j].1 == 0 { j += 1 }
        }
    }

    // Utility function to get the unique count of people involved in transactions
    private func getUniquePeopleCount() -> Int {
        let uniquePeople = Set(transactions.keys.flatMap { [$0.from, $0.to] })
        return uniquePeople.count
    }
}


// Define EdgeKey to uniquely identify a transaction
struct EdgeKey: Hashable {
    let from: Int
    let to: Int
}

// Dinics class skeleton for the flow network logic
class Dinics {
    class Edge: Hashable {
        let from: Int
        let to: Int
        var capacity: Int64
        var flow: Int64
        
        init(from: Int, to: Int, capacity: Int64, flow: Int64) {
            self.from = from
            self.to = to
            self.capacity = capacity
            self.flow = flow
        }
        
        // Implement Hashable protocol
        func hash(into hasher: inout Hasher) {
            hasher.combine(from)
            hasher.combine(to)
            hasher.combine(capacity)
            hasher.combine(flow)
        }
        
        // Implement Equatable protocol
        static func == (lhs: Edge, rhs: Edge) -> Bool {
            return lhs.from == rhs.from && lhs.to == rhs.to && lhs.capacity == rhs.capacity && lhs.flow == rhs.flow
        }
    }
    
    let personCount: Int
    let person: [String]  // Person array (optional for handling names)

    init(n: Int) {
        self.personCount = n
        self.person = Array(repeating: "Person", count: n)  // Just placeholders, should be filled with actual names
    }
    
    // Placeholder functions for Dinics algorithm
    func recompute() {
        // Recompute the flow based on Dinic's algorithm
    }
    
    func getEdges() -> [Edge] {
        // Return the current edges with flow and capacity
        return []
    }
    
    func getGraph() -> [[Edge]] {
        // Return the residual graph of edges
        return []
    }
    
    func setSource(s: Int) {
        // Set source node for the flow network
    }
    
    func setSink(t: Int) {
        // Set sink node for the flow network
    }
    
    func getPersonCount() -> Int {
        return personCount
    }
}
