//
//  Dinics.swift
//  SmoothSettle
//
//  Created by Dajun Xian on 2024/9/22.
//

import Foundation
class Dinics: NetworkFlowSolverBase {
    private var level: [Int]

    // Constructor for the Dinics algorithm solver
    override init(n: Int, vertexLabels: [String]) {
        self.level = [Int](repeating: -1, count: n)
        super.init(n: n, vertexLabels: vertexLabels)
    }

    // Solve the max flow problem using Dinic's algorithm
    override func solve() {
        var next = [Int](repeating: 0, count: n)

        while bfs() {
            next = [Int](repeating: 0, count: n)
            var f: Int64 = dfs(at: s, next: &next, flow: INF)
            while f != 0 {
                maxFlow = maxFlow &+ f
                f = dfs(at: s, next: &next, flow: INF)
            }
        }

        for i in 0..<n {
            if level[i] != -1 {
                minCut[i] = true
            }
        }
    }

    private func bfs() -> Bool {
        // Initialize the level graph
        level = [Int](repeating: -1, count: n)
        level[s] = 0  // Set the source level to 0

        print("Starting BFS from source \(s)")

        var queue: [Int] = [s]
        while !queue.isEmpty {
            let node = queue.removeFirst()
            print("Visiting node \(node)")

            for edge in graph[node] {
                let cap = edge.remainingCapacity()

                // Only add edges with remaining capacity to the level graph
                if cap > 0 && level[edge.to] == -1 {
                    level[edge.to] = level[node] + 1
                    queue.append(edge.to)
                    print("Edge from \(node) to \(edge.to) with remaining capacity \(cap)")
                }
            }
        }

        print("BFS complete, level graph constructed")
        return level[t] != -1  // Return true if the sink is reachable
    }



    private func dfs(at: Int, next: inout [Int], flow: Int64) -> Int64 {
        if at == t { return flow }
        let numEdges = graph[at].count

        while next[at] < numEdges {
            let edge = graph[at][next[at]]
            let cap = edge.remainingCapacity()

            if cap > 0 && level[edge.to] == level[at] + 1 {
                let bottleNeck = dfs(at: edge.to, next: &next, flow: min(flow, cap))
                if bottleNeck > 0 {
                    edge.augment(bottleNeck: bottleNeck)
                    return bottleNeck
                }
            }

            next[at] += 1
        }

        return 0
    }




}
