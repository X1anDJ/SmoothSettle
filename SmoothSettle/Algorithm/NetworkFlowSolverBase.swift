//
//  NetworkFlowSolverBase.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/22.
//

import Foundation
class NetworkFlowSolverBase {
    // To avoid overflow, set infinity to a safe value
    let INF: Int64 = Int64.max / 4  // Reduced to avoid approaching Int64 bounds

    // Nested Edge class representing edges in the flow graph
    class Edge {
        let from: Int
        let to: Int
        var flow: Int64
        let capacity: Int64
        var residual: Edge?

        init(from: Int, to: Int, capacity: Int64) {
            self.from = from
            self.to = to
            self.capacity = capacity
            self.flow = 0
        }

        // Return remaining capacity of the edge
        func remainingCapacity() -> Int64 {
            return capacity - flow
        }

        // Augment the flow along the edge
        func augment(bottleNeck: Int64) {
            flow = flow &+ bottleNeck  // Use safe overflow handling
            residual?.flow = residual!.flow &- bottleNeck  // Use safe overflow handling
        }
    }

    var n: Int   // Number of nodes
    var s: Int   // Source node
    var t: Int   // Sink node
    var maxFlow: Int64   // Maximum flow
    var graph: [[Edge]]  // Graph represented as adjacency list
    var minCut: [Bool]   // Array to mark nodes in minimum cut
    var vertexLabels: [String]   // Labels for nodes

    // Initialize the flow solver with the number of nodes and their labels
    init(n: Int, vertexLabels: [String]) {
        self.n = n
        self.s = 0
        self.t = 0
        self.maxFlow = 0
        self.graph = [[Edge]](repeating: [], count: n)
        self.minCut = [Bool](repeating: false, count: n)
        self.vertexLabels = vertexLabels
    }

    // Add an edge between two nodes in the graph
    func addEdge(from: Int, to: Int, capacity: Int64) {
        let e1 = Edge(from: from, to: to, capacity: capacity)
        let e2 = Edge(from: to, to: from, capacity: 0)
        e1.residual = e2
        e2.residual = e1
        graph[from].append(e1)
        graph[to].append(e2)
    }

    // Add a list of edges to the flow graph
    func addEdges(newEdges: [Edge]) {
        for edge in newEdges {
            addEdge(from: edge.from, to: edge.to, capacity: edge.capacity)
        }
    }

    // Get the list of all edges in the graph
    func getEdges() -> [Edge] {
        return graph.flatMap { $0 }
    }

    // Get the residual graph
    func getGraph() -> [[Edge]] {
        return graph
    }

    // Set the source node for the flow network
    func setSource(_ s: Int) {
        self.s = s
    }

    // Set the sink node for the flow network
    func setSink(_ t: Int) {
        self.t = t
    }

    // Get the current source node
    func getSource() -> Int {
        return s
    }

    // Get the current sink node
    func getSink() -> Int {
        return t
    }

    // Get the maximum flow calculated
    func getMaxFlow() -> Int64 {
        solve()
        return maxFlow
    }

    // Force recomputation of the flow
    func recompute() {
        maxFlow = 0
        solve()
    }

    // Placeholder method to solve the flow network problem
    func solve() {
        // This method should be implemented by subclasses like Dinics
    }

    // Print all edges in the flow network
    func printEdges() {
        for edge in getEdges() {
            print("\(vertexLabels[edge.from]) ----\(edge.capacity)----> \(vertexLabels[edge.to])")
        }
    }
}
