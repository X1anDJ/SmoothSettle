import Foundation

struct SimpleEntry<K: Hashable, V: Hashable>: Hashable {
    let key: K
    let value: V
}

class SimplifyDebts {
    private static let OFFSET: Int64 = 1000000000
    private static var visitedEdges: Set<Int64> = []

    static func main() {
        createGraphForDebts()
    }

    private static func createGraphForDebts() {
        let person = ["A", "B", "C", "D"]
        let n = person.count
        var solver = Dinics(n: n, vertexLabels: person)

        var transactions: [SimpleEntry<Int, Int>: Int64] = [:]

        // Adding transactions between people
        addTransaction(transactions: &transactions, from: 0, to: 1, amount: 90)
        addTransaction(transactions: &transactions, from: 0, to: 3, amount: 20)
        addTransaction(transactions: &transactions, from: 1, to: 2, amount: 40)
        addTransaction(transactions: &transactions, from: 1, to: 3, amount: 20)
        addTransaction(transactions: &transactions, from: 1, to: 0, amount: 13)
        addTransaction(transactions: &transactions, from: 2, to: 1, amount: 50)
        addTransaction(transactions: &transactions, from: 2, to: 0, amount: 28)
        addTransaction(transactions: &transactions, from: 3, to: 2, amount: 40)
        addTransaction(transactions: &transactions, from: 3, to: 1, amount: 40)
        addTransaction(transactions: &transactions, from: 3, to: 0, amount: 13)

        simplifyTransactions(transactions: transactions, solver: &solver)

        print("\nSimplifying Debts...\n--------------------\n")

        visitedEdges = Set<Int64>()
        var edgePos: Int?

        while let pos = getNonVisitedEdge(edges: solver.getEdges()) {
            solver.recompute()
            let firstEdge = solver.getEdges()[pos]
            solver.setSource(firstEdge.from)
            solver.setSink(firstEdge.to)
            
            let maxFlow = solver.getMaxFlow()
            print("Max flow calculated: \(maxFlow)")
            
            visitedEdges.insert(getHashKeyForEdge(u: solver.getSource(), v: solver.getSink()))

            solver = Dinics(n: n, vertexLabels: person)
            solver.addEdge(from: solver.getSource(), to: solver.getSink(), capacity: maxFlow)
        }

        solver.printEdges()
        print()
    }

    private static func addTransaction(transactions: inout [SimpleEntry<Int, Int>: Int64], from: Int, to: Int, amount: Int64) {
        let key = SimpleEntry(key: from, value: to)
        transactions[key, default: 0] += amount
    }

    private static func simplifyTransactions(transactions: [SimpleEntry<Int, Int>: Int64], solver: inout Dinics) {
        var simplified = [SimpleEntry<Int, Int>: Int64]()

        for (key, debt) in transactions {
            let reverseKey = SimpleEntry(key: key.value, value: key.key)

            if let currentDebt = simplified[reverseKey] {
                if currentDebt > debt {
                    simplified[reverseKey] = currentDebt - debt
                } else if currentDebt < debt {
                    simplified[key] = debt - currentDebt
                    simplified[reverseKey] = nil
                } else {
                    simplified[reverseKey] = nil
                }
            } else {
                simplified[key] = debt
            }
        }

        // Add the remaining simplified transactions to the solver
        for (key, value) in simplified {
            solver.addEdge(from: key.key, to: key.value, capacity: value)
        }
    }

    private static func getNonVisitedEdge(edges: [Dinics.Edge]) -> Int? {
        for (index, edge) in edges.enumerated() {
            if !visitedEdges.contains(getHashKeyForEdge(u: edge.from, v: edge.to)) {
                return index
            }
        }
        return nil
    }

    private static func getHashKeyForEdge(u: Int, v: Int) -> Int64 {
        return Int64(u) * OFFSET + Int64(v)
    }
}
