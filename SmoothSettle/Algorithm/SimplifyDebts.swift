//
//  SmoothSettleAlgorithmTests.swift
//  SmoothSettleAlgorithmTests
//
//  Created by 刘逸飞 on 2024/10/6.
//


// SimplifyDebts class in Swift
class SimplifyDebts {
    static let OFFSET: Int64 = 1000000000
    var visitedEdges: Set<Int64> = []

    func createGraphForDebts() -> String {
        let person = ["A", "B", "C", "D"]
        let n = person.count
        let solver = Dinics(n: n, person: person)
        
        var transactions: [EdgeKey: Int64] = [:]
        addTransaction(&transactions, from: 0, to: 1, amount: 90)
        addTransaction(&transactions, from: 1, to: 2, amount: 90)
        addTransaction(&transactions, from: 2, to: 3, amount: 90)
        addTransaction(&transactions, from: 3, to: 0, amount: 100)
        
        simplifyTransactions(transactions: transactions, solver: solver)
        
        print("\nInitial Transactions:")
        for (key, amount) in transactions {
            print("\(person[key.from]) owes \(person[key.to]) an amount of \(amount)")
        }
        
        print("Simplifying Debts...")
        print("--------------------")
        
        visitedEdges = []
        
        while getNonVisitedEdge(edges: solver.getEdges()) != nil {
            solver.recompute()
            let firstEdge = solver.getEdges().first!  // 获取第一个边缘
            solver.setSource(s: firstEdge.from)
            solver.setSink(t: firstEdge.to)
            let residualGraph = solver.getGraph()
            var newEdges: [Dinics.Edge] = []
            
            for edges in residualGraph {
                for edge in edges {
                    let remainingFlow = (edge.flow < 0) ? edge.capacity : (edge.capacity - edge.flow)
                    if remainingFlow > 0 {
                        newEdges.append(edge)
                    }
                }
            }
        }
        
        // Return result for UI display
        return "Debts simplified successfully"
    }

    // Add transaction helper function
    func addTransaction(_ transactions: inout [EdgeKey: Int64], from: Int, to: Int, amount: Int64) {
        let key = EdgeKey(from: from, to: to)
        transactions[key] = amount
    }

    // Helper function to simplify transactions
    func simplifyTransactions(transactions: [EdgeKey: Int64], solver: Dinics) {
        var netAmount = Array(repeating: Int64(0), count: solver.person.count)
        
        // Calculate net balance for each person
        for (key, amount) in transactions {
            netAmount[key.from] -= amount
            netAmount[key.to] += amount
        }
        
        print("Initial debt amounts: ")
        for (i, amount) in netAmount.enumerated() {
            print("\(solver.person[i]): \(amount)")
        }
        
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
            
            creditors[i].1 -= amount
            debtors[j].1 -= amount
            
            if creditors[i].1 == 0 { i += 1 }
            if debtors[j].1 == 0 { j += 1 }
        }
    }

    // Get non-visited edge helper function
    func getNonVisitedEdge(edges: [Dinics.Edge]) -> Int? {
        for (index, edge) in edges.enumerated() {
            let edgeHash = Int64(edge.hashValue)
            if !visitedEdges.contains(edgeHash) {
                visitedEdges.insert(edgeHash)
                return index
            }
        }
        return nil
    }
}

// Define EdgeKey for transactions
struct EdgeKey: Hashable {
    let from: Int
    let to: Int
}

// Dinics class skeleton
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
        
        // 实现Hashable协议
        func hash(into hasher: inout Hasher) {
            hasher.combine(from)
            hasher.combine(to)
            hasher.combine(capacity)
            hasher.combine(flow)
        }
        
        // 实现Equatable协议
        static func == (lhs: Edge, rhs: Edge) -> Bool {
            return lhs.from == rhs.from && lhs.to == rhs.to && lhs.capacity == rhs.capacity && lhs.flow == rhs.flow
        }
    }
    
    let person: [String]
    
    init(n: Int, person: [String]) {
        self.person = person
        // Initialize the Dinics solver
    }
    
    func recompute() {
        // Recompute the flow
    }
    
    func getEdges() -> [Edge] {
        // Return all edges
        return []
    }
    
    func getGraph() -> [[Edge]] {
        // Return residual graph
        return []
    }
    
    func setSource(s: Int) {
        // Set source for the flow network
    }
    
    func setSink(t: Int) {
        // Set sink for the flow network
    }
}
