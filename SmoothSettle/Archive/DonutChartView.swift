////
////  DonutChartView.swift
////  SmoothSettle
////
////  Created by Dajun Xian on 2024/12/2.
////
//
//import Foundation
//import SwiftUI
//import Charts
//
//// MARK: - Chart Data Model
//struct ChartData: Identifiable {
//    let id = UUID()
//    let name: String
//    let owes: Double
//    let percentage: Double // New property to store percentage
//}
//
//
//struct DonutChartView: View {
//    var data: [ChartData]
//    
//    var body: some View {
//        ZStack {
//            if data.isEmpty {
//                Text("No owes to display.")
//                    .foregroundColor(.gray)
//            } else {
//                PieChart(data: data)
//                    .overlay(
//                        Circle()
//                            .fill(Color.white)
//                            .frame(width: 100, height: 100)
//                    )
//            }
//        }
//    }
//}
//
//struct PieChart: View {
//    var data: [ChartData]
//    
//    var body: some View {
//        Chart {
//            ForEach(data) { entry in
//                PieMark(
//                    angle: .value("Percentage", entry.percentage)
//                    
//                )
//                .annotation(position: .overlay) {
//                    VStack {
//                        Text(entry.name)
//                            .font(.caption)
//                            .foregroundColor(.black)
//                        Text(String(format: "%.1f%%", entry.percentage))
//                            .font(.caption2)
//                            .foregroundColor(.black)
//                    }
//                }
//            }
//        }
//        .chartLegend(.hidden)
//        .frame(height: 300)
//    }
//    
//    // Determine color based on whether the person is owed or owes
//    func color(for owes: Double) -> Color {
//        owes >= 0 ? Color.green : Color.red
//    }
//}
